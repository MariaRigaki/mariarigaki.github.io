# Website Rebuild Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild https://mariarigaki.github.io/ on the current HugoBlox `academic-cv` starter, running on current Hugo, with source in git and no existing URL broken.

**Architecture:** A new orphan `main` branch in the existing public `MariaRigaki/mariarigaki.github.io` repo holds the Hugo source. GitHub Actions builds it and deploys to Pages; no rendered HTML is committed. Content is recovered from two different stale folders and re-homed into the new starter's directory names, with `aliases` front matter preserving every published URL.

**Tech Stack:** Hugo extended 0.166.0, HugoBlox `kit/modules/blox` (Hugo Modules via Go), Tailwind CSS v4, pnpm, Pagefind, GitHub Actions.

**Spec:** `docs/superpowers/specs/2026-09-16-website-rebuild-design.md`

## Global Constraints

- Hugo **extended** 0.166.0, pinned in the workflow. Not `latest`.
- Package manager is **pnpm** (`pnpm-lock.yaml` ships with the starter). Never commit a `package-lock.json`.
- Theme module: `github.com/HugoBlox/kit/modules/blox`.
- `config/_default/hugo.yaml` must list `'^tailwindcss$'` under `security.exec.allow`, or the CSS transform is denied and the build fails.
- Name is **Maria Rigaki**. Role is **Post-doctoral Researcher**, Czech Technical University in Prague. No "Dr." honorific anywhere.
- `baseURL: https://mariarigaki.github.io/`
- Every page that exists on the live site today must keep responding at its current URL, via `aliases` where the path changed.
- Working repo: `~/repos/mariarigaki.github.io`. The three old folders under `~/repos` are read-only sources until Task 13.

## Citation policy

Every publication carries the **peer-reviewed** version as its identity, with the
open-access copy offered alongside. These are separate fields, not alternatives:

| Shown as | Front matter |
|---|---|
| Venue | `publication: {name, volume, issue}` + `publication_types` + `peer_reviewed: true` |
| **Cite** button | a `cite.bib` file beside `index.md`, served verbatim |
| **DOI** button | `hugoblox.ids.doi` |
| **Preprint** button | `hugoblox.ids.arxiv` |
| **PDF** button | `links: [{type: pdf, url: …}]` — the openly readable copy |

`cite.bib` is generated from the DOI via Crossref content negotiation, **not** from
`citations`. That file is a Google Scholar export and is lossy: `pages={pp--70}`,
`author={Rigaki, M and Garcia, S}`, mangled title case ("The power of meme",
"with LLMS"), and the ESWA paper dated 2025 where the publisher says 2026. Treat
`citations` as the list of what to include, never as citation text.

`publication_types` uses CSL strings in this generation, not the old numeric codes:
`paper-conference`, `article-journal`, `article` (preprint), `thesis`.

### Resolved identifiers

Verified against Crossref. Use these rather than re-deriving them.

| Slug | Type | Venue | Identifier |
|---|---|---|---|
| `gan-knife-fight` | paper-conference | IEEE Security and Privacy Workshops 2018 | `10.1109/spw.2018.00019` |
| `machete` | paper-conference | IEEE EuroS&PW 2019 | `10.1109/eurospw.2019.00058` |
| `survey` | article-journal | ACM Computing Surveys 56(4) | `10.1145/3624010` |
| `malware-extraction` | article-journal | Computers & Security 129 | `10.1016/j.cose.2023.103192` |
| `meme` | paper-conference | ESORICS 2023 (Springer) | `10.1007/978-3-031-51482-1_3` |
| `out-cage` | paper-conference | ICAART 2024 (SciTePress) | `10.5220/0012391800003636` |
| `prompt-exploit-repeat` | paper-conference | ICAART 2024 (Springer) | `10.1007/978-3-031-87330-0_2` |
| `adaptive-cyber-agents` | article-journal | Expert Systems with Applications 299 | `10.1016/j.eswa.2025.129987` |
| `alquistcoder` | article-journal | Computational Intelligence 42(4) | `10.1111/coin.70282` |
| `hackphyr` | article | arXiv preprint | arXiv `2409.11276` |
| `evaluating-generalization` | article | arXiv preprint | arXiv `2603.10041` |
| `dissertation` | thesis | CTU Prague | none |

**Do not trust a Crossref title search for `hackphyr` or `evaluating-generalization`.**
Both are preprints with no DOI, and Crossref returns confidently wrong matches for
each (a Chinese cultural tourism paper, and an unrelated cyber-attack paper).
Confirmed with Maria on 2026-09-16 that both are still unpublished.

**Machete is already correct on the live site.** The existing entry is the
EuroS&PW paper with `doi: 10.1109/EuroSPW.2019.00058`; Virus Bulletin 2019 is a
separate *talk*, handled in Task 5. Do not merge them, and do not create a second
Machete publication.

## Critical context: the source folders disagree with the live site

There is no single folder that reproduces the live site. Content must be recovered from two places:

| Live URL | Title | Recover from |
|---|---|---|
| `/publication/gan-fight/gan-knife-fight/` | Bringing a GAN to a Knife-fight | `Mari_website/content/publication/gan-knife-fight.md` |
| `/publication/machete/machete/` | Machete: Dissecting the Operations… | `Mari_website/content/publication/machete.md` |
| `/publication/malware-extraction/` | Stealing and evading malware classifiers… | `mari_website_new/starter-hugo-academic-main/content/publication/malware-extraction/index.md` |
| `/publication/meme/` | The Power of MEME | `…/content/publication/meme/index.md` |
| `/publication/out-cage/` | Out of the Cage | `…/content/publication/out-cage/index.md` |
| `/publication/survey/` | A Survey of Privacy Attacks in ML | `…/content/publication/survey/index.md` |
| `/talk/arming-malware-with-gans/` | Arming Malware with GANs | `Mari_website/content/talk/arming.md` |
| `/talk/forget-me-not-malware-classification-as-a-continual-learning-problem/` | Forget me not | `Mari_website/content/talk/cybersecai.md` |
| `/talk/stealing-malware-classification-models-for-antivirus-evasion/` | Stealing Malware Classification Models | `Mari_website/content/talk/cybersecai2021/index.md` |
| `/talk/virus-bulletin-2019/` | Virus Bulletin 2019 | `Mari_website/content/talk/virusb2019.md` |
| `/post/hacking-nn-programmatically/` | Changing Weights and Biases Programmatically… | `Mari_website/content/post/hacking-nn-programmatically.md` |
| `/post/summer-hacakathon-2019/` | Scoping it out! | `Mari_website/content/post/summer-hacakathon-2019.md` |

The Wowchemy folder lost the talks and the two older papers at some point after the January 2024 publish; the Academic folder still has them. Note `summer-hacakathon` is misspelled in the live URL — **preserve the typo in the alias**, fix it only in the new slug.

Deliberately allowed to 404 (starter demo content that was published by accident): `/project/`, `/project/example/`, `/project/external-project/`, `/slides/`, `/slides/example/`, `/admin/`.

---

### Task 1: Safety net

Nothing is created yet. This task makes it impossible to lose the current site or accidentally overwrite it.

