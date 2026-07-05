---
paths:
  - "**/*.py"
  - "**/pyproject.toml"
  - "**/requirements*.txt"
---

# Python conventions

- `uv` for envs + deps (`uv venv`, `uv add`, `uv run`); `pyproject.toml` is the single source — no `setup.py`, no bare `requirements.txt` for new work.
- Target a current CPython (3.12+). Never a deprecated interpreter.
- Before done: `ruff format` + `ruff check --fix`, and `mypy`/`pyright` where the repo is typed. Type-hint new code.
- Test with `pytest`; fixtures over setup/teardown; parametrize instead of loops.
- Never `eval`/`exec` untrusted input; no untrusted-data object deserializers or unsafe YAML loaders — use data-only formats.
- `subprocess` with an args list + `shell=False`; parameterized DB queries, never string-built SQL.
- Tokens/secrets from the `secrets` module (not `random`); fetch real credentials at runtime (see the `secrets` skill), never hardcode.
- Prefer stdlib + a lean dep set; pin via the lockfile (`uv.lock`). Audit with `pip-audit`; track unresolved advisories under `docs/advisories/`.
