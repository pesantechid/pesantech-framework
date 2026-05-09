# ADR 0002 — Base Version Pinned: pesantech-framework v1.0.0 (laradashboard v1.1.3)

| Field    | Value |
|----------|-------|
| Status   | Accepted |
| Date     | 2026-05-09 |
| Deciders | @pesantechid/engineering |

## Context

Per Pesantech Engineering Playbook §4.4 and §5.5, every project must record the base template version it was bootstrapped from, including the upstream laradashboard version it tracks.

This ADR records the initial state of `pesantech-framework` as the Pesantech L1 base template.

## Decision

The Pesantech base template (`pesantech-framework`) is formally declared at:

- **Pesantech base version:** `v1.0.0+laradashboard-1.1.3`
- **Upstream laradashboard tag:** `v1.1.3` (verified via `git describe`: HEAD is 1 commit above `v1.1.3`)
- **Upstream remote:** `https://github.com/laradashboard/laradashboard.git`
- **PHP:** 8.3 / 8.4
- **Laravel:** 13.x
- **Livewire:** 4.x
- **nwidart/laravel-modules:** 13.x

### Sync strategy

Upstream sync follows **Tier 1 (tag-based)** per Playbook §4.3:
- Monthly cadence or on security advisory.
- MUST merge upstream tags, never `upstream/main`.
- Playbook §4.3.3 sync procedure MUST be followed.

### Version tagging convention

```
v{MAJOR}.{MINOR}.{PATCH}+laradashboard-{UPSTREAM_VERSION}
```

Next tag to be created after this compliance PR merges:
```
git tag -a v1.0.0+laradashboard-1.1.3 -m "Initial Pesantech base — synced from laradashboard v1.1.3"
```

## Consequences

**Positive:**
- Clear audit trail of which upstream version each project is based on.
- Security advisories can be mapped to exact CVE-affected version range.
- Rollback path is unambiguous.

**Negative:**
- Tagging discipline must be maintained on every sync — automated reminder needed (quarterly calendar item).

## Alternatives considered

- **Track upstream branch instead of tag:** Rejected — branches are mutable, non-reproducible. See Playbook §4.3.1.
- **No versioning on base:** Rejected — projects cannot know when to sync or what changed.

## References

- Playbook §4.3 — Upstream sync procedure
- Playbook §4.4 — Base versioning scheme
- Playbook §5.5 — Post-bootstrap day-1 checklist (ADR-0002 requirement)
