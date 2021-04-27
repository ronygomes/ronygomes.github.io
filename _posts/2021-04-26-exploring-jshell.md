---
layout: post
title: Exploring JShell
date: 2021-04-26 18:30:00 +0600
tags: java java9 jshell
---

# Introduction
`JShell` is REPL (Read, Eval, Print, Loop) for Java Programming Language,
introduced in Java 9. It's a great way to quickly prototype an idea or learn
some new API. The great thing about `JShell` is it comes with builtin code
completion and documentation. Exploring new API or Java library have never been
to easy!

# Start and Exit JShell
If you have Java 9+ installed on your machine `JShell` is already installed. To
start the `JShell` type following command, assuming `$JAVA_HOME/bin` is in
`$PATH`:

{% highlight shell %}
$ jshell -version
jshell 16.0.1

$ jshell
|  Welcome to JShell -- Version 16.0.1
|  For an introduction type: /help intro

jshell> /exit
|  Goodbye
{% endhighlight %}

You can type any statement or expression in `JShell`. Control commands start
with `/`. Typing `/exit` or pressing `Ctrl+d` will exit out of `JShell`.


# Getting Help

JShell has a great `help` support. Help can be accessed with `/help` or `/?`. If
you enter `/help` command then list of all commands will be printed. `/help` can be
called for other commands or subjects. Subjects are detailed text on some
specific topic. Currently available subjects are `intro`, `keys`, `id`,
`shortcuts`, `context`, `rerun`.

{% highlight shell %}
jshell> /help
|  Type a Java language expression, statement, or declaration.
|  Or type one of the following commands:
|  /list [<name or id>|-all|-start]
|  	list the source you have typed
|  /edit <name or id>

# ... (Showing first 5 lines)

jshell> /help /list
|  
|                                   /list
|                                   =====
|  
|  Show the snippets, prefaced with their snippet IDs.
|  
|  /list
|  	List the currently active snippets of code that you typed or read with /open
|  
|  /list -start

# ... (Showing first 10 lines)

jshell> /help intro
|  
|                                   intro
|                                   =====
|  
|  The jshell tool allows you to execute Java code, getting immediate results.

# ... (Showing first 5 lines)
{% endhighlight %}

# Playing with JShell

You can write any statement, declare methods, class in `JShell`. Each of these
statements are called snippets.

{% highlight shell %}
jshell> Math.PI
$1 ==> 3.141592653589793

jshell> 3 + 8
$2 ==> 11

jshell> int i = 20;
i ==> 20

jshell> int square(int x) {
   ...>     return x * x;
   ...> }
|  created method square(int)

jshell> class Person {
   ...>     private String name;
   ...>     
   ...>     public Person(String name) {
   ...>         this.name = name;
   ...>     }
   ...>     
   ...>     @Override
   ...>     public String toString() {
   ...>         return "Person{name=" + name + "}";
   ...>     }
   ...> }
|  created class Person

jshell> nothing 
|  Error:
|  cannot find symbol
|    symbol:   variable nothing
|  nothing
|  ^-----^

jshell> square($2)
$6 ==> 121

jshell> square(i)
$7 ==> 400

jshell> /2
3 + 8
$8 ==> 11
{% endhighlight %}

You can also rerun last snippet with `/!` and `-<n>` to rerun n-th previous snippet.

You can view snippets using `/list` command. By default it only shows active
snippets, `-all` options shows all deleted, startup and error snippets. Error
snippets are prefixed with `e` and startup snippets are prefixed with `s`.

{% highlight shell %}
jshell> /list -all
  s1 : import java.io.*;
  s2 : import java.math.*;
  s3 : import java.net.*;
  s4 : import java.nio.file.*;
  s5 : import java.util.*;
  s6 : import java.util.concurrent.*;
  s7 : import java.util.function.*;
  s8 : import java.util.prefs.*;
  s9 : import java.util.regex.*;
 s10 : import java.util.stream.*;
   1 : Math.PI
   2 : 3 + 8
   3 : int i = 20;
   4 : int square(int x) {
           return x * x;
       }
   5 : class Person {
           private String name;
           
           public Person(String name) {
               this.name = name;
           }
           
           @Override
           public String toString() {
               return "Person{name=" + name + "}";
           }
       }
   6 : square($2) // Can use custom variable
  e1 : nothing
   7 : square(i)
   8 : 3 + 8
{% endhighlight %}

You can also list variables, methods, classes and imports using `/vars`,
`/methods`, `/types`, `/imports` respectively.

