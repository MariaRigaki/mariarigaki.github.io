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
