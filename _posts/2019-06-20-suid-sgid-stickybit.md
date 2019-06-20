---
layout: post
title: "SUID, SGID, Sticky Bit"
date: 2019-06-20 10:00:00 +0600
tags: linux suid sgid stickbit
---

# Introduction
Special permission like __SUID__, __SGID__, __Sticky bit__ can be set in files or directories using `chmod` command.
These permissions allow files and directories to work effectively in collaborative environment.

# SUID
__SUID__ (Set User Identifier) allows to run a file with the privilege of the owner of that file. The runner must have
the privilege to execute that file but while executing the file runner's privilege is elevated to the owner.

#### Example
Lets see an example, lets check the permission of `passwd` command:

{% highlight shell %}
$ ls -l $(which passwd)
-rwsr-xr-x 1 root root 59640 Jan 25  2018 /usr/bin/passwd
{% endhighlight %}

Note __passwd__ command's  owner is root and owner's privilege __rws__, execute bit is __s__ meaning __SUID__ is set for
this executable.

`passwd` command can be run in two ways. __root__ user can change other's password like below:
{% highlight shell %}
$ su root
$ passwd <user>
{% endhighlight %}

Any non privileged user can change his own password using `passwd` command like below:
{% highlight shell %}
$ passwd
{% endhighlight %}

In both cases `/etc/passwd` file is updated with new password. Now if we check the permission of `/etc/passwd` file:

{% highlight shell %}
$ ls -l /etc/passwd
-rw-r--r-- 1 root root 2450 Jan 27 15:59 /etc/passwd
{% endhighlight %}

We can see only __root__ has the write permission in `/etc/passwd` file. Then how can a non privileged user changes the
content of `/etc/passwd` file using some command. Hence the __SUID__ bit.

As __SUID__ bit is set in `passwd` command, when an non privileged user executes the command (user must have execute
permission) he/she run the `passwd` command with the privilege of __root__. Then `passwd` command decides what the
regular user can do. In this case can only change his own password.

You may be wondering, as `passwd` command is running with all the privilege of __root__, what if it is doing something
evil. Moreover what if some closed source command needs __SUID__ bit to be set. Luckily starting form Kernel version 2.2
Linux has a feature called __capabilites__ which can assign only the permission a command needs to finish his job.

We can set __SUID__ bit on a file using `chmod`.
{% highlight shell %}
$ cat hello.sh

#!/bin/bash
echo "Hello World"

$ ls -l hello.sh
-rw-rw-r-- 1 john john 31 Jun 20 10:54 /home/john/hello.sh

$ chmod u+s hello.sh

$ ls -l hello.sh
-rwSrw-r-- 1 john john 31 Jun 20 10:54 /home/john/hello.sh
{% endhighlight %}

As __hello.sh__ was not executable when adding __SUID__ for owner using __u+s__, executable bit is now __S__ (Uppercase
s). Now lets make __hello.sh__ executable.

{% highlight shell %}
$ chmod u+x hello.sh

$ ls -l hello.sh
-rwsrw-r-- 1 john john 31 Jun 20 10:54 /home/john/hello.sh
{% endhighlight %}

As __hello.sh__ is executable now __SUID__ is denoted by lowercase __s__. Now make this script executable for other
users.

{% highlight shell %}
$ chmod o+x hello.sh

$ ls -l hello.sh
-rwsrw-r-x 1 john john 31 Jun 20 10:54 /home/john/hello.sh
{% endhighlight %}

Now any other user can run the script with the permission of owner of the script ie. __john__. But for security reason
changing __SUID__ bit doesn't have any impact on any scripts. If __hello.sh__ was a compiled binary. It would work like
as expected. Lets see that in action.

I have written a simple C code which prints the User ID of runner along with Effective UID, the user whose permission is
active.

{% highlight c %}
// file: program.c
#include <stdio.h>
#include <unistd.h>

int main(int argc, char** argv) {
    printf("Runner UID: %d\n", getuid());
    printf("Effective UID: %d\n", geteuid());
    return 0;
}
{% endhighlight %}

