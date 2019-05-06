---
layout: post
title: "Mount and Friends"
date: 2019-05-06 12:00:00 +0600
tags: linux mount findmnt umount losetup
---

# Introduction
For accessing files/data from a file system, it must be mounted using `mount` command. When the system boots up `mount`
command automatically mounts file systems specified in `/etc/fstab`.

# Mounting Block Device
`mount` command is flexible, but the most common usage is like below:
{% highlight shell %}
mount [-t type] [device-name] [mount-point]
{% endhighlight %}

If __-t__ is omitted `mount` tried to automatically determines the file system type. If either __device-name__ or
__mount-point__ is omitted `mount` will determines other information from `/etc/fstab` or prints error if not found.

All modern Linux distributor mounts USB flash devices automatically. But suppose an USB flash device is inserted and
detected as __/dev/sdb__ but wasn't able to mount automatically. Now we can list all block devices using `lsblk`
command.

{% highlight shell %}
$ lsblk --fs

NAME   FSTYPE LABEL UUID                                 MOUNTPOINT
sda
├─sda1 ext4         7eb875e6-d73f-44e9-b9ec-074972cbb23b /
├─sda2 swap         bd8597fb-8d2b-477f-a78f-0b50a8add1c8 [SWAP]
sdb
└─sdb1 vfat   John  CAFC-CDC5
{% endhighlight %}

`lsblk` lists all the block devices detected in this machine. And from above information we can see this computer's
primary HDD is __sda__ with two partitions (sda1 and sda2). __sda1__ partition is mounted as __root (/)__ of this
machine and __sda2__ partition is used as swap memory.

__sdb__ is our USB flash drive with label 'John'. It only has one partition __sdb1__ with file system type of
__vfat__. Now for mounting __sdb1__ on '/media/John/' folder we have to write the following command:

{% highlight shell %}
$ sudo mkdir /media/John
$ sudo mount -t vfat /dev/sdb1 /media/John/
{% endhighlight %}
Now we can access data from the flash drive using __/media/John__ directory.

We can also omit __-t &lt;type&gt;__, in that case `mount` will automatically determine the file system.
{% highlight shell %}
$ sudo mount /dev/sdb1 /media/John/
{% endhighlight %}

# Unmounting
`umount` command is used for unmounting a mounted device. Device can be unmounted either using device name or mount
point. Now for unmounting the previously mounted USB flash device we can write any of following commands:

{% highlight shell %}
$ sudo umount /dev/sdb1

# Or using mount point
$ sudo umount /media/John/
{% endhighlight %}

# Mounting File
We can also access the data of an __iso__ or __img__ file using `mount` command. Let consider we want to install Debian
in our system and we have downloaded Debian live CD __debian-9.6.0-amd64-xfce-CD-1.iso__ from internet. Now we want to
check what is inside this __iso__. We can easily mount the __iso__ using following command:

{% highlight shell %}
$ mkdir ~/debian
$ sudo mount debian-9.6.0-amd64-xfce-CD-1.iso ~/debian
{% endhighlight %}
In this case we mounted on __debian__ folder in home instead of predefined mount folder like __/mnt__ or __/media__.

Now if we do a `lsblk`:
{% highlight shell %}
$ lsblk --fs

NAME   FSTYPE  LABEL                UUID                                 MOUNTPOINT
loop0  iso9660 Debian 9.6.0 amd64 1 2018-11-10-11-37-56-00               /home/john/debian
sda
├─sda1 ext4                         7eb875e6-d73f-44e9-b9ec-074972cbb23b /
├─sda2 swap                         bd8597fb-8d2b-477f-a78f-0b50a8add1c8 [SWAP]
{% endhighlight %}

Now we can see there is an entry with label __Debian 9.6.0 amd64__, which is mounted in __/home/john/debian__.  File
system type is __iso9660__.

This __iso__ is named as __loop0__. Loop device is used when we want to access a file as block device. `mount`
automatically assign first available loop device while mounting file. Actually previous command can be written like
following:

{% highlight shell %}
$ sudo mount -o loop debian-9.6.0-amd64-xfce-CD-1.iso ~/debian
{% endhighlight %}

We have specified __loop__ option using __-o__. This will use the first available loop device. We can also specify
specific loop device like below:

{% highlight shell %}
$ sudo mount -o loop=/dev/loop3 debian-9.6.0-amd64-xfce-CD-1.iso ~/debian
{% endhighlight %}

We can also assign and mount loop device separately. Loop device is assigned using `losetup` command:
{% highlight shell %}
$ sudo losetup /dev/loop0 debian-9.6.0-amd64-xfce-CD-1.iso
$ sudo mount /dev/loop0 ~/debian
{% endhighlight %}

# List Mounted Devices
We can see the already mounted device using various ways. `mount` command without any arguments prints currently mounted
devices:

{% highlight shell %}
$ mount

sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,relatime)
proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
udev on /dev type devtmpfs (rw,nosuid,relatime,size=8092868k,nr_inodes=2023217,mode=755)
devpts on /dev/pts type devpts (rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000)
tmpfs on /run type tmpfs (rw,nosuid,noexec,relatime,size=1624848k,mode=755)
# ... (Showing first 5 lines)
{% endhighlight %}
This actually prints the content of `/proc/mounts`. We can also filter the list by type using __-t__ flag.

