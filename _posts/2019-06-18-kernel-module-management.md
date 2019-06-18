---
layout: post
title: "Kernel Module Management"
date: 2019-06-18 10:00:00 +0600
tags: linux modprobe lsmod depmod insmod rmmod
---

# Introduction
Loadable Kernel Modules are object files with __.ko__ extension which extends the capabilities of kernel. These modules
can be loaded while kernel is running and can be removed when no longer needed. Usually hardware drivers are provided as
kernel modules and loaded only those modules required by current machine's hardware. `modprobe` command is used for
loading and unloading of modules.

# List Loaded and Installed Modules
List of currently loaded modules is found in `/proc/modules` file. `lsmod` command is wrapper around that file which
prints list of currently loaded modules.

{% highlight shell %}
$ lsmod
Module                  Size  Used by
lp                     20480  0
parport                49152  3 lp,parport_pc,ppdev
ip_tables              28672  0
x_tables               40960  1 ip_tables

# ... (Showing first 5 lines)
{% endhighlight %}

Each row prints information about a loaded kernel module. __Module__ and __Size__ column shows module name and size in
bytes respectively. __User by__ column list modules that depends upon this module.

`lsmod` lists only loaded modules. All installed modules for currently running kernel can be found in
__/lib/modules/$(uname -r)/kernel__ directory.

Those modules can be listed using following command:

{% highlight shell %}
$ find /lib/modules/$(uname -r)/kernel/ -type f -name .*ko
{% endhighlight %}

Details of an modules can be queried using `modinfo` command:
{% highlight shell %}
$ modinfo <module_name>

$ modinfo rt2800pci

filename:       /lib/modules/4.15.0-20-generic/kernel/drivers/net/wireless/ralink/rt2x00/rt2800pci.ko
license:        GPL
firmware:       rt2860.bin
description:    Ralink RT2800 PCI & PCMCIA Wireless LAN driver.
version:        2.3.0
alias:          pci:v00001814d0000539Fsv*sd*bc*sc*i*
depends:        rt2x00lib,rt2800lib,rt2800mmio,rt2x00mmio,rt2x00pci,eeprom_93cx6
name:           rt2800pci
vermagic:       4.15.0-20-generic SMP mod_unload 
parm:           nohwcrypt:Disable hardware encryption. (bool)
{% endhighlight %}

`modinfo` lists various detailed information about the module. Some modules takes configurable parameters listed as
__parm__. This modules takes one bool parameter named __nohwcrypt__.

# Load and Unloaded Modules

Kernel modules can be loaded and removed using `modprobe` command. For loading a command following command is used:

{% highlight shell %}
$ sudo modprobe <module_name>
{% endhighlight %}

For loading with parameters we can execute `modprobe` like below:

{% highlight shell %}
$ sudo modprobe rt2800pci nohwcrypt=1
{% endhighlight %}

`modprobe` automatically finds all dependencies of the module and loads all required modules. `modprobe` has an option
__-n__ for dry running the command without actually changing anything. Along with __-n__ we can add __-v__, verbose for
investigating what commands will `modprobe` execute.

{% highlight shell %}
$ sudo modprobe -nv stp

insmod /lib/modules/4.15.0-20-generic/kernel/net/llc/llc.ko 
insmod /lib/modules/4.15.0-20-generic/kernel/net/802/stp.ko
{% endhighlight %}

We can see that __llc__ modules will also be loaded as dependency of __stp__.

We can remove a module using __-r__ option in `modprobe`.
{% highlight shell %}
$ sudo modprobe -r stp
{% endhighlight %}

Another command for installing kernel modules is `insmod` and `rmmod` for removing modules. But these command doesn't
load dependencies. You have to manually resolve dependencies.

`modprobe` uses __/lib/modules/$(uname-r)/modules.dep.bin__ file for resolving dependences. There is a text files for
viewing dependencies named __modules.dep__. These files can be generated using `depmod` command. We can re-generate the
dependency using following command:

{% highlight shell %}
$ sudo depmod
{% endhighlight %}

This will generate __modules.dep.bin__ and __modules.dep__ for currently running kernel.

Some symbol are provided by kernel and some are provided by other modules. If a modules didn't find a symbol it assumes
kernel will provide it. This can create unresolved dependencies if kernel doesn't provide the required symbol. We can
also check for unresolved dependencies using `depmod` command. For that we will need a map for kernel provided symbol.

We can find kernel provided symbol in __System.map__ file. For checking symbol errors with __System.map__ file __-eE__
option is used.

{% highlight shell %}

$ locate System.map
/boot/System.map-4.15.0-20-generic

$ sudo depmod -eE /boot/System.map-4.15.0-20-generic
{% endhighlight %}

# modprobe Configuration

We can see the currently loaded configuration using command below:
{% highlight shell %}
$ modprobe -c
{% endhighlight %}

Configuration files are located in `/etc/modprobe.d/`. `modprobe` will load all files ending with __.conf__ in this
directly.

Now create file __/etc/modprobe.d/custom.conf__ with following lines:
{% highlight shell %}
# file: /etc/modprobe.d/custom.conf
option rt2800pci nohwcrypt=1
blacklist usbkbd
{% endhighlight %}

Lets assume that our hardware requires __rt2800pci__ and __usbkbd__ kernel modules to be loaded. Now if we start the
system __rt2800pci__ module will loaded with __nohwcrypt=1__ option. But __usbkbd__ won't be loaded as it is
blacklisted.  Modules is blacklisted if some other module provide better support then this module.

# Tools Version
* kmod version 24 -XZ -ZLIB -EXPERIMENTAL
* find (GNU findutils) 4.7.0-git

# Bookmarks
* [modprobe(8) Manual Page](https://linux.die.net/man/8/modprobe)
* [modprobe.d(5) Manual Page](https://linux.die.net/man/5/modprobe.d)
* [depmod(8) Manual Page](https://linux.die.net/man/8/depmod)
* [modinfo(8) Manual Page](https://linux.die.net/man/8/modinfo)
