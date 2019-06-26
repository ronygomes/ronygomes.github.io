---
layout: post
title: "Learning RPM"
date: 2019-06-26 10:30:00 +0600
tags: linux rpm
---

# Overview
__RPM__ (RPM Package Manager) can install, update, erase, verify packages. It is default package manager for Red Hat
based distributions. RPM works on both installed and raw `rpm` packages. RPM doesn't automatically resolve dependencies
of packages. Dependencies need to collect manually and install using `rpm` command.

# Package Naming Convention
RPM packages are suffixed with __rpm__ extension and follows a fixed naming convention. Every RPM package follows
following format.

```
PACKAGE_NAME-PACKAGE_VERSION-RELEASE_VERSION-OS_NAME-ARCHITECTURE.rpm
```

__Example:__
{% highlight text %}
tree-1.6.0-10.el7.x86_64.rpm
{% endhighlight %}

Here __tree__ is the name of the package. __1.6.0__ is version of tree. __10__ is package release version, means how
many times this version of application is packaged. Same version of application may need to repackage for updating
package metadata. Next field is indented operating system, __el7__ means Red Hat Enterprise Linux (EL) 7. Last field is
architecture type which is __x86_64__.

# Obtaining Packages
I am using CentOS 7 for running examples in this article. Although better alternate for downloading and resolving
dependencies is `yum` but for the sake of this article I will be downloading packages manually using `curl`.

{% highlight shell %}
$ cat /etc/centos-releas
CentOS Linux release 7.6.1810 (Core)
{% endhighlight %}

Packages for this version of CentOS is located in following URL:
```
http://mirror.centos.org/centos/7.6.1810/os/x86_64/Packages/
```

Lets create a shell variable with this URL:
{% highlight shell %}
$ CENTOS7_PACKAGE_ROOT="http://mirror.centos.org/centos/7.6.1810/os/x86_64/Packages"
{% endhighlight %}

I will search package names using browser and download using `curl`. I got from searching that complete package name of
__tree__ command is `tree-1.6.0-10.el7.x86_64.rpm`. Now I can download __tree__ like below:

{% highlight shell %}
$ curl -O $CENTOS7_PACKAGE_ROOT/tree-1.6.0-10.el7.x86_64.rpm

$ ls
tree-1.6.0-10.el7.x86_64.rpm
{% endhighlight %}

# Install/Update Package
As `rpm` doesn't automatically resolve dependencies, we have to manually resolve all dependencies. Let's first install a
basic program without any dependencies.

`tree-1.6.0-10.el7.x86_64.rpm` package doesn't have any dependency. We can install directly with following command:

{% highlight shell %}
$ sudo -i tree-1.6.0-10.el7.x86_64.rpm
{% endhighlight %}

`rpm` doesn't show any messages if installs successfully. We can add `vh` option to add verbose message with hash to
denote progress.

{% highlight shell %}
$ sudo -ivh tree-1.6.0-10.el7.x86_64.rpm
Preparing...                          ################################# [100%]
Updating / installing...
   1:tree-1.6.0-10.el7                ################################# [100%]
{% endhighlight %}

For upgrading a package we have to use `-U` option. As we just install `tree` trying to upgrade this version again will
do nothing. But we can re-install this package with `--reinstall` option.

{% highlight shell %}
$ sudo -U tree-1.6.0-10.el7.x86_64.rpm
        package tree-1.6.0-10.el7.x86_64 is already installed

$ sudo --reinstall -vh tree-1.6.0-10.el7.x86_64.rpm

Preparing...                          ################################# [100%]
Updating / installing...
   1:tree-1.6.0-10.el7                ################################# [ 50%]
Cleaning up / removing...
   2:tree-1.6.0-10.el7                ################################# [100%]
{% endhighlight %}

If we want to upgrade a package only if its already installed we can use `-F` option.

{% highlight shell %}
$ sudo -F tree-1.6.0-10.el7.x86_64.rpm
{% endhighlight %}

Now for installing packages with dependencies we have to collect and install dependencies manually. Let's try install
`nmap` package which have dependencies. I have download the nmap packge file named `nmap-6.40-16.el7.x86_64.rpm`. Now if
we run the install command like below:

