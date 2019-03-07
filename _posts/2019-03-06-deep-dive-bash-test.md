---
layout: post
title: "Deep Dive Bash test"
date: 2019-03-06 17:30:00 +0600
tags: bash bash-builtin test
---

# Introduction
Had hard time learning __if/else__ for the first time in bash after coming from C/C++. I was quite confused why spacing
is so important with `[` and `]`. Later realized  `[` is just a synonym for `test` command.

# Understanding if

If we look into the signature of `if` bash builtin:
{% highlight shell %}
if COMMANDS_0
then
    COMMANDS_1
fi
{% endhighlight %}

`if` executes based on the exit status of __COMMAND_0__. Now following code should and will run without any error if
`echo` exits successfully.

{% highlight shell %}
if echo "Near if"
    then echo "Inside if"
fi

# Output:
# Near if
# Inside if
{% endhighlight %}

`if` also works with exit status of `funciton`. As we can control/return exit status of function, we can write a
function like,

{% highlight shell %}
True () {
    echo "Inside 'True' function"
    return 0
}

# As last command's exit status is returned automatically
# We can even remove the return statement
True () {
    echo "Inside 'True' function"
}
{% endhighlight %}

Now we can write `if` like:
{% highlight shell %}
if True
then
    echo "Inside if"
fi

# Output:
# Inside 'True' function
# Inside if
{% endhighlight %}

We can further update the function and write function like __file_exists__:

{% highlight shell %}
file_exists() {
    FILE_NAME="$1"
    # Redirecting both stdin and stdout to /dev/null
    ls "$FILE_NAME" &> /dev/null
}

if file_exists "/etc/passwd"
then
    echo "File exists"
fi

# Output:
# File exists
{% endhighlight %}

Bash builtin `test` is like __file_exits__ function but with lots of options and flexible. We can check existence of
file using __-f__ `test` option.

{% highlight shell %}
if test -f "/etc/passwd"
then
    echo "File exists"
fi
{% endhighlight %}

# test Operations
`test` builtin has lots of options for checking conditions. `test` also has a synonym `[`, which behaves exactly same as
`test` only expects last augments to be `]`.

## File Operations:
Here only some important file operations are mentioned. For complete list see `help test`.

| Option               | Description                             |
|:--------------------:|:----------------------------------------|
| __-a FILE__          |  True if FILE exists                    |
| __-e FILE__          |  True if FILE exists                    |
| __-f FILE__          |  True if FILE is a regular file         |
| __-d FILE__          |  True if FILE is a directory            |
| __-h FILE__          |  True if FILE is a symbolic link        |
| __-L FILE__          |  True if FILE is a symbolic link        |
| __-r FILE__          |  True if FILE is readable by user       |
| __-w FILE__          |  True if FILE is writeable by user      |
| __-x FILE__          |  True if FILE is executable by user     |
| __-s FILE__          |  True if FILE is not empty              |
| __-O FILE__          |  True if FILE is owned by user          |
| __-G FILE__          |  True if FILE is owned by user's group  |
| __FILE1 -nt FILE2__  |  True if FILE1 is newer than FILE2      |
| __FILE1 -ef FILE2__  |  True if FILE1 is hard link of FILE2    |

All file operations except __-h__ and __-L__ works on the target file if FILE is a symbolic link.

{% highlight shell %}
if test -d "/etc"
then
    echo "File exists and is a directory"
fi

# Can also be written with [
if [ -d "/etc" ]
then
    echo "File exists and is a directory"
fi

# Output:
# File exists and is a directory
{% endhighlight %}


## String Operations:

| Option                  | Description                                  |
|:-----------------------:|:---------------------------------------------|
| __-z STRING__           |  True if STRING is empty                     |
| __-n STRING__           |  True if STRING is not empty                 |
| __STRING1 = STRING2__   |  True if STRING1 and STRING2 are equal       |
| __STRING1 != STRING2__  |  True if STRING1 and STRING2 not are equal   |

{% highlight shell %}
if [ -z "" ]
then
    echo "Empty String"
fi

# Output:
# Empty String

if [ "John" != "Jane" ]
then
    echo "Strings are not equal"
