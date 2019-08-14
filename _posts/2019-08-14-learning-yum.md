---
layout: post
title: "Learning YUM"
date: 2019-08-14 11:30:00 +0600
tags: pacman
---

# Introduction
Yellowdog Updater, Modifier (YUM) is a package manager, which is widely used to manage rpm packages in Red Hat based
distributions. Unlike `rpm` command line tool, it can automatically resolve, download and install package dependencies.

As `yum` is also installed as an RPM package, we can query details about this like any other RPM package. I am using
CentOS 7 for running examples in this article.

{% highlight shell %}
$ cat /etc/centos-releas
CentOS Linux release 7.5.1804 (Core)
{% endhighlight %}

For showing version of `yum` package we can run following command.

{% highlight shell %}
$ rpm -q yum
yum-3.4.3-158.el7.centos.noarch
{% endhighlight %}

The examples in this article are taken disabling __fastestmirror__ plugin. To disable __fastestmirror__ plugin change
__enabled=1__ to __enabled=0__ in `/etc/yum/pluginconf.d/fastestmirror.conf` file.

# Finding Package
`yum` has very comprehensive commands for finding packages. We can list various packages using __list__ subcommand. By
default `list` subcommand shows installed and available packages.

{% highlight shell %}
$ yum list

Installed Packages
GeoIP.x86_64                          1.5.0-11.el7                     @anaconda
NetworkManager.x86_64                 1:1.10.2-13.el7                  @anaconda
NetworkManager-libnm.x86_64           1:1.10.2-13.el7                  @anaconda
NetworkManager-team.x86_64            1:1.10.2-13.el7                  @anaconda
# ... (Skipping lines until available section)
Available Packages
389-ds-base.x86_64                    1.3.8.4-25.1.el7_6               updates
389-ds-base-devel.x86_64              1.3.8.4-25.1.el7_6               updates
389-ds-base-libs.x86_64               1.3.8.4-25.1.el7_6               updates
389-ds-base-snmp.x86_64               1.3.8.4-25.1.el7_6               updates

# ... (Skipping further output)
{% endhighlight %}

Each line contains package description in following format:

{% highlight text %}
PackageName     [Epoch:]PackageVersion    SourceRepositoryName
{% endhighlight %}

If __Epoch__ number exists it is used to override regular version numbering. If no Epoch number than its default to
__1__. If two packages exists with following version __1.3.4__ and __2:1.2.0__, later will get precedence while
installing although former is updated version.

Last column is the source repository of package. Here repository name __@anaconda__ means those packages were installed
from installation media.

We can list only installed, available packages using __installed__, __avaibale__ list option respectively.
{% highlight shell %}
$ yum list installed

Installed Packages
GeoIP.x86_64                          1.5.0-11.el7                     @anaconda
NetworkManager.x86_64                 1:1.10.2-13.el7                  @anaconda
NetworkManager-libnm.x86_64           1:1.10.2-13.el7                  @anaconda
NetworkManager-team.x86_64            1:1.10.2-13.el7                  @anaconda

# ... (Showing first 5 lines)

{% endhighlight %}
`list` subcommand also supports __updates__ for listing updates of installed packages, __extras__ for listing packages
which are installed in system but doesn't contain in any repository, __obsoletes__ for listing installed packages which
are replaced by other packages.

We can further filter list by specifying package name glob. For listing all package names starting with 'vim':

{% highlight shell %}
$ yum list all vim* # Same as 'yum list vim*'

vim-minimal.x86_64                  2:7.4.160-4.el7                 @anaconda
Available Packages
vim-X11.x86_64                      2:7.4.160-6.el7_6               updates
vim-common.x86_64                   2:7.4.160-6.el7_6               updates
vim-enhanced.x86_64                 2:7.4.160-6.el7_6               updates
vim-filesystem.x86_64               2:7.4.160-6.el7_6               updates
vim-minimal.x86_64                  2:7.4.160-6.el7_6               updates
{% endhighlight %}

By default `yum` only lists the latest package, we can provide __--showduplicates__ options for listing all packages.

