---
# Manual Mac Settings — Voice / Read-Aloud Reference

These are manually configured macOS voice options for having text read aloud.
None of these are managed by Ansible — they require one-time manual setup on the Mac.

---

## Quick Reference — Shortcuts

```
REQUIRES NO PRE-ACTION (just hit the key):
  Cmd+F5              Toggle VoiceOver on/off (reads focused UI element / entire screen)

REQUIRES TEXT SELECTED FIRST:
  Option+Esc          Speak Selection — reads only the selected text, then stops

REQUIRES TEXT COPIED TO CLIPBOARD FIRST (Cmd+C):
  Option+Shift+S      Speak Clipboard — Automator Quick Action, reads whatever is on clipboard
  Ctrl+Shift+X        Stop Speaking — Automator Quick Action, kills the say process
```

---

## Option 1 — Speak Selection

**Shortcut:** `Option+Esc`
**Pre-action required:** Select text first

Reads only the highlighted selection, then stops. No continuous narration.

**Setup location:** System Settings → Accessibility → Spoken Content → Speak Selection (enabled)

**Voice setting:** System Settings → Accessibility → Spoken Content → System Voice
- Siri Voice 2 or Siri Voice 4 recommended for natural output

**To stop mid-read:** Hit `Option+Esc` again.

---

## Option 2 — VoiceOver Toggle

**Shortcut:** `Cmd+F5`
**Pre-action required:** None — just hit the shortcut

Toggles VoiceOver on and off. When on, it narrates the currently focused UI element
and screen content as you navigate. Hit `Cmd+F5` again to turn it off.

Best used when you want to navigate and have the screen narrated, not for
reading a single block of text.

**Setup location:** Built into macOS — no setup required. `Cmd+F5` works immediately.

---

## Option 3 — Speak Clipboard (Automator Quick Action)

**Shortcut:** `Option+Shift+S` — speaks clipboard
**Shortcut:** `Ctrl+Shift+X` — stops speaking
**Pre-action required:** Copy the text you want read (`Cmd+C`), then hit the shortcut

Reads whatever text is currently on the clipboard using the macOS `say` command.
Useful for reading a full chat response: copy it, trigger the shortcut, walk away.

**Setup location:**
- Quick Action created in Automator (`~/Library/Services/Speak Clipboard.workflow`)
- Shortcut assigned in System Settings → Keyboard → Keyboard Shortcuts → Services → General

**Automator script content:**
```bash
say "$(pbpaste)"
```

**Stop action script content:**
```bash
killall say
```

---

## Notes

- All three options use the same system voice configured in Spoken Content settings.
- Option 3 is the only one that works without needing to be in front of the screen
  (copy, trigger, step away).
- If Option 3 shortcut does not work, check System Settings → Privacy & Security →
  Automation and confirm Automator has permission.
