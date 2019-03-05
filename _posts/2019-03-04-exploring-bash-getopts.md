---
layout: post
title: "Exploring Bash getopts"
date: 2019-03-04 15:30:00 +0600
tags: bash bash-builtin getopts
---

# Introduction
Bash has a builtin command `getopts` for parsing parameters given as options (i.e -v, -e). `getopts` can only parse
single character arguments that starts with __-__. GNU style options (i.e. --version) should be parsed manually or with
other command.

# Usage
`getopts` has the following signature:
{% highlight shell %}
getopts OPTSTRING NAME [ARG]
{% endhighlight %}
__OPTSTRING__ is possible options as string. Each time `getopts` is invoked it parses an __ARG__ character using
__OPTSTRING__. If __ARG__ is omitted `getopts` parses positional parameters (i.e. __$1 - $9__).

__OPTSTRING__ accepts any uppercase, lowercase, number and most special characters as option. When it starts with
*colon* (:), error reporting is turned off. If *colon* (:) is added after a option/character then that options must have
value.

__OPTSTRING Example:__

`vn` - Accepts __-v__ and __-n__ options. __-vn__ or __-nv__ is also possible. If any invalid options is given prints an
error message.

`:vn` - Accepts same options as `vn`, error reporting is turned off as prefixed with colon (:).

 `vn:` - Accepts same -v option, but -n now expects value, (i.e. -n3 or -n 3 or -vn3 or -vn 3).

`getopts` has 3 predefined variables:

| Name           | Description                                                                  |
|:--------------:|:-----------------------------------------------------------------------------|
| `OPTIND`       | Index of next argument to process. It is initialized to 1 when shell starts  |
| `OPTARG`       | If options accepts value, then its put on this variable                      |
| `OPTERR`       | Defaults to 1, stops error reporting when 0                                  |


`getopts` fails when all options is parsed. So its can be written with loop:

{% highlight shell %}
#!/bin/bash
# filename: getopts-test.sh
while getopts "vn:" NAME; do
    printf "NAME: %s, OPTIND: %d, OPTARG: %s\n" $NAME $OPTIND $OPTARG
done

# if run as ./getopts-test.sh -n -v 3
# NAME: v, OPTIND: 2, OPTARG:
# NAME: n, OPTIND: 4, OPTARG: 3

# if run as ./getopts-test.sh -nv3
# NAME: v, OPTIND: 1, OPTARG: 
# NAME: n, OPTIND: 2, OPTARG: 3

# if run as ./getopts-test.sh -zn3
# test.sh: illegal option -- z
# NAME: ?, OPTIND: 1, OPTARG: 
# NAME: n, OPTIND: 2, OPTARG: 3
{% endhighlight %}

When error reporting is off, invalid character is put in __OPTARG__ and `?` is put in __NAME__.

{% highlight shell %}
#!/bin/bash
# filename: getopts-test.sh
while getopts ":vn:" NAME; do
    printf "NAME: %s, OPTIND: %d, OPTARG: %s\n" $NAME $OPTIND $OPTARG
done

# if run as ./getopts-test.sh -zn3
# NAME: ?, OPTIND: 1, OPTARG: z
# NAME: n, OPTIND: 2, OPTARG: 3

{% endhighlight %}

Its helpful to use `getopts` with case statement.

{% highlight shell %}
#!/bin/bash
# filename: getopts-test.sh
while getopts ":vn:" NAME; do
    case "$NAME" in
        v) echo "Version 1.00" ;;
        n) echo "n:" $OPTARG ;;
        *) echo "Invalid argument";;
    esac
done

# shift parsed parameters
shift $(( OPTIND - 1 ))

# if run as ./getopts-test.sh -v -n 3 -z
# Version 1.00
# n: 3
# Invalid argument
{% endhighlight %}

# Tools Version
* bash 4.4.19(1)-release

# Bookmarks
* [$ help __getopts__](https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html#Bourne-Shell-Builtins)
* [StackOverflow Question](https://stackoverflow.com/questions/16483119/an-example-of-how-to-use-getopts-in-bash)
