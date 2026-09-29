# Changelog

## [1.0.2+3] - 2026-09-29

### Fixed
- **Push reminders were effectively never sent.** The app schedules
  `next_notification_time` for when a plant is *predicted* to dry out or finish growing,
  but the worker re-checked the synced snapshot (`water < 20`, `stage === 5`), which was
  taken before that moment. The app now records `next_notification_kind` and the worker
  sends that reminder (older saves get a generic reminder).
- **The worker's cron trigger was commented out**, so it only ran when someone opened
  its URL — and that URL was public, letting anyone trigger pushes to every due user.
  The cron is enabled and the manual trigger now requires `POST /run` with a bearer
  token (`MANUAL_TRIGGER_TOKEN`); error details are no longer returned to callers.
- Saves that were due but needed no message stayed due and were re-read on every run.
- `flutter build`/`flutter test` failed on a fresh clone: `assets/images/frames/` is
  declared in `pubspec.yaml` but was not in the repository. The folder is now tracked,
  and missing per-location frame art renders nothing instead of an error box.
- The widget test pumped the app without a `ProviderScope` and always failed; replaced
  with a focused test of the window frame.
- Analyzer warnings: unused imports/variables and redundant null assertions.

### Changed
- Untracked `.wrangler/` and `.firebase/` caches (Cloudflare account details) and
  generator debug screenshots; they are git-ignored now.

### Added
- Suggested `firestore.rules`, worker setup docs, CI (analyze + test), this changelog.
