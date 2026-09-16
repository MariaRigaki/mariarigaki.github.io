# mariarigaki.github.io

Source for https://mariarigaki.github.io/ — Hugo + HugoBlox `academic-cv`.

## Editing the site

    pnpm install     # first time on a new machine only
    hugo server      # then open http://localhost:1313

The site rebuilds as you save. **Push to `main` and it publishes itself** — GitHub
Actions builds and deploys. No build output lives in git.

## Adding things

**A blog post** — create `content/blog/<slug>/index.md`:

    ---
    title: 'Your title'
    date: 2026-09-16
    authors: [me]
    tags: [something]
    ---

    Your text.

Images go in the same folder next to `index.md`, referenced by bare filename.

**A paper** — create `content/publications/<slug>/index.md`; copy
`content/publications/meme/` as a template. Add its DOI to the map in
`scripts/fetch-citations.py`, then run:

    python3 scripts/fetch-citations.py

That fetches the publisher's official BibTeX into the paper's `cite.bib`, which is
what the page's **Cite** button serves. Don't paste a Google Scholar export — Scholar
mangles author names, title case and sometimes the year.

**A talk** — create `content/events/<slug>/index.md`, same shape as the existing ones.

**Your bio, role, employment, education, links** — all in `data/authors/me.yaml`.

**Your CV** — replace it at all four paths, or old links go stale:
`static/uploads/cv.pdf`, `static/files/cv.pdf`, `static/cv.pdf`,
`static/files/Short CV - Maria Rigaki.pdf`.

## Before changing any URL

    ./scripts/check-urls.sh

Checks that every URL this site published as of September 2026 still resolves, and
that each redirect lands on a real page. Must report **41/41** and exit 0.

If you rename or move a page, add its old path to `aliases:` in the page's front
matter rather than letting it 404. `scripts/redirect-map.tsv` records every redirect.
About 103 old taxonomy, pagination and author URLs are *deliberately* left to 404 —
a decision, not an oversight; the file's header explains it.

## Things that will bite you

- **Hugo is pinned to 0.166.0** in `.github/workflows/deploy.yml` — the current release
  when this was built. The theme runs on it fine; the pin just stops a future Hugo
  release breaking a deploy unattended. When you bump it, run `./scripts/check-urls.sh`
  and check for build warnings first. (The theme that *couldn't* run on modern Hugo was
  the old Wowchemy one this replaced.)
- **Don't run `upgrade.yml` casually** — it upgrades the theme modules and changes the
  pinned Hugo version out from under `deploy.yml`.
- **`master` is the old site**, kept as history. Don't commit to it.
- **Rollback:** branch `archive/rendered-2024` is the site exactly as published in
  January 2024. Pointing GitHub Pages back at it restores the old site.
- **Appearance** (fonts, colours) is configured in `config/_default/params.yaml`.
  Changing it doesn't touch content or URLs.
