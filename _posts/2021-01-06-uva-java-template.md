---
layout: post
title: Online Judge - Java Template
date: 2021-01-06 18:00:00 +0600
tags: online-judge java
---

# Overview

I have been professionally working in Java for more than 7 years. But for
solving various online judge problems (which I seldom do) I use C or C++. I
realized I have never submitted a single problem in any online judge in Java.
Today I will submit solution to a simple problem `10055 - Hashmat the Brave
Warrior` in Online Judge and try to understand the gotchas of Java.

# Java Submission Specification

As stated
[here](https://onlinejudge.org/index.php?id=15&Itemid=30&option=com_content&task=view),
for Online Judge following rule must be followed to submit solution in Java.

1. Whole solution should be in a single Java file. File can have multiple
   non-public class(es)
2. No package definition allowed
3. Program must begin in `public static main(String args[])` method of `Main`
   class
4. Filename doesn't matter but `Main` class can't be public

{% highlight java %}
// No package definition

// No class will be public
class Helper {
    // code
}

// Main.main() will be called by online judge
class Main {
    public static void main(String[] args) {
        // code
    }
}
{% endhighlight %}

# Quick Summary

After successful submission I tweaked the code in various way to reduce the
execution time. Following is the quick summary of execution time for 
`JAVA 1.8.0 - OpenJDK Java` which currently Online Judge uses.

| Method/Class Used                                               | Execution Time |
|:---------------------------------------------------------------:|:--------------:|
| `java.io.BufferedReader` & `String#split()`                     |     0.650s     |
| `java.io.BufferedReader` & `String#split()` & try-with-resource |     0.890s     |
| `java.io.BufferedReader` & `java.util.StringTokenizer`          |     0.860s     |
| `java.util.Scanner`                                             |     1.060s     |

# Details

Following code is used to run the code.

{% highlight java %}
// Filename: Oj10055.java
public class Oj10055 {
    public static void main(String[] args) throws IOException {
        Main.main(args);
    }
}
{% endhighlight %}

As Online Judge forces to code in `Main` class, only following code is
submitted.

First I tried with `java.util.Scanner` as I expected this code to run fastest as
this looks smartest but it is quite slow. It executes in __1.060s__.

{% highlight java %}
import java.util.*;

class Main {
    public static void main(String[] args) {

        Scanner sc = new Scanner(System.in);
        while (sc.hasNextLong()) {
            long a = sc.nextLong();
            long b = sc.nextLong();

            System.out.println(Math.abs(a - b));
        }

    }
}
{% endhighlight %}

I was quite disappointed as same code in ANSI C runs in __0.152s__. So I tried to
reduce the time a bit.

Then I used `BufferedReader` and parses data manually using String `split()`.
This code run the fastest. Took around __0.650s__.

{% highlight java %}
import java.io.*;

class Main {
    public static void main(String[] args) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));

        String line;
        while ((line = reader.readLine()) != null) {
            String[] parts = line.split(" ", 2);
            long a = Long.parseLong(parts[0]);
            long b = Long.parseLong(parts[1]);;

            System.out.println(Math.abs(a - b));
        }

        reader.close();
    }
}
{% endhighlight %}

Then I tried to make this code a bit smarter using `try-with-resource` but this
slowed down the code and took __0.890s__.


{% highlight java %}
import java.io.*;

class Main {
    public static void main(String[] args) throws IOException {
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(System.in))) {

            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(" ", 2);
                long a = Long.parseLong(parts[0]);
                long b = Long.parseLong(parts[1]);;

                System.out.println(Math.abs(a - b));
            }

        }
    }
}
{% endhighlight %}

Then I updated code with `java.util.StringTokenizer` as its much easier to parse
using this class. I used the following code but execution time increased. Took
__0.860s__. Probably `java.util.StringTokenizer` is not ideal for minor input
parsing.

{% highlight java %}
import java.util.*;
import java.io.*;

class Main {
    public static void main(String[] args) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));

        String line;
        StringTokenizer st;
        while ((line = reader.readLine()) != null) {
            st = new StringTokenizer(line);
            long a = Long.parseLong(st.nextToken());
            long b = Long.parseLong(st.nextToken());

            System.out.println(Math.abs(a - b));
        }

        reader.close();
    }
}
{% endhighlight %}

# Bookmarks
* [Online Judge](https://onlinejudge.org/)
* [10055 - Hashmat the Brave Warrior](https://onlinejudge.org/index.php?option=onlinejudge&Itemid=8&page=show_problem&problem=996)