fi

# Output:
# Strings are not equal
{% endhighlight %}

## Arithmetic Operations:

| Option             | Description                                     |
|:------------------:|:------------------------------------------------|
| __NUM1 -eq NUM2__  |  True if NUM1 and NUM2 are equal                |
| __NUM1 -ne NUM2__  |  True if NUM1 and NUM2 are not equal            |
| __NUM1 -lt NUM2__  |  True if NUM1 is less than NUM2                 |
| __NUM1 -le NUM2__  |  True if NUM1 is less than or equal to NUM2     |
| __NUM1 -gt NUM2__  |  True if NUM1 is greater than NUM2              |
| __NUM1 -ge NUM2__  |  True if NUM1 is greater than or equal to NUM2  |

{% highlight shell %}
NUM1=5
NUM2=6
if [ "$NUM1" -lt "$NUM2" ]
then
    echo "$NUM1 is less than $NUM2"
fi

# Output:
# 5 is less than 6
{% endhighlight %}

## Other Operations:

| Option              | Description                                  |
|:-------------------:|:---------------------------------------------|
| __-v VAR__          |  True if VAR is defined                      |
| __! EXPR__          |  True if EXPR is false                       |
| __EXPR1 -a EXPR2__  |  True if both EXPR1 and EXPR2 is true        |
| __EXPR1 -o EXPR2__  |  True if either EXPR1 or EXPR2 is true       |

{% highlight shell %}
NAME="John"
if [ -v NAME ]
then
    echo "\$NAME = $NAME"
fi

# Output:
# $NAME = John

if [ ! -f "/root/not-exists" ]
then
    echo "File doesn't exists"
fi

# Output:
# File doesn't exists

NUM=5
if [ "$NUM" -gt 1 -a "$NUM" -lt 10 ]
then
    echo "$NUM is between 1-10"
fi

# We can also write using &&, as two separate command
NUM=5
if [ "$NUM" -gt 1 ] && [ "$NUM" -lt 10 ]
then
    echo "$NUM is between 1-10"
fi

# Output:
# 5 is between 1-10
{% endhighlight %}

# Playing with if
When we add multiple commands with `if` separated with `;`,`if` depends on exit status of last command.
{% highlight shell %}
if cat /file-not-found; echo "Hello"
then
    echo "Inside if"
fi

# Output:
# cat: /file-not-found: No such file or directory
# Hello
# Inside if

{% endhighlight %}

Same code can be written with grouping command `{}`. Inside `{` and `}` all command must end with `;`.
{% highlight shell %}
if { cat /file-not-found; echo "Hello"; }
then
    echo "Inside if"
fi

{% endhighlight %}

We can also run code inside a sub shell using `(` and `)`. This will create a separate environment and run code inside
that environment.

{% highlight shell %}
NUM=5
{ NUM=6; }
echo $NUM # Output: 6

# Created sub-shell
NUM=5
( NUM=6 )
echo $NUM # Output: 5

{% endhighlight %}

We can execute `if` clauses in sub shell, the output will be same.

{% highlight shell %}
if ( cat /file-not-found; echo "Hello" )
then
    echo "Inside if"
fi

{% endhighlight %}

# [ VS [[
Bash has another builtin `[[` which is superset of `[`. Its supports all features of `[` plus some more. The most
useful feature is matching regular expression with `=~`.

{% highlight shell %}
if [[ "John" =~ Jo.n ]]
then
    echo "Matched Jo.n"
fi

# Output:
# Matched Jo.n
{% endhighlight %}

We can also use `&&` and `||` inside `[[` and `]]`.
{% highlight shell %}
NUM=5
if [[ "$NUM" -gt 1 && "$NUM" -lt 10 ]]
then
    echo "$NUM is between 1-10"
fi
{% endhighlight %}
Check `help [[` for more details.
# Tools Version
* bash 4.4.19(1)-release

# Bookmarks
* [$ help __test__](https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html#Bourne-Shell-Builtins)
* [StackOverflow Question](https://unix.stackexchange.com/questions/306111/what-is-the-difference-between-the-bash-operators-vs-vs-vs)
