## Worktlow Orchestration
### 1. Plan Node Default
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately - don't keep pushing
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity
### 2. Subagent Strategy
- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One tack per subagent for focused execution
### 3. Self-Improvement Loop
- After ANY correction from the user: update 'tasks/lessons.md*
with the pattern
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for relevant project
- Never use sed incorrectly and corrupt files 
### 4. Verification Before Done
- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness
### 5. Demand Elegance (Balanced)
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes - don't over-engineer
- Challenge your own work before presenting it

### 6. Docker & Container Workflow
- When a project needs an isolated test environment, default to a `docker-compose.yml` + `docker/Dockerfile` + `docker/scripts/` layout
- Always prefer `network_mode: host` for our local dev/test containers unless explicitly told otherwise
- Never create custom Docker bridge networks for our workstation testing by default
- Host networking is required to avoid the DNS resolution and connectivity issues we repeatedly hit with normal Docker networking
- When using Compose build config, prefer:
  - `dockerfile: docker/Dockerfile`
  - `network: host`
- When using runtime config, prefer:
  - `network_mode: host`
- Keep docker-related helper scripts in `docker/scripts/` instead of scattering them around the repo
- Prefer Alpine Linux for smaller/faster containers whenever the workload supports it cleanly
- Use Arch Linux containers for Arch-native tools, package workflows, or when the runtime needs to match the host Arch environment
- Use `debian:slim` only when Alpine is not practical for the workload or dependency stack
- Container setups should stay simple, reproducible, and easy to tear down and rebuild
- If a tool fails under non-host networking, do not waste time troubleshooting bridge networking first - move to host networking
- For Zig projects in containers, include Valgrind-based memory leak auditing when applicable
- Docker test environments are for development and verification first, not production orchestration

### 6. Autonomous Bug Fizing
- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests - then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how
### Zig Projects 
- For zig projects, follow the same principles but also: 
- Use zig's built-in testing and formatting tools to maintain code quality
- Leverage zig's error handling patterns for robust code 
- Embrace zig's simplicity and performance focus in your solutions 
- When working on zig projects, priortize readability and maintainability while still delivering efficient code
- For zig projects, consider using zig's package manager for depedencies and modular code organization
- For zig projects, take advantage of zig's cross-compilation capabilities to test on multiple platforms easily 
- For zig projects, stay up to date with the latest zig features and best practicies to ensure your code is modern and efficient
- With zig projects, I'm always leveraging zig-0.16.0-dev and if you need to access std lib its at /opt/zig-0.16.0-dev 
- Leverage zig's modular build system for example, having feature flags to enable/disable functionality so you can minimize binary size when necessary. 
- Leverage zig version pinning via refs flag for a project when using depedencies to ensure consistent builds accross environments. 
- Never use local paths for zig depedencies unless specified. use zig fetch to pull in depedencies from remote sources to ensure reproducibility.
- For zig projects, consider using zig's built in formatter to maintain consistent code style accross code base. 

### Rust Projects 
- For rust projects, follow the same principles but also: 
- use rust's built-in testing framework to maintain code quality and ensure correctness 
- Leverage rust's powerful type system and ownership model to write safe and effecient code 
- Embrace rust's focus on performance and safety in your solutions 
- When working on rust projects, prioritize readability and maintainability while still delivering efficient code 
- For rust projects, consider using cargo for depedency management and project organization
- For rust projects, take advantage of rust's cross-compilation capabilities to test on multiple platforms easily 
- For rust projects, stay up to date with the latest rust features and best practicies to ensure your code is modern and efficient 
- All our rust projects currently leverage rust 2024. We do not use rust 2021. Rust 1.90+ is required for all our rust projects.
- For rust projects, consider using clippy for linting and code quality checks to maintain a clean codebase
- For rust projects, consider using rustfmt for consistent code and formatting across the codebase to improve readability and maintainability.
- For rust projects, leverage cargo's workspace feature to manage multiple related packages in a single repository, improving organization and dependency management
- For rust projects, consider using cargo's feature flags to enable or disable functionality in your codebase, allowing for more flexible and customizable builds.
- leverage rust's powerful macro system to reduce boilerplate code and improve code reuse, while still maintaining readability and maintainability in your rust projects.  

### Dev System
- Our dev system we test and build most our projects on are tailored around Arch Linux primarily, with secondary support for other linux distros. 
- We use a 9950x3d 64GB of DDR5 and a Nvidia RTX 5090 for our dev system.
- leverage proxmox for virtualization and we can easily spin up and test on different hardware proxmox systems are: 
- PVE 1 - Ryzen 5900X / 96GB DDR4 / RX570 
- PVE 2 - Ryzen 7950X3d/ 96GB DDR5 
- PVE 3 - Intel 14900k / 128GB DDR5 / RTX 4090 
- PVE 4 - Intel 12900KF / 128GB DDR5 / RTX 3070 
- PVE 5 - Dell XPS - intel i7 9th gen / 32GB / RTX 2060
- PVE 6 - Dell XPS intel i7 9th gen / 32GB / RTX 2060 
- PVE 7 - RYZEN EPYPC 4th gen 24 core / 128GB ECC / 4 TB nvme x2 in zfs raid config mirror - Which is a baremetal server with public exposure
- Also our Dev system has several VM's staged - Windows, etc. You have permitted permisions to do a reverse shell into these systems when specified to test on different Operating systems - Mainly Windows, popOS, fedora, and also arch.
- Arch Linux is our main system. 
- Proxmox Cluster is our main secondary testing environment outside of this host. 
- For local Docker and Docker Compose testing on this workstation, default to host networking
- Expected defaults for local container testing:
  - `dockerfile: docker/Dockerfile`
  - `network: host`
  - `network_mode: host`
- Test 1: verify the container can resolve DNS correctly under host networking
- Test 2: verify the app can reach all expected local services under host networking
- Do not assume custom Docker networks will work correctly on this workstation
- If a project needs Linux-environment testing and Alpine is sufficient, prefer Alpine first
- If the project is Arch-specific, use an Arch container instead of Alpine

## Task Management
1. **Plan First**: Write plan to "tasks/todo.md" with checkable items
2. **Verify Plan**: Check in before starting implementation
3. **Track Progress**: Mark items complete as you go
4. **Explain Changes**: High-level summary at each step
5. **Document Results**: Add review section to 'tasks/todo.md"
6. **Capture Lessons**: Update 'tasks/lessons.md' after corrections
7. Do Not fill codebase comments and docs/ section with version numbers all over the place. Clean organized docs are under docs/ and CHANGELOG.md in project root for versioning
8. When documenting we place documentation organized in docs/ directory in projects. 
9. DO Not be a marketing or sales documentation, accuracy and organization is key.

## Core Principles
- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimat Impact**: Changes should only touch what's necessary. Avoid introducing bugs.
- **Don't create terrible file naming conventions like file_v2 or v2 or v1 in the file names when it doesnt make sense. Stick to naming convention best practices
- ** Professional Documentation**: Clear, concise, and accurate documentation is a must. No marketing fluff. Accuracy matters. 
- ** Good Commenting Hygiene**: Comments should explain "why", not "what". Avoid redudant comments. Keep them up to date. Do not put static version numbers in code comments. 
- **Test Everything**: If it can be tested, it should be. Don't mark a task complete without proving it works.