{% highlight shell %}
$ sudo -i nmap-6.40-16.el7.x86_64.rpm
error: Failed dependencies:
        libpcap.so.1()(64bit) is needed by nmap-2:6.40-16.el7.x86_64
        nmap-ncat = 2:6.40-16.el7 is needed by nmap-2:6.40-16.el7.x86_64
{% endhighlight %}

We can see from the error message that `nmap` has two dependencies which is not currently installed in our machine. We
can see that __libcap.so.1__ is a library and __nmap-ncat__ in another package.

Now if we search in __$CENTOS7_PACKAGE_ROOT__ URL using a web browser we can easily find following packages
`libpcap-1.5.3-11.el7.x86_64.rpm` and `nmap-ncat-6.40-16.el7.x86_64.rpm`. Now lets try to first install dependencies.

{% highlight shell %}
$ sudo -i libpcap-1.5.3-11.el7.x86_64.rpm
$ sudo -i nmap-ncat-6.40-16.el7.x86_64.rpm
{% endhighlight %}

Now we can install `nmap` without any error using following command:

{% highlight shell %}
$ sudo -i nmap-6.40-16.el7.x86_64.rpm
{% endhighlight %}

# Remove Package
We can remove a package using `--erase` or `-e` option like below:

{% highlight shell %}
$ sudo rpm -e nmap
{% endhighlight %}

Note we have given only package name not the whole `rpm` file name. This will only remove `nmap` and won't remove its
dependencies. Again dependencies have to be removed manually.

Install and erase both takes `--test` parameter. In this case `rpm` dry runs the command and doesn't change anything.

{% highlight shell %}
$ rpm -evh --test nmap
{% endhighlight %}

# Query Package
__RPM__ has very flexible way to search and gather information about installed and raw `rpm` packages. Query command is
`--query` or `-q` for short. By default `rpm` queries on installed packages.

For querying all installed packages use `-a` with query command.

{% highlight shell %}
$ rpm -qa

selinux-policy-targeted-3.13.1-229.el7.noarch
grub2-common-2.02-0.76.el7.centos.noarch
kexec-tools-2.0.15-21.el7.x86_64
kbd-legacy-1.15.5-15.el7.noarch
openssh-clients-7.4p1-16.el7.x86_64

# ... (Showing first 5 lines)
{% endhighlight %}

We can query detailed information about a package using `-i` option:

{% highlight shell %}
$ rpm -qi bash

Name        : bash
Version     : 4.2.46
Release     : 31.el7
Architecture: x86_64
Install Date: Tue 28 May 2019 12:45:09 PM +06
Group       : System Environment/Shells
Size        : 3667773
License     : GPLv3+
Signature   : RSA/SHA256, Mon 12 Nov 2018 08:21:49 PM +06, Key ID 24c6a8a7f4a80eb5
Source RPM  : bash-4.2.46-31.el7.src.rpm
Build Date  : Tue 30 Oct 2018 11:09:33 PM +06
Build Host  : x86-01.bsys.centos.org
Relocations : (not relocatable)
Packager    : CentOS BuildSystem <http://bugs.centos.org>
Vendor      : CentOS
URL         : http://www.gnu.org/software/bash
Summary     : The GNU Bourne Again shell
Description :
The GNU Bourne Again shell (Bash) is a shell or command language
interpreter that is compatible with the Bourne shell (sh). Bash
incorporates useful features from the Korn shell (ksh) and the C shell
(csh). Most sh scripts can be run by bash without modification.
{% endhighlight %}

We can also filter packages using these fields. Like for listing all packages with GPLv3+ license we can write:

{% highlight shell %}
$ rpm -qa License=GPLv3+

sed-4.2.2-5.el7.x86_64
coreutils-8.22-23.el7.x86_64
readline-6.2-10.el7.x86_64
cpio-2.11-27.el7.x86_64
less-458-9.el7.x86_64

# ... (Showing first 5 lines)
{% endhighlight %}

For listing all files of a package `-l` option is used:
{% highlight shell %}
$ rpm -ql bash
{% endhighlight %}

