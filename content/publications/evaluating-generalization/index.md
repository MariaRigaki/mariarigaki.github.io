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
abstract: 'Autonomous offensive agents often fail to transfer beyond the networks on which they are trained. We isolate a minimal but fundamental shift -- unseen host/subnet IP reassignment in an otherwise fixed enterprise scenario -- and evaluate attacker generalization in the NetSecGame environment. Agents are trained on five IP-range variants and tested on a sixth unseen variant; only the meta-learning agent may adapt at test time. We compare three agent families (traditional RL, adaptation agents, and LLM-based agents) and use action-distribution-based behavioral/XAI analyses to localize failure modes. Some adaptation methods show partial transfer but significant degradation under unseen reassignment, indicating that even address-space changes can break long-horizon attack policies. Under our evaluation protocol and agent-specific assumptions, prompt-driven pretrained LLM agents achieve the highest success on the held-out reassignment, but at the cost of increased inference-time compute, reduced transparency, and practical failure modes such as repetition/invalid-action loops.'
---
