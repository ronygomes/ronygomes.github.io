---
layout: post
title: "lspci and lsusb"
date: 2019-05-07 11:30:00 +0600
tags: linux lspci lsusb
---

# Introduction
`lspci` and `lsusb` are tools for displaying information about __PCI__ and __USB__ buses along with connected devices.

# lspci Usage
`lspci` without any arguments prints all connected PCI devices.
{% highlight shell %}
$ lspci

00:00.0 Host bridge: Intel Corporation 3rd Gen Core processor DRAM Controller (rev 09)
00:01.0 PCI bridge: Intel Corporation Xeon E3-1200 v2/3rd Gen Core processor PCI Express Root Port (rev 09)
00:02.0 VGA compatible controller: Intel Corporation 3rd Gen Core processor Graphics Controller (rev 09)
00:14.0 USB controller: Intel Corporation 7 Series/C210 Series Chipset Family USB xHCI Host Controller (rev 04)
00:16.0 Communication controller: Intel Corporation 7 Series/C216 Chipset Family MEI Controller #1 (rev 04)
00:1a.0 USB controller: Intel Corporation 7 Series/C216 Chipset Family USB Enhanced Host Controller #2 (rev 04)
00:1b.0 Audio device: Intel Corporation 7 Series/C216 Chipset Family High Definition Audio Controller (rev 04)
00:1c.0 PCI bridge: Intel Corporation 7 Series/C216 Chipset Family PCI Express Root Port 1 (rev c4)
00:1c.1 PCI bridge: Intel Corporation 7 Series/C210 Series Chipset Family PCI Express Root Port 2 (rev c4)
00:1c.2 PCI bridge: Intel Corporation 7 Series/C210 Series Chipset Family PCI Express Root Port 3 (rev c4)
00:1d.0 USB controller: Intel Corporation 7 Series/C216 Chipset Family USB Enhanced Host Controller #1 (rev 04)
00:1f.0 ISA bridge: Intel Corporation HM76 Express Chipset LPC Controller (rev 04)
00:1f.2 SATA controller: Intel Corporation 7 Series Chipset Family 6-port SATA Controller [AHCI mode] (rev 04)
00:1f.3 SMBus: Intel Corporation 7 Series/C216 Chipset Family SMBus Controller (rev 04)
01:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Thames [Radeon HD 7500M/7600M Series]
07:00.0 Network controller: Ralink corp. RT3290 Wireless 802.11n 1T/1R PCIe
07:00.1 Bluetooth: Ralink corp. RT3290 Bluetooth
08:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8101/2/6E PCI Express Fast/Gigabit Ethernet controller (rev 05)
09:00.0 Unassigned class [ff00]: Realtek Semiconductor Co., Ltd. RTS5229 PCI Express Card Reader (rev 01)
{% endhighlight %}

Each line contains information about a PCI slot in following format:

```
<SlotID> <DeviceClass>: <VendorName> <DeviceDescription> (<Rev>)
```

SlotID is a number in __bus:device.function__ format for denoting where the device resides in hardware. So from
previous example 'VGA compatible controller' is the __02__ number device in __00__ number bus. Both __bus__ and
__device__ number is in hex format.

We can filter devices with slot number with __-s__ option. Following will only show information about device with
__00:02.0__ slot number:

{% highlight shell %}
$ lspci -s 00:02.0

00:02.0 VGA compatible controller: Intel Corporation 3rd Gen Core processor Graphics Controller (rev 09)
{% endhighlight %}

We can also filter by device number like below:
{% highlight shell %}
$ lspci -s 00

00:00.0 Host bridge: Intel Corporation 3rd Gen Core processor DRAM Controller (rev 09)
01:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Thames [Radeon HD 7500M/7600M Series]
07:00.0 Network controller: Ralink corp. RT3290 Wireless 802.11n 1T/1R PCIe
07:00.1 Bluetooth: Ralink corp. RT3290 Bluetooth
08:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8101/2/6E PCI Express Fast/Gigabit Ethernet controller (rev 05)
09:00.0 Unassigned class [ff00]: Realtek Semiconductor Co., Ltd. RTS5229 PCI Express Card Reader (rev 01)
{% endhighlight %}

For filtering with bus number we have to add __:__ as below:
{% highlight shell %}
$ lspci -s 07:

07:00.0 Network controller: Ralink corp. RT3290 Wireless 802.11n 1T/1R PCIe
07:00.1 Bluetooth: Ralink corp. RT3290 Bluetooth
{% endhighlight %}

This is only showing device in bus number __07__. We can also filter by function number like __.0__.
This will show all device's first function.

`lspci` supports two type of view mode.

| Mode Flag  | Description
|:----------:|:---------------------------------------------------
|            | If neither __-m__ or __-t__ specified, prints in human readable mode
| __-m__     | Easily parse able (machine readable) format ,__-mm__ for backward incompatible
| __-t__     | Tree like diagram of all buses

Now we can view all devices in tree view like below using following command:
{% highlight shell %}
$ lspci -t

-[0000:00]-+-00.0
           +-01.0-[01-06]----00.0
           +-02.0
           +-14.0
           +-16.0
           +-1a.0
           +-1b.0
           +-1c.0-[07]--+-00.0
           |            \-00.1
           +-1c.1-[08]----00.0
           +-1c.2-[09-0e]----00.0
           +-1d.0
           +-1f.0
           +-1f.2
           \-1f.3
{% endhighlight %}

We can add verbose flag with mode for detailed information. `lspci` supports various verbose flag given below:

|  Verbose Flag   | Description
|:---------------:|:-------------------------
| __-v__          | Display verbose messages
| __-vv__         | Display more verbose messages
| __-vvv__        | Display even more messages