For listing only documentation `-d` option and for only configuration file `-c` option is used:

{% highlight shell %}
$ rpm -qd bash
/usr/share/doc/bash-4.2.46/COPYING
/usr/share/info/bash.info.gz
/usr/share/man/man1/..1.gz
/usr/share/man/man1/:.1.gz
/usr/share/man/man1/[.1.gz
# ... (Showing first 5 lines)
$ rpm -qc bash
/etc/skel/.bash_logout
/etc/skel/.bash_profile
/etc/skel/.bashrc

{% endhighlight %}

Dependencies of a package can be viewed using `-R` option.
{% highlight shell %}
$ rpm -qR bash

/bin/sh
config(bash) = 4.2.46-31.el7
libc.so.6()(64bit)
libc.so.6(GLIBC_2.11)(64bit)
libc.so.6(GLIBC_2.14)(64bit)
libc.so.6(GLIBC_2.15)(64bit)
libc.so.6(GLIBC_2.2.5)(64bit)
libc.so.6(GLIBC_2.3)(64bit)
libc.so.6(GLIBC_2.3.4)(64bit)
libc.so.6(GLIBC_2.4)(64bit)
libc.so.6(GLIBC_2.8)(64bit)
libdl.so.2()(64bit)
libdl.so.2(GLIBC_2.2.5)(64bit)
libtinfo.so.5()(64bit)
rpmlib(BuiltinLuaScripts) <= 4.2.2-1
rpmlib(CompressedFileNames) <= 3.0.4-1
rpmlib(FileDigests) <= 4.6.0-1
rpmlib(PayloadFilesHavePrefix) <= 4.0-1
rtld(GNU_HASH)
rpmlib(PayloadIsXz) <= 5.2-1
{% endhighlight %}

We can also query which package a certain file belongs to using `-f` option:
{% highlight shell %}
$ rpm -qf /etc/yum.conf
yum-3.4.3-161.el7.centos.noarch
{% endhighlight %}

We can also filter package by group. We can run the following command to find out installed package's groups.

{% highlight shell %}
$ rpm -qa --qf "%{GROUP}\n" | sort -u

Applications/Archiving
Applications/Databases
Applications/Editors
Applications/File
Applications/Internet
Applications/Multimedia
Applications/Publishing
Applications/System
Applications/Text
Development/Languages
Development/Libraries
Development/System
Development/Tools
Public Keys
System Environment/Base
System Environment/Daemons
System Environment/Kernel
System Environment/Libraries
System Environment/Shells
Unspecified
{% endhighlight %}

Now to filter using group we can run following command:

{% highlight shell %}
$ rpm -qg "Applications/Text"

gawk-4.0.2-4.el7_3.1.x86_64
sed-4.2.2-5.el7.x86_64
grep-2.20-3.el7.x86_64
diffutils-3.3-4.el7.x86_64
less-458-9.el7.x86_64
{% endhighlight %}

For querying on a raw `rpm` package `-p` is used. For querying documentation files in a uninstalled `rpm` package we
have to use following command:

{% highlight shell %}
$ rpm -qdp tree-1.6.0-10.el7.x86_64.rpm

/usr/share/doc/tree-1.6.0/LICENSE
/usr/share/doc/tree-1.6.0/README
/usr/share/man/man1/tree.1.gz
{% endhighlight %}

## Query Format
We can format output of package listing using `--query-format` or `--qf` filter. These filters takes tags. List of tags
can be found using `--querytags` command:

{% highlight shell %}
$ rpm --querytags
ARCH
ARCHIVESIZE
BASENAMES
BUGURL
BUILDARCHS

# ... (Showing first 5 lines of 205 lines)
{% endhighlight %}

Now we can format list output like below:
{% highlight shell %}
$ rpm -qa --qf "%{NAME} %{SIZE}\n"

selinux-policy-targeted 20055219
grub2-common 3915374
kexec-tools 774283
kbd-legacy 503608
openssh-clients 2651616
{% endhighlight %}

For formatting an array `[]` is wrapped around the tag.

{% highlight shell %}
$ rpm -ql --qf "[%{FILENAMES} %{FILEMODES}\n]" bash

/etc/skel/.bash_logout 33188
/etc/skel/.bash_profile 33188
/etc/skel/.bashrc 33188
/usr/bin/alias 33261
/usr/bin/bash 33261

# ... (Showing first 5 lines)
{% endhighlight %}

Some tag can take additional parameter for rendering different type of output. Here we changed output type of
__FILEMODES__ using __:perms__ tag type.

{% highlight shell %}
$ rpm -ql --qf "[%{FILENAMES} %{FILEMODES:perms}\n]" bash

/etc/skel/.bash_logout -rw-r--r--
/etc/skel/.bash_profile -rw-r--r--
/etc/skel/.bashrc -rw-r--r--
/usr/bin/alias -rwxr-xr-x
/usr/bin/bash -rwxr-xr-x

# ... (Showing first 5 lines)
{% endhighlight %}

# Verify Files
`rpm` can also report changes in configuration file. Lets first list the configuration file of `bash` package.

{% highlight shell %}
$ rpm -qc bash

/etc/skel/.bash_logout
/etc/skel/.bash_profile
/etc/skel/.bashrc
{% endhighlight %}

Now lets try to verify configuration files using `-V` options.

{% highlight shell %}
$ rpm -V bash
{% endhighlight %}

It prints nothing, meaning configuration file is same as installed configuration. Now change `/etc/skel/.bash_profile` file and
rerun the command:

{% highlight shell %}
$ vi /etc/skel/.bash_profile

$ rpm -V yum
S.5....T.  c /etc/skel/.bash_profile
{% endhighlight %}

Its printing in following format

```
CHANGE_DETAILS FILE_TYPE FILE_PATH
```

__CHANGE_DETAILS__ is a string in  __SM5DLUGTP__ format. Each character denotes a change type.

S.5....T. means `/etc/skel/.bash_profile` file is different in length (S), MD5 (5) and access time (T) from original
configuration file.

| Option         | Description
|:--------------:|:-------------------------------------
| __S__          | File size differs from original file
| __M__          | File permission and mode differs
| __5__          | Differs MD5 hash
| __D__          | Device major/minor version mismatch
| __L__          | readlink(2) path mismatch
| __U__          | User ownership changed
| __G__          | Group ownership changed
| __T__          | Access time changed
| __P__          | Capabilities differ

__FILE_TYPE__ can be any of following chars:

| Option         | Description
|:--------------:|:-------------------------------------
| __c__          | Configuration file
| __d__          | Documentation file
| __g__          | Ghost file (Files doesn't included in package)
| __l__          | Licence file
| __r__          | Readme file


# Miscellaneous
`rpm` can also verify MD5 and signature of a package using `-K` option:

{% highlight shell %}
$ rpm -K tree-1.6.0-10.el7.x86_64.rpm
tree-1.6.0-10.el7.x86_64.rpm: rsa sha1 (md5) pgp md5 OK
{% endhighlight %}

In rpm public keys are also installed as packages. Each public key installed as separated package. Details can be viewed
of available public keys like normal package using `-i` option:

{% highlight shell %}
$ rpm -qa gpg-pubkey
gpg-pubkey-f4a80eb5-53a7ff4b

$ rpm -qi gpg-pubkey
{% endhighlight %}

Now import another public key using following command:

{% highlight shell %}
$ rpm --import <PUB_KEY>

$ rpm -qa gpg-pubkey
gpg-pubkey-f4a80eb5-53a7ff4b
gpg-pubkey-b0c18a82-81b1e91c

{% endhighlight %}

If we need to rebuild `rpm` local database of packages, following command can be used:
{% highlight shell %}
$ sudo rpm --rebuilddb
{% endhighlight %}
Local database in located in `/var/lib/rpm/` directory.

# Tools Version
* RPM version 4.11.3

# Bookmarks
* [rpm(8) Manual Page](https://linux.die.net/man/8/rpm)
* [rpmkeys(8) Manual Page](https://www.unix.com/man-page/linux/8/rpmkeys/)
* [rpmdb(8) Manual Page](https://www.unix.com/man-page/linux/8/rpmdb/)
