/**
 * Exit Alias Extension
 *
 * Registers /exit and /bye as aliases for pi's built-in /quit command.
 * The slash command search matches by name, so typing "exit" won't find "quit".
 * This extension makes all common exit terms work.
 *
 * Usage:
 * - /exit → exits pi
 * - /bye → exits pi
 * - /quit (built-in) → continues to work
 *
 * Installation:
 * Copy this file to ~/.pi/agent/extensions/ or .pi/extensions/
 * and run /reload to apply without restarting.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	const exitCommands = [
		{ name: "exit", description: "Exit pi (alias for /quit)" },
		{ name: "bye", description: "Exit pi (alias for /quit)" },
	];

	for (const { name, description } of exitCommands) {
		pi.registerCommand(name, {
			description,
			handler: async (_args, ctx) => {
				ctx.shutdown();
			},
		});
	}
}