**Files:**
- Create: `~/backups/website-sources-2026-09-16.tar.gz`
- Modify: `~/repos/Mari_website/.git/config` (remove remote)

**Interfaces:**
- Produces: branch `archive/rendered-2024` and tag `live-2024-01-21` on `origin`; a local snapshot tarball of all three source folders.

- [ ] **Step 1: Snapshot all three source folders before touching anything**

```bash
mkdir -p ~/backups
tar czf ~/backups/website-sources-2026-09-16.tar.gz \
  -C ~/repos Mari_website Mari_website_bak mari_website_new
ls -lh ~/backups/website-sources-2026-09-16.tar.gz
```

Expected: a tarball of roughly 100–400 MB.

- [ ] **Step 2: Verify the snapshot actually contains the recoverable content**

```bash
tar tzf ~/backups/website-sources-2026-09-16.tar.gz \
  | grep -E 'Mari_website/content/(talk|post|publication)/' | head -20
```

Expected: the talk, post and publication markdown files listed in the table above. If this is empty, STOP — the snapshot is bad.

- [ ] **Step 3: Archive the currently-published branch on the remote**

```bash
cd /tmp && rm -rf pages-archive
git clone git@github.com:MariaRigaki/mariarigaki.github.io.git pages-archive
cd pages-archive
git checkout master
git branch archive/rendered-2024
git tag live-2024-01-21
git push origin archive/rendered-2024 live-2024-01-21
```

- [ ] **Step 4: Verify the archive exists on the remote**

```bash
git ls-remote --heads --tags origin | grep -E 'archive/rendered-2024|live-2024-01-21'
```

Expected: two lines. This is the rollback path; do not proceed without it.

- [ ] **Step 5: Neutralize the dangerous remote in the obsolete folder**

`~/repos/Mari_website` points at the live Pages repo with a diverged master (71 ahead / 17 behind). A forced push from there would overwrite the site.

```bash
cd ~/repos/Mari_website
git remote rename origin DISABLED-origin
git remote set-url DISABLED-origin "DISABLED-was-git@github.com:MariaRigaki/mariarigaki.github.io.git"
git remote -v
```

Expected: the remote is named `DISABLED-origin` with a non-resolvable URL. The folder stays readable as a content source.

- [ ] **Step 6: Capture the live URL inventory as the migration's acceptance criteria**

```bash
mkdir -p ~/repos/_website-migration
curl -s https://mariarigaki.github.io/sitemap.xml \
  | grep -oE '<loc>[^<]*' | sed 's|<loc>||' \
  | sed 's|https://mariarigaki.github.io||' | sort \
  > ~/repos/_website-migration/live-urls.txt
wc -l ~/repos/_website-migration/live-urls.txt
```

Expected: 51 URLs.

---

### Task 2: Scaffold the new site and prove it builds

**Files:**
- Create: `~/repos/mariarigaki.github.io/` (whole tree from starter)
- Create: `~/repos/mariarigaki.github.io/docs/superpowers/specs/2026-09-16-website-rebuild-design.md`
- Create: `~/repos/mariarigaki.github.io/docs/superpowers/plans/2026-09-16-website-rebuild.md`
- Create: `~/repos/mariarigaki.github.io/scripts/check-urls.sh`
- Create: `~/repos/mariarigaki.github.io/scripts/expected-urls.txt`
- Modify: `~/repos/mariarigaki.github.io/config/_default/hugo.yaml`

**Interfaces:**
- Consumes: `~/repos/_website-migration/live-urls.txt` from Task 1.
- Produces: a green `hugo` build; `scripts/check-urls.sh` which every later content task re-runs.

- [ ] **Step 1: Clone the repo and create the orphan source branch**

```bash
cd ~/repos
git clone git@github.com:MariaRigaki/mariarigaki.github.io.git
cd mariarigaki.github.io
git checkout --orphan main
git rm -rf . >/dev/null
```

Expected: an empty working tree on a branch with no parent. `master` is untouched.

- [ ] **Step 2: Lay down the starter**

```bash
cd /tmp && rm -rf academic-cv-starter
git clone --depth 1 https://github.com/HugoBlox/theme-academic-cv.git academic-cv-starter
rm -rf academic-cv-starter/.git
cp -r academic-cv-starter/. ~/repos/mariarigaki.github.io/
cd ~/repos/mariarigaki.github.io && ls
```

Expected: `config/`, `content/`, `go.mod`, `package.json`, `pnpm-lock.yaml`, `netlify.toml`.

- [ ] **Step 3: Allow the Tailwind binary in Hugo's security policy**

Without this the build fails with `access denied: "tailwindcss" is not whitelisted`.

In `config/_default/hugo.yaml`, replace:

```yaml
security:
  _merge: deep
```

with:

```yaml
security:
  _merge: deep
  exec:
    allow:
      - '^(dart-)?sass$'
      - '^go$'
      - '^git$'
      - '^node$'
      - '^postcss$'
      - '^tailwindcss$'
      - '^npx$'
```

- [ ] **Step 4: Install Node dependencies with pnpm**

```bash
cd ~/repos/mariarigaki.github.io
corepack enable 2>/dev/null || npm i -g pnpm
pnpm install --frozen-lockfile
ls node_modules/.bin/tailwindcss
```

Expected: the `tailwindcss` binary exists. If a `package-lock.json` appears, delete it — pnpm is the project's package manager.

- [ ] **Step 5: Build, to confirm the toolchain works before any content changes**

```bash
PATH="$PWD/node_modules/.bin:$PATH" hugo --gc --minify
```

Expected: a page count table and `Total in …`, with no `ERROR` lines. If Hugo is not 0.166.0 locally, install it first — the pinned version is a global constraint.

- [ ] **Step 6: Write the URL parity check**

This is the migration's test. It fails now and must pass before cutover.

Create `scripts/check-urls.sh`:

```bash
#!/usr/bin/env bash
# Verify every URL the live site publishes still resolves in a local build.
# Usage: ./scripts/check-urls.sh [public_dir]
set -uo pipefail

PUBLIC="${1:-public}"
EXPECTED="$(dirname "$0")/expected-urls.txt"
fail=0

while IFS= read -r url; do
  [ -z "$url" ] && continue
  # A URL resolves if the path exists as a rendered page, or if some page
  # declares it as an alias (Hugo renders aliases as redirect stubs).
  candidate="${PUBLIC}${url}index.html"
  if [ -f "$candidate" ]; then
    continue
  fi
  echo "MISSING: $url"
  fail=$((fail + 1))
done < "$EXPECTED"

total=$(grep -cve '^\s*$' "$EXPECTED")
echo "----"
echo "$((total - fail))/$total expected URLs resolve"
[ "$fail" -eq 0 ] || echo "FAIL: $fail missing"
exit $((fail > 0))
```

```bash
chmod +x scripts/check-urls.sh
```

- [ ] **Step 7: Seed the expected-URL list, excluding the demo pages we deliberately drop**

```bash
cd ~/repos/mariarigaki.github.io
grep -vE '^/(project|slides|admin)/' ~/repos/_website-migration/live-urls.txt \
  > scripts/expected-urls.txt
wc -l scripts/expected-urls.txt
```

Expected: 45 URLs (51 live minus 6 deliberately dropped).

