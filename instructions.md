Repository Instructions — Reusable Structure
=========================================

Purpose
-------
This document summarizes the repository's reusable structure, build/packaging workflow, and common patterns so they can be referenced by automation, contributors, or a Copilot/agent instructions file.

Top-level overview
------------------
- `CMakeLists.txt`: primary build description; sets targets and architectures.
- `compile.sh`: helper to configure and build (CMake + make).
- `package.sh`: assembles the install root and builds a `.pkg` installer.
- `setup_frida.sh`: downloads Frida devkits and produces a fat `fridagum` library.
- `uninstaller.sh`: removes installed files and LaunchDaemon.
- Public headers: `ammonia.h`, `SandboxSPI.h`.
- Directories: `ammonia/`, `libinfect/`, `opener/` (core components).

Directory responsibilities (reusable components)
---------------------------------------------
- `ammonia/` — the main executable sources and entrypoint (`main.m`, `main.h`).
- `libinfect/` — injection/interposition library (Frida Gum wrappers, `envbuf.*`) used to inject/open processes and modify environment for spawned processes.
- `opener/` — generic tweak loader: enumerates `tweaks/`, applies whitelist/blacklist`, and `dlopen`s tweak dylibs.

Languages & platform
--------------------
- Objective‑C (`.m`) for high-level behavior and Cocoa/Foundation usage.
- C (`.c`) for low-level helpers and env buffer manipulation.
- C headers (`.h`) define public APIs.
- Shell scripts for build/packaging; CMake for cross-arch builds.
- Targets macOS; scripts produce universal binaries (`lipo`) for x86_64/arm64/arm64e.

Build & packaging patterns (reusable steps)
-----------------------------------------
1. Run `sh setup_frida.sh` to fetch Frida devkits and build `fridagum`.
2. Build with `sh compile.sh` (internally runs CMake and make).
3. Run `sh package.sh` to create installer package and `postinstall` actions.

Runtime/deployment layout
-------------------------
- Install root (packaging uses): `/private/var/ammonia/core/`
- Contents: `ammonia` (binary), `fridagum.dylib`, `libinfect.dylib`, `libopener.dylib`, `tweaks/` (dylibs + optional `.whitelist`/`.blacklist`).

Reusable code patterns
----------------------
- Tweak loader pattern: a loader scans `tweaks/`, honors `.whitelist`/`.blacklist`, and uses `dlopen` plus a known entry `LoadFunction` or Objective‑C `+load` to initialize the tweak.
- Injection pattern: `libinfect` intercepts `posix_spawn`/spawn-like APIs (via Frida Gum) to arrange injection of `libopener` into new processes.
- Constructor/init pattern: use `__attribute__((constructor))` or `+load` for early initialization.
- Frida integration: embed Frida Gum static library, expose a thin wrapper header for consistent usage across modules.

Conventions and suggestions for instructions
-------------------------------------------
- Document the required system preconditions (SIP disabled, elevated privileges for installer) near build instructions.
- Keep `setup_frida.sh` and `package.sh` steps explicit and ordered.
- Recommend that new tweaks provide one of: `+load`, a constructor, or a `void LoadFunction(void *)` export for compatibility with `opener`.
- For development, advise how to build a tweak as a universal dylib matching the project's archs and placement under `tweaks/`.

Ambiguities that may need clarification
--------------------------------------
- Scope: should these rules apply repository-wide, or be limited to only `ammonia` and `libinfect` components?
- Format preference: do you want this as an agent `instructions.md`, a README section, or a Copilot customization file?

Example prompts for an instructions-driven copilot/agent
-----------------------------------------------------
- "When editing `opener/opener.m`, preserve the whitelist semantics and add a unit test that verifies `dlopen` is only called for allowed dylibs."  
- "Create a new tweak dylib template that implements `LoadFunction(void *)` and includes build flags for arm64/arm64e." 

Next steps
----------
- I can convert this into a formal `.instructions.md` file following `agent-customization` templates, or expand any section with more detail. Tell me the preferred target file and format.