{% highlight shell %}
$ yum list python

Installed Packages
python.x86_64                           2.7.5-68.el7                    @anaconda
Available Packages
python.x86_64                           2.7.5-80.el7_6                  updates

$ yum --showduplicates list python

Installed Packages
python.x86_64                           2.7.5-68.el7                    @anaconda
Available Packages
python.x86_64                           2.7.5-76.el7                    base
python.x86_64                           2.7.5-77.el7_6                  updates
python.x86_64                           2.7.5-80.el7_6                  updates
{% endhighlight %}

We can also query detailed information using __info__ subcommand. __info__ subcommand also takes __installed__,
__available__, __obsoletes__ options like __list__.

{% highlight shell %}
$ yum info tree

Available Packages
Name        : tree
Arch        : x86_64
Version     : 1.6.0
Release     : 10.el7
Size        : 46 k
Repo        : base/7/x86_64
Summary     : File system tree viewer
URL         : http://mama.indstate.edu/users/ice/tree/
License     : GPLv2+
Description : The tree utility recursively displays the contents of directories in a
            : tree-like format.  Tree is basically a UNIX port of the DOS tree
            : utility.
{% endhighlight %}

We can also search in package name and summary using using __search__ subcommand.
{% highlight shell %}
$ yum search vim

protobuf-vim.x86_64 : Vim syntax highlighting for Google Protocol Buffers descriptions
vim-X11.x86_64 : The VIM version of the vi editor for the X Window System
vim-common.x86_64 : The common files needed by any version of the VIM editor
vim-enhanced.x86_64 : A version of the VIM editor which includes recent enhancements
vim-filesystem.x86_64 : VIM filesystem layout
vim-minimal.x86_64 : A minimal version of the VIM editor
{% endhighlight %}

For searching also in metadata we can add __all__ option.
{% highlight shell %}
$ yum search all vim

vim-X11.x86_64 : The VIM version of the vi editor for the X Window System
vim-common.x86_64 : The common files needed by any version of the VIM editor
vim-enhanced.x86_64 : A version of the VIM editor which includes recent enhancements
vim-filesystem.x86_64 : VIM filesystem layout
vim-minimal.x86_64 : A minimal version of the VIM editor
protobuf-vim.x86_64 : Vim syntax highlighting for Google Protocol Buffers descriptions
grilo-plugins.x86_64 : Plugins for the Grilo framework
{% endhighlight %}

If we don't know the package name but want to query by executable or file name, `yum` has __provides__ subcommand for
that. For querying which package provides `/etc/passwd` file we can execute following command.

{% highlight shell %}
$ yum provides /etc/passwd

setup-2.8.71-10.el7.noarch : A set of system configuration and setup files
Repo        : base
Matched from:
Filename    : /etc/passwd


setup-2.8.71-9.el7.noarch : A set of system configuration and setup files
Repo        : @anaconda
Matched from:
Filename    : /etc/passwd
{% endhighlight %}

For investigating dependencies of package `yum` have __deplist__ command. Following line will show dependencies of
`tree` command.

{% highlight shell %}
$ yum deplist tree

package: tree.x86_64 1.6.0-10.el7
  dependency: libc.so.6(GLIBC_2.14)(64bit)
   provider: glibc.x86_64 2.17-260.el7_6.6
  dependency: rtld(GNU_HASH)
   provider: glibc.x86_64 2.17-260.el7_6.6
   provider: glibc.i686 2.17-260.el7_6.6
{% endhighlight %}

# Installing Package
`yum` __install__ subcommand is used for installing new packages. Unlike `rpm`, this command will also download and
install dependencies.

{% highlight shell %}
$ sudo yum install tree

Resolving Dependencies
--> Running transaction check
---> Package tree.x86_64 0:1.6.0-10.el7 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

======================================================================================
 Package       Arch              Version                  Repository          Size
======================================================================================
Installing:
 tree         x86_64            1.6.0-10.el7                base              46 k

Transaction Summary
======================================================================================
Install  1 Package

