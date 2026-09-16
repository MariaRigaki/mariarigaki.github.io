# Website rebuild: migrate to HugoBlox academic-cv on current Hugo

- **Date:** 2026-09-16
- **Status:** Draft — awaiting review
- **Owner:** Maria Rigaki
- **Site:** https://mariarigaki.github.io/

## Context

The personal site has been unbuildable since roughly 2024 and the published
content is frozen at January 2024. Three candidate source folders exist on
disk, and the one that actually produced the live site is not the one that
looks canonical.

Established by inspection:

| Folder | What it is | Disposition |
|---|---|---|
| `~/repos/Mari_website` | Academic v4 source, content frozen Apr 2022 | Obsolete |
| `~/repos/Mari_website_bak` | Byte-identical copy of the above | Duplicate |
| `~/repos/mari_website_new/starter-hugo-academic-main` | Wowchemy 5.8.1 source of the live site | Current, to be replaced |

The live source is confirmed by matching publication slugs (`malware-extraction`,
`meme`, `out-cage`, `survey`) and the `Wowchemy 5.7.0` generator string in the
published HTML. It is **entirely untracked by git** — `mari_website_new` has zero
commits and no remote. A single copy on one laptop is the only extant source.

A second hazard: `~/repos/Mari_website` has a git remote pointing at
`MariaRigaki/mariarigaki.github.io` with a diverged local `master`
(71 ahead / 17 behind, unrelated content). A forced push from that folder
would overwrite the published site.

## Why the current theme cannot move to modern Hugo

Latest Hugo is v0.166.0 (2026-09-09). Troubleshooting on a scratch copy,
in order:

1. Repointing the dead `wowchemy/v5` module at its maintained successor
   `HugoBlox/.../blox-bootstrap/v5 v5.9.7` fixes the original
   `.File.UniqueID` crash. **Resolved.**
2. `getCSV` (removed in Hugo 0.163) — fixed by one local shortcode override.
   **Resolved.**
3. `.Site.GoogleAnalytics` (removed) in `blox-seo` v0.2.2 — fixed by one local
   partial override. **Resolved.**
4. **Blocking:** the theme resolves every homepage block and list view
   dynamically via `templates.Exists (printf "partials/%s" $path)`. Hugo 0.146
   moved partials from `layouts/partials/` to `layouts/_partials/`, so every
   such lookup now returns false:

   ```
   ERROR uses a `about.biography` block but the `about.biography` block was not
         found at `layouts/partials/blocks/about.biography.html`
   WARN  Failed to locate view at `partials/views/%!s(uint64=2).html`
   ```

This is the theme's entire dispatch mechanism, not a handful of call sites.
Mixing in newer `blox-core`/`blox-seo` modules fails differently — they belong
to the Tailwind generation and expect different partial names. `blox-bootstrap`
v5 is the Bootstrap-era line and is in maintenance only.

**Conclusion:** pinning Hugo to 0.111.3 is the only way to keep the current
theme. Rejected — the explicit goal is to run on current Hugo.

## Decision

Migrate to the current **HugoBlox `academic-cv`** starter
(`github.com/HugoBlox/kit/modules/blox`).

Verified: cloned the starter and built it with Hugo 0.166.0 — 93 pages, no
errors, in 873ms. Requires a Node dependency install and adding `tailwindcss` to Hugo's
`security.exec.allow`, both one-time configuration.

Rationale: actively maintained (updated 2026-09-13), same content lineage as
the existing site so publications and author data port with edits rather than
rewrites, and its stock homepage already matches the chosen "academic
shop-window" shape.

### Approaches rejected

- **Fork `blox-bootstrap` v5 and fix the partial lookups.** Preserves the exact
  current look, but means owning a permanent fork of a discontinued theme line
  and re-fixing it on every Hugo release.
- **A lean general theme** (Congo, Blowfish, PaperMod) with hand-rolled
  publication lists. Elegant and much lighter, but discards publication types,
  citation export, BibTeX import and talk pages — the wrong trade for a site
  whose purpose is an academic shop-window.

## Goals

- Site builds on current Hugo with no local theme patches.
- Source under version control with history, on GitHub.
- Content brought current: bio, CV, all publications, dissertation.
- A low-friction path to publishing blog posts.
- No existing URL breaks.

## Non-goals

- Custom domain. Staying on `mariarigaki.github.io`.
- Visual redesign beyond what the starter provides out of the box.
- Migrating the Netlify CMS admin UI. It is unused; dropped.
- Preserving the Bootstrap-era look.

## Architecture

### Repository and branches

All work happens in the existing **public** `MariaRigaki/mariarigaki.github.io`.

- New orphan branch **`main`** holds the Hugo source; becomes the default branch.
- Existing **`master`** is preserved untouched as branch `archive/rendered-2024`
  plus a tag. The 2019–2024 published HTML is never lost.
- GitHub Pages build type switches from **legacy branch build** to
  **GitHub Actions**. After the switch no rendered HTML is committed anywhere.
- Fresh local clone at `~/repos/mariarigaki.github.io`.

Rationale for source on the default branch rather than a separate `source`
branch: one less thing to remember, and the default branch is what a fresh
clone lands on.