- [ ] **Step 8: Run the check and watch it fail**

```bash
./scripts/check-urls.sh
```

Expected: FAIL, with most URLs reported MISSING. This is the baseline. Record the passing count.

- [ ] **Step 9: Copy in the spec and this plan, then commit**

```bash
mkdir -p docs/superpowers/specs docs/superpowers/plans
cp /path/to/2026-09-16-website-rebuild-design.md docs/superpowers/specs/
cp /path/to/2026-09-16-website-rebuild.md docs/superpowers/plans/
# Maria's paper list — currently only in the folder we archive in Task 13
cp ~/repos/Mari_website/citations docs/citations.bib
ls docs/superpowers/specs/ docs/superpowers/plans/ docs/citations.bib
printf 'public/\nresources/\n.hugo_build.lock\nnode_modules/\npackage-lock.json\n.pagefind/\n' > .gitignore
git add -A
git commit -m "chore: scaffold HugoBlox academic-cv site on Hugo 0.166

Replaces the unbuildable Wowchemy 5.8.1 source. Adds the URL parity
check that guards the migration against breaking published links."
```

---

### Task 3: Site identity and configuration

**Files:**
- Modify: `config/_default/hugo.yaml`
- Modify: `config/_default/params.yaml`
- Modify: `config/_default/menus.yaml`

**Interfaces:**
- Produces: correct `baseURL` and site title; navigation without Projects or Courses.

- [ ] **Step 1: Set the base URL and title**

In `config/_default/hugo.yaml`:

```yaml
baseURL: 'https://mariarigaki.github.io/'
title: 'Maria Rigaki'
```

- [ ] **Step 2: Trim navigation to sections that will have content**

Replace the `main:` block in `config/_default/menus.yaml` with:

```yaml
main:
  - name: Bio
    url: /
    weight: 10
  - name: Papers
    url: /#papers
    weight: 20
  - name: Talks
    url: /#talks
    weight: 30
  - name: Blog
    url: /blog/
    weight: 40
  - name: Experience
    url: /experience/
    weight: 50
  - name: CV
    url: /uploads/cv.pdf
    weight: 60
```

- [ ] **Step 3: Delete the demo sections entirely**

Removing them from the nav is not enough — they would still build, appear in the
sitemap and be picked up by search.

```bash
cd ~/repos/mariarigaki.github.io
rm -rf content/projects content/courses content/slides
ls content/
```

Expected: `authors`, `blog`, `events`, `publications`, `_index.md` only.

- [ ] **Step 4: Build and confirm nav renders without demo entries**

```bash
PATH="$PWD/node_modules/.bin:$PATH" hugo --gc --minify
grep -o 'href="/projects/"\|href="/courses/"' public/index.html | head
ls public/projects public/courses public/slides 2>/dev/null || echo "demo sections gone"
```

Expected: no nav links, and none of those directories built.

- [ ] **Step 5: Commit**

```bash
git add -A config/ content/
git commit -m "config: set site identity, trim nav, drop demo sections"
```

---

### Task 4: Author profile and biography

**Important:** this starter does **not** use `content/authors/<name>/_index.md`. The
biography block resolves its person from `data/authors/<slug>.yaml` (schema
`hugoblox/author/v1`) and its avatar from `assets/media/authors/<slug>.*`. The
owner slug is `me`, set by `username: me` in the `resume-biography-3` block.

**Files:**
- Modify: `data/authors/me.yaml`
- Replace: `assets/media/authors/me.png`
- Modify: `content/_index.md` (CV button target, demo "My Research" text)
- Create: `static/uploads/cv.pdf` (placeholder, replaced in Task 9)

**Interfaces:**
- Consumes: avatar from `~/repos/Mari_website/content/authors/admin/avatar.png`.
- Produces: the author slug `me`, referenced as `authors: [me]` by every content page in Tasks 5-8.

- [ ] **Step 1: Replace the demo avatar and add the placeholder CV**

```bash
cd ~/repos/mariarigaki.github.io
cp ~/repos/Mari_website/content/authors/admin/avatar.png assets/media/authors/me.png
mkdir -p static/uploads
cp ~/repos/mari_website_new/starter-hugo-academic-main/static/files/cv.pdf static/uploads/cv.pdf
ls -la assets/media/authors/me.png static/uploads/cv.pdf
```

- [ ] **Step 2: Rewrite `data/authors/me.yaml`**

Replace the whole file with:

```yaml
schema: hugoblox/author/v1
slug: me
is_owner: true
name:
  display: Maria Rigaki
  given: Maria
  family: Rigaki
role: Post-doctoral Researcher

affiliations:
  - name: Czech Technical University in Prague
    url: https://cs.felk.cvut.cz/

bio: |
  Maria Rigaki is a post-doctoral researcher in the Department of Computer
  Science at the Czech Technical University in Prague. As a member of the
  Stratosphere Lab, she works on the security and privacy of machine learning,
  and on applications of AI in cyber security. Before that she spent many years
  as a software developer and systems architect, working on telecommunications,
  physical security, emergency response systems and critical infrastructure.

  In her spare time Maria enjoys hacking and playing with guitars.

links:
  - icon: at-symbol
    url: mailto:maria.rigaki@aic.fel.cvut.cz
    label: E-mail Me
  - icon: brands/github
    url: https://github.com/mariarigaki
  - icon: academicons/google-scholar
    url: https://scholar.google.co.uk/citations?user=90yGfrsAAAAJ

interests:
  - Applications of ML in systems security
  - Privacy and Security of Machine Learning
  - Network Security
  - Malware Analysis
  - CTFs
  - OSINT

education:
  - degree: PhD in Computer Science
    institution: Czech Technical University in Prague
    summary: |
      Dissertation: *Offensive Applications of Machine Learning in Cybersecurity*.
  - degree: MSc in Information Security
    institution: Luleå University of Technology, Sweden
  - degree: Diploma in Electrical Engineering and Computer Science
    institution: University of Patras, Greece

experience:
  - role: Post-doctoral Researcher
    org: Czech Technical University in Prague
  - role: Researcher / PhD Student
    org: Czech Technical University in Prague
    start: 2017-08-01
  - role: Senior Solution Architect
    org: Ericsson Norway
    start: 2012-03-15
    end: 2017-07-30
  - role: Systems Engineer
    org: Ericsson Greece
    start: 2007-08-07
    end: 2012-02-28
  - role: Software Developer
    org: Bytemobile (now Citrix)
    start: 2004-04-01
    end: 2007-01-10
```

Three deliberate omissions, all requiring Maria's input rather than a guess:

- **`postnominals`.** The schema supports `postnominals: [PhD]`. Maria rejected the
  "Dr." honorific; whether she wants a `PhD` postnominal is a separate question.
  Left out — ask before adding.
- **`pronouns`.** The schema supports it. Never inferred. Left out unless she asks.
- **Dates on the PhD, post-doc and `date_end` of the PhD-student role.** The exact
  defence date and post-doc start are unknown. Left blank rather than fabricated.
  Ask Maria, then fill in `start:`/`end:` for those three entries.

- [ ] **Step 3: Point the CV button at the real file and replace the demo research text**

In `content/_index.md`, in the `resume-biography-3` block:

```yaml
      button:
        text: Download CV
        url: uploads/cv.pdf
```

In the same file, the `markdown` block still contains the starter's placeholder
text about "a research scientist in the Moonshot team at DeepMind". Replace its
`text:` with a short paragraph in Maria's words, or delete the whole `markdown`
block if the biography already says enough.

- [ ] **Step 4: Check the rest of the homepage for demo copy**

```bash
grep -nE 'DeepMind|Moonshot|Alex Johnson|example\.com|hugoblox\.com' content/_index.md
```

Expected: no output. Fix every hit before moving on.

- [ ] **Step 5: Build and verify the bio renders correctly**

```bash
PATH="$PWD/node_modules/.bin:$PATH" hugo --gc --minify
grep -c "Maria Rigaki" public/index.html
grep -o "Post-doctoral Researcher" public/index.html | head -1
grep -ri "PhD Student\|Alex Johnson" public/index.html || echo "clean"
```

Expected: the name appears, the role appears, and neither the old title nor the
demo persona survives anywhere.

- [ ] **Step 6: Commit**

```bash
git add data/authors assets/media/authors static/uploads content/_index.md
git commit -m "content: replace demo persona with Maria's profile"
```

---

### Task 5: Port the four talks

**Files:**
- Create: `content/events/arming-malware-with-gans/index.md`
- Create: `content/events/forget-me-not/index.md`
- Create: `content/events/stealing-malware-classification-models/index.md`
- Create: `content/events/virus-bulletin-2019/index.md`
- Delete: `content/events/example/`

**Interfaces:**
- Consumes: `~/repos/Mari_website/content/talk/{arming,cybersecai,virusb2019}.md` and `cybersecai2021/index.md`.
- Produces: four `/events/<slug>/` pages, each aliasing its live `/talk/<slug>/` URL.

- [ ] **Step 1: Remove the demo talk**

```bash
cd ~/repos/mariarigaki.github.io
rm -rf content/events/example
```

- [ ] **Step 2: Create the first talk**

`content/events/arming-malware-with-gans/index.md`:

```yaml
---
title: 'Arming Malware with GANs'
abstract: 'Generative Adversarial Networks (GANs) are a recent invention that shows impressive results in generating completely new images of faces, building interiors and much more. In this talk we present how we can use GANs to modify network traffic parameters in order to mimic other types of traffic. More specifically, we modify an open source malware to use a GAN to dynamically adapt its Command and Control network behavior and mimic the traffic characteristics of Facebook chat. In this way it is able to avoid the detection from new-generation Intrusion Prevention Systems that use behavioral characteristics. We will present our experiments from a real-life scenario that used the Stratosphere behavioral IPS deployed in a router between the malware which was deployed in our lab and the C&C server deployed in AWS. Results show that it is possible for the malware to become undetected when given the input parameters from a GAN. The malware is also aware of whether or not it is being blocked and uses this as a feedback signal in order to improve the GAN model. Finally, we discuss the implications of this work in malware detection as well as other areas such as censorship circumvention.'
event_name: "Security Session '18"
location: Brno, Czech Republic
date: '2018-04-07T00:00:00Z'
authors:
  - me
links:
  - type: pdf
    url: 'https://www.stratosphereips.org/s/Arming-Malware-with-GANs.pdf'
aliases:
  - /talk/arming-malware-with-gans/
---
```

- [ ] **Step 3: Create the second talk**

`content/events/forget-me-not/index.md`:

```yaml
---
title: 'Forget me not: Malware Classification as a Continual Learning Problem'
abstract: 'It is well known in the machine learning community that the performance of models degrades over time with the introduction of new data, getting worse in solving both new and old tasks. This is also true for security applications of machine learning, but there is less knowledge of how this happens, when, and why. In the particular case of malware classification, the increasing growth in the amount of malicious files forces the community to research machine learning models that use data more effectively. Inspired by the way humans learn, Continual Learning algorithms try to incrementally learn new tasks from data that keeps changing, without forgetting the tasks learned in the past. In this talk we will try to address the following questions: Is Continual Learning a suitable approach for security-related datasets and problems? Can Continual Learning methods learn new malware families effectively without forgetting old ones? What are the improvements in terms of speed and storage?'
event_name: 'Cybersec & AI Prague'
date: '2019-10-31T20:05:32+01:00'
authors:
  - me
  - Elnaz Babayeva
  - Sebastian Garcia
aliases:
  - /talk/forget-me-not-malware-classification-as-a-continual-learning-problem/
---
```

- [ ] **Step 4: Create the third talk**

`content/events/stealing-malware-classification-models/index.md`:

```yaml
---
title: 'Stealing Malware Classification Models for Antivirus Evasion'
abstract: 'Model stealing attacks have been successfully demonstrated in several domains. However, in the area of malware detection, there is no comparison of surrogate creation strategies, nor a comparison of surrogates for generating adversarial malware. More importantly, no work attempted to "steal" real antivirus systems in order to evade them. Model extraction attacks are interesting from a security perspective because they can be used as a stepping stone for subsequent attacks, such as the adversarial creation of malware. In this talk we will present our findings and lessons on model stealing attacks against three stand-alone machine learning malware classifiers and four AVs. Using a limited amount of queries, we explored a number of active learning strategies for creating surrogate models that reached up to 98% agreement with the target model. As a second step we used 30 different models (surrogates and targets, including AVs) to generate adversarial malware and compared their evasion capabilities.'
event_name: 'Cybersec & AI 2021'
event_url: 'https://cybersecai.com'
date: '2021-11-05T15:00:00+02:00'
authors:
  - me
  - Sebastian Garcia
aliases:
  - /talk/stealing-malware-classification-models-for-antivirus-evasion/
---
```

- [ ] **Step 5: Create the fourth talk**

`content/events/virus-bulletin-2019/index.md`:

```yaml
---
title: 'Virus Bulletin 2019'
abstract: 'Reports on cyber espionage operations have been on the rise in the last decade. However, operations in Latin America are heavily under researched and potentially underestimated. In this paper we analyse and dissect a cyber espionage tool known as Machete. The results presented in this work are based on the collection, reversing and analysis of Machete samples from 2013 to 2019. Our research shows that Machete is operated by a highly coordinated and organized group that focuses on Latin American targets. We describe the five phases of the APT operations from delivery to exfiltration of information and we show why Machete is considered a cyber espionage tool.'
event_name: 'Virus Bulletin 2019'
location: London, United Kingdom
date: '2019-10-04T00:00:00Z'
authors:
  - Veronica Valeros
  - me
  - Kamila Babayeva
  - Sebastian Garcia
aliases:
  - /talk/virus-bulletin-2019/
---
```

- [ ] **Step 6: Add the section alias so the old list page keeps working**

Add to the front matter of `content/events/_index.md`:

```yaml
aliases:
  - /event/
```

- [ ] **Step 7: Build and verify all four talk URLs resolve**

```bash
PATH="$PWD/node_modules/.bin:$PATH" hugo --gc --minify
./scripts/check-urls.sh | grep -E 'talk/|event/' || echo "all talk URLs OK"
```

Expected: no `MISSING:` lines mentioning `/talk/` or `/event/`. The overall passing count should rise by 5.

- [ ] **Step 8: Commit**

