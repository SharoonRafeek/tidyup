# Contributing

Thanks for helping improve TidyUp.

## Development

```bash
swift build
swift test
./scripts/build-app.sh && open build/TidyUp.app
./scripts/build-dmg.sh
```

You need macOS 26 or newer and Xcode 26 or newer. Rewrites only run on an Apple Intelligence-compatible Mac, but the build and unit tests work without the model.

## Branches

Open pull requests against `main`. Merging `main` into `production` through a pull request publishes a new release.

## Guidelines

- Keep pull requests focused on one change.
- Add or update tests in `Tests/TidyUpTests` when you change rewrite logic (chunking, validation, protected spans, case handling).
- If you change prompts in `FixMode`, describe the inputs you tested in the pull request.
- Never log selected text or rewrite output.
- Run `swift build` and `swift test` before opening a pull request.

## Reporting issues

Include your macOS version, Mac model, the app you were typing in, and the mode you used. Please don't paste private text. A short made-up sample that reproduces the problem is enough.
