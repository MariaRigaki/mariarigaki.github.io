---
title: 'Offensive Applications of Machine Learning in Cybersecurity'
authors:
  - me
date: '2025-12-05T00:00:00Z'
publishDate: '2025-12-05T00:00:00Z'
publication_types: ['thesis']
publication:
  name: 'PhD Dissertation, Czech Technical University in Prague'
featured: true
links:
  - type: pdf
    url: /uploads/dissertation.pdf
abstract: 'As artificial intelligence and machine learning become deeply embedded in security-critical systems, their dual-use nature raises questions about how these technologies can be used by adversaries. This thesis explores the offensive applications of machine learning and artificial intelligence in cybersecurity, focusing on how adversaries can exploit such technologies to evade detection and execute complex attacks. It addresses two complementary challenges: the evasion of malware detection systems and the use of large language models (LLMs) as autonomous planning agents in network security environments.

  The first part of the thesis investigates the evasion of static malware machine learning classifiers and antivirus engines through model extraction attacks. By leveraging active learning and transfer learning, surrogate models are constructed to approximate black-box target detectors under budget-constrained queries. These surrogates are then used to generate evasive malware samples that maintain functionality while bypassing detection. We introduce MEME, a novel algorithm that unifies model extraction and malware evasion into a single, efficient algorithm. We evaluate the ability of the surrogate models and MEME to evade several malware classifiers and AV products and demonstrate that attackers can produce evasive malware using query-efficient strategies.

  The second part of the thesis examines the offensive use of LLMs as autonomous agents in simulated network environments. We present an extension of the ReAct [1] agentic architecture (ReAct+), which enables pre-trained LLMs to perform multi-step planning and execute realistic attack sequences in adversarial simulations. To address the limitations of cloud-based models, we develop Hackphyr, a fine-tuned open-weight model capable of running locally with competitive performance. We evaluate these LLM-based agents in two security environments, NetSecGame and Microsoft CyberBattleSim, and analyze their behavior against traditional RL agents and known attack patterns. Our findings demonstrate the viability of LLMs in decision-making tasks in the cybersecurity domain.

  By combining practical offensive techniques with a focus on real-world applicability and limitations, this thesis aims to deepen the understanding of emerging threats in AI-driven cybersecurity.'
---
