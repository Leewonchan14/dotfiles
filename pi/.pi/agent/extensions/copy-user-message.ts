import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { spawnSync } from "node:child_process";

const MAX_PREVIEW = 100;

export default function (pi: ExtensionAPI) {
  pi.registerCommand("copy-msg", {
    description: "Search & pick a message from your history and copy it to clipboard",
    handler: async (_args, ctx) => {
      const entries = ctx.sessionManager.getBranch();

      // Collect user messages with preview
      const userMsgs = collectUserMessages(entries);
      if (userMsgs.length === 0) {
        ctx.ui.notify("No user messages found", "warning");
        return;
      }

      // Single message: copy directly
      if (userMsgs.length === 1) {
        return copyWithNotify(ctx, userMsgs[0].text);
      }

      // Ask for optional keyword to filter
      const keyword = await ctx.ui.input(
        `Search keyword (Enter to show all ${userMsgs.length} messages):`,
        ""
      );
      if (keyword === null) {
        ctx.ui.notify("Cancelled", "info");
        return;
      }

      // Filter by keyword (case-insensitive)
      const kw = keyword.trim().toLowerCase();
      const filtered = kw
        ? userMsgs.filter(
            (m) =>
              m.text.toLowerCase().includes(kw) ||
              m.preview.toLowerCase().includes(kw)
          )
        : userMsgs;

      if (filtered.length === 0) {
        ctx.ui.notify(`No messages matching "${keyword}"`, "warning");
        return;
      }

      if (filtered.length === 1) {
        return copyWithNotify(ctx, filtered[0].text);
      }

      // Show picker: most recent first, with #index for reference
      const reversed = [...filtered].reverse();
      const labels = reversed.map(
        (m) => `#${m.index}  ${m.preview.replace(/\s+/g, " ")}`
      );

      const choice = await ctx.ui.select(
        `Select a message to copy (${filtered.length} matches):`,
        labels
      );

      if (!choice) {
        ctx.ui.notify("Cancelled", "info");
        return;
      }

      const idx = labels.indexOf(choice);
      if (idx === -1) return;

      const selected = reversed[idx];
      copyWithNotify(ctx, selected.text);
    },
  });
}

function collectUserMessages(
  entries: any[]
): { index: number; text: string; preview: string }[] {
  const msgs: { index: number; text: string; preview: string }[] = [];
  for (const entry of entries) {
    if (entry.type !== "message" || entry.message.role !== "user") continue;
    const text = extractUserText(entry.message);
    if (!text.trim()) continue;
    const firstLine = text.split("\n")[0];
    const preview =
      firstLine.length > MAX_PREVIEW
        ? firstLine.slice(0, MAX_PREVIEW) + "…"
        : firstLine;
    msgs.push({
      index: msgs.length + 1,
      text,
      preview,
    });
  }
  return msgs;
}

function extractUserText(msg: any): string {
  if (typeof msg.content === "string") {
    return msg.content;
  }
  if (Array.isArray(msg.content)) {
    return msg.content
      .filter((c: any) => c.type === "text")
      .map((c: any) => c.text)
      .join("\n");
  }
  return "";
}

function copyWithNotify(ctx: any, text: string) {
  if (copyToClipboard(text)) {
    ctx.ui.notify("✅ Copied message to clipboard", "info");
  } else {
    ctx.ui.notify("❌ Failed to copy to clipboard", "error");
  }
}

function copyToClipboard(text: string): boolean {
  try {
    const platform = process.platform;
    if (platform === "darwin") {
      const r = spawnSync("pbcopy", [], { input: text });
      return r.error === undefined;
    } else if (platform === "win32") {
      const r = spawnSync("clip", [], { input: text });
      return r.error === undefined;
    } else {
      // Linux: try wl-copy (Wayland) then xclip (X11)
      const r1 = spawnSync("wl-copy", [], { input: text });
      if (r1.error) {
        const r2 = spawnSync("xclip", ["-selection", "clipboard"], {
          input: text,
        });
        return r2.error === undefined;
      }
      return true;
    }
  } catch {
    return false;
  }
}
