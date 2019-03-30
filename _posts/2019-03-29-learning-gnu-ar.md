---
layout: post
title: "Learning GNU ar"
date: 2019-03-29 13:30:00 +0600
tags: linux bash gnu ar
---

# Introduction
GNU `ar` can create, modify, extract archive. Usually __.a__ extension is used for denoting `ar` archives. This sort of
archive is used for creating library for holding commonly used subroutines. `ar` can also create an index for symbol
defined in library and stores in archive, which speeds up linking to the library.

# Usage
`ar` has the following signature:
{% highlight shell %}
ar [-]OPTION[MODIFIER [MEMBER]] ARCHIVE [MEMBER...]
{% endhighlight %}
__-__ is optional for `ar`, but I prefer to add __-__ in the command for consistency.

__Options:__

| Option | Description                                                                  |
|:------:|:-----------------------------------------------------------------------------|
| `r`    | Insert or replace the members in the archive
| `q`    | Quickly inserts members at the end of archive, doesn't update symbol table
| `s`    | Create or update symbol table, can also be used as modifier
| `t`    | Lists members in the archive
| `p`    | Prints content of file in archive on standard output
| `m`    | Moves member order in archive
| `d`    | Delete members in archive
| `x`    | Extracts files from archive

__Modifier:__

| Modifier     | Description                                                                  |
|:------------:|:-----------------------------------------------------------------------------|
| `a <MEMBER>` | Inserts after MEMBER in archive, by default inserts at end
| `b <MEMBER>` | Inserts before MEMBER in archive
| `c`          | Create archive if not exists
| `o`          | Preserve original date while extraction, else file stamped with extraction time
| `s`          | Create symbol table of binary object, can be seen using `nm -s <archive>`
| `T`          | Creates thin archive. Thin archive uses original file reference instead on copy
| `u`          | Inserts only if MEMBER is newer then the same name MEMBER in archive
| `v`          | Verbose mode, prints detailed information
| `V`          | Prints version

For complete list see `man ar`.

__Example:__

For demonstration purpose lets create sample files to work with using following script. This creates 3 files each with
one line 'Line NUM', where NUM is file number.

{% highlight shell %}
for NUM in 1 2 3; do
    echo "Line $NUM" > "file$NUM";
done
{% endhighlight %}

Now for creating an archive named __pack.a__ with __file1__ and __file3__ in it,
{% highlight shell %}
$ ar -r pack.a file1 file3
ar: creating pack.a
{% endhighlight %}

This creates __pack.a__ and prints a message in standard error. We can omit this message by adding __c__ modifier.
{% highlight shell %}
$ rm pack.a
$ ar -rc pack.a file1 file3
{% endhighlight %}

We can view the file names using __t__ option, __v__ modifies can be used for detailed information.
{% highlight shell %}
$ ar -t pack.a
file1
file3

$ ar -tv pack.a
rw-r--r-- 0/0     14 Jan  1 06:00 1970 file1
rw-r--r-- 0/0      7 Jan  1 06:00 1970 file3
{% endhighlight %}

__p__ option dumps the archive content in standard output, __v__ modifier prints with filename
{% highlight shell %}
$ ar -p pack.a
Line 1
Line 3

$ ar -pv pack.a
<file1>

Line 1

<file3>

Line 3
{% endhighlight %}

Now if we try to add __file3__ again in __pack.a__ it will be replaced. But __q__ options doesn't check for duplication
and quickly append at bottom. In some system it also doesn't update symbol table.
{% highlight shell %}
$ ar -r pack.a file3
$ ar -t pack.a
file1
file3

$ ar -q pack.a file3
$ ar -t pack.a
file1
file3
flle3
{% endhighlight %}

We can delete using __d__ option
{% highlight shell %}
$ ar -d pack.a file3
$ ar -t pack.a
file1
file3
{% endhighlight %}

By default __r__ appends new member at bottom. But __m__ option can be used for moving position

{% highlight shell %}
$ ar -r pack.a file2
$ ar -t pack.a
file1
file3
file2

# Move after file1
$ ar -ma file1 pack.a file2
$ ar -t pack.a
file1
file2
file3

# Insert file2 before file3
$ ar -d pack.a file2
$ ar -rb file3 pack.a file2
{% endhighlight %}

For updating index of symbol table we can use either __s__ option directly or with modifier __s__ while inserting or
appending. We can see symbol table with `nm -s <archive>`. Symbol table is meaningful only for compiled objects. In this
article only text files is used for archiving.

{% highlight shell %}
$ ar -s pack.a

# Or update table with 'r' or 'q'
$ ar -qs pack.a
{% endhighlight %}

For extracting from archive __x__ option is used. __o__ modifier can be used for exacting with original timestamps.

{% highlight shell %}
$ rm file1 file2 file3
$ ar -xo pack.a
$ ls
file1 file2 file3

# For extracting specific file(s)
$ rm file2
$ ar -x pack.a file2
$ ls
file1 file2 file3
{% endhighlight %}

For creating thin archive __T__ option is used, in this case file reference is used. An archive can either be thin or
normal. But can't be both. If member location or content changes `ar` produces error.

{% highlight shell %}
$ ar -rcT thin.a file1 file2 file3
$ ls
file1 file2 file3 pack.a thin.a

$ rm file1
$ ar -t thin.a
ar: thin.a: Malformed archive

{% endhighlight %}

# Tools Version
* GNU ar (GNU Binutils for Ubuntu) 2.30

# Bookmarks
* [ar(1) Manual Page](https://linux.die.net/man/1/ar)
* [MIT ar docs](http://web.mit.edu/gnu/doc/html/binutils_1.html)
