<p align="center">
  <img src="docs/images/icon.png" width="128" alt="TidyUp icon">
</p>

<h1 align="center">TidyUp</h1>

<p align="center">Fix typos in any app with one shortcut, using Apple Intelligence on your Mac.</p>

TidyUp is a macOS menu bar app that rewrites selected text with Apple's on-device [Foundation Models](https://developer.apple.com/documentation/foundationmodels) framework. Your text stays on your Mac. It needs no API key, backend, or network request.

## Features

- **One shortcut, any app.** Select text and press **Control + G**. You can change the shortcut in Settings.
- **Two modes:**
  - **Humanify** fixes typos, spelling, and grammar. It keeps your casual wording, slang, and lowercase style.
  - **Clean** fixes grammar, capitalization, and punctuation, and spells out texting shorthand.
- **Private by design.** Rewrites run on-device, and selected text is never logged.
- **Safe fallbacks.** If a rewrite changes your text too much, TidyUp keeps the original. Your clipboard is restored afterward. URLs, email addresses, file paths, and inline code are kept exactly as written.

## Download

Get the latest DMG from [Releases](https://github.com/SharoonRafeek/tidyup/releases/latest), open it, and drag TidyUp to Applications.

Releases aren't notarized by Apple yet, so macOS blocks the first launch with "Apple could not verify TidyUp". To open it:

1. Click **Done** on the warning.
2. Open **System Settings → Privacy & Security**, scroll down to the message about TidyUp, and click **Open Anyway**.

Or remove the quarantine flag in Terminal:

```bash
xattr -dr com.apple.quarantine /Applications/TidyUp.app
```

## Requirements

- macOS 26 or newer on an Apple Intelligence-compatible Mac (Apple silicon)
- Apple Intelligence turned on in System Settings, with the on-device model downloaded
- Xcode 26 or newer (Swift 6.2 or newer) to build

## Build and run

```bash
git clone https://github.com/SharoonRafeek/tidyup.git
cd tidyup
./scripts/build-app.sh
open build/TidyUp.app
```

This builds an ad-hoc signed `build/TidyUp.app` that includes the app icon. For quick iteration, `swift run` also works, but the app runs without its icon.

To package a DMG, run `./scripts/build-dmg.sh`. It writes `build/TidyUp-<version>.dmg`.

On first use, grant Accessibility permission under **System Settings → Privacy & Security → Accessibility**. Builds are ad-hoc signed, so after rebuilding you may need to remove TidyUp from that list and add it again.

## Set up Apple Intelligence

If the model isn't ready, the menu bar panel shows a setup guide instead of the mode picker:

1. Click **Open System Settings**, then go to **Apple Intelligence & Siri** (**Siri** on newer macOS versions). Turn on Apple Intelligence if you see a switch.
2. Keep your Mac on Wi-Fi and power, with free storage. macOS downloads and prepares the model automatically. You don't need to install a model file.
3. Keep the TidyUp panel open. It checks availability every five seconds and when you come back from System Settings. You can also click **Check Again**.

On unsupported Macs, the guide explains the device, language, and region requirements instead. See [Apple's setup guide](https://support.apple.com/en-us/121115) for the current requirements.

## How it works

1. Saves your clipboard, then copies the current selection with `Cmd+C`.
2. Rewrites the text in a new on-device `LanguageModelSession` using the instructions for the selected mode. Long text is split into chunks first.
3. Checks the result. Rewrites that add commentary, answer the text instead of fixing it, or change it too much are rejected.
4. Replaces the selection through macOS Accessibility. If that fails, it pastes with `Cmd+V`.
5. Restores your original clipboard.

Logs go to the terminal and to macOS unified logging (subsystem `com.sharoonrafeek.tidyup`). Selected text and rewrite output are never logged.

## Project structure

```
Sources/TidyUp/
├── App/          App entry point and app state (AppModel)
├── Models/       Fix modes and prompts, hotkeys, model availability
├── Rewriting/    Foundation Models rewriting, chunking, and output checks
├── System/       Accessibility, clipboard, global hotkey, key events, logging
└── Views/        Menu bar panel, settings, and setup UI
Tests/TidyUpTests/   Unit tests for the rewrite pipeline and hotkeys
Resources/            Info.plist and the app icon (Icon Composer format)
scripts/              App, DMG, and release version scripts
```

## Known limitations

- Some apps don't support synthetic copy and paste, or replacing text through Accessibility.
- Apple Intelligence supports a limited set of languages and has a limited context window. Very long selections, or text blocked by the model's guardrails, can fail. Errors appear in the menu bar panel.
- Keep the original app and selection focused while the rewrite runs.

## Releases

Merging a pull request into `production` runs `.github/workflows/release.yml`. It tests the code, builds the DMG, and publishes a GitHub Release tagged `v<version>`.

Each release bumps the patch number (`1.0.0` → `1.0.1`). For a minor or major release, raise `CFBundleShortVersionString` in `Resources/Info.plist` (for example to `1.1.0`) in the pull request, and that version is used.

## Contributing

Contributions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
