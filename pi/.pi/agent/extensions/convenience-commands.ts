/**
 * Convenience Commands Extension
 *
 * Provides handy aliases and shortcuts:
 * - /exit  → Exit pi (alias for /quit)
 * - /bye   → Exit pi (alias for /quit)
 * - /clear → Start a new empty session (same as /new)
 *
 * Usage:
 *   /exit          - Quit pi
 *   /bye           - Quit pi
 *   /clear         - Start a fresh session
 *
 * Installation:
 * Place in ~/.pi/agent/extensions/ for auto-discovery.
 * Run /reload to apply without restarting.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	// ── Session management ──────────────────────────────────────

	pi.registerCommand("clear", {
		description: "Start a new empty session (same as /new)",
		handler: async (_args, ctx) => {
			const currentSessionFile = ctx.sessionManager.getSessionFile();

			const result = await ctx.newSession({
				parentSession: currentSessionFile ?? undefined,
				withSession: async (replacementCtx) => {
					replacementCtx.ui.notify("New session started", "info");
				},
			});

			if (result.cancelled) {
				ctx.ui.notify("New session cancelled", "info");
			}
		},
	});

	// ── Exit aliases ────────────────────────────────────────────

	pi.registerCommand("exit", {
		description: "Exit pi (alias for /quit)",
		handler: async (_args, ctx) => {
			ctx.shutdown();
		},
	});

	pi.registerCommand("bye", {
		description: "Exit pi (alias for /quit)",
		handler: async (_args, ctx) => {
			ctx.shutdown();
		},
	});
}
