# Pesantech Engineering Playbook
## Reusable Base + Multi-Project Module Strategy

| Field | Value |
|---|---|
| Document type | Engineering Playbook (Internal Standard) |
| Version | 1.1 |
| Status | Approved for execution |
| Owner | Pesantech.id Engineering |
| Audience | Developer team, AI implementation agents, future hires, contractors |
| Last reviewed | 2026-05-07 |
| Next review | Quarterly |
| Supersedes | v1.0 (2026-05-06) |
| Changelog from v1.0 | §4 rewritten (tag-based sync). New: §6.7 module versioning & migration. New: §6.8 deprecation policy. New: §11.4 secrets rotation. New: §11.8 email deliverability. New: §12.6 disaster recovery. New: §15 feature flags. New: §16 AI-assisted implementation. |

---

## Document Conventions

| Marker | Meaning |
|---|---|
| **MUST** / **MUST NOT** | Non-negotiable. Violation = blocker for merge. |
| **SHOULD** / **SHOULD NOT** | Strongly recommended. Deviations require ADR. |
| **MAY** | Optional. Use judgment. |
| **ADR** | Architecture Decision Record (see §13) |
| **PR** | Pull Request |
| **AI agent** | Coding agent (Claude Code, Cursor, etc.) implementing tasks given by maintainers |

This document is written to be **operationally precise** — readable both by humans and by AI agents executing tasks. Specifications use imperative, testable language. Examples are concrete.

---

## Table of Contents

