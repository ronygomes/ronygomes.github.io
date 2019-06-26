---
layout: post
title: "Creating Static C Library with GCC"
date: 2019-04-01 17:15:00 +0600
tags: linux c gcc
---

# Introduction
For ease of usage and re-usability we can compile C procedures using GCC and distribute as library. Static libraries are
bundled directly with executable program, for that program size increases but don't have to worry about library runtime
dependencies.

# Usage
For this article we will use a simple program. First we will run the program, then will split into files and reuse some
part as static library.

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

Now we can compile and run using following commands, __-o__ for naming executable name:

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

For creating reusable library first we have to __compile__ only the files we want to include in library using __-c__
option. Then all object file are bundled using `ar` command. __-s__ option is added for creating index in archive.
Indexing a library fasten linking. Library must be prefixed with __lib__ and `ar` binary ends with __.a__.

{% highlight shell %}
$ gcc -I "$PWD" -c greeter.c decorate.c
$ ls
decorate.c decorate.o greeter.c greeter.o greet.h main.c

# Create archive named 'libgreet.a'
$ ar -rsc libgreet.a decorate.o greeter.o

# We can view the symbol table using nm -s
$ nm -s libgreet.a

Archive index:
printDecorated in decorate.o
printGreetings in greeter.o

decorate.o:
                 U _GLOBAL_OFFSET_TABLE_
0000000000000000 T printDecorated
                 U printf

greeter.o:
                 U _GLOBAL_OFFSET_TABLE_
                 U printDecorated
0000000000000000 T printGreetings
{% endhighlight %}

Now we can compile using __libgreet.a__. __libgreet.a__ must be after __main.c__ for successful compilation.
{% highlight shell %}
$ gcc -I "$PWD" -o main main.c ./libgreet.a
{% endhighlight %}

We can also add library reference using __-l__ option. This will search for library in `/usr/lib/` and `/usr/local/lib`.
We can add additional path using __-L__ option.

{% highlight shell %}
# Note added as -lgreet not libgreet
$ gcc -I "$PWD" -L "$PWD" -o main main.c -lgreet
{% endhighlight %}

Now if we copy the `libgreet.a` in `/usr/local/lib/` or `/usr/lib/` and copy `greet.h` in `/us/local/include/` or
`/usr/include/`, then we can compile like below.

{% highlight shell %}
$ gcc -o main main.c -lgreet
{% endhighlight %}

Now lets write these steps in a make file. Create a file __Makefile__ in same directory and copy following code.
{% highlight make %}
.DEFAULT_GOAL:= run
.SILENT:

libgreet.a: greeter.c decorate.c greet.h
	gcc -I. -c greeter.c decorate.c
	ar -rsc libgreet.a greeter.o decorate.o

build: greet.h main.c libgreet.a
	gcc -I. main.c libgreet.a -o main

clean:
	rm -f greeter.o decorate.o libgreet.a main

run: build
	./main && make -s clean
{% endhighlight %}

Now run using following command:
{% highlight shell %}
$ make
{% endhighlight %}

# Tools Version
* gcc (Ubuntu 7.3.0-27ubuntu1~18.04) 7.3.0
* GNU Make 4.1

# Bookmarks
* [Edx Course - C Programming: Using Linux Tools and Libraries](https://www.edx.org/course/c-programming-using-linux-tools-and-libraries)