{% highlight shell %}
jshell> /vars
|    double $1 = 3.141592653589793
|    int $2 = 11
|    int i = 20

jshell> /methods
|    int square(int)

jshell> /types
|    class Person

jshell> /imports
|    import java.io.*
|    import java.math.*
|    import java.net.*
|    import java.nio.file.*
|    import java.util.*
|    import java.util.concurrent.*
|    import java.util.function.*
|    import java.util.prefs.*
|    import java.util.regex.*
|    import java.util.stream.*
{% endhighlight %}
These packages are imported by default.

A snippets can be dropped or edited using `/drop` and `/edit` command. Dropped snippets can be seen using `-all` in `/list` command.

{% highlight shell %}
jshell> /drop 6
|  dropped variable $6

jshell> /set editor vim
|  Editor set to: vim

jshell> /edit 4
# Opened in Vim, making square to cube and saving it.
# (In Vim)
# int square(int x) {
#    return x * x;
# }

# New method snippet is created cube() as $8
jshell> /methods
|    int square(int)
|    int cube(int)

jshell> /list 8

   8 : int cube(int x) {
           return x * x * x;
       }
{% endhighlight %}

By default `/edit` command searches in `$JSHELLEDITOR`, `$VISUAL`, `$EDITOR` in
this order. Otherwise opens in a simple AWT editor.

# Saving and Loading File
You can save and load `JShell` session data with `/save` and `/open` command:

{% highlight shell %}
jshell> /save article.jsh
jshell> /exit

$ jshell
# /open command can also open java file ie '/open Person.java'
jshell> /open article.jsh
jshell> /list
# Same output as previous
{% endhighlight %}

# History
You can view entered commands using `/history` command. `-all` will display
commands of all previous sessions. If we run `/history` command after previous
commands following output will be displayed: 

{% highlight shell %}
jshell> /history

/open article.jsh
/list
/history
{% endhighlight %}

# AutoComplete & Documentation
`JShell` has builtin autocomplete and documentation support.