The source repo is public. This was a deliberate reversal of an earlier
preference for a private source repo: GitHub Pages for a `<user>.github.io`
site can only be served from that exact public repo, so a private source would
require Actions to push rendered HTML across repositories via a deploy key.
Public source removes that machinery entirely. Trade-off accepted: drafts and
unpublished edits are visible.

### Build and deploy

`.github/workflows/deploy.yml`:

```
checkout → setup-node + pnpm install --frozen-lockfile
  → setup-hugo (extended, pinned 0.166.0)
  → hugo --minify → pagefind index → actions/deploy-pages
```

Hugo version is pinned in the workflow, not floating, so a Hugo release cannot
break a deploy unattended. Bumping it is a one-line change.

`config/_default/hugo.yaml` needs `tailwindcss` added to `security.exec.allow`;
without it the Tailwind CSS transform is denied and the build fails.

### Local development

```
pnpm install     # once
hugo server      # day-to-day
```

The starter ships a `pnpm-lock.yaml` and declares `packageManager: pnpm@10.14.0`;
it has no `package-lock.json`, so CI must use pnpm. `npm install` works locally
but generates a competing lockfile and should not be committed.

## Site structure

Stock starter homepage blocks, which already match the chosen shape:

```
resume-biography-3   photo, role, interests, CV button, social links
collection #papers   recent publications
collection #talks    talks & events
collection #news     recent blog posts, compact
experience           separate page
```

Navigation: **Bio · Papers · Talks · Blog · Experience · CV**

The starter's Projects and Courses sections are removed — there is no content
for them and empty nav items look unfinished.

## URL compatibility

The new starter renames content directories:

| Old | New |
|---|---|
| `content/publication/` | `content/publications/` |
| `content/post/` | `content/blog/` |
| `content/talk/` | `content/events/` |

Published papers are cited and linked externally, so every migrated page gets
`aliases` front matter preserving its old path. Before cutover, the new page
inventory is diffed against the current live site to confirm nothing 404s.

This is the highest-risk part of the migration and is verified explicitly
rather than assumed.

## Content migration

| Item | Plan |
|---|---|
| Bio | Role becomes **Post-doctoral Researcher**, Czech Technical University in Prague. No honorific. Education gains the PhD entry. |
| CV | Maria supplies an updated PDF. Existing Apr-2022 `cv.pdf` is used as a placeholder until then; nothing blocks on it. |
| Publications | Listed in `citations` (11 papers). Front matter written per paper; each `cite.bib` fetched from the DOI via Crossref, not from the Scholar export. |
| Dissertation | Own entry, type `thesis` — *Offensive Applications of Machine Learning in Cybersecurity*, linked to `~/repos/thesis/main.pdf`. |
| Talks | Port the existing 4. |
| Blog | Port the two real 2019 posts, which were dropped in the last migration and survive only in `~/repos/Mari_website`. |
| Demo content | Delete all starter examples: demo blog posts, courses, example projects, example slides. |

### Citations

Maria supplied `citations`, a Google Scholar BibTeX export naming the 11 papers
to display. It is the source of truth for *which* papers appear, and for nothing
else: Scholar exports are lossy (`pages={pp--70}`, `author={Rigaki, M and
Garcia, S}`, mangled title case, and the Expert Systems paper dated 2025 where
the publisher says 2026).

Each paper's citation is instead fetched from its DOI via Crossref content
negotiation, which returns the publisher's own record, and written to a
`cite.bib` beside the page. HugoBlox auto-detects that file and renders it as
the **Cite** button.

Peer-reviewed versions lead. Per paper: `publication` holds the venue,
`hugoblox.ids.doi` drives the DOI button, `hugoblox.ids.arxiv` drives a separate
Preprint button, and `links: [{type: pdf}]` offers an openly readable copy — so
citing the published version and linking an accessible PDF are not in tension.

Nine of the eleven have DOIs, resolved and verified. Hackphyr (arXiv 2409.11276)
and Evaluating Generalization Mechanisms (arXiv 2603.10041) are still preprints,
confirmed with Maria on 2026-09-16; Crossref returns confidently wrong matches
for both, so neither is looked up by title.

The `academic` BibTeX importer was evaluated and dropped: it would regenerate
entries for the six papers already live, discarding their hand-written abstracts
and the aliases that keep their URLs working.

## Verification before cutover

1. `hugo --minify` completes with no errors on pinned Hugo.
2. Page inventory diffed against the live site; every existing URL resolves,
   via alias where the path changed.
3. Site reviewed locally via `hugo server` before Pages is switched over.
4. Pages build type switched only after the above pass.

## Rollback

`archive/rendered-2024` holds the exact HTML currently being served. Reverting
means pointing Pages back at that branch with the legacy build type. No data
loss at any step.

## Cleanup

After the new site is live and verified:

- Neutralize the git remote in `~/repos/Mari_website` so it cannot overwrite
  the published site.
- Archive `Mari_website`, `Mari_website_bak` and `mari_website_new`.

Nothing is deleted before cutover, and deletions are confirmed with Maria
first.

## Open items

- Updated CV PDF — Maria to supply.
- PhD defence date and post-doc start date — needed for the author profile and the
  dissertation entry; deliberately left blank rather than guessed.
- Whether Maria wants a `PhD` postnominal, and whether to publish pronouns. Both
  are supported by the author schema; neither is assumed.
