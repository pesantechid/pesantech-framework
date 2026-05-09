## Summary

<!-- Describe what this PR does and why. Link to issue/ticket if applicable. -->

Closes #

---

## Checklist (Pesantech Engineering Playbook §8.3)

### General
- [ ] Linked issue/ticket referenced above
- [ ] Branch name follows convention (`feat/`, `fix/`, `chore/`, `refactor/`, `docs/`)
- [ ] Commit messages follow Conventional Commits format

### Code quality
- [ ] Tests added or updated for changes made
- [ ] `composer test` passes locally (Pint + PHPStan level 6 + Pest)
- [ ] No new PHPStan errors without baseline entry justification
- [ ] No new Rector suggestions left unaddressed

### Modules (if applicable)
- [ ] New table names prefixed with module slug (e.g. `crm_clients`)
- [ ] New migrations are reversible (`down()` implemented) — or marked `FORWARD-ONLY` per §6.7.5
- [ ] Permissions seeded via `{Module}PermissionSeeder` if new permissions added
- [ ] Module README updated if public API surface changed
- [ ] No direct cross-module calls (use events/hooks per §6.3.5)

### Security
- [ ] No secrets, tokens, or credentials committed
- [ ] No modifications to `app/`, `bootstrap/`, `config/`, `routes/` core files — or ADR linked if unavoidable
- [ ] CORS, auth, or session config changes reviewed

### Documentation
- [ ] CHANGELOG.md updated (Keep-a-Changelog format)
- [ ] ADR written if this PR introduces an architectural decision (§13.2)

---

## Testing Notes

<!-- How was this tested? What scenarios were covered? -->
