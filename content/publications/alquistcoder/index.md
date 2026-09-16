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
abstract: 'The widespread adoption of large language models (LLMs) for code generation has introduced significant security risks, as these models relatively frequently produce code containing exploitable vulnerabilities and can be manipulated into assisting with malicious tasks. Existing mitigation strategies range from general-purpose alignment of large-scale models to post-generation filtering and repair, yet even state-of-the-art models such as GPT-4 produce vulnerable code at substantial rates in security-critical contexts, and the extent to which security hardening degrades general coding utility remains an open question. This paper investigates whether a modular architecture separating Intent Recognition from code generation, combined with constitution-driven synthetic training data targeting specific vulnerability classes, can substantially enhance the security of a compact model while retaining competitive practical utility. We propose AlquistCoder, a 3.8 B-parameter secure coding assistant coupling a Phi-4-mini–based coding model with a ModernBERT-based input-side Intent Recognition classifier, trained using a novel synthetic data framework (Design–Amplify–Refine). We evaluate AlquistCoder on both established benchmarks (CyberSecEval, HumanEval) and two novel instruments we develop concurrently—VulnBench and MalBench—to address critical gaps in assessing hard secure-coding scenarios and multi-turn adversarial manipulation, respectively. Results show a 3–5× reduction in vulnerability rates relative to Qwen3, Gemma3, and GPT-4, the lowest malicious assistance rates among all compared models, and competitive functional correctness (HumanEval pass@1 of 77.44). All models, datasets, and benchmarks are publicly released.'
---