```bash
git add content/events
git commit -m "content: port four talks with aliases to published URLs"
```

---

### Task 6: Port the two blog posts

**Files:**
- Create: `content/blog/hacking-nn-programmatically/index.md`
- Create: `content/blog/scoping-it-out/index.md`
- Delete: `content/blog/{data-visualization,get-started,notebook-onboarding,project-management,second-brain,teach-courses}/`

**Interfaces:**
- Consumes: `~/repos/Mari_website/content/post/hacking-nn-programmatically.md` (153 lines) and `summer-hacakathon-2019.md` (124 lines).
- Produces: two `/blog/<slug>/` pages aliasing their live `/post/` URLs.

- [ ] **Step 1: Remove the starter's demo posts**

```bash
cd ~/repos/mariarigaki.github.io
rm -rf content/blog/data-visualization content/blog/get-started \
       content/blog/notebook-onboarding content/blog/project-management \
       content/blog/second-brain content/blog/teach-courses
ls content/blog/
```

Expected: only `_index.md` remains.

- [ ] **Step 2: Port the first post, body text carried over verbatim**

```bash
mkdir -p content/blog/hacking-nn-programmatically
awk 'c>=2{print} /^---$/{c++}' \
  ~/repos/Mari_website/content/post/hacking-nn-programmatically.md \
  > /tmp/post1-body.md
wc -l /tmp/post1-body.md
```

Then write `content/blog/hacking-nn-programmatically/index.md` with this front matter followed by the contents of `/tmp/post1-body.md`:

```yaml
---
title: 'Changing Weights and Biases Programmatically for "Neural Network Hacking" and more'
date: 2019-11-29T20:17:04+01:00
authors:
  - me
tags:
  - machine-learning
  - security
aliases:
  - /post/hacking-nn-programmatically/
---
```

- [ ] **Step 3: Port the second post**

```bash
mkdir -p content/blog/scoping-it-out
awk 'c>=2{print} /^---$/{c++}' \
  ~/repos/Mari_website/content/post/summer-hacakathon-2019.md \
  > /tmp/post2-body.md
wc -l /tmp/post2-body.md
```

Then write `content/blog/scoping-it-out/index.md` with this front matter followed by the contents of `/tmp/post2-body.md`.

The alias keeps the original misspelling, which is the URL that is actually published:

```yaml
---
title: 'Scoping it out!'
subtitle: 'Using an oscilloscope to perform side-channels'
date: 2019-07-29T13:16:05+02:00
authors:
  - me
tags:
  - side-channels
  - oscilloscope
aliases:
  - /post/summer-hacakathon-2019/
---
```

- [ ] **Step 4: Add the section alias**

Add to the front matter of `content/blog/_index.md`:

```yaml
aliases:
  - /post/
```

- [ ] **Step 5: Check for broken image references carried over from the old posts**

```bash
grep -nE '!\[|\{\{<\s*figure' content/blog/*/index.md
```

Any referenced image must be copied from `~/repos/Mari_website/content/post/` or `~/repos/Mari_website/static/` into the post's own folder, and the reference rewritten to a bare filename. Resolve every hit before moving on.

- [ ] **Step 6: Build and verify**

```bash
PATH="$PWD/node_modules/.bin:$PATH" hugo --gc --minify
./scripts/check-urls.sh | grep '/post/' || echo "all post URLs OK"
```

- [ ] **Step 7: Commit**

```bash
git add content/blog
git commit -m "content: restore the two 2019 blog posts lost in the last migration"
```

---

### Task 7: Port the six published publications

These are already live and externally cited. Getting their aliases right is the
single highest-risk item in this migration.

The four that exist in HugoBlox format are in the **old** Wowchemy schema and must
be upgraded, not just copied: numeric `publication_types`, a string `publication`,
`url_*` fields and `authors: [admin]` are all deprecated in this generation.

**Files:**
- Create: `content/publications/{gan-knife-fight,machete,malware-extraction,meme,out-cage,survey}/index.md`
- Delete: `content/publications/{conference-paper,journal-article,preprint}/`

**Interfaces:**
- Consumes: the sources in the recovery table; the resolved identifier table.
- Produces: six `/publications/<slug>/` pages, each aliasing its live URL, each with a `cite.bib` generated in Task 8.

- [ ] **Step 1: Remove the starter's demo publications**

```bash
cd ~/repos/mariarigaki.github.io
rm -rf content/publications/conference-paper content/publications/journal-article \
       content/publications/preprint
ls content/publications/
```

- [ ] **Step 2: Copy the four that already exist in HugoBlox format**

```bash
SRC=~/repos/mari_website_new/starter-hugo-academic-main/content/publication
for p in malware-extraction meme out-cage survey; do
  cp -r "$SRC/$p" content/publications/
done
rm -f content/publications/*/cite.bib   # stale Scholar-derived citations; regenerated in Task 8
ls content/publications/
```

- [ ] **Step 3: Upgrade each copied entry to the current schema**

For all four, apply these transformations. Keep the existing `abstract`, `tags`,
`featured` and `image` values — they are hand-written and worth preserving.

| Old field | Replace with |
|---|---|
| `authors: [admin, …]` | `authors: [me, …]` |
| `publication_types: ['1']` | `publication_types: ['paper-conference']` |
| `publication_types: ['2']` | `publication_types: ['article-journal']` |
| `publication_types: ['3']` | `publication_types: ['article']` |
| `publication: In *Venue*` (string) | `publication: {name: 'Venue', volume: N, issue: N}` |
| `publication_short` | delete |
| `url_pdf: 'X'` | `links: [{type: pdf, url: 'X'}]` |
| `url_code`/`url_slides`/`url_video`/`url_dataset`/`url_poster`/`url_project`/`url_source` | a `links:` entry of that `type`, or delete if empty |
| `doi: ''` | `hugoblox: {ids: {doi: …}}` from the identifier table |
| `projects: []`, `slides: ""` | delete if empty |

Target state per slug — add `aliases` at the same time:

```yaml
# malware-extraction
publication_types: ['article-journal']
publication:
  name: 'Computers & Security'
  volume: 129
peer_reviewed: true
hugoblox:
  ids:
    doi: 10.1016/j.cose.2023.103192
aliases:
  - /publication/malware-extraction/
```

```yaml
# meme
publication_types: ['paper-conference']
publication:
  name: 'ESORICS 2023'
peer_reviewed: true
hugoblox:
  ids:
    arxiv: 2308.16562
    doi: 10.1007/978-3-031-51482-1_3
aliases:
  - /publication/meme/
```

```yaml
# out-cage  — upgraded from arXiv preprint to the published version
publication_types: ['paper-conference']
publication:
  name: 'International Conference on Agents and Artificial Intelligence (ICAART)'
  volume: 3
  pages: '774--781'
peer_reviewed: true
hugoblox:
  ids:
    doi: 10.5220/0012391800003636
aliases:
  - /publication/out-cage/
```

```yaml
# survey
publication_types: ['article-journal']
publication:
  name: 'ACM Computing Surveys'
  volume: 56
  issue: 4
peer_reviewed: true
hugoblox:
  ids:
    doi: 10.1145/3624010
aliases:
  - /publication/survey/
```

