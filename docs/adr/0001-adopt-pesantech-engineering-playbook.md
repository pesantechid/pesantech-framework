# ADR 0001 — Adopt Pesantech Engineering Playbook v1.1

| Field    | Value |
|----------|-------|
| Status   | Accepted |
| Date     | 2026-05-09 |
| Deciders | @pesantechid/engineering |

## Context

Pesantech.id is building multiple Laravel-based products (agency tools, internal systems, SaaS candidates). Without a shared standard, each project reinvents auth, RBAC, CI/CD, module structure, and security configuration — costing weeks per project and creating inconsistency.

A playbook that codifies a single base + composable modules strategy is needed to:
- Ship new projects in <1 day instead of 1–2 weeks.
- Ensure security patches propagate cleanly across all projects.
- Treat every business capability as a reusable, versionable module.

## Decision

Adopt **Pesantech Engineering Playbook v1.1** (2026-05-07) as the internal engineering standard for all Pesantech.id products.

The playbook is stored at `docs/playbook.md` in this repository and will be distributed to all project repositories via the base template.

Key decisions codified by the playbook:
1. Base template (`pesantech-framework`) is immutable in projects — all customization lives in `Modules/`.
2. Upstream sync uses tags only (Tier 1), never branches.
3. PHPStan level 6+ enforced in CI.
4. All modules must have table prefix, PermissionSeeder, reversible migrations, and Pest tests.
5. AI agents (Claude Code, Cursor) must follow §16 task specification standard.

## Consequences

**Positive:**
- Consistent engineering standards across all projects.
- AI agents have explicit, testable constraints — fewer hallucinations and scope violations.
- Security patches and upstream improvements propagate predictably.

**Negative:**
- Some upfront investment required to bring existing repos into compliance.
- Developers must learn and follow the standard.

**Risks & mitigations:**
- Playbook may become stale: quarterly review cadence (next review: 2026-08-07) mitigates this.

## Alternatives considered

- **No playbook (ad-hoc):** Rejected — already experiencing duplication and inconsistency across projects.
- **Adopt a public standard (e.g. Spatie guidelines):** Rejected — does not cover Pesantech's specific multi-project module strategy and AI-assisted development workflow.

## References

- `docs/playbook.md` — full document
- https://adr.github.io — ADR pattern