{% highlight shell %}
jshell> Sy<Tab>
SyncFailedException   SynchronousQueue      System
jshell> Sys<Tab> # will autocomplete 'System'
jshell> System.out.p<Tab> # out.p becomes out.print
print(     printf(    println(
jshell> System.out.println(<Tab>
$1        $2        i         square(   

Signatures:
void PrintStream.println()
void PrintStream.println(boolean x)
void PrintStream.println(char x)
void PrintStream.println(int x)
void PrintStream.println(long x)
void PrintStream.println(float x)
void PrintStream.println(double x)
void PrintStream.println(char[] x)
void PrintStream.println(String x)
void PrintStream.println(Object x)

<press tab again to see documentation>
{% endhighlight %}

It shows all candidate variables along with all overloaded methods. If `<Tab>` is
pressed again shows documentation.

{% highlight shell %}
jshell> System.out.println(
void PrintStream.println()
Terminates the current line by writing the line separator string.The line separator string is
defined by the system property line.separator , and is not necessarily a single newline
character ( '\n' ).

<press tab to see next documentation>
jshell> System.out.println(
{% endhighlight %}

# Forward Reference
`JShell` can define method or class with previously declared or undeclared
variables. Lets see that in example:

{% highlight shell %}
jshell> int ten = 10
ten ==> 10

jshell> int add10(int x) {
   ...>     return x + ten;
   ...> }
|  created method add10(int)

jshell> add10(5)
$3 ==> 15

jshell> int add20(int y) {
   ...>     return y + twenty;
   ...> }
|  created method add20(int), however, it cannot be invoked until variable twenty is declared

jshell> add20(7)
|  attempted to call method add20(int) which cannot be invoked until variable twenty is declared

jshell> twenty = 20
|  Error:
|  cannot find symbol
|    symbol:   variable twenty
|  twenty = 20
|  ^----^

jshell> int twenty = 20
twenty ==> 20

jshell> add20(7)
$7 ==> 27
{% endhighlight %}

# Keyboard Shortcuts
Following are some important shortcuts to remember. For all keyboard shortcuts
see `/help keys`.

| Shortcut               | Description                                        |
|:----------------------:|:--------------------------------------------------:|
| `Ctrl+L`               | Clear Screen                                       |
| `Ctrl+C`               | Interrupt Statement                                |
| `Ctrl+A`               | Beginning of line                                  |
| `Ctrl+E`               | End of line                                        |
| `Ctrl+R`               | Reverse Search                                     |
| `Ctrl+Enter`           | Insert new line in snippet                         |
| `Ctrl+_`               | Undo edit                                          |
| `Ctrl+X then Ctrl+B`   | Navigate to matching bracket                       |
| `Meta+U`               | Uppercase word                                     |
| `Meta+L`               | Lowercase word                                     |

`JShell` also have some code helper shortcuts.

| Shortcut               | Description                                        |
|:----------------------:|:--------------------------------------------------:|
| `Shift+Tab then v`     | Declare variable for expression                    |
| `Shift+Tab then m`     | Declare method for expression                      |
| `Shift+Tab then i`     | Automatically import expression class              |

# Context & Environment
Execution environment can be updated with `/evn`, `/reset`, `/reload` commands.
With `/env` command external module or library can be loaded. Lets load apache
common in `JShell`.

{% highlight shell %}
$ wget https://repo1.maven.org/maven2/org/apache/commons/commons-lang3/3.12.0/commons-lang3-3.12.0.jar
$ jshell --class-path commons-lang3-3.12.0.jar
# Alternative 
# jshell> /env -class-path commons-lang3-3.12.0.jar
jshell> /env
|     --class-path commons-lang3-3.12.0.jar

jshell> import org.apache.commons.lang3.StringUtils

jshell> StringUtils.abbreviate("Hello World", 10)
$2 ==> "Hello W..."

jshell> /list

   1 : import org.apache.commons.lang3.StringUtils;
   2 : StringUtils.abbreviate("Hello World", 10)

# /reset will restart the context and reset all entered snippets
jshell> /reset 
|  Resetting state.

jshell> /list # Prints Nothing 

jshell> 2 + 2
$1 ==> 4
# /reload will restart the context and rerun entered snippets
jshell> /reload
|  Restarting and restoring state.
-: 2 + 2
jshell> /list

   1 : 2 + 2

{% endhighlight %}

# /set Command
With `/set` command various options like editor, startup snippets, displayed
feedback, prompt, snippets indent number can be configured. Running only `/set`
will display configs:

{% highlight shell %}
jshell> /set 
|  /set editor -default
|  /set indent 4
|  /set start -retain -default
|  /set feedback normal
|  
|  Available feedback modes:
|     concise
|     normal
|     silent
|     verbose
|  
|  To show mode settings use '/set prompt', '/set truncation', ...
|  or use '/set mode' followed by the feedback mode name.

{% endhighlight %}

JShell has a startup script `PRINTING` which can be used to import print
helpers. `-retain` option will retain configuration for future `JShell` sessions:

{% highlight shell %}
jshell> /set start -retain DEFAULT PRINTING

jshell> /list -all

  s1 : void print(boolean b) { System.out.print(b); }
  s2 : void print(char c) { System.out.print(c); }
  s3 : void print(int i) { System.out.print(i); }
  s4 : void print(long l) { System.out.print(l); }
  s5 : void print(float f) { System.out.print(f); }
  s6 : void print(double d) { System.out.print(d); }
  s7 : void print(char s[]) { System.out.print(s); }
  s8 : void print(String s) { System.out.print(s); }
  s9 : void print(Object obj) { System.out.print(obj); }
 s10 : void println() { System.out.println(); }
 s11 : void println(boolean b) { System.out.println(b); }
 s12 : void println(char c) { System.out.println(c); }
 s13 : void println(int i) { System.out.println(i); }
 s14 : void println(long l) { System.out.println(l); }
 s15 : void println(float f) { System.out.println(f); }
 s16 : void println(double d) { System.out.println(d); }
 s17 : void println(char s[]) { System.out.println(s); }
 s18 : void println(String s) { System.out.println(s); }
 s19 : void println(Object obj) { System.out.println(obj); }
 s20 : void printf(java.util.Locale l, String format, Object... args) { System.out.printf(l, format, args); }
 s21 : void printf(String format, Object... args) { System.out.printf(format, args); }
 s22 : import java.io.*;
 s23 : import java.math.*;
 s24 : import java.net.*;
 s25 : import java.nio.file.*;
 s26 : import java.util.*;
 s27 : import java.util.concurrent.*;
 s28 : import java.util.function.*;
 s29 : import java.util.prefs.*;
 s30 : import java.util.regex.*;
 s31 : import java.util.stream.*;

jshell> println("Hello World")
Hello World
{% endhighlight %}

# Resource
* [JShell User Guide](https://docs.oracle.com/javase/9/jshell/introduction-jshell.htm#JSHEL-GUID-630F27C8-1195-4989-9F6B-2C51D46F52C8)