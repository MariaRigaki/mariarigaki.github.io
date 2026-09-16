---
title: 'Bringing a GAN to a Knife-fight: Adapting Malware Communication to Avoid Detection'
authors:
  - me
  - Sebastian Garcia
date: '2018-05-24T00:00:00Z'
publication_types: ['paper-conference']
publication:
  name: 'IEEE Security and Privacy Workshops (SPW)'
  pages: '70--75'
peer_reviewed: true
hugoblox:
  ids:
    doi: 10.1109/spw.2018.00019
links:
  - type: pdf
    url: 'https://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=8424635'
abstract: 'Generative Adversarial Networks (GANs) have been successfully used in a large number of domains. This paper proposes the use of GANs for generating network traffic in order to mimic other types of traffic. In particular, our method modifies the network behavior of a real malware in order to mimic the traffic of a legitimate application, and therefore avoid detection. By modifying the source code of a malware to receive parameters from a GAN, it was possible to adapt the behavior of its Command and Control (C2) channel to mimic the behavior of Facebook chat network traffic. In this way, it was possible to avoid the detection of new-generation Intrusion Prevention Systems that use machine learning and behavioral characteristics. A real-life scenario was successfully implemented using the Stratosphere behavioral IPS in a router, while the malware and the GAN were deployed in the local network of our laboratory, and the C2 server was deployed in the cloud. Results show that a GAN can successfully modify the traffic of a malware to make it undetectable. The modified malware also tested if it was being blocked and used this information as a feedback to the GAN. This work envisions the possibility of self-adapting malware and self-adapting IPS.'
tags:
  - GAN
  - intrusion detection
aliases:
  - /publication/gan-knife-fight/
  - /publication/gan-fight/gan-knife-fight/
---
