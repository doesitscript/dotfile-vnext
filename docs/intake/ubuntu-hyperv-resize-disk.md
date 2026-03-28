# How to expand Ubuntu disk inside Virtual Machines

## For two times in my life I struggled to find a way to increase Ubuntu LVM disk size inside virtual machines (Hyper-V and WSL2). Maybe these solution works for you.

[![Gustavo Gondim](https://miro.medium.com/v2/resize:fill:64:64/1*YMmVLT0xa4h20BnwK0mlmw.jpeg)

](/@ggondim?source=post_page---byline--f31e667cbf04---------------------------------------)[Gustavo Gondim](/@ggondim?source=post_page---byline--f31e667cbf04---------------------------------------)

Follow

2 min read·

Feb 9, 2023

7

Listen

Share

More

![](https://miro.medium.com/v2/resize:fit:1256/1*kIjwdfp4R5vpgF4r1psuWA.png)

If your df -h command is resulting a 100% use like this picture, you should try this article.
## TL;DR

$ sudo lvmdiskscan
$ sudo growpart /dev/sda 3
$ sudo pvresize /dev/sda3
$ sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
$ sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv
$ df -h
## 1. If you have a Hyper-V virtual machine (maybe also applicable to VirtualBox or VMware)

### Increase the physical disk file (VHDX or VDI)

In Hyper-V, follow these steps:

1. Shutdown the virtual machine
* In Hyper-V Manager go to Settings → select the hard drive → Edit. If this option is disabled, delete any checkpoints for the VM.
* Select the Expand operation and increase to a desirable size.
* Turn on the VM again and follow the next step

### Find your /sda/dev device

1. Inside VM’s terminal, find the right /sda/dev device with command:

$ sudo lvmdiskscanThe result is something like this:

![](https://miro.medium.com/v2/resize:fit:912/1*KufyIxwrswcrcUSUPTCUEA.png)

You are looking to device at the first column where the third column is named “LVM physical volume”. Note down the number after “/dev/sda” (in this example is “3”.

2. Run the following commands replacing the device number you found above:

$ sudo growpart /dev/sda 3
$ sudo pvresize /dev/sda3I think growpart is a CLI from cloud-guest-utils. So, maybe you need sudo apt install cloud-guest-utils first.

Now follow the steps below.

## 2. If you already had increased physical disk space OR you have a WSL2 subsystem

Run the commands:

$ sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
$ sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv
## Now list storage devices again and be happy 😛

$ df -hPress enter or click to view image in full size![](https://miro.medium.com/v2/resize:fit:1248/1*EkibiC7EfpgLuGA5feGF-g.png)

[Hyper V

](/tag/hyper-v?source=post_page-----f31e667cbf04---------------------------------------)[Ubuntu Vm

](/tag/ubuntu-vm?source=post_page-----f31e667cbf04---------------------------------------)[Ubuntu

](/tag/ubuntu?source=post_page-----f31e667cbf04---------------------------------------)[Lvm

](/tag/lvm?source=post_page-----f31e667cbf04---------------------------------------)[Wsl

](/tag/wsl?source=post_page-----f31e667cbf04---------------------------------------)

7

7

[![GGondim](https://miro.medium.com/v2/resize:fill:96:96/1*bf9_uNbm2i3TDd1HaDpGFg.jpeg)

](https://medium.com/ggondim?source=post_page---post_publication_info--f31e667cbf04---------------------------------------)[![GGondim](https://miro.medium.com/v2/resize:fill:128:128/1*bf9_uNbm2i3TDd1HaDpGFg.jpeg)

](https://medium.com/ggondim?source=post_page---post_publication_info--f31e667cbf04---------------------------------------)Follow

[
## Published in GGondim

](https://medium.com/ggondim?source=post_page---post_publication_info--f31e667cbf04---------------------------------------)[2 followers](/ggondim/followers?source=post_page---post_publication_info--f31e667cbf04---------------------------------------)

·[Last published&nbsp;Sep 25, 2024](/ggondim/guia-para-um-design-de-produto-eficiente-06a212cee2c8?source=post_page---post_publication_info--f31e667cbf04---------------------------------------)

teste

Follow

[![Gustavo Gondim](https://miro.medium.com/v2/resize:fill:96:96/1*YMmVLT0xa4h20BnwK0mlmw.jpeg)

](/@ggondim?source=post_page---post_author_info--f31e667cbf04---------------------------------------)[![Gustavo Gondim](https://miro.medium.com/v2/resize:fill:128:128/1*YMmVLT0xa4h20BnwK0mlmw.jpeg)

](/@ggondim?source=post_page---post_author_info--f31e667cbf04---------------------------------------)Follow

[
## Written by Gustavo Gondim

](/@ggondim?source=post_page---post_author_info--f31e667cbf04---------------------------------------)[211 followers](/@ggondim/followers?source=post_page---post_author_info--f31e667cbf04---------------------------------------)

·[149 following](/@ggondim/following?source=post_page---post_author_info--f31e667cbf04---------------------------------------)

Produtos digitais e tecnologia ∴ Diretor @Eletromidia | Cofundador @NOALVO

Follow
