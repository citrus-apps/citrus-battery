**Download for your Mac** (macOS 13 or later):
[Apple Silicon](https://github.com/citrus-apps/citrus-battery/releases/download/v1.3.2/CitrusBattery-1.3.2-arm64-macOS13.0.zip) ·
[Intel](https://github.com/citrus-apps/citrus-battery/releases/download/v1.3.2/CitrusBattery-1.3.2-x86_64-macOS13.0.zip)

Already using Citrus Battery 1.1 or later? It offers this update itself. New
installs: the app isn't notarized, so allow it once in **System Settings → Privacy
& Security → Open Anyway**. See [INSTALL.md](https://github.com/citrus-apps/citrus-battery/blob/v1.3.2/docs/INSTALL.md).

## New

- **Leaf on the battery.** Low Power Mode can now show as a leaf drawn over the
  battery icon, as well as beside it (Settings → Menu Bar). While the percentage,
  a charging bolt or a plug is in the icon, the leaf moves beside the battery.

## Fixes

- A sleep could be recorded as losing no charge when the battery's first reading
  after waking was still the one from before the sleep.
- A brief connection problem no longer shows every iPhone and iPad as disconnected.
- Each iPhone and iPad updates as soon as it's read, instead of waiting for a slow
  Wi-Fi device.
- A window opened just after a hidden login launch no longer closes by itself.
- Settings now says when updates can't work, instead of showing them as working.
- The menu bar icon on Macs without macOS's own battery icon updates as soon as
  the charge crosses one of its steps.
- Less memory and energy use over long sessions: old sleep periods are let go,
  long sleep histories load faster, and background checks share wakeups with the
  rest of macOS.
