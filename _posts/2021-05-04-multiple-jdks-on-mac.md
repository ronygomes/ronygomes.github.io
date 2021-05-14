---
layout: post
title: Multiple JDKs on Mac
date: 2021-05-04 20:00:00 +0600
tags: mac java jdk
---

# Overview
With the new release model of `Java`, now new Java version is released after
every 6 months. For learning and experimenting with different JDK versions it is
mandatory to install and manage multiple versions. In this article we will learn
how easily we can manage multiple JDKs on Mac OS.

# Install Location
When an Oracle JDK is installed in Mac OS, it is installed in following
directory: `/Library/Java/JavaVirtualMachines`. I have 3 JDK installed in my
machine, so it has 3 separate directory. We can view the content of this
directory using `ls` command.

{% highlight shell %}
$ ls -la /Library/Java/JavaVirtualMachines
total 0
drwxr-xr-x  5 root  wheel  160 May  2 12:48 .
drwxr-xr-x  4 root  wheel  128 Jan 23  2020 ..
drwxr-xr-x  3 root  wheel   96 May  2 12:48 jdk-16.0.1.jdk
drwxr-xr-x  3 root  wheel   96 Dec 13  2016 jdk1.7.0_79.jdk
drwxr-xr-x  3 root  wheel   96 Sep  8  2019 jdk1.8.0_221.jdk
{% endhighlight %}

Now lets see which version of `java` binary is selected by default.
{% highlight shell %}
$ java -version 
java version "16.0.1" 2021-04-20
Java(TM) SE Runtime Environment (build 16.0.1+9-24)
Java HotSpot(TM) 64-Bit Server VM (build 16.0.1+9-24, mixed mode, sharing)

$ which java
/usr/bin/java

$ readlink $(which java)
/System/Library/Frameworks/JavaVM.framework/Versions/Current/Commands/java

$ readlink /System/Library/Frameworks/JavaVM.framework/Versions/Current/Commands/java
$ ls -la /System/Library/Frameworks/JavaVM.framework/Versions/Current/Commands/java
-rwxr-xr-x  1 root  wheel  38880 May 28  2020 /System/Library/Frameworks/JavaVM.framework/Versions/Current/Commands/java
{% endhighlight %}

It looks like `java` is alias to
`/System/Library/Frameworks/JavaVM.framework/Versions/Current/Commands/java`.
But this file is not symbolic link. Now lets see which version it is:

{% highlight shell %}
$ /System/Library/Frameworks/JavaVM.framework/Versions/Current/Commands/java -version 
java version "16.0.1" 2021-04-20
Java(TM) SE Runtime Environment (build 16.0.1+9-24)
Java HotSpot(TM) 64-Bit Server VM (build 16.0.1+9-24, mixed mode, sharing)
{% endhighlight %}

By this it seems like it is coping Java 16 binary. But MD5 sum of these two binary doesn't match.

{% highlight shell %}

$ md5 /Library/Java/JavaVirtualMachines/jdk-16.0.1.jdk/Contents/Home/bin/java
MD5 (/Library/Java/JavaVirtualMachines/jdk-16.0.1.jdk/Contents/Home/bin/java) = 6260ad30c7ac6f36226589f8c31d01b9

$ md5 /System/Library/Frameworks/JavaVM.framework/Versions/Current/Commands/java
MD5 (/System/Library/Frameworks/JavaVM.framework/Versions/Current/Commands/java) = 41a719da5c04632f527db111d61088d0
{% endhighlight %}

Actually binaries within
`/System/Library/Frameworks/JavaVM.framework/Versions/Current/Commands` are stub
applications that determine which Java to use. And by default top Java version
is selected for use.

# Introducing `java_home` Command
`/System/Library/Frameworks/JavaVM.framework/Versions/Current/Commands`
directory has a binary named `java_home` which can be used for querying various
installed Java version's home directory. This binary is aliased as
`/usr/libexec/java_home`. As `/usr/libexec` directory is not included in `$PATH` by
default, so always need to enter full command path.

