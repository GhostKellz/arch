# Playwright: which toolchain to use

Two installs exist for different jobs. Do not mix them within one repo.

## Python Playwright — cross-project / ad-hoc / the `webapp-testing` skill
- Shared venv: `~/.venvs/playwright/bin/python` (chromium installed).
- The `webapp-testing` skill is built around Python (its `scripts/with_server.py`
  and `examples/*.py`). Use this venv for one-off browser checks on any project,
  especially Python-stack repos (Django/Flask/FastAPI) or repos with no E2E setup.
- Run: `~/.venvs/playwright/bin/python your_script.py`

## Node Playwright — a repo's committed E2E suite
- If a repo already ships Playwright (e.g. Nexus: `@playwright/test` +
  `frontend/playwright.config.ts` + `e2e/`), use the repo's toolchain and match
  its conventions. Never add a parallel Python suite to a Node project.
- Run: `cd <repo>/frontend && node script.mjs` or `npx playwright test`.

## Rule of thumb
Python = your portable ad-hoc/skill tool. Node (or whatever the repo uses) =
that project's real E2E. Choose by what the repo already standardizes on.