Now we can see the detailed information about __00:02__ device in machine readable format like below:

{% highlight shell %}
$ lspci -mvs 00:02

Device:	00:02.0
Class:	VGA compatible controller
Vendor:	Intel Corporation
Device:	3rd Gen Core processor Graphics Controller
SVendor:	Hewlett-Packard Company
SDevice:	3rd Gen Core processor Graphics Controller
Rev:	09

{% endhighlight %}

We can see only vendor and product id with __-n__ flag. __-nn__ show vendor and product name along with vendor and
product id.

{% highlight shell %}
$ lspci -ns 00:02

00:02.0 0300: 8086:0166 (rev 09)
{% endhighlight %}

By default `lspci` searches `/usr/share/misc/pci.ids` for finding vendor and product name from vendor/product id. You
can use __-Q__ for querying the central database if unable to recognize vendor or product name.

We can list available kernel modules and loaded kernel modules of devices with __-k__ option. This information also
added in __--v__ verbose mode.

{% highlight shell %}
$ lspci -ks 00:02

00:02.0 VGA compatible controller: Intel Corporation 3rd Gen Core processor Graphics Controller (rev 09)
	Subsystem: Hewlett-Packard Company 3rd Gen Core processor Graphics Controller
	Kernel driver in use: i915
	Kernel modules: i915
{% endhighlight %}

# lsusb Usage
`lsusb` without any arguments also prints all USB buses.

{% highlight shell %}
$ lsusb

Bus 004 Device 003: ID 05c8:0348 Cheng Uei Precision Industry Co., Ltd (Foxlink) 
Bus 004 Device 002: ID 8087:0024 Intel Corp. Integrated Rate Matching Hub
Bus 004 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 001 Device 002: ID 8087:0024 Intel Corp. Integrated Rate Matching Hub
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 003 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 002 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
{% endhighlight %}

We can also print tree view with __-t__ flag.
{% highlight shell %}
$ lsusb -t

/:  Bus 04.Port 1: Dev 1, Class=root_hub, Driver=ehci-pci/2p, 480M
    |__ Port 1: Dev 2, If 0, Class=Hub, Driver=hub/6p, 480M
        |__ Port 5: Dev 3, If 0, Class=Video, Driver=uvcvideo, 480M
        |__ Port 5: Dev 3, If 1, Class=Video, Driver=uvcvideo, 480M
/:  Bus 03.Port 1: Dev 1, Class=root_hub, Driver=xhci_hcd/4p, 5000M
/:  Bus 02.Port 1: Dev 1, Class=root_hub, Driver=xhci_hcd/4p, 480M
/:  Bus 01.Port 1: Dev 1, Class=root_hub, Driver=ehci-pci/2p, 480M
    |__ Port 1: Dev 2, If 0, Class=Hub, Driver=hub/6p, 480M
{% endhighlight %}

Now lets consider a single line:

```
Bus 03.Port 1: Dev 1, Class=root_hub, Driver=xhci_hcd/4p, 5000M
```

We can see this device is in __Bus 03__ and __Port 1__. __Dev__ is device id, an incremental index of detected
device.

It's __Class__ is root_hub. Each host controller is attached with a root_hub. __Driver__ is kernel module used
for this device. Finally it's speed is 5000M, means it is a USB 3.0 device.

Not all USB devices listed here are accessible for regular use, some are used internally. In this laptop I have 4 bus
each with 1 port, but I have 3 physical USB ports. Lets call them __USB_R__ and __USB_L0__ and __USB_L1__.

Now let me attach a USB wireless mouse in __USB_R__ and a flash drive in __USB_L0__.
Now if we execute `lsusb -t`:

{% highlight shell %}
$ lsusb -t

/:  Bus 04.Port 1: Dev 1, Class=root_hub, Driver=ehci-pci/2p, 480M
    |__ Port 1: Dev 2, If 0, Class=Hub, Driver=hub/6p, 480M
        |__ Port 5: Dev 3, If 0, Class=Video, Driver=uvcvideo, 480M
        |__ Port 5: Dev 3, If 1, Class=Video, Driver=uvcvideo, 480M
/:  Bus 03.Port 1: Dev 1, Class=root_hub, Driver=xhci_hcd/4p, 5000M
    |__ Port 2: Dev 17, If 0, Class=Mass Storage, Driver=usb-storage, 5000M
/:  Bus 02.Port 1: Dev 1, Class=root_hub, Driver=xhci_hcd/4p, 480M
/:  Bus 01.Port 1: Dev 1, Class=root_hub, Driver=ehci-pci/2p, 480M
    |__ Port 1: Dev 2, If 0, Class=Hub, Driver=hub/6p, 480M
        |__ Port 2: Dev 13, If 0, Class=Human Interface Device, Driver=usbhid, 12M
        |__ Port 2: Dev 13, If 1, Class=Human Interface Device, Driver=usbhid, 12M
        |__ Port 2: Dev 13, If 2, Class=Human Interface Device, Driver=usbhid, 12M

{% endhighlight %}

Note flash driver is detected at __Port 2__ of __Bus 03.Port 1__ and wireless mouse is detected
in __Port 1__ of __Bus 01.Port1__. It is __Dev 13__ but with 3 interfaces (if 0, if 1, if 2).
It has speed of 12M.

`lsusb` searches for product and vendor name in `/var/lib/usbutils/usb.ids`.
# Tools Version
* lspci version 3.5.2
* lsusb (usbutils) 007

# Bookmarks
* [lspci(8) Manual Page](https://linux.die.net/man/8/lspci)
* [lsusb(8) Manual Page](https://linux.die.net/man/8/lsusb)
