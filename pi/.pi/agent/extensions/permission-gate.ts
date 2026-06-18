/**
 * Permission Gate Extension
 *
 * Blocks dangerous bash commands (rm -rf, sudo, chmod 777) and requests AI
 * review before asking for user confirmation.
 *
 * For rm -rf specifically, target paths are classified:
 *   - system (/, /etc, /usr, ...) → dialog with AI review
 *   - config (~/.config, ~/.pi, ~/.dotfiles, ...) → dialog with AI review
 *   - safe (node_modules, dist, ~/clawd/, /tmp, ...) → auto-approved
 *
 * The dialog appears immediately with a loading indicator; the AI review
 * arrives asynchronously in the background. The user can choose Yes/No
 * at any time without waiting for the review.
 *
 * Patterns checked: rm -rf, sudo, chmod/chown 777
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import type { TUI, Component } from "@earendil-works/pi-tui";
import { truncateToWidth, wrapTextWithAnsi } from "@earendil-works/pi-tui";
import type { Theme } from "@earendil-works/pi-coding-agent";

// ── Types ──────────────────────────────────────────────────────────────────

type PathRisk = "system" | "config" | "safe";

// ── Path classification ────────────────────────────────────────────────────

/**
 * Absolute system-critical paths. Any rm -rf targeting these (or their
 * children) triggers the permission dialog.
 */
const SYSTEM_PREFIXES = [
	"/etc",
	"/usr",
	"/bin",
	"/sbin",
	"/var",
	"/System",
	"/Library",
	"/Applications",
	"/opt",
	"/dev",
	"/cores",
	"/home",
	"/private/etc",
	"/private/var",
];

/**
 * Home-relative config paths. rm -rf on these triggers the dialog.
 */
const CONFIG_RELATIVE_PREFIXES = [
	".config",
	".pi",
	".dotfiles",
	".ssh",
	".aws",
	".gnupg",
	".docker",
	".kube",
	".gitconfig",
];

const HOME_DIR = process.env.HOME || "/Users/twoone14";

function extractRmTargets(command: string): string[] {
	// Extract non-flag arguments after `rm`
	const tokens = command.trim().split(/\s+/);
	const args = tokens.slice(1).filter((t) => !t.startsWith("-"));
	return args.filter((a) => a.length > 0);
}

function classifyPath(path: string): PathRisk {
	const resolved = path
		.replace(/^~(?=$|\/)/, HOME_DIR)
		.replace(/^\$HOME(?=$|\/)/, HOME_DIR);

	// Root directory is always system-critical
	if (resolved === "/") return "system";
	if (resolved === HOME_DIR) return "system"; // rm -rf ~

	if (resolved.startsWith("/")) {
		// Check system prefixes
		for (const prefix of SYSTEM_PREFIXES) {
			if (resolved === prefix || resolved.startsWith(prefix + "/")) {
				return "system";
			}
		}

		// Check home-relative config paths
		if (resolved.startsWith(HOME_DIR + "/")) {
			const rel = resolved.slice(HOME_DIR.length + 1);
			for (const cp of CONFIG_RELATIVE_PREFIXES) {
				if (rel === cp || rel.startsWith(cp + "/")) {
					return "config";
				}
			}
		}

		// All other absolute paths (including home subdirs like
		// clawd, Desktop, /tmp, etc.) are safe
		return "safe";
	}

	// Relative paths are always safe (within project context)
	return "safe";
}

function isAllSafeRmTargets(command: string): boolean {
	const targets = extractRmTargets(command);
	if (targets.length === 0) return false; // no targets = unknown, show dialog
	return targets.every((t) => classifyPath(t) === "safe");
}

// ── Dangerous patterns ─────────────────────────────────────────────────────

interface DangerousPattern {
	pattern: RegExp;
	hint: string;
}

const dangerousPatterns: DangerousPattern[] = [
	{ pattern: /\brm\s+(-rf?|--recursive)/i, hint: "rm -rf (recursive forced deletion)" },
	{ pattern: /\bsudo\b/i, hint: "sudo (superuser privileges)" },
	{ pattern: /\b(chmod|chown)\b.*777/i, hint: "chmod/chown 777 (world-writable permissions)" },
];

