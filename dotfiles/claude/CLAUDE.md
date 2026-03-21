## Worktlow Orchestration
### 1. PLan Node Default
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately - don't keep pushing
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity
### 2. Subagent Strategy
- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One tack per subagent for focused execution
## 3. Self-Improvement Loop
- After ANY correction from the user: update 'tasks/lessons.md*
with the pattern
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for relevant project
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


## Task Management
1. **Plan First**: Write plan to "tasks/todo.md" with checkable items
2. **Verify Plan**: Check in before starting implementation
3. **Track Progress**: Mark items complete as you go
4. **Explain Changes**: High-level summary at each step
5. **Document Results**: Add review section to 'tasks/todo.md"
6. **Capture Lessons**: Update 'tasks/lessons.md' after corrections
## Core Principles
- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimat Impact**: Changes should only touch what's necessary. Avoid introducing bugs.

