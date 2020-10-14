+++
title = "AMD Radeon RX 5000 Series Freezing on Ubuntu 20.04 LTS"
date = 2020-10-13T22:17:24-04:00
images = []
tags = []
categories = []
draft = false
+++

I have a new desktop computer, complete with a Radeon RX 5600 XT GPU. As a linux user, I immediately installed Pop!_OS 20.04 on it as soon as it was built. However, I found that the system would randomly freeze:

- Logging into a new session would sometimes freeze the system for 10+ seconds
- Opening Firefox for the first time after a fresh boot would reliably freeze the system for 10+ seconds
- Opening Google Maps in Firefox would sometimes freeze the system indefinitely
- The system would sometimes display a black screen when resuming from sleep
- Sometimes glitching/artifacting would happen after resuming from sleep
- HDMI audio would sometimes stop working until a reboot

After trying unsuccessfully to debug using `syslog` and `dmesg` for a few days, I updated the Linux kernel. Lo and behold! All the abovementioned problems were gone. I suspect that the issues have to do with the kernel-level drivers for the AMD GPU. The linux version that ships with Ubuntu 20.04 (and all derivatives thereof) is 5.4, whereas I'm currently running 5.9.0. 

**If you experience any of the freezes listed above, try updating the Linux kernel.**

## How to Update the Kernel

In order to update to the latest kernel, I used the handy tool [Mainline](https://github.com/bkw777/mainline). You can install either [via PPA](https://code.launchpad.net/~cappelikan/+archive/ubuntu/ppa) or by building from source. [As this tutorial instructs](https://linuxhint.com/update_ubuntu_kernel_20_04/), on Ubuntu 20.04 LTS, Mainline should get you all the way there. [Unfortunately, with Pop!_OS, we have to manually make a `systemd-boot` entry.](https://frank.kumro.io/installing-a-mainline-kernel-on-popos/)

## Links

Links describing the issue with Google Maps:
- https://community.amd.com/thread/250909
- https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1875459
- https://www.reddit.com/r/linuxhardware/comments/fur8so/system_freezes_when_gaming_or_using_google_maps/

Links describing other freezing issues:
- https://bbs.archlinux.org/viewtopic.php?id=254283