Previously mount used to keep mounted device list in `/etc/mtab` file but now it just a symlink for `/proc/mounts`.

We can also use `findmnt` command for checking currently mounted file systems in computer. Following command shows a
tree view of mounted devices:

{% highlight shell %}
$ findmnt

TARGET                                SOURCE     FSTYPE          OPTIONS
/                                     /dev/sda1  ext4            rw,relatime,errors=remount-ro,data=ordered
├─/sys                                sysfs      sysfs           rw,nosuid,nodev,noexec,relatime
│ ├─/sys/kernel/security              securityfs securityfs      rw,nosuid,nodev,noexec,relatime
│ ├─/sys/fs/cgroup                    tmpfs      tmpfs           ro,nosuid,nodev,noexec,mode=755
# ... (Showing first 5 lines)
{% endhighlight %}

We can query details of a specific mount with `findmnt` command using either device name or mount point:

{% highlight shell %}
$ findmnt /dev/loop0

TARGET            SOURCE     FSTYPE  OPTIONS
/home/john/debian /dev/loop0 iso9660 ro,relatime,nojoliet,check=s,map=n,blocksize=2048
{% endhighlight %}

# List Available File System Types
For mounting a file system, our kernel must know how to work with that file system. To list all known file systems we can
run following command:

{% highlight shell %}
$ cat /proc/filesystems
nodev	sysfs
nodev	rootfs
nodev	ramfs
nodev	bdev
nodev	proc
# ... (Showing first 5 lines)
{% endhighlight %}
But this list doesn't shows all the available file systems. We can directly list the file system kernel modules.

{% highlight shell %}
$ ls -l /lib/modules/$(uname -r)/kernel/fs/*/*ko

-rw-r--r-- 1 root root   93742 Apr 24  2018 /lib/modules/4.15.0-20-generic/kernel/fs/9p/9p.ko
-rw-r--r-- 1 root root   36534 Apr 24  2018 /lib/modules/4.15.0-20-generic/kernel/fs/adfs/adfs.ko
-rw-r--r-- 1 root root  122094 Apr 24  2018 /lib/modules/4.15.0-20-generic/kernel/fs/affs/affs.ko
-rw-r--r-- 1 root root  275398 Apr 24  2018 /lib/modules/4.15.0-20-generic/kernel/fs/afs/kafs.ko
-rw-r--r-- 1 root root  419038 Apr 24  2018 /lib/modules/4.15.0-20-generic/kernel/fs/aufs/aufs.ko
# ... (Shows first 5 lines)
{% endhighlight %}

`blkid` is a tool for querying details information about block device. It has __-k__ flags which also shows all
available file system types.

{% highlight shell %}
$ blkid -k
linux_raid_member
ddf_raid_member
isw_raid_member
lsi_mega_raid_member
via_raid_member
# ... (Shows first 5 lines)
{% endhighlight %}

# Mount Options
We can specify comma separated options using __-o__ flag. Following command will remount __/dev/sdb1__ device with read
only mode.
{% highlight shell %}
$ sudo mount /dev/sdb1 /media/John
$ sudo mount -o remount,ro /dev/sbd1
{% endhighlight %}

| Option           | Description
|:----------------:|:-----------------------------------------------
| __ro__           | Mounts the file system read only
| __rw__           | Mounts the file system read write
| __auto__         | Added in /etc/fstab, automatically mounts the file system
| __noauto__       | Reverse of __auto__
| __remount__      | Mount an already mounted file system again
| __sync__         | I/O operations are done synchronously
| __async__        | I/O operations are done asynchronously
| __dev__          | Interpret as character or block device
| __nodev__        | Don't interpret as character or block device
| __exec__         | Can execute binary in mounted file system
| __noexec__       | Reverse of __exec__
| __user__         | Allow  user to mount/unmount the file system
| __nouser__       | Allow any user to mount/unmount the file system
| __suid__         | Allows set-user-ID and set-group-ID bits to take effect
| __nosuid__       | Ignores set-user-ID and set-group-ID bits
| __defaults__     | Same as __-o rw,suid,dev,exec,auto,nouser,async__

See `man mount` for complete list of options:

# Mount with /etc/fstab
While booting the system mounts read `/etc/fstab` file automatically and mounts the partitions which has option
__auto__.

{% highlight shell %}
$ cat /etc/fstab

UUID=7eb875e6-d73f-44e9-b9ec-074972cbb23b /               ext4    errors=remount-ro 0       1
UUID=bd8597fb-8d2b-477f-a78f-0b50a8add1c8 none            swap    sw                0       0
{% endhighlight %}

For manually mounting missing partitions we can execute following command:

{% highlight shell %}
$ sudo mount -a
{% endhighlight %}

# Tools Version
* mount from util-linux 2.31.1 (libmount 2.31.1: selinux, btrfs, assert, debug)
* umount from util-linux 2.31.1 (libmount 2.31.1: selinux, btrfs, assert, debug)
* findmnt from util-linux 2.31.1
* losetup from util-linux 2.31.1

# Bookmarks
* [mount(8) Manual Page](https://linux.die.net/man/8/mount)
* [umount(8) Manual Page](https://linux.die.net/man/8/umount)
* [findmnt(8) Manual Page](https://linux.die.net/man/8/findmnt)
* [losetup(8) Manual Page](https://linux.die.net/man/8/losetup)