`out-cage` is the only one whose meaning changes: it is currently presented as a
preprint but was published at ICAART 2024. Keep any existing arXiv PDF link as a
`links: [{type: pdf}]` entry so the open-access copy stays reachable.

- [ ] **Step 4: Port the two older papers from the Academic-format source**

Both live at doubled paths on the live site; the aliases must match exactly.

`content/publications/gan-knife-fight/index.md`:

```yaml
---
title: 'Bringing a GAN to a Knife-fight: Adapting Malware Communication to Avoid Detection'
authors:
  - me
  - Sebastian Garcia
date: '2018-05-24T00:00:00Z'
publication_types: ['paper-conference']
publication:
  name: 'IEEE Security and Privacy Workshops (SPW)'
peer_reviewed: true
hugoblox:
  ids:
    doi: 10.1109/spw.2018.00019
aliases:
  - /publication/gan-fight/gan-knife-fight/
---
```

`content/publications/machete/index.md`:

```yaml
---
title: 'Machete: Dissecting the Operations of a Cyber Espionage Group in Latin America'
authors:
  - Veronica Valeros
  - me
  - Sebastian Garcia
date: '2019-06-20T00:00:00Z'
publication_types: ['paper-conference']
publication:
  name: 'IEEE European Symposium on Security and Privacy Workshops (EuroS&PW)'
  pages: '464--473'
peer_reviewed: true
hugoblox:
  ids:
    doi: 10.1109/eurospw.2019.00058
links:
  - type: pdf
    url: 'https://ieeexplore.ieee.org/abstract/document/8802467'
aliases:
  - /publication/machete/machete/
---
```

Copy `abstract` and `tags` verbatim from
`~/repos/Mari_website/content/publication/gan-knife-fight.md` and `machete.md`.
Note Machete has **three** authors here; the Virus Bulletin talk in Task 5 has four
and is a separate output — do not reconcile them.

- [ ] **Step 5: Add the section alias**

Add to the front matter of `content/publications/_index.md`:

```yaml
aliases:
  - /publication/
```

- [ ] **Step 6: Confirm no deprecated fields survive**

```bash
grep -rnE "^\s*(url_pdf|url_code|url_slides|url_video|url_dataset|url_poster|url_project|url_source|publication_short|external_link):" content/publications/ \
  && echo "STOP: deprecated fields remain" || echo "schema clean"
grep -rn "publication_types: \['[0-9]'\]" content/publications/ \
  && echo "STOP: numeric publication types remain" || echo "types clean"
```

Expected: both report clean. The module emits deprecation warnings for the `url_*`
fields, so a noisy build here means the upgrade was incomplete.

- [ ] **Step 7: Build and verify every publication URL resolves**

```bash
PATH="$PWD/node_modules/.bin:$PATH" hugo --gc --minify 2>&1 | grep -i "deprecat" || echo "no deprecation warnings"
./scripts/check-urls.sh | grep '/publication' || echo "all publication URLs OK"
```

Expected: no MISSING lines for any `/publication/...` path, including the two
doubled ones.

- [ ] **Step 8: Commit**

```bash
git add content/publications
git commit -m "content: port six published papers, upgrade schema, preserve URLs"
```

---

### Task 8: Dissertation and the five newer papers

No longer blocked — `citations` supplies the list and the identifiers are resolved
above. Still needs the dissertation defence date from Maria.

**Files:**
- Create: `scripts/fetch-citations.py`
- Create: `content/publications/{prompt-exploit-repeat,adaptive-cyber-agents,alquistcoder,hackphyr,evaluating-generalization,dissertation}/index.md`
- Create: `content/publications/*/cite.bib` for all eleven papers
- Create: `static/uploads/dissertation.pdf`

**Interfaces:**
- Consumes: the resolved identifier table; `~/repos/thesis/main.pdf`; PDFs in `~/Documents/research/dissertation/my_papers/`.
- Produces: eleven publication pages plus the dissertation. No aliases — these URLs are new.

- [ ] **Step 1: Write the citation fetcher**

`scripts/fetch-citations.py`:

```python
#!/usr/bin/env python3
"""Fetch publisher-authoritative BibTeX from a DOI into each publication's cite.bib.

Crossref content negotiation returns the publisher's own record, which is more
accurate than a Google Scholar export. Papers without a DOI are skipped.
"""
import pathlib, sys, time, urllib.request

DOIS = {
    "gan-knife-fight":      "10.1109/spw.2018.00019",
    "machete":              "10.1109/eurospw.2019.00058",
    "survey":               "10.1145/3624010",
    "malware-extraction":   "10.1016/j.cose.2023.103192",
    "meme":                 "10.1007/978-3-031-51482-1_3",
    "out-cage":             "10.5220/0012391800003636",
    "prompt-exploit-repeat": "10.1007/978-3-031-87330-0_2",
    "adaptive-cyber-agents": "10.1016/j.eswa.2025.129987",
    "alquistcoder":         "10.1111/coin.70282",
    # hackphyr and evaluating-generalization are preprints with no DOI.
}

root = pathlib.Path("content/publications")
failures = []

for slug, doi in DOIS.items():
    folder = root / slug
    if not folder.is_dir():
        print(f"SKIP  {slug}: folder does not exist yet")
        continue
    req = urllib.request.Request(
        f"https://doi.org/{doi}",
        headers={"Accept": "application/x-bibtex",
                 "User-Agent": "mariarigaki.github.io citation fetcher"},
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            bib = r.read().decode("utf-8").strip()
    except Exception as e:
        print(f"FAIL  {slug}: {e}")
        failures.append(slug)
        continue
    if not bib.startswith("@"):
        print(f"FAIL  {slug}: response is not BibTeX")
        failures.append(slug)
        continue
    (folder / "cite.bib").write_text(bib + "\n")
    print(f"OK    {slug}: {len(bib)} bytes")
    time.sleep(0.5)

sys.exit(1 if failures else 0)
```

- [ ] **Step 2: Hand-write `cite.bib` for the two preprints**

No DOI means no Crossref record. `content/publications/hackphyr/cite.bib`:

```bibtex
@misc{rigaki2024hackphyr,
  title         = {Hackphyr: A Local Fine-Tuned LLM Agent for Network Security Environments},
  author        = {Rigaki, Maria and Catania, Carlos and Garcia, Sebastian},
  year          = {2024},
  eprint        = {2409.11276},
  archivePrefix = {arXiv},
  primaryClass  = {cs.CR}
}
```

`content/publications/evaluating-generalization/cite.bib`:

```bibtex
@misc{lukas2026evaluating,
  title         = {Evaluating Generalization Mechanisms in Autonomous Cyber Attack Agents},
  author        = {Luk{\'a}{\v{s}}, Ond{\v{r}}ej and Shin, Jihoon and Rivas, Emilia and
                   Forni, Diego and Rigaki, Maria and Catania, Carlos and Piplai, Aritran and
                   Kiekintveld, Christopher and Garcia, Sebastian},
  year          = {2026},
  eprint        = {2603.10041},
  archivePrefix = {arXiv},
  primaryClass  = {cs.CR}
}
```

- [ ] **Step 3: Create the three newly-published papers**

`content/publications/prompt-exploit-repeat/index.md`:

```yaml
---
title: 'Prompt. Exploit. Repeat: Automating Network Security Testing with LLMs'
authors:
  - me
  - Ondřej Lukáš
  - Carlos Catania
  - Sebastian Garcia
date: '2024-01-01T00:00:00Z'
publication_types: ['paper-conference']
publication:
  name: 'International Conference on Agents and Artificial Intelligence (ICAART)'
  pages: '15--36'
peer_reviewed: true
hugoblox:
  ids:
    doi: 10.1007/978-3-031-87330-0_2
abstract: ''
---
```

`content/publications/adaptive-cyber-agents/index.md`:

```yaml
---
title: 'Building Adaptative and Transparent Cyber Agents with Local Language Models'
authors:
  - me
  - Carlos A. Catania
  - Sebastian Garcia
date: '2026-03-01T00:00:00Z'
publication_types: ['article-journal']
publication:
  name: 'Expert Systems with Applications'
  volume: 299
peer_reviewed: true
hugoblox:
  ids:
    doi: 10.1016/j.eswa.2025.129987
abstract: ''
---
```

Note the date is **2026**, per the publisher record, not the 2025 in `citations`.

`content/publications/alquistcoder/index.md`:

```yaml
---
title: 'AlquistCoder: A Synthetic Data Approach to Training Compact Secure Coding Assistants and Building Security Benchmarks'
authors:
  - Ondřej Kobza
  - Adam Černý
  - Ivan Dostál
  - Jan Šedivý
  - me
  - Muris Sladić
  - Sebastian Garcia
date: '2026-01-01T00:00:00Z'
publication_types: ['article-journal']
publication:
  name: 'Computational Intelligence'
  volume: 42
  issue: 4
peer_reviewed: true
hugoblox:
  ids:
    doi: 10.1111/coin.70282
abstract: ''
---
```

- [ ] **Step 4: Create the two preprints**

`content/publications/hackphyr/index.md`:

```yaml
---
title: 'Hackphyr: A Local Fine-Tuned LLM Agent for Network Security Environments'
authors:
  - me
  - Carlos Catania
  - Sebastian Garcia
date: '2024-09-17T00:00:00Z'
publication_types: ['article']
publication:
  name: 'arXiv preprint'
peer_reviewed: false
hugoblox:
  ids:
    arxiv: 2409.11276
links:
  - type: pdf
    url: https://arxiv.org/pdf/2409.11276
abstract: ''
---
```

`content/publications/evaluating-generalization/index.md`:

```yaml
---
title: 'Evaluating Generalization Mechanisms in Autonomous Cyber Attack Agents'
authors:
  - Ondřej Lukáš
  - Jihoon Shin
  - Emilia Rivas
  - Diego Forni
  - me
  - Carlos Catania
  - Aritran Piplai
  - Christopher Kiekintveld
  - Sebastian Garcia
date: '2026-03-01T00:00:00Z'
publication_types: ['article']
publication:
  name: 'arXiv preprint'
peer_reviewed: false
hugoblox:
  ids:
    arxiv: 2603.10041
links:
  - type: pdf
    url: https://arxiv.org/pdf/2603.10041
abstract: ''
---
```

- [ ] **Step 5: Fill in the abstracts**

Every `abstract: ''` above must be filled before the site goes live. Sources, in
order of preference:

1. **arXiv** for the two preprints and any paper with an arXiv version. The API
   endpoint `export.arxiv.org/api/query` does not respond from this machine, but
   the abstract page does:

```bash
curl -s https://arxiv.org/abs/2409.11276 \
  | python3 -c "import sys,re,html; s=sys.stdin.read(); \
      m=re.search(r'<blockquote class=\"abstract[^\"]*\">(.*?)</blockquote>',s,re.S); \
      print(' '.join(html.unescape(re.sub(r'<[^>]+>','',m.group(1))).split()))"
```

2. **The PDFs** in `~/Documents/research/dissertation/my_papers/` — `Local_LLM_Agents_Rigaki_etal.pdf`, `prompt_exploit_official.pdf`, `adaptive_cyberagents.pdf`.
3. Crossref carries abstracts for only some of these publishers; do not rely on it.

Copy the abstract as published. Do not paraphrase or summarise.

- [ ] **Step 6: Add the dissertation**

```bash
cd ~/repos/mariarigaki.github.io
cp ~/repos/thesis/main.pdf static/uploads/dissertation.pdf
mkdir -p content/publications/dissertation
```

`content/publications/dissertation/index.md`:

```yaml
---
title: 'Offensive Applications of Machine Learning in Cybersecurity'
authors:
  - me
date: '2025-01-01T00:00:00Z'
publication_types: ['thesis']
publication:
  name: 'PhD Dissertation, Czech Technical University in Prague'
featured: true
links:
  - type: pdf
    url: /uploads/dissertation.pdf
abstract: ''
---
```

The `date` is a placeholder. Get the actual defence date from Maria, and take the
abstract from the front matter of `~/repos/thesis/main.tex`.

- [ ] **Step 7: Generate every cite.bib and confirm**

```bash
python3 scripts/fetch-citations.py
ls content/publications/*/cite.bib | wc -l
head -3 content/publications/meme/cite.bib
```

Expected: exit 0, and 11 `cite.bib` files (9 fetched + 2 hand-written). The
dissertation has no `cite.bib`.

- [ ] **Step 8: Build and confirm nothing regressed**

```bash
PATH="$PWD/node_modules/.bin:$PATH" hugo --gc --minify
./scripts/check-urls.sh
grep -rn "abstract: ''" content/publications/ && echo "STOP: abstracts still empty" || echo "abstracts filled"
```

Expected: the URL check still passes with the same count as after Task 7, and no
empty abstracts remain.

- [ ] **Step 9: Verify the Cite and DOI buttons actually render**

```bash
grep -o 'cite.bib' public/publications/meme/index.html | head -1
grep -o 'doi.org/10.1007[^"]*' public/publications/meme/index.html | head -1
grep -o 'arxiv.org/abs/2409.11276' public/publications/hackphyr/index.html | head -1
```

Expected: one hit each — Cite on a published paper, a DOI link, and a Preprint
link on the arXiv-only paper.

- [ ] **Step 10: Commit**

```bash
git add scripts/fetch-citations.py content/publications static/uploads
git commit -m "content: add dissertation and five newer papers with official citations"
```

---

### Task 9: Experience page and final CV

**Files:**
- Modify: `data/authors/me.yaml` (the `experience:` list — the `/experience/` page is generated from it, there is no separate content file)
- Replace: `static/uploads/cv.pdf`

- [ ] **Step 1: Swap in the real CV once Maria supplies it**

```bash
cd ~/repos/mariarigaki.github.io
cp /path/to/new-cv.pdf static/uploads/cv.pdf
pdfinfo static/uploads/cv.pdf | grep -i pages
```

Expected: more than the 1 page of the April 2022 placeholder.

- [ ] **Step 2: Confirm the CV link in the nav resolves**

```bash
PATH="$PWD/node_modules/.bin:$PATH" hugo --gc --minify
ls -la public/uploads/cv.pdf
```

- [ ] **Step 3: Commit**

```bash
git add static/uploads/cv.pdf
git commit -m "content: update CV"
```