Lets compile the program using __gcc__ and change the owner to __root__.
{% highlight shell %}
$ gcc -o program program.c

$ ls -l program
-rwxr-xr-x 1 john john 8392 Jun 20 11:30 /home/john/program

$ sudo chown root:root program

$ ls -l program
-rwxr-xr-x 1 root root 8392 Jun 20 11:30 /home/john/program

$ ./program
UID: 1000
Effective UID: 1000

$ id -un 1000
john
{% endhighlight %}

Now lets change the __SUID__ bit and run again.

{% highlight shell %}
$ sudo chmod u+s program

$ ls -l program
-rwsr-xr-x 1 root root 8392 Jun 20 11:30 /home/john/program

$ ./program
UID: 1000
Effective UID: 0

$ id -un 0
root
{% endhighlight %}

# SGID
__SGID__ (Set Group Identifier) works both on files and directories. When added on file it works just like __SUID__ but
for group.

{% highlight shell %}
$ sudo chown john:staff gprog

$ chmod o+x gprog
$ chmod g+s gprog

$ ls -l gporg
-rwxr-sr-x 1 john staff 31 Jun 20 11:30 /home/john/gprog
{% endhighlight %}

As __SGID__ is set for this executable, an user who is not part of __staff__ group can run this imaginary program with
the permission of __staff__ group.

__SGID__ bit can also be set on directory. Normally when an user creates a new file, that file's group is set to the
user's current active group. But if __SGID__ bit is set for parent directory then new file's group is set to parent
directory's group.

{% highlight shell %}
$ mkdir reports

$ ls -ld reports
drwxr-xr-x 2 john john 4096 Jun 20 12:13 reports/

$ cd reports
$ touch file1

$ ls -l file1
-rw-r--r-- 1 john john 0 Jun 20 12:17 file1
{% endhighlight %}

Now let's change the group of __reports__ directory to __staff__ and set __GUID__ bit. Now files created inside this
directory will automatically belong to __staff__ group as it is the group of parent directory.

{% highlight shell %}
$ sudo chown john:staff reports
$ sudo chmod g+s reports

$ ls -ld reports
drwxr-xr-x 2 john staff 4096 Jun 20 12:13 reports/

$ cd reports
$ touch file2

$ ls -l file2
-rw-r--r-- 1 john staff 0 Jun 20 12:17 file2
{% endhighlight %}

It is very useful for collaborative environment. Otherwise if a user creates some file without switching group that
file becomes inaccessible for other users.


# Sticky bit
Stick bit is only meaningful when set on directory. This is also a feature for collaborative environment. If sticky bit
is set on a directory, then only the owner can remove or rename file inside that directory, even when the other regular
user has write access.

{% highlight shell %}
$ sudo mkdir /sticky
$ sudo chown root:staff /sticky
$ sudo chmod ugo+rwx /sticky
$ sudo chmod +t /sticky

# Sticky bit is denoted with 't' ('T' if not executable)
$ ls -ld /sticky
drwxrwxrwt 2 root staff 4096 Jun 20 12:51 /sticky/

$ cd /sticky
$ touch file1
$ ls -l file1
rw-rw-rw- 1 john john 0 Jun 20 12:55 file

$ su jane
$ cd /sticky
$ rm file
rm: cannot remove 'file': Operation not permitted

$ mv file file1
mv: cannot move 'file' to 'file2': Operation not permitted

$ echo "Can write but can't delete" > file
{% endhighlight %}

__sticky__ folder has complete __rwx__ for everybody, but  __jane__ cannot delete files of __john__ as sticky bit is
set.

# Tools Version
* chmod (GNU coreutils) 8.28
* gcc (Ubuntu 7.3.0-27ubuntu1~18.04) 7.3.0

# Bookmarks
* [chmod(1) Manual Page](https://linux.die.net/man/1/chmod)
* [geteuid(2) Manual Page](https://linux.die.net/man/2/geteuid)
* [Wikipedia - Setuid](https://en.wikipedia.org/wiki/Setuid)
