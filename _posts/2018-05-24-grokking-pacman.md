---
layout: post
title: "Grokking Pacman"
date: 2018-05-24 19:30:00 +0600
tags: pacman
---

# Introduction
Pacman (Arch Linux package manager) is the official front end of
[libalpm(3)][libalpm], the 'Arch Linux Package Management' library. It uses
`tar.xz` format as binary package format for simplicity and ease of use.
Conventionally prefixed `pkg` for denoting pacman package ie.
`grep-3.1.1-x86_64.pkg.tar.xz`.

# Usage

Show pacman version
{% highlight shell %}
$ pacman -V
{% endhighlight %}

Print Root, Conf File, DB Path, Cache Dirs, etc
{% highlight shell %}
$ pacman -v # or --verbose
{% endhighlight %}

Following options can be used to alter default path or directory:

| Option         | Description               | Default                |
|:--------------:|:-------------------------:|:----------------------:|
| --root         | Program installation root | /                      |
| --config       | Configuration file        | /etc/pacman.conf       |
| --dbpath or -b | Sync database directory   | /var/lib/pacman/       |
| --cachedir     | Package cache directory   | /var/cache/pacman/pkg/ |
| --hookdir      | Hooks directory           | /etc/pacman.d/hooks/   |
| --gnupg        | GnuPG directory           | /etc/pacman.d/gnupg/   |
| --logfile      | Action log                | /var/log/pacman.log    |

Change mirror list in `/etc/pacman.d/mirrorlist` as mirror precedence is order
based.

## Query Installed Packages
Query details about locally installed packages using __--query__ or __-Q__.

Show all installed package:
{% highlight shell %}
$ pacman -Q
{% endhighlight %}

List can be filtered using:

| -d | Packages installed as dependency            |
| -e | Explicitly installed packages               |
| -n | Packages installed form sync database       |
| -m | Installed manually or from AUR              |
| -g | Package belonging to named group            |
| -u | Outdated packages                           |
| -t | Not required or optionally required package |

List orphan packages:
{% highlight shell %}
$ pacman -Qdt
{% endhighlight %}

Print detailed info of package, __-ii__ prints with backup files information:
{% highlight shell %}
$ pacman -Qi <package-name>
{% endhighlight %}

Print all files of the package, add __-q__ for package name without version:
{% highlight shell %}
$ pacman -Ql <package-name>
{% endhighlight %}

Print changelog of a package if exist:
{% highlight shell %}
$ pacman -Qc <package-name>
{% endhighlight %}

Query which package owns the file:
{% highlight shell %}
$ pacman -Qo <filename>
{% endhighlight %}

Search locally installed packages by name or description using regexp:
{% highlight shell %}
$ pacman -Qs <regexp>
{% endhighlight %}

Check package required files are present in system:
{% highlight shell %}
$ pacman -Qk <package-name>
{% endhighlight %}

By default query against local database, __-p__ can be used for binary package.

Executing __-i__ on an binary package:
{% highlight shell %}
$ pacman -Qip <package-name>.pkg.tar.xz
{% endhighlight %}

## Install/Update Repository Packages
Package can be synchronized with remote, including all its dependencies using
__--sync__ or __-S__.

Refresh sync database, __-yy__ will refresh even if up to date:
{% highlight shell %}
$ sudo pacman -Sy
{% endhighlight %}

Update all outdated packages in system:
{% highlight shell %}
$ sudo pacman -Su
{% endhighlight %}

Install or update package with all its dependencies. Although not recommended
__--noconfirm__ can be used for bypassing confirmation:

{% highlight shell %}
$ sudo pacman -S --noconfirm <package-name or group>
{% endhighlight %}

Display information from sync database:
{% highlight shell %}
$ pacman -Si <package-name>
{% endhighlight %}

List all packages of target repository:
{% highlight shell %}
$ pacman -Sl <repository-name>
{% endhighlight %}

Print name of group with its members, omitting name will print all group:
{% highlight shell %}
$ pacman -Sgg <group-name>
{% endhighlight %}

Clear unused local package cache, __-cc__ will clear all cache:
{% highlight shell %}
$ sudo pacman -Sc
{% endhighlight %}

Download packages from the server without install/updating:
{% highlight shell %}
$ sudo pacman -Sw <package-name>
{% endhighlight %}

Search package by name or description, add __-q__ for only package name:
{% highlight shell %}
$ pacman -Ss <regexp>
{% endhighlight %}

## Install/Update Binary Packages
__--upgrade__ or __-U__ is used for updating or installing binary packages.

Update or install package from local binary package or URL:
{% highlight shell %}
$ sudo pacman -U /path/to/package
{% endhighlight %}

For *downgrading* a package, download from [Arch Linux Achieve][ala] and install
like above.

## Remove Packages
Remove package by name or group using __--remove__ or __-R__.

Remove a package or all packages of a group:
{% highlight shell %}
$ sudo pacman -R <package-name or group>
{% endhighlight %}

Remove package with non required dependencies, add __-n__ for including backup
configuration:
{% highlight shell %}
$ sudo pacman -Rsn <package-name>
{% endhighlight %}

## Query Remote Files
Search or Query file details of sync database packages using __--files__ or __-F__.

Refresh sync packages file database, __-yy__ will refresh even up to date:
{% highlight shell %}
$ sudo pacman -Fy
{% endhighlight %}

List files of package:
{% highlight shell %}
$ pacman -Fl <package-name>
{% endhighlight %}

Search for the owner of file:
{% highlight shell %}
$ pacman -Fo <filename>
{% endhighlight %}

Search filename with regular expression, omitting __-x__ will perform text search:
{% highlight shell %}
$ pacman -Fxs <regexp>
{% endhighlight %}

## Modify Local Database
__--database__ or __-D__ for modifying local package database attribute and internal
consistency check.

Check internal database dependency, __-Dkk__ for ensuring all decencies are in sync
database:
{% highlight shell %}
$ pacman -Dk
{% endhighlight %}

Mark package installation reason as dependency. Useful while installing package
for AUR dependency:
{% highlight shell %}
$ sudo pacman -D --asdeps <package-name>
{% endhighlight %}

Package can be marked __--asexplicit__ for keeping a dependent package even
when parent package is removed.

# Tools Version
* pacman 5.0.2

# Bookmarks
* [ManjaroWiki - Pacman Overview](https://wiki.manjaro.org/index.php?title=Pacman_Overview)
* [ArchWiki - Pacman Rosetta](https://wiki.archlinux.org/index.php/Pacman/Rosetta)
* [pacman(8) Manual Page](https://www.archlinux.org/pacman/pacman.8.html)

[libalpm]: https://www.archlinux.org/pacman/libalpm.3.html
[ala]: https://archive.archlinux.org
