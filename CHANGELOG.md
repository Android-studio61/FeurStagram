# Changelog

All notable changes to FeurStagram should be documented in this file.

## Unreleased

### Added

- Added an **automatic update check**: on each launch FeurStagram asks GitHub
  for the latest release and, if the installed build is out of date, shows a
  dialog inviting the user to download the update. Enabled by default;
  toggleable from the new **Updates** section of the settings page. The toggle
  is never frozen by the permanent lock.
- Added a **Suggested accounts** toggle that blocks account/user
  recommendation endpoints (profile "Suggested for you", stories-tray injected
  accounts, search null-state recs, post-follow chaining, friend/business
  suggestions). Blocked by default.
- Improved documentation structure.
- Added security and contribution guidelines.
- Added dedicated installation, build-from-source, privacy, and FAQ pages.
- Added GitHub issue and pull request templates.

### Changed

- Improved README clarity and installation flow.
- Improved GitHub Pages links and trust messaging.

### Fixed

- Permanent lock no longer freezes a surface the instant its switch is
  flipped. The blocked-state is snapshotted when the settings page opens, so a
  surface toggled on by mistake during a session can be turned back off until
  Done restarts the app. Previously a stray tap (e.g. Stories) was locked in
  immediately and forced a reinstall.

## Previous releases

See GitHub Releases for APK downloads and version-specific changes.
