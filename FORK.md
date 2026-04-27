# Pesantech Framework - Fork Strategy & Maintenance Guide

## 📦 Fork Information

- **Original Repository:** [Lara Dashboard](https://github.com/laradashboard/laradashboard)
- **Forked To:** [pesantech-framework](https://github.com/pesantechid/pesantech-framework)
- **Fork Date:** 2026-04-27
- **Current Version:** Based on Lara Dashboard v1.1.2
- **Maintenance Strategy:** Merge-based sync with upstream

---

## 🎯 Purpose

**Pesantech Framework** is a production-ready Laravel 12 + Livewire 3 **modular framework** for building scalable business applications across multiple domains (Travel, CRM, Finance, etc.).

This is a **stable base project** that never changes. Each business product/domain gets its own separate repository that uses this framework as a foundation.

---

## 🌳 Git Strategy

### **Branches**

```
main       - Stable, always synced with upstream (Lara Dashboard)
           - Used for releases and stable deployments
           - No direct commits here (only merges from upstream)

develop    - Working/staging branch
           - Testing ground for upstream updates
           - Where customizations are developed before release
           
upstream/* - Remote branches from Lara Dashboard (reference only)
```

### **Remotes**

```bash
origin     = https://github.com/pesantechid/pesantech-framework.git  (YOUR FORK)
upstream   = https://github.com/laradashboard/laradashboard.git      (ORIGINAL)
```

---

## 🔄 How to Sync with Upstream

### **Regular Sync (Monthly or on upstream releases)**

```bash
# 1. Fetch latest from upstream
git fetch upstream

# 2. Check what's new
git log --oneline main..upstream/main

# 3. Switch to develop branch for testing
git checkout develop

# 4. Merge upstream into develop (test first)
git merge upstream/main

# If there are conflicts, resolve them:
# - Edit conflicting files
# - git add .
# - git commit -m "Merge upstream v1.x.x"

# 5. Push develop to origin
git push origin develop

# 6. After testing, merge develop into main
git checkout main
git merge develop
git push origin main
```

### **One-Command Sync Script**

```bash
#!/bin/bash
# Save as ./scripts/sync-upstream.sh

git fetch upstream
git checkout develop
git merge upstream/main
git push origin develop
git checkout main
git merge develop
git push origin main
echo "✅ Synced with upstream!"
```

---

## ⚙️ File Structure

**NEVER modify these core files directly** - use custom files instead:

```
❌ DON'T EDIT:
  - app/Http/Kernel.php
  - config/app.php
  - routes/web.php
  - app/Providers/AppServiceProvider.php

✅ DO EDIT:
  - app/Providers/PesantechServiceProvider.php (NEW)
  - config/pesantech.php (NEW)
  - routes/pesantech.php (NEW)
  - app/Customizations/ (NEW)
```

This ensures when you merge upstream updates, you won't have conflicts.

---

## 📝 Customizations Log

### Current Version
- **Base:** Lara Dashboard v1.1.2
- **Custom Files:**
  - `planning.md` - PRD & architecture document
  - `FORK.md` - This file
  - `app/Providers/PesantechServiceProvider.php` - (planned)
  - `config/pesantech.php` - (planned)

### Sync History

| Date | Upstream Version | Notes |
|------|------------------|-------|
| 2026-04-27 | v1.1.2 | Initial fork setup |

---

## 🚀 Product Repositories (Using This Framework)

Each product/domain has its own repository:

- **[spidest-travel](https://github.com/pesantechid/spidest-travel)** - Hajj & Umrah Travel Website
  - Module: `TravelWebsite`
  - Uses: pesantech-framework as base

- **spidest-crm** (coming soon) - Customer Relationship Management
  - Module: `CRM`
  - Uses: pesantech-framework as base

- **spidest-finance** (coming soon) - Financial Management
  - Module: `Finance`
  - Uses: pesantech-framework as base

---

## 🔧 Troubleshooting

### **Merge Conflicts During Sync**

```bash
# If you get conflicts when merging upstream
# 1. Check conflicts
git status

# 2. Resolve conflicts in your editor
# 3. Stage resolved files
git add .

# 4. Complete merge
git commit -m "Merge upstream & resolve conflicts"
git push origin develop
```

### **Accidentally Pushed to Main**

```bash
# If you pushed directly to main (don't do this!):
git reset --soft HEAD~1
git checkout develop
git push -f origin main (only if not shared with others)
```

### **Want to Cherry-Pick a Feature**

```bash
# Instead of full merge, cherry-pick specific commits
git fetch upstream
git cherry-pick <commit-hash>
git push origin develop
```

---

## 📋 Checklist for Upstream Merges

Before merging upstream, always:

- [ ] Fetch latest: `git fetch upstream`
- [ ] Switch to develop: `git checkout develop`
- [ ] Check commits: `git log --oneline main..upstream/main`
- [ ] Merge: `git merge upstream/main`
- [ ] Test locally: `npm run dev` & manual testing
- [ ] Resolve any conflicts
- [ ] Push to origin: `git push origin develop`
- [ ] Verify on GitHub: Check develop branch
- [ ] Merge to main: `git checkout main && git merge develop && git push`

---

## 🎓 Best Practices

1. **Never force-push to main** - It's your source of truth
2. **Always test on develop first** - Before merging to main
3. **Keep custom code isolated** - Use separate files/folders
4. **Document customizations** - Update this file
5. **Tag releases** - When you merge to main: `git tag -a v1.1.2-pesantech-1`
6. **Write clear commit messages** - For merge commits

---

## 📞 Support

- **Upstream Issues:** Report to [Lara Dashboard](https://github.com/laradashboard/laradashboard/issues)
- **Fork Issues:** Report to [pesantech-framework](https://github.com/pesantechid/pesantech-framework/issues)

---

**Last Updated:** 2026-04-27  
**Maintained By:** Pesantech Team