Total download size: 46 k
Installed size: 87 k
Is this ok [y/d/N]:
{% endhighlight %}

As `tree` doesn't have any external package dependencies, only 1 package, __tree__ itself will be installed. We can see
that `yum` is prompting us for __y/d/N__ option. __y__ will install the package. We can also provide __-y__ flag with
__install__ command for skipping confirmation. If we press __N__, installation will be aborted and a transaction file
will be created.

{% highlight shell %}

Is this ok [y/d/N]: N
Exiting on user command
Your transaction was saved, rerun it with:
 yum load-transaction /tmp/yum_save_tx.2019-08-14.17-34.zxALJW.yumtx
{% endhighlight %}

Let's see the content of /tmp/yum_save_tx.2019-08-14.17-34.zxALJW.yumtx file.

{% highlight shell %}
$ sudo cat/tmp/yum_save_tx.2019-08-14.17-34.zxALJW.yumtx

298:e4fd91afa5eacab19b081c18b730515b7a7353cc
0
1
installed:299:cbe54d850072ab2b5f5cf9bbb03d2e7d23a167b4
1
mbr: tree,x86_64,0,1.6.0,10.el7 70
  repo: base
  ts_state: u
  output_state: 20
  isDep: False
  reason: user
  reinstall: False
{% endhighlight %}

We can continue the transaction using following command:

{% highlight shell %}
$ sudo yum load-transaction /tmp/yum_save_tx.2019-08-14.17-34.zxALJW.yumtx
{% endhighlight %}

If we select __d__ in installation prompt, then the package won't be install but will be downloaded in `/var/cache/yum`
directory.

{% highlight shell %}

Is this ok [y/d/N]: d
Background downloading packages, then exiting:
tree-1.6.0-10.el7.x86_64.rpm                                      |  46 kB  00:00:00
exiting because "Download Only" specified

{% endhighlight %}

We can search the downloaded file using `find` command like below:

{% highlight shell %}
$ find /var/cache/yum -name tree*
/var/cache/yum/x86_64/7/base/packages/tree-1.6.0-10.el7.x86_64.rpm
{% endhighlight %}

We can directly download a package using __--downloadonly__ flag. With __--downloaddir__ we can specify download
location.

{% highlight shell %}
$ sudo yum install --downloadonly --downloaddir=$PWD tree
# Omitting output

$ ls
tree-1.6.0-10.el7.x86_64.rpm
{% endhighlight %}

We can install __.rpm__ packages using `yum` __localinstall__ command. Unlike `rpm` command installing with
__localinstall__ also downloads and installs dependencies.

{% highlight shell %}
$ sudo yum localinstall tree-1.6.0-10.el7.x86_64.rpm
{% endhighlight %}

Sometime a packge may need to reinstall. `yum` has __reinstall__ command for that.

{% highlight shell %}
$ sudo yum reinstall tree
{% endhighlight %}

# Updating Package

We can check for update using following command. This command will download new meatadata and display list like `yum
list updates`.

{% highlight shell %}
$ sudo yum check-update
{% endhighlight %}

We can specify pacakge glob then packges matching that will be printed. Let's check the update status of `curl` packge.

{% highlight shell %}
$ sudo yum check-update curl
curl.x86_64                   7.29.0-51.el7_6.3                    updates

$ rpm -q curl
curl-7.29.0-46.el7.x86_64
{% endhighlight %}

We can update a package using __update__ subcommand. If don't specify any packges all updatable packges will be updated.
We can add __--skip-broken__ flag for skipping packages with unmet dependcies. We can also skip update of packges using
__-x__ flag.

{% highlight shell %}
$ sudo yum update curl

# Update all installed updatable packages except vim
$ sudo yum update --skip-broken -x vim
{% endhighlight %}

By default `yum` __update__ installs obsoletes packages. If update of obsolete packages is disabled in `/etc/yum.conf`,
then we can update obsoletes packages using __--obsoletes__ flag with __update__ or using __upgrage__ subcommand.

