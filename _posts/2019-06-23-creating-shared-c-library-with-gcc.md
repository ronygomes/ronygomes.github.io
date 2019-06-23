---
layout: post
title: "Creating Shared C Library with GCC"
date: 2019-06-23 10:30:00 +0600
tags: linux c gcc
---

# Introduction
For ease of usage and re-usability we can compile C procedures using GCC and distribute as library. By compiling as
shared or dynamic library we can share a single source of library across different applications in system. This reduces
the overall size of application but need to mange dependency and path of shared libraries.

# Compiling Application Without Library
For this article we will use a simple program. First we will run the program, then will split into files and reuse some
part as shared library.

{% highlight c %}
// main.c
#include <stdio.h>

void printDecorated(char* message) {
    printf("- %s -\n", message);
}

void printGreetings(int n) {
    for (int i = 0; i < n; i++) {
        printDecorated("Hello");
    }
}

int main () {
    printGreetings(3);
    return 0;
}
{% endhighlight %}

Now we can compile and run using following commands, __-o__ for naming the executable:

{% highlight shell %}
$ gcc -o main main.c
$ ./main
- Hello -
- Hello -
- Hello -
{% endhighlight %}

Now we can reorganize the functions in separate files. Lets move __printDecorate__ function in __decorate.c__ and
__printGreetings__ in __greeter.c__ file. We also create a header file with these function prototypes __greet.h__ and
update include statements.

{% highlight c %}
// greet.h
void printGreetings(int);
void printDecorated(char *);

{% endhighlight %}

{% highlight c %}
// decorate.c
#include <stdio.h>

void printDecorated(char* message) {
    printf("- %s -\n", message);
}

{% endhighlight %}

{% highlight c %}
// greeter.c
#include <stdio.h>
#include "greet.h"

void printGreetings(int n) {
    for (int i = 0; i < n; i++) {
        printDecorated("Hello");
    }
}

{% endhighlight %}

{% highlight c %}
// main.c
#include <stdio.h>
#include "greet.h"

int main () {
    printGreetings(3);
    return 0;
}

{% endhighlight %}

For compiling and running we use following commnads:
{% highlight shell %}
$ gcc -o main decorate.c greeter.c main.c
$ ./main
- Hello -
- Hello -
- Hello -
{% endhighlight %}

Note we have included using `"greet.h"` not `<greet.h>`. This will work as long as __greet.h__ is in same folder. By
default `gcc` searches for include files in `/usr/include/` or `/usr/local/include/`. We can also add additional path
using `gcc` __-I__ option.

Now if we change the include statement of __main.c__ and __greeter.c__ to `<greet.h>`. We can compile like below:
{% highlight shell %}
$ gcc -I "$PWD" -o main decorate.c greeter.c main.c
{% endhighlight %}

Or we can copy __greet.h__ in `/usr/include/` or `/usr/local/include/`, then we can compiler directly.
{% highlight shell %}
$ gcc -o main decorate.c greeter.c main.c
{% endhighlight %}

# Compiling and Running Shared Library

As the compiled code will be shared across multiple applications we have to compile differently with __pic__ (Position
Independent Code) option. This will make sure that library doesn't store data at fixed addresses which will cause issue
when shared across multiple applications.

{% highlight shell %}
$ ls
decorate.c greeter.c greet.h main.c

# Added -I for including greet.h in $PWD
$ gcc -I "$PWD" -fpic -c greeter.c decorate.c

$ ls
decorate.c decorate.o greeter.c greeter.o greet.h main.c

{% endhighlight %}

Now create a shared library using following command. Library must be prefixed with __lib__ and shared library are
suffixed with __.so__. Here __libgreet.so__ is the name of library.

{% highlight shell %}
$ gcc -shared -o libgreet.so decorate.o greeter.o
{% endhighlight %}

Now lets compile the __main.c__ using newly created shared library.

{% highlight shell %}
$ ls
decorate.c  decorate.o  greeter.c  greeter.o  greet.h  libgreet.so  main.c

# -L include addtional library, by default searches in /usr/local/lib/ or /usr/lib/
# -l uses libgreet.so library, note only `greet` is given
$ gcc -I "$PWD" -L "$PWD" -o main main.c -lgreet

{% endhighlight %}

Now if we copy the __libgreet.a__ in `/usr/local/lib/` or `/usr/lib/` and __greet.h__ in `/us/local/include/` or
`/usr/include/`, then we can compile like below:

{% highlight shell %}
$ gcc -o main main.c -lgreet
{% endhighlight %}

Now lets try to run the application.

{% highlight shell %}
$ ./main
./main: error while loading shared libraries: libgreet.so: cannot open shared object file: No such file or directory

# We can check runtime dependencies using `ldd`
$ ldd ./main
        linux-vdso.so.1 (0x00007ffc71da5000)
        libgreet.so => /home/john/greet/libgreet.so (0x00007f633013b000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f632fd4a000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f633053f000)

{% endhighlight %}

We can see using `ldd` that compile reference of __libgreet.so__ is added but __./main__ doesn't know the runtime path
of __libgreet.so__. We can add the runtime path using __$LD_LIBRARY_PATH__ environment variable.

{% highlight shell %}
$ export LD_LIBRARY_PATH="$PWD:$LD_LIBRARY_PATH"

$ ./main
- Hello -
- Hello -
- Hello -
{% endhighlight %}

`ldconig` keeps track of all shared library configured in `/etc/ld.so.conf.d`. We can list currently knows shared
library using following command:

{% highlight shell %}
$ ldconfig -p
{% endhighlight %}

`ldcondig` searched both `/usr/local/lib/` and `/usr/lib/` for dependencies. After we copy __libgreet.so__ to __lib__
folder we can run following command to update the shared library list.

{% highlight shell %}
$ sudo ldconfig
{% endhighlight %}

Now we can run __main__ directly without exporting library path in __$LD_LIBRARY_PATH__.

# Creating Makefile
Now lets write these steps in a make file. Create a file __Makefile__ in same directory and copy following code.

{% highlight make %}
.DEFAULT_GOAL:= run
.SILENT:

libgreet.so: greeter.c decorate.c greet.h
	gcc -I. -fpic -c greeter.c decorate.c
	gcc -shared -o libgreet.so decorate.o greeter.o

build: greet.h main.c libgreet.so
	gcc -I. -L. main.c -o main -lgreet

clean:
	rm -f greeter.o decorate.o libgreet.so main

run: build
	LD_LIBRARY_PATH=".:$LD_LIBRARY_PATH" ./main && make -s clean
{% endhighlight %}

Now run using following command:

{% highlight shell %}
$ make
{% endhighlight %}

# Tools Version
* gcc (Ubuntu 7.3.0-27ubuntu1~18.04) 7.3.0
* GNU Make 4.1

# Bookmarks
* [CProgramming - Shared Library](https://www.cprogramming.com/tutorial/shared-libraries-linux-gcc.html)
