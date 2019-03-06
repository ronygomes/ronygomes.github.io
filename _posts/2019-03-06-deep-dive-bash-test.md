---
layout: post
title: "Deep Dive Bash test"
date: 2019-03-06 17:30:00 +0600
tags: bash bash-builtin test
published: false
---

# Introduction
Had hard time coding __if/else__ for the first time in bash after coming from C/C++. I was quite confused why spacing is
so important with `[` and `]`. Later realized  `[` is just a synonym for `test` command.

# Understanding if

if we look into the signature of `if` bash builtin:
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

# As last command's exit status is returned
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
{% endhighlight %}

Bash builtin `test` is like __file_exits__ function but with lots of options and flexible. We can check existence of
file using __-f__ `test` option.

{% highlight shell %}
if test -f "/etc/passwd"
then
    echo "File exists"
fi
{% endhighlight %}

# Tools Version
* bash 4.4.19(1)-release

# Bookmarks
* [$ help __test__](https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html#Bourne-Shell-Builtins)
