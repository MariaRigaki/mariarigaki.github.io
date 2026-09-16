---
title: "The Power of MEME: Adversarial Malware Creation with Model-Based Reinforcement Learning"

# Authors
# If you created a profile for a user (e.g. the default `me` user), write the username (folder name) here
# and it will be replaced with their full name and linked to their profile.
authors:
  - me
  - Sebastian Garcia

date: '2023-08-31T00:00:00Z'

# Schedule page publish date (NOT publication's date).
publishDate: '2023-08-31T00:00:00Z'

# Publication type.
# Accepts a single type but formatted as a YAML list (for Hugo requirements).
# Enter a publication type from the CSL standard.
publication_types: ['paper-conference']

# Publication metadata — structured fields used by citation styles and BibTeX export.
publication:
  name: 'ESORICS 2023'

peer_reviewed: true

# Standard identifiers for auto-linking
hugoblox:
  ids:
    arxiv: 2308.16562
    doi: 10.1007/978-3-031-51482-1_3

abstract: Due to the proliferation of malware, defenders are increasingly turning to automation and machine learning as part of the malware detection tool-chain. However, machine learning models are susceptible to adversarial attacks, requiring the testing of model and product robustness. Meanwhile, attackers also seek to automate malware generation and evasion of antivirus systems, and defenders try to gain insight into their methods. This work proposes a new algorithm that combines Malware Evasion and Model Extraction (MEME) attacks. MEME uses model-based reinforcement learning to adversarially modify Windows executable binary samples while simultaneously training a surrogate model with a high agreement with the target model to evade. To evaluate this method, we compare it with two state-of-the-art attacks in adversarial malware creation, using three well-known published models and one antivirus product as targets. Results show that MEME outperforms the state-of-the-art methods in terms of evasion capabilities in almost all cases, producing evasive malware with an evasion rate in the range of 32-73%. It also produces surrogate models with a prediction label agreement with the respective target models between 97-99%. The surrogate could be used to fine-tune and improve the evasion rate in the future. 

# Summary. An optional shortened abstract.
summary: ''

tags:
- Malware
- Reinforcement Learning
- Model extraction

# Display this page in the Featured widget?
featured: true

# Custom links
links:
- type: pdf
  url: 'https://arxiv.org/pdf/2308.16562.pdf'

# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder.
image:
  caption: 'Image credit: [**Unsplash**](https://unsplash.com/photos/pLCdAaMFLTE)'
  focal_point: ''
  preview_only: false

# Associated Projects (optional).
#   Associate this publication with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `internal-project` references `content/projects/internal-project/index.md`.
#   Otherwise, set `projects: []`.
projects: []

aliases:
  - /publication/meme/
---