{% highlight shell %}
$ readlink /usr/libexec/java_home
/System/Library/Frameworks/JavaVM.framework/Versions/Current/Commands/java_home
{% endhighlight %}

Now lets play with `java_home`:

{% highlight shell %}
# Executing without any args prints top installed Java's Home
$ /usr/libexec/java_home
/Library/Java/JavaVirtualMachines/jdk-16.0.1.jdk/Contents/Home

# -V options shows list of all installed JDK 
$ /usr/libexec/java_home -V
Matching Java Virtual Machines (3):
    16.0.1, x86_64:	"Java SE 16.0.1"	/Library/Java/JavaVirtualMachines/jdk-16.0.1.jdk/Contents/Home
    1.8.0_221, x86_64:	"Java SE 8"	/Library/Java/JavaVirtualMachines/jdk1.8.0_221.jdk/Contents/Home
    1.7.0_79, x86_64:	"Java SE 7"	/Library/Java/JavaVirtualMachines/jdk1.7.0_79.jdk/Contents/Home

/Library/Java/JavaVirtualMachines/jdk-16.0.1.jdk/Contents/Home

# Can list a specific Java's home with -v 
$ /usr/libexec/java_home -v 1.8
/Library/Java/JavaVirtualMachines/jdk1.8.0_221.jdk/Contents/Home

# -exec is used to run specific version of java
$ /usr/libexec/java_home -v 1.8 -exec java -version
java version "1.8.0_221"
Java(TM) SE Runtime Environment (build 1.8.0_221-b11)
Java HotSpot(TM) 64-Bit Server VM (build 25.221-b11, mixed mode)

{% endhighlight %}

# Switching Java Version
Interesting thing is all commands in
`/System/Library/Frameworks/JavaVM.framework/Versions/Current/Commands` obeys
`$JAVA_HOME` environment variable. So if we update the `JAVA_HOME` variable we
can use different `java` version.

{% highlight shell %}
# Initial Java Version is 16
$ java -version 
java version "16.0.1" 2021-04-20
Java(TM) SE Runtime Environment (build 16.0.1+9-24)
Java HotSpot(TM) 64-Bit Server VM (build 16.0.1+9-24, mixed mode, sharing)

# Exported Java 1.8 as JAVA_HOME
$ export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)

# Now its Java 1.8
$ java -version 
java version "1.8.0_221"
Java(TM) SE Runtime Environment (build 1.8.0_221-b11)
Java HotSpot(TM) 64-Bit Server VM (build 25.221-b11, mixed mode)
{% endhighlight %}

To make it permanent we have write this line in `.bash_profile`.
{% highlight shell %}
$ echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)' >> ~/.bash_profile
{% endhighlight %}

Now we are using system wide Java 8 but we still get `jshell` command which was
introduced in `Java 9`. But running `jshell` shows following error:

{% highlight shell %}
$ readlink $(which jshell)
/System/Library/Frameworks/JavaVM.framework/Versions/Current/Commands/jshell

$ jshell
Unable to locate an executable at "/Library/Java/JavaVirtualMachines/jdk1.8.0_221.jdk/Contents/Home/bin/jshell" (-1)
{% endhighlight %}

But we can write us a simple alias like below:
{% highlight shell %}
$ alias jshell16='/usr/libexec/java_home -v 16 -exec jshell'
$ jshell16
|  Welcome to JShell -- Version 16.0.1
|  For an introduction type: /help intro

jshell> 
{% endhighlight %}

We can also write alias to easily switch between JDKs like below:

{% highlight shell %}
$ alias setJdk7='unset JAVA_HOME; export JAVA_HOME=$(/usr/libexec/java_home -v 1.7)'
$ setJdk7
$ java -version 
java version "1.7.0_79"
Java(TM) SE Runtime Environment (build 1.7.0_79-b15)
Java HotSpot(TM) 64-Bit Server VM (build 24.79-b02, mixed mode)
{% endhighlight %}


# Link
* <https://stackoverflow.com/questions/15120745/understanding-oracles-java-on-mac>
* <https://developer.apple.com/library/archive/qa/qa1170/_index.html>