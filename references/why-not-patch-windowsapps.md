# Why This Project Does Not Patch WindowsApps

This project intentionally avoids modifying Codex Desktop installation files or Windows protected app directories.

## WindowsApps is protected

`WindowsApps` is a protected installation location. Manual edits can require elevated permissions, can be blocked by Windows, and can leave applications in a difficult-to-repair state.

## MSIX and binary patching are high risk

Repacking MSIX packages, editing `app.asar`, or replacing binaries can introduce integrity, update, signing, and recovery problems. Those actions are outside the scope of a project-level guardrail.

## Official bugs should be fixed officially

If Codex Desktop has a product bug, the durable fix should come from the product owner. A local project should not need to patch installed application binaries to keep normal source work moving.

## Project-level guardrails are easier to reverse

An `AGENTS.md` rule block and helper scripts are easy to inspect, edit, and remove. They keep changes inside the target project and do not require administrator permissions.