Obsolete packages are those installed packages which are replaced by other packages.  We can list obsolete packages
using following command.

{% highlight shell %}
$ yum list obsoletes

Obsoleting Packages
grub2.x86_64                        1:2.02-0.76.el7.centos.1           updates
    grub2.x86_64                    1:2.02-0.65.el7.centos.2           @anaconda
grub2-tools.x86_64                  1:2.02-0.76.el7.centos.1           updates
    grub2-tools.x86_64              1:2.02-0.65.el7.centos.2           @anaconda
grub2-tools-extra.x86_64            1:2.02-0.76.el7.centos.1           updates
    grub2-tools.x86_64              1:2.02-0.65.el7.centos.2           @anaconda
grub2-tools-minimal.x86_64          1:2.02-0.76.el7.centos.1           updates
    grub2-tools.x86_64              1:2.02-0.65.el7.centos.2           @anaconda
{% endhighlight %}

All of these are grub2 related packages. We can upgrade those packages using command below:

{% highlight shell %}
$ sudo yum upgrade grub2*
{% endhighlight %}

# Removing Package

Package can be removed using __remove__ command. This command doesn't remove dependencies. For removing package with all
it's unused dependencies __autoremove__ can be used.

{% highlight shell %}
$ sudo yum autoremove -y tree

Resolving Dependencies
--> Running transaction check
---> Package tree.x86_64 0:1.6.0-10.el7 will be erased
--> Finished Dependency Resolution
--> Finding unneeded leftover dependencies
Found and removing 0 unneeded dependencies

Dependencies Resolved

================================================================================
 Package        Arch             Version                  Repository       Size
================================================================================
Removing:
 tree           x86_64           1.6.0-10.el7             @base            87 k

Transaction Summary
================================================================================
Remove  1 Package

Installed size: 87 k
Downloading packages:
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Erasing    : tree-1.6.0-10.el7.x86_64                                     1/1
  Verifying  : tree-1.6.0-10.el7.x86_64                                     1/1

Removed:
  tree.x86_64 0:1.6.0-10.el7

Complete!
{% endhighlight %}

# Yum Group

We can install multiple packages which are usually installed together using group. `yum` has a __group__ subcommand.

We can list groups using __list__ command. __ids__ options also prints group id.

{% highlight shell %}
$ yum group list ids

Available Environment Groups:
   Minimal Install (minimal)
   Compute Node (compute-node-environment)
   Infrastructure Server (infrastructure-server-environment)
   File and Print Server (file-print-server-environment)
   Basic Web Server (web-server-environment)
   Virtualization Host (virtualization-host-environment)
   Server with GUI (graphical-server-environment)
   GNOME Desktop (gnome-desktop-environment)
   KDE Plasma Workspaces (kde-desktop-environment)
   Development and Creative Workstation (developer-workstation-environment)
Available Groups:
   Compatibility Libraries (compat-libraries)
   Console Internet Tools (console-internet)
   Development Tools (development)
   Graphical Administration Tools (graphical-admin-tools)
   Legacy UNIX Compatibility (legacy-unix)
   Scientific Support (scientific)
   Security Tools (security-tools)
   Smart Card Support (smart-card)
   System Administration Tools (system-admin-tools)
   System Management (system-management)
{% endhighlight %}

Adding __hidden__ will also show groups not marked as visible. Group list also take options like __installed__,
__environment__, __available__.

We can query information using __info__ command. We can either use group name or id.
{% highlight shell %}
$ yum group info "Smart Card Support"
# Or
$ yum group info smart-card

Group: Smart Card Support
 Group-Id: smart-card
 Description: Support for using smart card authentication.
 Default Packages:
   +coolkey
   +esc
   +pcsc-lite-ccid
 Optional Packages:
   opencryptoki
   opensc
{% endhighlight %}

Note __coolkey__ package had __+__ before it, means it will be installed if we install the group. __=__ means package is
already installed as a part of group and empty means package is installed but not as part of group.

__group install__ command is used for installing groups.
{% highlight shell %}
$ sudo yum group install <groupNameOrId>
{% endhighlight %}