1. [Strategic Intent](#1-strategic-intent)
2. [Reference Architecture](#2-reference-architecture)
3. [Repository Topology](#3-repository-topology)
4. [Base Repository Operating Model](#4-base-repository-operating-model)
5. [Project Bootstrap Procedure](#5-project-bootstrap-procedure)
6. [Module Engineering Standard](#6-module-engineering-standard)
7. [Module Sharing & Distribution](#7-module-sharing--distribution)
8. [Branching, Tagging & Release Engineering](#8-branching-tagging--release-engineering)
9. [Quality Gates & CI/CD](#9-quality-gates--cicd)
10. [Performance Engineering](#10-performance-engineering)
11. [Security Baseline](#11-security-baseline)
12. [Observability, Operations & Disaster Recovery](#12-observability-operations--disaster-recovery)
13. [Architecture Decision Records (ADR)](#13-architecture-decision-records-adr)
14. [Glossary & Appendices](#14-glossary--appendices)
15. [Feature Flags & Progressive Delivery](#15-feature-flags--progressive-delivery)
16. [AI-Assisted Implementation Standards](#16-ai-assisted-implementation-standards)

---

## 1. Strategic Intent

### 1.1 Why this playbook exists

Pesantech.id delivers Laravel-based products: agency tools, internal systems, eventually SaaS. Without standardization, each project re-invents auth, RBAC, settings, media library, email, audit log, CI/CD — costing weeks per project.

This playbook codifies a **single base + composable modules** strategy that:

- Ships a battle-tested foundation in <1 day instead of 1–2 weeks per project.
- Keeps the base **immutable** in projects so security patches propagate cleanly.
- Treats every business capability as a **module** that can be reused, shared, sold.
- Enables eventual graduation to **commercial/SaaS** without re-architecture.

### 1.2 Non-negotiable principles (the "constitution")

1. **Base is immutable in projects.** Projects **MUST NOT** modify `app/`, `bootstrap/`, `config/` (except files they add), `routes/` core files, or `database/migrations/` core files of the base. All customization lives in `Modules/*`.
2. **One change, one module.** A new business capability is a new module. **MUST NOT** sprawl across the base.
3. **Versioned, never copied.** Once a module is reused across ≥2 projects, it **MUST** be extracted to a versioned package.
4. **Reproducible builds.** Any project **MUST** be reproducible from a clean `git clone` + `composer install` + documented commands. Pinned versions, not "latest."
5. **Quality gates pass before merge.** Lint + static analysis + tests **MUST** be green. No exceptions.
6. **Document the why, not the what.** ADRs capture decisions. Code comments explain rationale, not mechanics.
7. **Track upstream releases, not branches.** Production-bound code **MUST** track upstream tags. Branch tracking is reserved for experimentation. (See §4 for full rationale and procedure.)

These seven points are the constitution. Every other rule derives from them.

### 1.3 Out of scope for this playbook

- Product-specific requirements → individual product PRDs.
- Hiring & team management.
- Sales/commercial strategy for productized modules.

---

## 2. Reference Architecture

### 2.1 Layered model

```
┌─────────────────────────────────────────────────────────────┐
│ L0 — Upstream                                               │
│   laradashboard/laradashboard (open source, MIT)            │
│   PHP 8.3+, Laravel 13, Livewire 4, Tailwind 4, Modules 13  │
│   We track tags. We do not modify.                          │
└──────────────────────────┬──────────────────────────────────┘
                           │ controlled, audited tag sync
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ L1 — Base Template (Pesantech)                              │
│   pesantechid/pesantech-framework                           │
│   Configured as GitHub Template Repository.                 │
│   Hardening: CI templates, Docker, security defaults,       │
│   org-mandated tooling. Tagged releases.                    │
└──────────────────────────┬──────────────────────────────────┘
                           │ "Use this template" → fresh repo
       ┌───────────────────┼───────────────────┐
       ▼                   ▼                   ▼
┌────────────┐      ┌────────────┐      ┌────────────┐
│ L2a Project│      │ L2b Project│      │ L2c Project│
│  Kendali   │      │   ...      │      │   ...      │
│ Modules/   │      │ Modules/   │      │ Modules/   │
└─────┬──────┘      └─────┬──────┘      └─────┬──────┘
      └─────────┬─────────┴─────────┬─────────┘
                ▼                   ▼
       ┌─────────────────┐  ┌─────────────────┐
       │ L3 Module Pkgs  │  │ L4 Infra        │
       │ (Composer VCS / │  │ (Docker, K8s,   │
       │  Private Pkgist)│  │  CI templates,  │
       │                 │  │  IaC)           │
       └─────────────────┘  └─────────────────┘
```

### 2.2 Layer responsibilities

| Layer | Repo example | Mutable by us? | Purpose |
|---|---|---|---|
| L0 Upstream | `laradashboard/laradashboard` | No (read only) | Source of truth for foundation |
| L1 Base Template | `pesantechid/pesantech-framework` | Yes, conservatively | Pesantech-hardened starting point |
| L2 Project | `pesantechid/kendali`, etc. | Yes, freely | Real product code |
| L3 Module Packages | `pesantechid/module-*` | Yes, semver-controlled | Reusable business capabilities |
| L4 Infra | `pesantechid/infra-tooling` | Yes | Deployment, CI, IaC, runtime configs |

### 2.3 Data flow rules

- **L0 → L1 sync:** scheduled, **tag-based only**, reviewed (see §4.3).
- **L1 → L2 instantiation:** once per project, via "Use this template".
- **L1 → L2 sync (post-instantiation):** on-demand, when L1 receives security patch or significant base improvement; tag-based.
- **L2 ↔ L3:** standard Composer dependency; SemVer enforced (see §7.4).
- **L4 → L1, L2:** distributed via reusable GitHub Actions workflows + shared Docker base images.

---

## 3. Repository Topology

### 3.1 Naming conventions

| Repo type | Naming | Example |
|---|---|---|
| Base template | `pesantechid/pesantech-framework` | (current) |
| Product (project) | `pesantechid/{product}` | `pesantechid/kendali` |
| Shared module package | `pesantechid/module-{name}` | `pesantechid/module-vault` |
| Infra tooling | `pesantechid/infra-{purpose}` | `pesantechid/infra-tooling` |
| Documentation site | `pesantechid/{product}-docs` | `pesantechid/kendali-docs` |

### 3.2 Visibility & access

| Repo type | Default visibility | Rationale |
|---|---|---|
| Base template | Public OR Private | Optional public allows community contribution back |
| Product | **Private** | Business logic, client-specific data |
| Module package | Private (default) | Until explicitly productized |
| Infra | Private | Contains deploy secrets templates |

Branch protection rules **MUST** be enabled on `main` for all repos.

### 3.3 Repo metadata requirements

Every repo **MUST** contain:

- `README.md` — purpose, setup, run commands, links to docs.
- `LICENSE` — explicit license (MIT for open, Proprietary for private).
- `CHANGELOG.md` — Keep-a-Changelog format.
- `CODEOWNERS` — for PR review routing.
- `.github/PULL_REQUEST_TEMPLATE.md` — checklist enforcing this playbook.
- `.github/dependabot.yml` — automated dependency updates.
- `SECURITY.md` — vulnerability disclosure process.
- `docs/adr/` — Architecture Decision Records.

---

## 4. Base Repository Operating Model

### 4.1 Setup as GitHub Template (one-time)

```
Settings → General → "Template repository" → ☑ enable
```

Consumable via:

```bash
gh repo create pesantechid/PROJECT_NAME \
  --template pesantechid/pesantech-framework \
  --private \
  --description "..."
```

### 4.2 Upstream remote configuration (one-time)

```bash
cd pesantech-framework
git remote add upstream https://github.com/laradashboard/laradashboard.git
git fetch upstream --tags
git remote -v   # verify
```

### 4.3 Upstream sync procedure (tag-based, MANDATORY)

**This section was rewritten in v1.1 to enforce tag-based sync.** Production code **MUST NOT** track upstream `main`. Rationale and tier model below.

#### 4.3.1 Why tags, not branches

Upstream Lara Dashboard uses release-branch workflow: features land in `feat/*` branches → tested in `release/v*.*.*` branches → merged to `main` → tagged. Their `main` is updated **only when a release is cut**. This means:

- Tags = explicit declaration "this is ready" by maintainers.
- Tags = reproducible (a tag is immutable; a branch HEAD changes).
- Tags = audit-trail for security advisories ("CVE affects ≤v1.1.2 → upgrade to v1.1.3").
- Tags = clean rollback path.

#### 4.3.2 Three-tier sync strategy

| Tier | Source | When to use | Production-allowed? |
|---|---|---|---|
| **1 — Tag** (default) | `upstream/v1.X.Y` tag | All routine syncs | ✅ Yes |
| **2 — Release branch** | `upstream/release/v1.X.0` branch | Critical fix merged but not yet tagged; pre-validation of upcoming tag in staging | ⚠️ Staging only, with ADR |
| **3 — Main branch** | `upstream/main` | Experimentation, contributing back, exploratory dev | ❌ Never |

#### 4.3.3 Standard sync procedure (Tier 1)

**Frequency:** monthly OR on security advisory.

```bash
# 1. Start clean
git checkout main && git pull
git checkout -b chore/upstream-sync-$(date +%Y%m%d)

# 2. Fetch upstream tags
git fetch upstream --tags

# 3. Identify target tag (review CHANGELOG before deciding)
git tag -l 'upstream-*' | tail -5   # see what we already merged
git tag -l 'v*' --sort=-v:refname --merged upstream/main | head -5
# Pick the latest stable tag, e.g. v1.1.3

# 4. Review what changed (MANDATORY — do not skip)
TARGET=v1.1.3
PREV=$(git describe --tags --abbrev=0 HEAD)
git log --oneline ${PREV}..${TARGET}
git diff ${PREV}..${TARGET} --stat

# 5. Merge the tag (not the branch)
git merge ${TARGET} --no-ff -m "chore(upstream): sync to laradashboard ${TARGET}"

# 6. Resolve conflicts (should be minimal — see §4.5)
# 7. Run quality gates LOCALLY before push
composer install && composer test

# 8. Push and open PR
git push origin chore/upstream-sync-$(date +%Y%m%d)
gh pr create --title "chore(upstream): sync to laradashboard ${TARGET}" \
  --body "Synced from upstream tag: ${TARGET}
  
  Upstream changelog excerpts:
  [paste relevant items from upstream CHANGELOG.md]
  
  Files changed: $(git diff --name-only ${PREV}..HEAD | wc -l)
  Tests: green locally"

# 9. After PR merge, tag the base
git checkout main && git pull
git tag -a v1.0.1+laradashboard-1.1.3 -m "Sync with upstream v1.1.3"
git push origin --tags
```

#### 4.3.4 Emergency sync procedure (Tier 2 — release branch)

**Use only when:** an upstream fix exists in `release/v*.*.*` but no tag has been cut, AND the fix is critical (security advisory or production bug).

**MUST** include an ADR justifying the deviation. Template:

```
ADR — Tier 2 sync deviation
Date: YYYY-MM-DD
Reason: CVE-XXXX-YYYY in laradashboard <v1.1.4
Source: upstream/release/v1.1.4 branch at commit abc1234
Target audience: staging only; production sync awaits official tag
Plan: re-sync to v1.1.4 tag when published (within 7 days expected)
```

Procedure:

```bash
git fetch upstream
COMMIT=abc1234   # specific commit, not branch HEAD
git merge ${COMMIT} --no-ff -m "chore(upstream): emergency sync to commit ${COMMIT}"
# Tag with explicit deviation marker
git tag -a v1.0.1+laradashboard-pre1.1.4-emergency -m "Emergency sync; replace with v1.1.4 tag when available"
```

After upstream cuts the tag, **MUST** re-sync to the tag and remove the emergency tag.

#### 4.3.5 Forbidden practices

- ❌ `git merge upstream/main` — bans Tier 3 in production code paths.
- ❌ Cherry-picking individual commits from upstream into base. Use tags or, if absolutely necessary, an ADR + emergency procedure.
- ❌ Skipping CHANGELOG review.
- ❌ Skipping local test run before push.

#### 4.3.6 What happens if upstream goes dormant

Upstream Lara Dashboard could pause development, pivot, or delete the repo. Mitigations:

- Pesantech base repo contains a **complete copy** of the upstream code at every synced tag — Anda tidak bergantung pada upstream availability.
- If upstream dormant >6 months, document this in an ADR and decide: (a) self-maintain the base (effectively forking permanently), (b) migrate to alternative upstream, or (c) freeze base version.

### 4.4 Base versioning scheme

L1 base versions follow SemVer with build metadata pointing to upstream:

```
v{MAJOR}.{MINOR}.{PATCH}+laradashboard-{UPSTREAM_VERSION}
```

Examples:
- `v1.0.0+laradashboard-1.1.3` — first stable Pesantech base, synced from upstream v1.1.3
- `v1.1.0+laradashboard-1.2.0` — minor base improvements + upstream sync

**MAJOR** bump when: breaking changes to org-mandated tooling, MUST/SHOULD policies that affect existing projects.
**MINOR** bump when: new tooling added, upstream sync, additive policy changes.
**PATCH** bump when: bug fixes in CI templates, Docker, or org configs.

### 4.5 What L1 base **MAY** add

- `Dockerfile.production` (FrankenPHP-based)
- `docker-compose.dev.yml`
- `.github/workflows/*` (reusable workflow templates)
- `.github/CODEOWNERS`
- `.editorconfig` overrides
- Pesantech-mandated quality config (e.g., stricter `phpstan.neon` ruleset)
- `docs/adr/` folder with org-wide ADRs
- Custom `.env.example` defaults aligned to Pesantech standards
- This playbook itself, at `docs/playbook.md`

### 4.6 What L1 base **MUST NOT** add

- Business logic of any specific product.
- Branding of any product (logos, names beyond "Pesantech Framework").
- Hardcoded credentials, even fake ones beyond what upstream ships.
- Third-party integration tokens.
- Modifications to `app/`, `bootstrap/`, `config/` (core upstream files) beyond what's strictly required for org tooling integration.

### 4.7 Base hardening checklist (one-time)

Apply to base before announcing it as production-ready:

- [ ] `.env.example` contains `TELESCOPE_ENABLED=false`, `PULSE_ENABLED=false` for production safety.
- [ ] `config/telescope.php` and `config/pulse.php` confirmed env-conditional.
- [ ] `Dockerfile.production` based on `dunglas/frankenphp` with hardened entrypoint.
- [ ] CI workflow runs Pint, PHPStan (level 6+), Pest, Rector dry-run.
- [ ] Dependabot configured for `composer` and `npm`.
- [ ] Pre-commit hook (Husky) enforces commit convention (already present in upstream).
- [ ] `docker-compose.dev.yml` with mysql, redis, mailpit, minio.
- [ ] `SECURITY.md` with disclosure email.
- [ ] `CONTRIBUTING.md` linking to this playbook.
- [ ] First sync from upstream tag completed.
- [ ] Base tagged `v1.0.0+laradashboard-{X.Y.Z}`.

---

## 5. Project Bootstrap Procedure

### 5.1 Pre-flight checklist (project-level)

Before bootstrap, the project lead **MUST** confirm:

- [ ] Project name approved (legal, trademark cleared if going commercial).
- [ ] Domain(s) registered.
- [ ] Repo naming follows §3.1.
- [ ] Initial PRD or scope document exists.
- [ ] Hosting/deploy target identified (VPS/K8s/etc.).
- [ ] Database technology chosen (MySQL is default; deviation requires ADR).
- [ ] Base version pinned (e.g., "this project starts from `pesantech-framework@v1.0.0`").

### 5.2 Bootstrap commands

```bash
# 1. Create from template
gh repo create pesantechid/PROJECT \
  --template pesantechid/pesantech-framework \
  --private \
  --description "PROJECT_DESCRIPTION"

# 2. Clone
git clone git@github.com:pesantechid/PROJECT.git
cd PROJECT

# 3. Add base remote for future syncs (tag-based, per §5.6)
git remote add base https://github.com/pesantechid/pesantech-framework.git
git fetch base --tags

# 4. Verify base version (record in ADR-0002)
git describe --tags --contains $(git rev-parse HEAD) || \
  echo "Note: template-instantiated repos lose tag context. Base version was: [check template at time of bootstrap]"

# 5. Configure environment
cp .env.example .env
# Edit .env

# 6. Install dependencies
composer install
npm install

# 7. Application key
php artisan key:generate

# 8. Database
php artisan migrate:fresh --seed
php artisan module:seed

# 9. Verify
composer test
composer dev
```

### 5.3 Project identity customization

The following **MUST** be updated:

| File | Change |
|---|---|
| `.env`, `.env.example` | `APP_NAME`, `APP_URL`, defaults |
| `composer.json` | `name`, `description` |
| `package.json` | `name`, `version` (start `0.1.0`) |
| `README.md` | Project README replacing template README |
| `public/favicon.ico`, `public/logo.svg` | Branded assets |

**Visual branding (logo, colors, site name displayed in UI) MUST go through the Settings panel** in the running application. Editing Blade templates for branding is forbidden — it creates conflicts on base sync.

### 5.4 First commit conventions

```bash
git add -A
git commit -m "chore: bootstrap from pesantech-framework template

Project: PROJECT_NAME
Template: pesantech-framework@vX.Y.Z+laradashboard-A.B.C
Domain: PROJECT.example.com
"
git tag -a v0.0.1 -m "Initial bootstrap"
git push origin main --tags
```

### 5.5 Post-bootstrap day-1 checklist

- [ ] CI pipeline runs and passes on first push.
- [ ] Branch protection on `main` enabled (require PR + 1 review + green CI).
- [ ] Secrets configured in GitHub Actions (see §11.3).
- [ ] Staging environment provisioned and reachable.
- [ ] First module scaffolded as smoke test (e.g., `php artisan module:make Smoke`).
- [ ] First ADRs written:
  - ADR-0001 — Adopt Pesantech Engineering Playbook v1.1
  - ADR-0002 — Base version pinned (record `pesantech-framework@vX.Y.Z`)
  - ADR-0003 — Database technology chosen
  - ADR-0004 — Initial runtime (PHP-FPM vs Octane)
  - ADR-0005 — Multi-tenancy strategy
  - ADR-0006 — Module taxonomy for this project
  - ADR-0007 — Upstream sync strategy (per §4.3)

### 5.6 Project sync from base (post-instantiation)

Once a project is instantiated, future base updates flow via the `base` remote:

```bash
cd PROJECT
git fetch base --tags
git checkout -b chore/sync-base-vX.Y.Z

# Pick target tag from base
TARGET=v1.1.0+laradashboard-1.2.0
git merge ${TARGET} --no-ff
# Resolve conflicts (should be minimal if §1.2 principle 1 is honored)

composer install && composer test
git push origin chore/sync-base-vX.Y.Z
gh pr create --title "chore(base): sync to ${TARGET}"
```

**Frequency:** monthly OR on security advisory from base.

---

## 6. Module Engineering Standard

### 6.1 Module taxonomy

| Category | Definition | Example | Reuse expectation |
|---|---|---|---|
| **Core extension** | Adds to base capabilities | `Modules/AuditPlus` | High — extraction candidate |
| **Domain (business)** | Implements business capability | `Modules/Crm` | Medium — extract when proven |
| **Integration** | Wraps third-party API | `Modules/IntegrationsCloudflare` | Per-vendor reuse |
| **Project-specific** | Logic only for one product | `Modules/KendaliReports` | None — never extract |

Naming **MUST** reflect category:
- Domain: single noun, StudlyCase: `Crm`, `Billing`, `Reports`
- Integration: `Integrations{Vendor}`: `IntegrationsCloudflare`
- Project-specific: `{ProjectAcronym}{Capability}`: `KendaliReports`

### 6.2 Module structure (mandatory)

```
modules/{ModuleName}/
├── Config/
│   └── config.php
├── Console/Commands/
├── Database/
│   ├── factories/
│   ├── migrations/
│   └── seeders/
│       ├── {Module}DatabaseSeeder.php   # MUST exist
│       └── {Module}PermissionSeeder.php # MUST exist
├── Entities/                            # Models
├── Http/
│   ├── Controllers/
│   ├── Middleware/
│   ├── Requests/
│   └── Resources/
├── Livewire/
├── Providers/
│   ├── {Module}ServiceProvider.php
│   ├── EventServiceProvider.php
│   └── RouteServiceProvider.php
├── Resources/
│   ├── assets/{css,js}
│   ├── lang/{en,id}
│   └── views/
├── Routes/{api.php,web.php}
├── Services/
├── Tests/
│   ├── Feature/
│   ├── Unit/
│   └── Pest.php
├── composer.json                        # MUST exist (for distribution)
├── module.json                          # MUST exist
├── package.json                         # If module has frontend assets
├── CHANGELOG.md                         # MUST exist
└── README.md                            # MUST exist
```

### 6.3 Mandatory conventions

#### 6.3.1 Database

- **Table prefix MUST match module slug**: `crm_clients`, `billing_invoices`, `assets_domains`. Never bare names.
- **Migration filename MUST include module prefix**:
  ```
  2026_05_01_100000_crm_create_clients_table.php
  ```
- **Foreign keys to core User table use `users` (no prefix)**. Document in module's README which core tables are touched.
- **Cross-module foreign keys MUST be soft references** (no FK constraint) and resolved via service layer, to keep modules independently disable-able.
- **Every migration MUST be reversible** (`down()` implemented and tested). Exception: data backfills that destroy data (see §6.7).

#### 6.3.2 Routes

- **Web routes prefix**: `/admin/{module-slug}` for admin, `/{module-slug}` for public.
- **Route names prefix**: `admin.{module}.` or `{module}.`.
- **API routes**: `/api/v{N}/{module-slug}` with version bump on breaking changes.

#### 6.3.3 Permissions

- **Pattern**: `{module}.{resource}.{action}`
- **Examples**: `crm.client.view`, `crm.client.create`, `billing.invoice.send`
- **Seeder**: `{Module}PermissionSeeder` registered via `module.json` providers.

#### 6.3.4 Services & DI

- Business logic **MUST** live in Services, not Controllers/Livewire.
- Services **SHOULD** depend on interfaces, not concrete classes, when reuse is plausible.
- Avoid static helpers for business logic; prefer dependency injection for testability.

#### 6.3.5 Events & hooks

- Modules **MUST** emit Laravel events for significant state changes (`InvoicePaid`, `DomainRenewed`).
- Cross-module integration **MUST** use events or eventy hooks — never direct calls into another module's internals.
- Hook names **MUST** be namespaced: `eventy('crm.client.menu', $items)`.

### 6.4 Module quality gates

A module **MUST** ship with:

- [ ] Unit tests for services (≥70% line coverage of Service classes).
- [ ] Feature tests for HTTP endpoints (happy path + auth/validation failures).
- [ ] PHPStan level ≥6 clean.
- [ ] Pint clean.
- [ ] Migrations run + rollback successfully on fresh DB.
- [ ] Permissions seeded correctly.
- [ ] Minimum ID + EN translations.

### 6.5 Module documentation

Each module's `README.md` **MUST** include:

1. Purpose (1 paragraph).
2. Dependencies (other modules, composer packages, external services).
3. Installation steps if not via Composer.
4. Configuration (env vars, config keys).
5. Permissions list.
6. Public API surface (events, hooks, commands).
7. Database tables created.
8. Known limitations.
9. Compatibility matrix (Laravel version, base version).

### 6.6 Module lifecycle

```
[Draft] → [In-project] → [Stabilized] → [Extracted] → [Published] → [Deprecated] → [Sunset]
```

**Promotion criteria:**

| Transition | Required evidence |
|---|---|
| Draft → In-project | Passes module quality gates §6.4 |
| In-project → Stabilized | Used in 2+ projects with no source changes for ≥1 quarter |
| Stabilized → Extracted | ADR justifying extraction; SemVer plan |
| Extracted → Published | Public docs, support process documented |
| Published → Deprecated | See §6.8 |
| Deprecated → Sunset | See §6.8 |

### 6.7 Module versioning & migration coordination (NEW in v1.1)

This section addresses a gap in v1.0 that becomes critical when modules are shared across projects: **how do you coordinate database migrations when Project A uses module v1.0 and Project B uses module v2.0?**

#### 6.7.1 Migration types

| Migration type | Description | Rule |
|---|---|---|
| **Additive** | Add column, table, index | Safe in MINOR version bump |
| **Backward-compatible alter** | Widen column, add nullable, increase limit | Safe in MINOR |
| **Backward-incompatible alter** | Drop column, rename, change type, NOT NULL on existing | **MUST** be MAJOR version bump |
| **Data backfill** | Populate new column, migrate format | **MUST** be reversible OR documented as forward-only |

#### 6.7.2 The two-phase migration pattern

For backward-incompatible changes, **MUST** use two-phase migration to allow zero-downtime deploy and version overlap:

**Example: renaming `crm_clients.email` to `crm_clients.primary_email`.**

❌ Wrong (v2.0 breaks v1.x consumers):
```php
// Single migration in v2.0
$table->renameColumn('email', 'primary_email');
```

✅ Right (two-phase):
```php
// v1.5.0 (deprecation phase) — additive only
Schema::table('crm_clients', function (Blueprint $table) {
    $table->string('primary_email')->nullable()->after('email');
});
// + Service layer reads from primary_email if set, else email
// + Backfill job copies email → primary_email
// + Mark email field deprecated in @property docblocks

// v2.0.0 (removal phase, after 1+ quarter and all consumers migrated) — breaking
Schema::table('crm_clients', function (Blueprint $table) {
    $table->dropColumn('email');
});
```

#### 6.7.3 Migration ordering when modules share consumers

When Project K depends on `module-vault@^1.0` and `module-billing@^2.0`, and both have migrations, ordering matters:

- Migration timestamp **MUST** reflect when the migration was created in the module's history, not project import time.
- If migrations from different modules conflict (rare — should be impossible if §6.3.1 table prefix rule is honored), the conflict is a **module-level bug** and **MUST** trigger a release in the conflicting module.

#### 6.7.4 Module compatibility matrix (mandatory in module README)

Every module **MUST** document compatibility:

```markdown
## Compatibility

| Module Vault | Laravel | Pesantech base | nwidart/laravel-modules | Notes |
|---|---|---|---|---|
| 1.0.x | ^13.0 | ^1.0 | ^13.0 | Initial release |
| 2.0.x | ^13.0,^14.0 | ^1.1 | ^13.0,^14.0 | Adds two-phase migration support |
```

#### 6.7.5 Forward-only migrations (when `down()` is impossible)

Some migrations cannot be reversed (data loss, destructive transformation). These **MUST**:

1. Be explicitly marked in the migration file:
   ```php
   /**
    * FORWARD-ONLY: This migration cannot be reverted.
    * Reason: Encrypts plaintext credentials; rolling back would re-expose them.
    * Mitigation: Backup database before deploying.
    */
   ```
2. Be announced in the CHANGELOG as a breaking change.
3. Trigger a MAJOR version bump.
4. Have `down()` implemented as `throw new \LogicException('FORWARD-ONLY migration')`.

### 6.8 Module deprecation & sunset policy (NEW in v1.1)

When a module is replaced, fundamentally changed, or no longer maintained, it enters deprecation. This section defines the procedure.

#### 6.8.1 Deprecation timeline

| Phase | Duration | Communication |
|---|---|---|
| **Announcement** | T-0 | CHANGELOG entry; README banner; email to consumer maintainers |
| **Deprecation** | T+0 to T+90 days minimum | Version bump (MINOR); deprecation warnings in code; alternative documented |
| **Maintenance-only** | T+90 to T+180 days | Only critical bug fixes & security patches |
| **Sunset** | T+180 days+ | No support; final security patch promised; archive label on repo |

For modules used in production by ≥1 paying customer, **timeline MUST extend to 12 months minimum** in deprecation + maintenance-only phases.

#### 6.8.2 Deprecation announcement (mandatory contents)

```markdown
## DEPRECATED — module-{name}

**As of v{X.Y.Z} ({date}), this module is deprecated.**

**Reason:** [Why deprecated. E.g., replaced by module-{newer}, technology shift, security architecture change.]

**Migration path:** [How consumers should migrate. Concrete steps.]

**Timeline:**
- T+0 ({date}): Deprecation announced.
- T+90 days ({date}): Last feature release. Maintenance-only thereafter.
- T+180 days ({date}): Sunset. Repository archived. No further updates.

**Affected consumers:** [List known consumer projects.]

**Questions:** [contact email or issue tracker]
```

#### 6.8.3 Code-level deprecation markers

**Class deprecation:**
```php
/**
 * @deprecated since v1.5.0, will be removed in v2.0.0. Use {NewClass} instead.
 */
class OldVaultService { ... }
```

**Method deprecation:**
```php
/**
 * @deprecated since v1.5.0, will be removed in v2.0.0. Use revealCredentialV2() instead.
 */
public function revealCredential() {
    trigger_deprecation('pesantechid/module-vault', '1.5.0', 
        'Method %s is deprecated, use revealCredentialV2() instead.', __METHOD__);
    return $this->revealCredentialV2();
}
```

#### 6.8.4 Forbidden during deprecation

- ❌ **MUST NOT** introduce new features into a deprecated module after deprecation announcement.
- ❌ **MUST NOT** remove deprecated methods/classes before timeline ends.
- ❌ **MUST NOT** sunset a module without first going through deprecation phase.

---

## 7. Module Sharing & Distribution

### 7.1 Three strategies, when to use each

| Strategy | Use when | Maintenance cost | Reusability |
|---|---|---|---|
| **A — In-project only** | Module is in Draft or In-project lifecycle | Low | Zero |
| **B — Composer VCS package** | Stabilized, used in 2–4 projects, internal | Medium | High |
| **C — Private Packagist / Public Packagist** | Stabilized + Productized, 5+ projects or external consumers | Higher (release engineering) | Highest |

**Default progression: A → B → C.** Skipping requires ADR.

### 7.2 Strategy B — Composer VCS

#### 7.2.1 Extract module to its own repo

```bash
cd modules/Vault
git init
git add .
git commit -m "chore: extract Vault module"
gh repo create pesantechid/module-vault --private --source=. --push
```

#### 7.2.2 Module's `composer.json`

```json
{
  "name": "pesantechid/module-vault",
  "description": "Encrypted credential vault module for Pesantech Framework",
  "type": "laravel-module",
  "license": "proprietary",
  "require": {
    "php": "^8.3",
    "illuminate/support": "^13.0",
    "nwidart/laravel-modules": "^13.0"
  },
  "autoload": {
    "psr-4": {
      "Modules\\Vault\\": "src/"
    }
  },
  "extra": {
    "laravel": {
      "providers": ["Modules\\Vault\\Providers\\VaultServiceProvider"]
    }
  }
}
```

#### 7.2.3 Consumer project's `composer.json`

```json
{
  "repositories": [
    {
      "type": "vcs",
      "url": "git@github.com:pesantechid/module-vault.git"
    }
  ],
  "require": {
    "pesantechid/module-vault": "^1.0"
  }
}
```

### 7.3 Strategy C — Private Packagist

Required when:
- Module sold to external customers, OR
- 5+ internal projects depend on it, OR
- Build performance becomes concern (VCS resolves slowly with many packages).

### 7.4 Versioning policy (SemVer)

| Change type | Version bump | Examples |
|---|---|---|
| Breaking (DB schema removal, public API removal, behavior change) | Major (1.x → 2.0) | Drop field, rename event class |
| Backward-compatible feature | Minor (1.0 → 1.1) | Add field, add endpoint |
| Backward-compatible fix | Patch (1.0.0 → 1.0.1) | Bug fix, performance improvement |

**Pre-1.0 (`0.x.y`):** anything goes; minor counts as breaking. Reach 1.0 after ≥1 month stable in production.

### 7.5 Cross-module compatibility matrix

When modules depend on each other, declare in `module.json`:

```json
{
  "name": "Reports",
  "requires": {
    "Crm": "^1.0",
    "Billing": "^1.2"
  }
}
```

Maintain a master compatibility matrix in `pesantechid/pesantech-framework` wiki when 5+ modules exist.

---

## 8. Branching, Tagging & Release Engineering

### 8.1 Branch model

**Trunk-based development** with short-lived feature branches. **MUST NOT** use long-running develop/staging branches.

Branch naming:
- `feat/{ticket-id}-short-desc` — new feature
- `fix/{ticket-id}-short-desc` — bug fix
- `chore/short-desc` — non-functional (deps, CI, docs)
- `refactor/short-desc` — refactoring without behavior change
- `docs/short-desc` — documentation only

### 8.2 Commit conventions

**Conventional Commits** enforced via Commitlint (already in upstream):

```
<type>(<scope>): <subject>

<body — what & why, not how>

<footer — refs, breaking changes>
```

### 8.3 PR workflow

1. Branch from `main`.
2. Make changes; commit with Conventional Commits.
3. Run `composer test` locally before push.
4. Push; open PR using template.
5. PR template enforces:
   - [ ] Linked issue/ticket
   - [ ] Tests added/updated
   - [ ] Migrations reversible (or marked forward-only per §6.7.5)
   - [ ] Permissions seeded (if new)
   - [ ] Documentation updated
   - [ ] No core file modified (or ADR linked)
6. CI must be green.
7. ≥1 review approval (self-review acceptable for solo dev when team size 1; mandatory separate reviewer when team size ≥2).
8. Squash-merge.

### 8.4 Tagging & releases

```bash
git tag -a v1.4.0 -m "Release v1.4.0: monthly report PDF generator"
git push origin --tags
```

**Build metadata** for tracking base version (recommended):

```
v1.4.0+base-1.0.2+laradashboard-1.2.0
```

Releases **MUST** be created via GitHub Releases UI or `gh release create` with autogenerated changelog from Conventional Commits.

---

## 9. Quality Gates & CI/CD

### 9.1 Mandatory gates

Every PR **MUST** pass:

| Gate | Tool | Failure threshold |
|---|---|---|
| Code style | Laravel Pint | Any violation |
| Static analysis | PHPStan (Larastan) | Level 6, no new errors |
| Type/refactor checks | Rector (dry-run) | No undeclared changes |
| Unit + Feature tests | Pest | <100% pass |
| Browser tests | Pest browser plugin | <100% pass (when applicable) |
| JS lint | ESLint | Any violation |
| JS types (if TS) | tsc | Any error |
| Dependency audit | `composer audit`, `npm audit` | High/Critical CVE |
| Secret scanning | gitleaks (CI) | Any finding |
| Migration reversibility | Custom Pest test | Up + down + up cycle on fresh DB |

### 9.2 Reusable CI workflow

Stored in L1 base at `.github/workflows/ci.yml`. Every project inherits via "Use this template" and **MAY** extend.

```yaml
name: CI
on:
  pull_request:
  push:
    branches: [main]

jobs:
  quality:
    runs-on: ubuntu-latest
    services:
      mysql:
        image: mysql:8.4
        env:
          MYSQL_ROOT_PASSWORD: secret
          MYSQL_DATABASE: testing
        ports: ['3306:3306']
        options: >-
          --health-cmd "mysqladmin ping"
          --health-interval 10s
      redis:
        image: redis:7
        ports: ['6379:6379']
    steps:
      - uses: actions/checkout@v4
      - uses: shivammathur/setup-php@v2
        with:
          php-version: '8.3'
          extensions: mbstring, mysql, redis, gd, intl, bcmath, zip
          coverage: pcov
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }

      - name: Composer install
        run: composer install --no-progress --prefer-dist --no-interaction

      - name: Env setup
        run: |
          cp .env.example .env.testing
          php artisan key:generate --env=testing

      - name: Migrate (forward)
        run: php artisan migrate --env=testing

      - name: Migrate rollback test
        run: |
          php artisan migrate:rollback --env=testing
          php artisan migrate --env=testing

      - name: Pint
        run: composer pint

      - name: PHPStan
        run: composer phpstan

      - name: Rector dry-run
        run: ./vendor/bin/rector process --dry-run

      - name: Pest
        run: composer pest

      - name: NPM
        run: |
          npm ci
          npm run lint
          npm run build

      - name: Composer audit
        run: composer audit --abandoned=report

      - name: NPM audit
        run: npm audit --audit-level=high
```

### 9.3 Branch protection ruleset

Apply to `main` of every project:

- ☑ Require PR before merge (1 approval)
- ☑ Require status checks: `quality`
- ☑ Require branches up-to-date before merge
- ☑ Require signed commits (recommended)
- ☑ Restrict force-pushes
- ☑ Restrict deletions

### 9.4 Deployment pipeline

**Staging** (continuous):
- Trigger: every push to `main`.
- Action: build container → push to registry → deploy via SSH or ArgoCD.
- Smoke test: `curl /health` returns 200, `php artisan migrate --pretend` works.

**Production** (gated):
- Trigger: tag matching `v*.*.*` is created.
- Action: same as staging + DB backup before migrate.
- Manual approval **MUST** be required (GitHub Environments → required reviewers).

---

## 10. Performance Engineering

### 10.1 Performance philosophy

**Measure before optimizing.** Premature optimization is debt.

### 10.2 Performance budgets

| Metric | Budget |
|---|---|
| TTFB (p50) admin | < 300 ms |
| TTFB (p95) admin | < 800 ms |
| LCP (p75) client portal | < 2.5 s |
| API JSON response (p95) | < 500 ms |
| Database queries per page (admin) | < 30 |
| Database queries per page (client portal) | < 15 |
| Memory per request | < 64 MB |
| Background job throughput | ≥ 100 jobs/min/worker |

### 10.3 Runtime: PHP-FPM vs Octane

| Scenario | Recommended | Rationale |
|---|---|---|
| <50 concurrent users, simple CRUD | PHP-FPM | Simpler, no state-leak risk |
| ≥50 concurrent users OR latency-sensitive | Octane + FrankenPHP | 3–10x throughput |
| Heavy real-time / WebSockets | Octane + Swoole | Coroutine support |
| Need Xdebug / aggressive debugging | RoadRunner OR PHP-FPM | FrankenPHP/Swoole degrade dev experience |

**Default for new Pesantech projects: start with PHP-FPM. Promote to Octane+FrankenPHP after first load test or when budgets exceeded.**

### 10.4 Caching strategy

| Layer | Technology | Use for |
|---|---|---|
| OPcache | PHP built-in | Bytecode (always on in prod) |
| Application cache | Redis | DB query results, settings, computed views |
| Route/config cache | Laravel artisan cache | Production deploys (`php artisan optimize`) |
| HTTP cache | Cloudflare / CDN | Static assets, public pages |
| View cache | Laravel | Compiled Blade (always on in prod) |

**Cache invalidation rules:**
- Tagged caches via `Cache::tags()` for hierarchical invalidation.
- Model changes invalidate via Observer pattern.
- TTL **MUST** be set explicitly; no infinite caches except for genuinely immutable data.

### 10.5 Database optimization checklist

For every new module:

- [ ] Foreign keys indexed.
- [ ] Common WHERE columns indexed.
- [ ] Common ORDER BY columns indexed.
- [ ] Composite indexes for multi-column WHERE.
- [ ] N+1 queries verified absent.
- [ ] `select(['col1', 'col2'])` for large tables.
- [ ] Pagination on all list queries.
- [ ] Bulk operations use `chunk()` or `lazy()` for >1000 rows.

### 10.6 Frontend optimization

- Vite production build with `--minify`.
- Tailwind purge enabled.
- Code-splitting per route (Livewire 4 supports this).
- Lazy-load heavy components.
- Image: WebP/AVIF with fallback; lazy `loading="lazy"`.

### 10.7 Monitoring & alerts

| Tool | Purpose | Environment |
|---|---|---|
| Laravel Pulse | Internal metrics dashboard | Staging + Production (sampled 1%) |
| Laravel Telescope | Request inspection | **Staging only** (`TELESCOPE_ENABLED=false` in prod) |
| Sentry / Bugsnag | Error tracking | Production |
| Uptime check (UptimeRobot, BetterStack) | External availability | Production |
| Server metrics (Netdata, Grafana) | CPU, memory, disk | Production |

**Alert thresholds:**
- Error rate > 1% over 5 min
- p95 TTFB > 2s over 5 min
- Disk > 85%
- Failed jobs > 10 in 5 min
- Down for >1 min

---

## 11. Security Baseline

### 11.1 OWASP alignment

Every project **MUST** address OWASP Top 10 (current edition).

### 11.2 Authentication & authorization

- 2FA (TOTP) **MUST** be available for all admin/staff roles.
- Password requirements: min 12 chars, no max, breached-password check (HIBP API).
- Session timeout: 8 hours idle, 7 days absolute.
- All routes default-deny — explicit `auth` middleware.
- Spatie Permission with policies, never `if ($user->is_admin)` checks.
- Sanctum tokens scoped per integration.

### 11.3 Secrets management

- **MUST NOT** commit secrets, even fake ones, beyond what upstream ships.
- Production secrets stored in: GitHub Actions Secrets, server `.env` (chmod 600), or vault service (HashiCorp Vault for K8s).
- Database backups encrypted at rest (age, sops, or built-in cloud).

### 11.4 Secrets rotation procedure (NEW in v1.1)

This section is critical because Vault-type modules encrypt customer credentials with `APP_KEY`. Rotation **without procedure** = data loss.

#### 11.4.1 Rotation calendar

| Secret | Rotation cadence | Triggered immediately on |
|---|---|---|
| `APP_KEY` | Annual + on suspicion of compromise | Suspected compromise; departing engineer with access |
| Database password | Quarterly | Suspected compromise; departing engineer with access |
| API tokens (Cloudflare, Telegram bot, etc.) | Quarterly OR on personnel change | Same as above |
| TLS certificates | Auto via Let's Encrypt (90-day) | N/A |
| 2FA backup codes (per user) | On personnel change | Same as above |

#### 11.4.2 `APP_KEY` rotation procedure (CRITICAL)

`APP_KEY` rotation is destructive if mishandled because Laravel's `Crypt` facade uses it to decrypt all encrypted data (including encrypted casts in models).

**MUST** follow this procedure:

```bash
# Phase 1: Preparation (runs against production replica)
# 1. Identify all encrypted data
php artisan tinker
>>> // List models with encrypted casts
>>> // Document affected tables and columns

# 2. Take a fresh, verified backup
mysqldump --single-transaction kendali_prod > backup-pre-rotation-$(date +%Y%m%d).sql
# Encrypt the backup
age -r $(cat backup-recipients.txt) backup-pre-rotation-*.sql > backup-pre-rotation-$(date +%Y%m%d).sql.age
# VERIFY restore works on staging
```

```bash
# Phase 2: Re-encryption (in a maintenance window)
# 1. Generate new key (do NOT replace yet)
NEW_KEY=$(php artisan key:generate --show)

# 2. Add new key as secondary
# Laravel supports APP_PREVIOUS_KEYS for rotation:
#   .env:
#     APP_KEY=base64:NEW...
#     APP_PREVIOUS_KEYS=base64:OLD...

# 3. Run re-encryption command (must be implemented in Vault module)
php artisan vault:reencrypt --confirm
# This iterates encrypted columns, decrypts with old, re-encrypts with new

# 4. After verification, remove APP_PREVIOUS_KEYS
```

#### 11.4.3 Required: Vault module re-encryption command

Every module that uses encrypted casts **MUST** ship with a re-encryption Artisan command:

```php
// modules/Vault/Console/Commands/ReencryptCommand.php
class ReencryptCommand extends Command
{
    protected $signature = 'vault:reencrypt {--confirm} {--chunk=100}';
    
    public function handle()
    {
        if (!$this->option('confirm')) {
            $this->error('Run with --confirm to proceed. Backup database first.');
            return 1;
        }
        
        Credential::chunk($this->option('chunk'), function ($creds) {
            foreach ($creds as $cred) {
                // Force re-encryption by saving (Laravel handles this if APP_PREVIOUS_KEYS set)
                $cred->touch();
                $cred->save();
            }
        });
    }
}
```

#### 11.4.4 Rotation drill (mandatory)

- **Quarterly:** rotate non-critical secret (e.g., a test API token) end-to-end.
- **Annually:** full rotation drill on staging including `APP_KEY`. Document results.
- **MUST** test restore from backup before any production rotation.

### 11.5 Data protection

- All PII fields encrypted at rest using Laravel encrypted casts.
- Credentials/tokens in vault module use envelope encryption (per-tenant DEK + master KEK).
- TLS 1.2+ only; HSTS preload.
- CSP strict policy; nonce-based.
- Database SSL connection in production.

### 11.6 Dependency hygiene

- Dependabot enabled.
- `composer audit` and `npm audit` in CI; high/critical = build failure.
- Quarterly manual review of all dependencies.

### 11.7 Logging & audit

- All write operations to sensitive entities logged via `ActionLog` (already in base).
- Logs **MUST NOT** contain PII or secrets — use Laravel's `dontFlash` + custom scrubber.
- Audit log retention: minimum 1 year.
- Failed login attempts logged + rate-limited (5/15min/IP, 5/15min/account).

### 11.8 Email deliverability (NEW in v1.1)

Email-sending products require operational setup beyond app code. Without this, emails go to spam — invoices unread, reminders unseen.

#### 11.8.1 DNS setup (mandatory before sending production email)

For domain `kendali.in` (and any sender domain):

| Record | Purpose | Example |
|---|---|---|
| **SPF** (TXT) | Authorized senders | `v=spf1 include:spf.postmarkapp.com ~all` |
| **DKIM** (TXT) | Cryptographic signature | Provided by mail provider |
| **DMARC** (TXT) | Policy for SPF/DKIM failures | `v=DMARC1; p=quarantine; rua=mailto:dmarc@kendali.in; pct=100` |
| **MX** | Receive bounces/replies | Postmark MX or self-hosted |

**MUST** verify all four records via:
```bash
dig TXT kendali.in
dig TXT _dmarc.kendali.in
dig TXT [selector]._domainkey.kendali.in
```

**MUST** use a deliverability tester (mail-tester.com, Postmark check) before first production send. Target score: 9/10 minimum.

#### 11.8.2 Domain warm-up

New domains have zero reputation. Sending 1000 invoices on day 1 → spam.

**Warm-up schedule:**

| Days | Daily volume cap |
|---|---|
| 1–7 | 50 |
| 8–14 | 200 |
| 15–30 | 1,000 |
| 30+ | Per provider limits |

#### 11.8.3 Provider choice

| Provider | Strengths | Cost (2026, ~) |
|---|---|---|
| **Postmark** | Best transactional deliverability, fast support | $15/mo for 10k |
| **AWS SES** | Cheapest at scale | $0.10 / 1k |
| **Mailgun** | Decent deliverability, EU region available | $15/mo for 10k |
| **Resend** | Developer-friendly, modern | $20/mo for 50k |

**Default recommendation for Pesantech:** Postmark for transactional (invoices, alerts). SES for bulk (campaigns).

#### 11.8.4 Bounce & complaint handling

- **MUST** subscribe to provider webhooks for bounces and complaints.
- **MUST** auto-suppress addresses after hard bounce or complaint.
- **MUST NOT** retry sending to suppressed addresses.

#### 11.8.5 Sender reputation monitoring

Monitor weekly:
- Postmaster Tools (Google) — sender reputation.
- Microsoft SNDS — Outlook reputation.
- Provider dashboards — bounce rate < 2%, complaint rate < 0.1%.

#### 11.8.6 Content best practices

- **MUST** include unsubscribe link in marketing/campaign emails (legal requirement; transactional invoices exempt but courteous).
- **MUST NOT** use spammy phrases ("FREE!!!", excessive caps).
- **MUST** include physical address in marketing emails (UU PDP + CAN-SPAM equivalent).
- Plain-text alternative alongside HTML.

### 11.9 Indonesia-specific (UU PDP)

- Right-to-export: every project **MUST** expose data export per data subject.
- Right-to-delete: deletion process documented; soft-delete + hard-delete-after-grace-period pattern.
- Privacy policy link visible in client portal.
- DPA template available for B2B clients.

---

## 12. Observability, Operations & Disaster Recovery

### 12.1 Three pillars

| Pillar | Tool | Retention |
|---|---|---|
| **Logs** | Laravel log → file → Loki/Papertrail | 30 days hot, 1 year cold |
| **Metrics** | Pulse + Prometheus | 90 days |
| **Traces** | OpenTelemetry → Jaeger/Tempo (when scale demands) | 7 days |

### 12.2 Health checks

Every project **MUST** expose:

- `GET /health` — basic liveness, returns 200 if app boots.
- `GET /health/ready` — readiness, checks DB, Redis, queue connection.

### 12.3 Backup & restore

- DB backup: daily, encrypted, off-site (R2 / S3 / Backblaze).
- Application files (uploaded media): daily incremental, encrypted, off-site.
- Retention: 30 days daily, 12 months monthly.

### 12.4 Incident response

- Severity classification:
  - **SEV1**: full outage, data loss, security breach. Response: <15 min.
  - **SEV2**: degraded service. Response: <1 hour.
  - **SEV3**: minor issue. Response: next business day.
- Postmortem **MUST** be written for SEV1/SEV2 within 1 week, blameless.

### 12.5 Runbooks

Each project **MUST** maintain `OPERATIONS.md` with:

- How to deploy / rollback.
- How to restore DB.
- How to access logs.
- How to scale.
- Common errors & fixes.
- On-call rotation (when applicable).

### 12.6 Disaster Recovery (NEW in v1.1)

Disasters happen: VPS host bankruptcy, accidental `DROP DATABASE`, ransomware, region outage. Without a DR plan, "we have backups" is a half-truth.

#### 12.6.1 RTO and RPO targets

| Tier | RTO (Recovery Time Objective) | RPO (Recovery Point Objective) | Use for |
|---|---|---|---|
| **Tier 1 — Production SaaS (Phase 3)** | 4 hours | 1 hour | When paying customers depend on uptime |
| **Tier 2 — Internal production** | 24 hours | 24 hours | Pesantech Phase 1 (single tenant) |
| **Tier 3 — Internal non-critical** | 1 week | 1 week | Dev/staging |

**RTO** = max time the service can be down before recovery. **RPO** = max data loss acceptable.

For Phase 1 Kendali, Tier 2 applies: max 24h downtime, max 24h data loss.

#### 12.6.2 Backup strategy (3-2-1 rule)

- **3** copies of data
- **2** different storage media/providers
- **1** off-site

For Pesantech:

| Backup | Where | Frequency | Encrypted? |
|---|---|---|---|
| Primary | VPS local (cron `mysqldump`) | Hourly | No (local) |
| Secondary | Cloudflare R2 (different region) | Daily | Yes (age) |
| Tertiary | Backblaze B2 (different provider) | Weekly | Yes (age) |

**Vault data** (encrypted credentials) backed up separately with separate encryption key — protects against compromise of primary backup encryption key.

#### 12.6.3 Restore drill (MANDATORY)

A backup that isn't tested is not a backup.

**Quarterly drill:**
1. Spin up fresh VPS or container.
2. Restore latest backup.
3. Verify application boots.
4. Verify last 24h of data is present.
5. Document time taken (must be < RTO).
6. File drill report in `OPERATIONS.md`.

**Annually:** full DR drill including DNS cutover, certificate provisioning, integrations re-config. Goal: complete recovery from "production lost" scenario in <RTO.

#### 12.6.4 Data classification (informs DR priority)

| Class | Examples | Loss impact | Recovery priority |
|---|---|---|---|
| **Critical** | Vault credentials, billing records, audit logs | Legal/financial | 1 (recover first) |
| **Important** | Client data, reports, tickets | Operational | 2 |
| **Replaceable** | Cached data, search indexes, sessions | Performance | 3 (rebuild rather than restore) |

#### 12.6.5 Off-VPS dependencies

Track all external dependencies that could fail independently:
- DNS (registrar)
- Email provider (Postmark)
- File storage (R2)
- TLS certificate (Let's Encrypt)
- Telegram Bot API
- Any future payment gateway

For each: document recovery procedure, alternative provider option, and contact.

#### 12.6.6 Communication plan

When disaster strikes:
- Customers notified within 1 hour (status page or email).
- ETA updates every 2 hours.
- Postmortem published within 1 week.

For Phase 1 Kendali (5 clients), a simple Telegram broadcast is sufficient. Phase 3 SaaS needs a real status page (statuspage.io or self-hosted Cachet).

---

## 13. Architecture Decision Records (ADR)

### 13.1 Why ADRs

ADRs capture *why* a decision was made, not just *what*.

### 13.2 When to write an ADR

Mandatory for:
- Choosing a database, queue driver, or runtime.
- Adopting/dropping a major dependency.
- Multi-tenancy strategy.
- Authentication provider choice.
- Departures from this playbook.
- Module extraction to package.
- Module deprecation.
- Tier 2 emergency upstream sync (per §4.3.4).

### 13.3 ADR template

Stored at `docs/adr/NNNN-title.md`:

```markdown
# ADR NNNN — Title

| Status   | Proposed / Accepted / Deprecated / Superseded by ADR-XXXX |
| Date     | YYYY-MM-DD                                                |
| Deciders | @maintainer1, @maintainer2                                |

## Context
What problem are we solving? What forces are at play?

## Decision
What are we doing? Be specific.

## Consequences
- Positive: ...
- Negative: ...
- Risks & mitigations: ...

## Alternatives considered
- Option A: rejected because ...
- Option B: rejected because ...

## References
- Links, benchmarks, prior art.
```

### 13.4 ADRs to write at project start (Pesantech standard set)

For every Pesantech project:

1. **ADR-0001**: Adopt this playbook (version pinned).
2. **ADR-0002**: Base version pinned (record `pesantech-framework@vX.Y.Z+laradashboard-A.B.C`).
3. **ADR-0003**: Database technology.
4. **ADR-0004**: Initial runtime (PHP-FPM vs Octane).
5. **ADR-0005**: Multi-tenancy strategy.
6. **ADR-0006**: Module taxonomy.
7. **ADR-0007**: Upstream sync strategy (Tier 1 default per §4.3).
8. **ADR-0008**: Module versioning & deprecation policy (per §6.7, §6.8).
9. **ADR-0009**: Secrets rotation procedure (per §11.4).

---

## 14. Glossary & Appendices

### 14.1 Glossary

| Term | Definition |
|---|---|
| **Base** | The pesantech-framework template (L1) — never directly used as project. |
| **Project** | A concrete product instance (L2). |
| **Module** | An installable, self-contained business capability under `modules/`. |
| **Workspace** | Isolated tenant within a multi-tenant project (Phase 2+). |
| **ADR** | Architecture Decision Record. |
| **SemVer** | Semantic Versioning — major.minor.patch. |
| **DEK / KEK** | Data Encryption Key / Key Encryption Key — envelope encryption pattern. |
| **RTO / RPO** | Recovery Time Objective / Recovery Point Objective. |
| **Tier 1/2/3 sync** | Upstream sync source (tag/release-branch/main) per §4.3. |

### 14.2 Tooling versions (as of 2026-05)

| Component | Version |
|---|---|
| PHP | 8.3 / 8.4 |
| Laravel | 13.x |
| Livewire | 4.x |
| Tailwind | 4.x |
| nwidart/laravel-modules | 13.x |
| spatie/laravel-permission | 6.4+ |
| MySQL | 8.4 LTS |
| Redis | 7.x |
| Node.js | 20.19+ |
| FrankenPHP | 1.x |
| Octane | 2.x |
| stancl/tenancy (when adopted) | 3.10+ |
| laravel/pennant (feature flags) | 1.x |

### 14.3 Quick reference cheatsheet

```bash
# Bootstrap project
gh repo create pesantechid/PROJECT --template pesantechid/pesantech-framework --private
git clone git@github.com:pesantechid/PROJECT.git && cd PROJECT
git remote add base https://github.com/pesantechid/pesantech-framework.git

cp .env.example .env && composer install && npm install
php artisan key:generate
php artisan migrate:fresh --seed && php artisan module:seed

# Daily dev
composer dev

# Module ops
php artisan module:make Crm
php artisan module:make-crud Client Crm
php artisan module:list
php artisan module:enable Crm
php artisan module:disable Crm
php artisan module:zip Crm

# Quality
composer pint
composer phpstan
composer pest
composer test

# Sync upstream → base (TAG-based per §4.3)
cd pesantech-framework
git fetch upstream --tags
git merge v1.1.3 --no-ff   # use specific tag, not branch

# Sync base → project
cd PROJECT
git fetch base --tags
git merge v1.1.0+laradashboard-1.2.0 --no-ff

# Production deploy
git tag -a v1.4.0 -m "Release v1.4.0"
git push origin --tags
```

### 14.4 Common pitfalls & remedies

| Pitfall | Symptom | Remedy |
|---|---|---|
| Editing `app/Models/User.php` | Conflicts on every base sync | Use UserMeta or extend in module |
| Module table named bare (e.g., `clients`) | Conflict in shared modules | Always prefix: `crm_clients` |
| Forgetting permission seeder | Missing perms in production | Module-level `PermissionSeeder` registered in `module.json` |
| Telescope/Pulse on in production | Performance + info disclosure | `.env` `TELESCOPE_ENABLED=false`, verified pre-prod |
| Cross-module direct dependency | Cannot disable one module | Use events or hooks |
| Octane state leak | Random user data in wrong session | Audit static properties; flush in `RequestHandled` listener |
| Tracking upstream `main` | Unreproducible builds, no audit trail | Use tag (Tier 1 per §4.3) |
| `APP_KEY` rotation without procedure | Encrypted data lost | Follow §11.4.2 procedure |
| Email goes to spam | Invoices unread | Setup SPF/DKIM/DMARC + warm-up per §11.8 |
| Backup never tested | Discovery during real outage that backup is corrupt | Quarterly restore drill per §12.6.3 |
| Module v2 breaking changes | Consumer projects stuck on v1 | Two-phase migration per §6.7.2 |

### 14.5 References

- Laravel 13 Release Notes — https://laravel.com/docs/13.x/releases
- nwidart/laravel-modules — https://laravelmodules.com
- Laravel Octane — https://laravel.com/docs/13.x/octane
- stancl/tenancy — https://tenancyforlaravel.com
- Conventional Commits — https://www.conventionalcommits.org
- Keep a Changelog — https://keepachangelog.com
- ADR pattern — https://adr.github.io
- OWASP Top 10 — https://owasp.org/Top10/
- 3-2-1 Backup Rule — https://www.backblaze.com/blog/the-3-2-1-backup-strategy/

---

## 15. Feature Flags & Progressive Delivery (NEW in v1.1)

### 15.1 Why feature flags

Feature flags decouple deploy from release. Code can be deployed to production with a feature **off**, then turned on for selected users/tenants/percentages. This enables:

- **Safer launches** — kill switch if something breaks.
- **Gradual rollout** — 1% → 10% → 100%.
- **A/B testing** — measure impact before full rollout.
- **Tenant-specific features** (Phase 3 SaaS) — beta features for selected workspaces.
- **Trunk-based development** — long-running feature work without long branches.

### 15.2 Tooling: laravel/pennant

Use **laravel/pennant** (first-party, lightweight):

```bash
composer require laravel/pennant
php artisan vendor:publish --provider="Laravel\Pennant\PennantServiceProvider"
php artisan migrate
```

### 15.3 Flag naming convention

Pattern: `{module}.{feature}` or `{scope}.{feature}`

Examples:
- `reports.llm-conclusion-draft` — LLM-assisted conclusion in Reports module
- `billing.online-payment` — payment gateway integration
- `client-portal.ticket-submission` — ticket submission for clients
- `experimental.new-dashboard` — UI experiments

### 15.4 Flag lifecycle

```
Created (off, in code) → Beta (selective on) → GA (default on) → Removed
```

**Every flag MUST have:**
- Owner (named person/team)
- Created date
- Removal target date (default: 90 days post-GA)

**Flag debt is real.** Flags left in code indefinitely become dead branches and confuse readers. **MUST** schedule flag removal.

### 15.5 Flag definition

```php
// In a service provider
use Laravel\Pennant\Feature;

Feature::define('reports.llm-conclusion-draft', function ($user) {
    // Default: only super admins
    return $user->hasRole('super-admin');
});

// Per-tenant flag (Phase 3)
Feature::define('billing.online-payment', function ($workspace) {
    return $workspace->is_beta_tester;
});

// Percentage rollout
Feature::define('client-portal.ticket-submission', function ($user) {
    return Lottery::odds(1, 10); // 10%
});
```

### 15.6 Flag usage

```php
if (Feature::active('reports.llm-conclusion-draft')) {
    $conclusion = $this->llmService->draftConclusion($report);
}
```

In Blade:
```blade
@feature('reports.llm-conclusion-draft')
    <button>Generate AI conclusion</button>
@endfeature
```

### 15.7 Flag types & when to use each

| Flag type | Lifetime | Purpose |
|---|---|---|
| **Release flag** | Days–weeks | Decouple deploy from launch |
| **Experiment flag** | Weeks | A/B test |
| **Permission flag** | Permanent | "Beta tier" feature gating (becomes permission, not flag) |
| **Ops flag** | Indefinite | Kill switch (long-lived, but documented) |
| **Permission flag** | Permanent | If permanent, **MUST** be migrated to RBAC permission instead |

### 15.8 Phase 1 minimum

For Pesantech Phase 1 (Kendali), minimal feature flag setup:

- [ ] `laravel/pennant` installed.
- [ ] Flag table migrated.
- [ ] Convention documented in project README.
- [ ] At least 2 flags in use (e.g., one release flag, one ops kill switch).

Don't over-invest before Phase 3. Just establish the foundation.

---

## 16. AI-Assisted Implementation Standards (NEW in v1.1)

This section addresses the operational reality that Pesantech uses AI agents (Claude Code, Cursor, etc.) for implementation. These standards ensure AI output meets the same quality bar as human-written code.

### 16.1 Why this section exists

AI agents perform best with:
- **Acceptance criteria that are testable** (not "implement well").
- **Complete context** (not "developer will know").
- **Explicit constraints** ("MUST NOT do X" beats "avoid X").
- **Reference to specific files/modules** (not "the config file").

Without these, AI output drifts: invented APIs, missed edge cases, inconsistent style.

### 16.2 Task specification standard

Every task given to an AI agent **MUST** follow this structure:

```markdown
## Task: [verb-led, specific]

### Context
- What this is part of (module name, PRD section, ADR reference)
- What already exists (file paths, model names)
- What NOT to touch

### Specification
- Inputs (data, parameters)
- Outputs (return types, side effects)
- Acceptance criteria (testable conditions)

### Constraints
- Files allowed to modify: [explicit list]
- Files MUST NOT modify: [explicit list]
- Style: follow Pint config at .pintrc
- Tests: MUST add Pest tests covering [scenarios]
- Migration: MUST be reversible OR mark forward-only per §6.7.5

### References
- Playbook section(s): [§X.Y]
- ADR(s): [ADR-NNNN]
- Module README: [path]
```

### 16.3 Example task (good)

```markdown
## Task: Add `assets:refresh-whois` Artisan command to Modules/Assets

### Context
- Part of Module Assets in Kendali project (PRD §6.2)
- Existing: `Modules/Assets/Services/WhoisService.php` already exists with method `lookup(string $domain): array`
- Existing: `Modules/Assets/Entities/AssetDomain.php` model with `last_whois_check_at` column
- DO NOT modify base Laravel files

### Specification
**Input:** No arguments. Optional `--client=ID` to scope to one client.
**Output:** Refreshes `expires_at`, `registrar`, `last_whois_check_at` for all domains where `last_whois_check_at` is null OR > 24h ago.
**Acceptance criteria:**
- Command lives at `Modules/Assets/Console/Commands/RefreshWhoisCommand.php`
- Registered in `Modules/Assets/Providers/AssetsServiceProvider.php`
- Pest test at `Modules/Assets/Tests/Feature/RefreshWhoisCommandTest.php` covering:
  - Refreshes domain due for check
  - Skips domain checked <24h ago
  - Handles WhoisService failure gracefully (logs, doesn't crash)
- Updates `last_whois_check_at` even on failure (to prevent retry loop)

### Constraints
- Files allowed to modify: 
  - `Modules/Assets/Console/Commands/RefreshWhoisCommand.php` (new)
  - `Modules/Assets/Providers/AssetsServiceProvider.php`
  - `Modules/Assets/Tests/Feature/RefreshWhoisCommandTest.php` (new)
- Files MUST NOT modify: anything outside `Modules/Assets/`
- Style: Pint
- Migration: none (no DB schema changes)

### References
- Playbook: §6.2, §6.3.4 (services), §16 (this section)
- PRD: §6.2 Module Assets
```

### 16.4 Example task (bad — what to avoid)

```markdown
## Task: Add a command to refresh domain expiries

Implement a way to refresh WHOIS data periodically. Make it nice.
```

**Why this fails:**
- "A way" — agent invents structure.
- "Refresh WHOIS data" — agent doesn't know which fields, which tables.
- "Periodically" — cron? On-demand? Both?
- "Make it nice" — unmeasurable.
- No file path, no module, no acceptance criteria, no test requirement.

### 16.5 Review standard for AI-generated PR

Every PR from AI agent **MUST** pass human review for:

| Check | Why |
|---|---|
| Did the agent follow file constraints? | AI sometimes "helpfully" modifies adjacent files |
| Are tests covering claimed scenarios? | AI sometimes writes tests that pass but don't actually test |
| Are acceptance criteria all met? | Spot-check each one |
| Are edge cases handled? | AI optimizes for happy path |
| Is style consistent with codebase? | Style guide compliance |
| Are there invented APIs? | AI sometimes references methods that don't exist |
| Are migrations reversible? | AI often skips `down()` |
| Are deprecation markers present (if applicable)? | AI doesn't auto-add unless told |
| Does it leak secrets in logs? | Always check |

### 16.6 AI agent instruction header (for repo)

Add to project root as `AGENTS.md` or `CLAUDE.md`:

```markdown
# AI Agent Instructions for [PROJECT]

## Project context
- Built on pesantech-framework (Laravel 13 + Livewire 4 + Tailwind 4)
- Multi-module architecture via nwidart/laravel-modules
- Read docs/playbook.md before any task

## Hard rules
1. NEVER modify files in app/, bootstrap/, config/, routes/, database/migrations/ at project root.
   All custom code lives in modules/.
2. ALWAYS prefix new tables with module slug (e.g., crm_clients).
3. ALWAYS write Pest tests for new code.
4. ALWAYS run `composer pint` and `composer phpstan` after edits.
5. NEVER commit secrets, even fake ones, in .env.example.
6. NEVER add features to a deprecated module.

## Style
- Follow Pint default rules (no overrides unless documented in .pintrc)
- PHP 8.3 features OK
- No facades in domain logic (use DI)
- Service classes for business logic, not Controllers/Livewire

## When unsure
Ask. Don't invent.
```

### 16.7 Task batch sizing

| Task complexity | Recommended batch |
|---|---|
| **Trivial** (1 file, ≤50 lines) | Direct task, AI implements, human reviews |
| **Small** (2–5 files, 1 module command) | Task spec + AI implements + AI tests + human reviews |
| **Medium** (full CRUD, 1 module) | Break into sub-tasks: model+migration, service, controller, views, tests. Human reviews each. |
| **Large** (full module) | Spec module, break into multi-day sub-tasks. Don't ask AI to "build the whole module" in one go. |

### 16.8 Common AI failure modes & countermeasures

| Failure | Counter |
|---|---|
| Inventing methods on existing classes | Provide actual class signatures in task context |
| Skipping `down()` in migrations | Explicit acceptance criterion |
| Tests that always pass (no real assertions) | Review test bodies, look for `assertTrue(true)` patterns |
| Modifying core files "to make it work" | Hard constraint in task; reject PR if violated |
| Adding new dependencies without justification | Explicit constraint: "no new composer packages without ADR" |
| Inconsistent style mid-file | Run Pint after merge; fail PR on style violation |
| Hallucinating Laravel APIs | Cross-check against actual Laravel docs URL in references |

---

## Document control

| Revision | Date | Author | Notes |
|---|---|---|---|
| 0.1 | 2026-05-05 | Pesantech | Initial draft (working title: OpsHub) |
| 1.0 | 2026-05-06 | Pesantech | Approved baseline |
| **1.1** | **2026-05-07** | **Pesantech** | **Tag-based upstream sync (§4.3 rewritten). Added: §6.7 versioning, §6.8 deprecation, §11.4 secrets rotation, §11.8 email deliverability, §12.6 disaster recovery, §15 feature flags, §16 AI-assisted implementation.** |

**Change process:** amendments via PR to `pesantechid/pesantech-framework` `docs/playbook.md`, requires review by ≥1 maintainer. Major version bumps when fundamental principles change.

*— End of document —*