// ── Extension entry point ──────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
	// Track which tool call IDs were approved by the user
	const approvedToolCallIds = new Set<string>();

	pi.on("tool_call", async (event, ctx) => {
		if (event.toolName !== "bash") return undefined;

		const command = event.input.command as string;

		// ── 1. sudo (always dangerous regardless of path) ──────────
		if (/\bsudo\b/i.test(command)) {
			return await promptOrBlock(
				event,
				ctx,
				command,
				dangerousPatterns[1],
				approvedToolCallIds,
			);
		}

		// ── 2. chmod/chown 777 (always dangerous) ──────────────────
		if (/\b(chmod|chown)\b.*777/i.test(command)) {
			return await promptOrBlock(
				event,
				ctx,
				command,
				dangerousPatterns[2],
				approvedToolCallIds,
			);
		}

		// ── 3. rm -rf with path classification ─────────────────────
		if (/\brm\s+(-rf?|--recursive)/i.test(command)) {
			// Auto-approve if all target paths are safe
			if (isAllSafeRmTargets(command)) {
				return undefined;
			}

			// System/config path → show dialog
			return await promptOrBlock(
				event,
				ctx,
				command,
				dangerousPatterns[0],
				approvedToolCallIds,
			);
		}

		return undefined;
	});

	pi.on("tool_result", async (event, _ctx) => {
		if (event.toolName !== "bash") return undefined;
		if (!approvedToolCallIds.has(event.toolCallId)) return undefined;

		approvedToolCallIds.delete(event.toolCallId);

		// Append AI review approval notice to the bash output
		return {
			content: [
				...event.content,
				{
					type: "text" as const,
					text: "\n\n✅ User approved execution after AI safety review.",
				},
			],
		};
	});
}

// ── Prompt or block helper ─────────────────────────────────────────────────

async function promptOrBlock(
	event: { toolCallId: string; input: { command: string }; toolName: string },
	ctx: ExtensionContext,
	command: string,
	matched: DangerousPattern,
	approvedToolCallIds: Set<string>,
): Promise<{ block: true; reason: string } | undefined> {
	if (!ctx.hasUI) {
		return {
			block: true,
			reason: `Dangerous command blocked: ${matched.hint} (no UI for confirmation)`,
		};
	}

	// Start AI review in background (dialog shows immediately)
	const reviewPromise = getAiReview(command, matched.hint, ctx);

	// Show interactive dialog with async review loading
	const choice = await showPermissionDialog(command, matched, reviewPromise, ctx);

	if (choice !== "Yes") {
		return {
			block: true,
			reason: `Dangerous command blocked: ${matched.hint} (denied by user after AI review)`,
		};
	}

	// Track this tool call for approval annotation in tool_result
	approvedToolCallIds.add(event.toolCallId);

	return undefined; // Allow execution
}

// ── Async dialog ───────────────────────────────────────────────────────────

async function showPermissionDialog(
	command: string,
	matched: DangerousPattern,
	reviewPromise: Promise<string | null>,
	ctx: ExtensionContext,
): Promise<string> {
	return ctx.ui.custom<string>((_tui: TUI, _theme: Theme, _keybindings: unknown, done: (result: string) => void) => {
		let reviewText = "🔄 AI 검토 중...";
		let selectedIndex = 1; // 0 = No, 1 = Yes
		let resolved = false;

		const component: Component = {
			render: (renderWidth: number) => {
				const w = renderWidth;
				const trunc = (text: string) => truncateToWidth(text, w, "", false);
				const lines: string[] = [];
				lines.push(trunc(`⚠️ Dangerous command: ${matched.hint}`));
				lines.push("");
				lines.push(trunc(`  ${command}`));
				lines.push("");
				lines.push(trunc("─── AI 안전 검토 ───"));
				// Wrap review text instead of truncating (preserves full content)
				if (reviewText.length > 0) {
					lines.push(...wrapTextWithAnsi(reviewText, w));
				}
				lines.push(trunc("──────────────────────"));
				lines.push("");
				lines.push(trunc("이 명령을 실행할까요?"));
				lines.push("");
				lines.push(trunc(selectedIndex === 1 ? "▸ Yes" : "  Yes"));
				lines.push(trunc(selectedIndex === 0 ? "▸ No" : "  No"));
				return lines;
			},

			handleInput(data: string) {
				if (data === "\x1b[A" || data === "\x1b[B") {
					selectedIndex = 1 - selectedIndex;
					return;
				}
				if (data === "\r" || data === "\n") {
					resolved = true;
					done(selectedIndex === 0 ? "No" : "Yes");
					return;
				}
				if (data === "\x1b" || data === "\x03") {
					resolved = true;
					done("No");
					return;
				}
			},

			invalidate() {
				// TUI calls this when it needs to re-render
			},
		};

		// Background: when review arrives, trigger re-render
		reviewPromise.then((review) => {
			if (resolved) return;
			reviewText = review ?? "(AI 검토 불가)";
			component.invalidate();
		});

		return component;
	});
}