We can also use package __install__ command to install group. We just need to add __@__ before group name. For
installing __smart-card__ group. We have to write.

{% highlight shell %}
$ sudo yum install @smart-card

# Or
$ sudo yum install @"Smart Card Support"
{% endhighlight %}

Group can have 3 type of package __Mandaotry__, __Default__, __Optional__. By default only __Mandatory__ and __Default__
packages are installed. We can add __group-package-type__ option in `/etc/yum.conf` or add with __--setopt__ while
installing package.

{% highlight shell %}
$ sudo yum --setopt=group-package-type=mandatory,default,optional \
           group install smart-card
{% endhighlight %}

Is it possible to install a package separately and then install the group containing that package. We may want to treat
that package as part of that group. For that we have to run following commands:

{% highlight shell %}
$ sudo yum group mark install <groupNameOrId>
$ sudo yum group mark convert <groupNameOrId>
{% endhighlight %}

We can update group using __update__ command:

{% highlight shell %}
$ sudo yum update @smart-card
$ sudo yum update @"Smart Card Support"

# Or
$ sudo yum group update smart-card
{% endhighlight %}

For removing we have __group remove__ but nothing like __autoremove__. For auto removing we have to use package level
command.

{% highlight shell %}
$ sudo yum remove @smart-card
$ sudo yum remove @"Smart Card Support"

# Or
$ sudo yum group remove smart-card
$ sudo yum group remove "Smart Card Support"

# Or better `autoremove`
$ sudo yum autoremove @smart-card
{% endhighlight %}

# Configuration
`yum` main configuration file is `/etc/yum.conf`. Also has a directory `/etc/yum/` which contains various other
configuration files.

Plugin related configurations are located in `/etc/yum/pluginconf.d/` directory. Files ending with __.repo__ files in
`/etc/yum.repos.d` directory contain repository information. Each file can contain multiple repository definition.

These repository files are installed as part of __centos-release__ package. We can see enabled repository using
following command. __disabled__ shows all disabled repository.

{% highlight shell %}
$ yum repolist enabled # Or yum repolist

repo id                          repo name                          status
base/7/x86_64                    CentOS-7 - Base                    10,019
extras/7/x86_64                  CentOS-7 - Extras                     435
updates/7/x86_64                 CentOS-7 - Updates                  2,500
repolist: 12,954
{% endhighlight %}

Detailed repository information can be seen using __repoinfo__ command. For querying detailed information about __base__
repository we have to write

{% highlight shell %}
$ yum repoinfo base

Repo-id      : base/7/x86_64
Repo-name    : CentOS-7 - Base
Repo-status  : enabled
Repo-revision: 1543161601
Repo-updated : Sun Nov 25 22:00:34 2018
Repo-pkgs    : 10,019
Repo-size    : 9.4 G
Repo-mirrors : http://mirrorlist.centos.org/?release=7&arch=x86_64&repo=os&infra=stock
Repo-baseurl : http://mirror.dhakacom.com/centos/7.6.1810/os/x86_64/ (9 more)
Repo-expire  : 21,600 second(s) (last: Wed Aug 14 17:05:26 2019)
  Filter     : read-only:present
Repo-filename: /etc/yum.repos.d/CentOS-Base.repo

repolist: 10,019
{% endhighlight %}

We can temporarily disable a repository using __--disablerepo__ and enable a disabled repository using __--enablerepo__
flag.

We can see that `/etc/yum.repos.d/CentOS-Base.repo` has __base__, __extra__, __updates__, __centosplus__ repository
definition. By default __centosplus__ repository is disabled. We can update that file or enable temporarily for a
single command like below:

{% highlight shell %}
$ yum --disablerepo="*" --enablerepo="centosplus" list
{% endhighlight %}

# Tools Version
* yum 3.4.3-158.el7.centos.noarch

# Bookmarks
* [yum(8) Manual Page](https://linux.die.net/man/8/yum)
* [yum.conf(5) Manual Page](https://linux.die.net/man/5/yum.conf)