---

### Task 10: Deployment workflow

**Files:**
- Create: `.github/workflows/deploy.yml`
- Delete: `netlify.toml`

**Interfaces:**
- Produces: a Pages deployment on every push to `main`.

- [ ] **Step 1: Remove the Netlify config, which does not apply here**

```bash
cd ~/repos/mariarigaki.github.io
rm -f netlify.toml
```

- [ ] **Step 2: Write the workflow**

`.github/workflows/deploy.yml`:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    env:
      HUGO_VERSION: 0.166.0
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: actions/setup-go@v5
        with:
          go-version: '1.22'

      - uses: pnpm/action-setup@v4
        with:
          version: 10.14.0

      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: pnpm

      - name: Install Hugo
        run: |
          curl -sSL -o hugo.tar.gz \
            "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"
          tar xzf hugo.tar.gz hugo
          sudo mv hugo /usr/local/bin/
          hugo version

      - run: pnpm install --frozen-lockfile

      - uses: actions/configure-pages@v5

      - name: Build
        env:
          HUGO_ENVIRONMENT: production
        run: |
          PATH="$PWD/node_modules/.bin:$PATH" \
            hugo --gc --minify --baseURL "https://mariarigaki.github.io/"

      - name: Build search index
        run: pnpm exec pagefind --site public

      - uses: actions/upload-pages-artifact@v3
        with:
          path: ./public

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - id: deployment
        uses: actions/deploy-pages@v4
```

- [ ] **Step 3: Commit and push the branch**

```bash
git add .github/workflows/deploy.yml
git rm --cached netlify.toml 2>/dev/null || true
git commit -m "ci: build and deploy to Pages via GitHub Actions"
git push -u origin main
```

- [ ] **Step 4: Confirm the workflow ran green before touching Pages settings**

```bash
gh run list --branch main --limit 3
gh run watch
```

Expected: the build job succeeds. The deploy job will fail until Pages is switched in Task 12 — that is expected at this point.

---

### Task 11: Full URL parity verification

**Files:**
- Uses: `scripts/check-urls.sh`, `scripts/expected-urls.txt`

- [ ] **Step 1: Clean build from scratch**

```bash
cd ~/repos/mariarigaki.github.io
rm -rf public resources .hugo_build.lock
PATH="$PWD/node_modules/.bin:$PATH" hugo --gc --minify
```

- [ ] **Step 2: Run the parity check — this must pass**

```bash
./scripts/check-urls.sh
```

Expected: `45/45 expected URLs resolve` and exit code 0. Do not proceed to cutover on any failure.

- [ ] **Step 3: Spot-check that aliases are real redirects, not empty files**

```bash
cat public/publication/meme/index.html | grep -i 'refresh\|canonical'
cat public/talk/virus-bulletin-2019/index.html | grep -i 'refresh'
```

Expected: each contains a meta-refresh redirect pointing at the new path.

- [ ] **Step 4: Review the site by eye**

```bash
PATH="$PWD/node_modules/.bin:$PATH" hugo server
```

Open http://localhost:1313/ and confirm: bio reads "Post-doctoral Researcher"; papers, talks and blog sections are populated; no Wowchemy demo content anywhere; nav has no dead links.

- [ ] **Step 5: Commit any fixes**

```bash
git add -A && git commit -m "fix: URL parity corrections" && git push
```

---

### Task 12: Cutover

**Interfaces:**
- Consumes: a green Task 11.
- Produces: the new site live at https://mariarigaki.github.io/.

- [ ] **Step 1: Make `main` the default branch**

```bash
gh repo edit MariaRigaki/mariarigaki.github.io --default-branch main
```

- [ ] **Step 2: Switch Pages from legacy branch build to GitHub Actions**

```bash
gh api -X POST repos/MariaRigaki/mariarigaki.github.io/pages/builds 2>/dev/null || true
gh api -X PUT repos/MariaRigaki/mariarigaki.github.io/pages \
  -f build_type=workflow
gh api repos/MariaRigaki/mariarigaki.github.io/pages --jq '{build_type, source, status}'
```

Expected: `build_type: workflow`.

- [ ] **Step 3: Trigger a deploy and wait**

```bash
gh workflow run "Deploy to GitHub Pages" --ref main
gh run watch
```

- [ ] **Step 4: Verify every published URL against the live site, not a local build**

```bash
fail=0
while read -r url; do
  code=$(curl -s -o /dev/null -w "%{http_code}" -L "https://mariarigaki.github.io${url}")
  [ "$code" = "200" ] || { echo "BROKEN $code $url"; fail=$((fail+1)); }
done < ~/repos/mariarigaki.github.io/scripts/expected-urls.txt
echo "broken: $fail"
```

Expected: `broken: 0`. Note `-L` follows the alias redirects, which is the behaviour a real visitor gets.

- [ ] **Step 5: If anything is broken, roll back**

```bash
gh api -X PUT repos/MariaRigaki/mariarigaki.github.io/pages \
  -f build_type=legacy -f 'source[branch]=archive/rendered-2024' -f 'source[path]=/'
```

Then fix forward on `main` without time pressure.

---

### Task 13: Cleanup

Only after Task 12 verifies clean. Confirm each deletion with Maria first.

- [ ] **Step 1: Confirm the backup is still good**

```bash
tar tzf ~/backups/website-sources-2026-09-16.tar.gz | wc -l
```

- [ ] **Step 2: Move the obsolete folders aside rather than deleting them**

```bash
mkdir -p ~/repos/_archived-2026-09
mv ~/repos/Mari_website ~/repos/Mari_website_bak ~/repos/mari_website_new \
   ~/repos/_archived-2026-09/
ls ~/repos/_archived-2026-09/
```

- [ ] **Step 3: Confirm the live site still builds and deploys from the new repo alone**

```bash
cd ~/repos/mariarigaki.github.io
rm -rf public resources
PATH="$PWD/node_modules/.bin:$PATH" hugo --gc --minify
./scripts/check-urls.sh
```

Expected: PASS with nothing outside `~/repos/mariarigaki.github.io` referenced.

- [ ] **Step 4: Record how to publish, for future Maria**

Add to `README.md`:

```markdown
# mariarigaki.github.io

Hugo source for https://mariarigaki.github.io/ — HugoBlox `academic-cv`.

## Writing

    pnpm install        # first time only
    hugo server         # http://localhost:1313

New blog post: create `content/blog/<slug>/index.md`.

New paper: create `content/publications/<slug>/index.md` with the venue in
`publication:` and the DOI under `hugoblox.ids.doi`, add the DOI to
`scripts/fetch-citations.py`, then run

    python3 scripts/fetch-citations.py

which writes the publisher's official BibTeX to that paper's `cite.bib`. Do not
paste a Google Scholar export as the citation — Scholar mangles author names,
title case and sometimes the year.

## Publishing

Push to `main`. GitHub Actions builds and deploys. Nothing else to do.

## Before changing URLs

Run `./scripts/check-urls.sh` after a build. It verifies that every URL the
site published as of September 2026 still resolves. Add an `aliases:` entry
rather than letting a published URL 404.
```

- [ ] **Step 5: Commit**

```bash
git add README.md && git commit -m "docs: how to write and publish" && git push
```