// ── AI Review fetch ────────────────────────────────────────────────────────

async function getAiReview(
	command: string,
	hint: string,
	ctx: ExtensionContext,
): Promise<string | null> {
	const model = ctx.model;
	if (!model || !ctx.modelRegistry) return null;

	try {
		const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
		if (!auth.ok || !auth.apiKey) return null;

		const baseUrl = model.baseUrl?.replace(/\/+$/, "");
		if (!baseUrl) return null;

		const headers: Record<string, string> = {
			"Content-Type": "application/json",
			...auth.headers,
		};

		const userMessage = `Analyze the path in this shell command. Keep your response to 3 lines max. Write in Korean.

\`\`\`
${command}
\`\`\`

Pattern: ${hint}

Focus on the TARGET PATH: extract the path being operated on and assess:
1. Is it a system directory (/, /etc, /usr, /bin, /var, /opt, /home)?
2. Is it a known safe temp/test directory (/tmp, /private/tmp)?
3. Is it a project/node_modules directory?

Respond in exactly this format:
📁 <extracted target path>
✅/⚠️/🚫 <is this path safe to delete? why>
💡 <one-line safer alternative if needed>
`;

		let url: string;
		let body: object;

		if (model.api === "anthropic-messages") {
			if (!headers["x-api-key"]) {
				headers["x-api-key"] = auth.apiKey;
			}
			if (!headers["anthropic-version"]) {
				headers["anthropic-version"] = "2023-06-01";
			}
			url = `${baseUrl}/messages`;
			body = {
				model: model.id,
				max_tokens: 1024,
				thinking: { type: "disabled" },
				messages: [{ role: "user", content: userMessage }],
			};
		} else {
			if (!headers["Authorization"]) {
				headers["Authorization"] = `Bearer ${auth.apiKey}`;
			}
			url = `${baseUrl}/chat/completions`;
			body = {
				model: model.id,
				max_tokens: 1024,
				thinking: { type: "disabled" },
				messages: [{ role: "user", content: userMessage }],
			};
		}

		const response = await fetch(url, {
			method: "POST",
			headers,
			body: JSON.stringify(body),
			signal: ctx.signal,
		});

		if (!response.ok) return null;

		const data = (await response.json()) as Record<string, unknown>;

		if (model.api === "anthropic-messages") {
			const content = data.content as Array<{ text?: string }> | undefined;
			return content?.[0]?.text ?? null;
		}

		const choices = data.choices as Array<Record<string, unknown>> | undefined;
		if (choices && choices.length > 0) {
			const msg = choices[0].message as Record<string, unknown> | undefined;
			if (msg) {
				// Use content first (final answer)
				const text = typeof msg.content === "string" ? msg.content : null;
				if (text && text.length > 0) return text;

				// Fallback: reasoning_content tail
				const reasoning = msg.reasoning_content as string | undefined;
				if (reasoning) {
					const lines = reasoning.trim().split("\n");
					return lines.slice(-3).join("\n");
				}
			}
		}

		return null;
	} catch {
		return null;
	}
}
