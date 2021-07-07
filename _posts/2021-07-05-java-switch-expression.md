---
layout: post
title: Java Switch Expression
date: 2021-07-05 22:00:00 +0600
tags: java12
---

# Introduction
`Java Switch Expression` was first introduced as `Preivew Featuer` in Java 12,
later this feature was finalized in Java 14. `Preview Features` itself was
introduced in Java 12 as **JEP 12**. 

> A `Preview Features` is a new feature of the Java language, Java Virtual Machine, 
> or Java SE API that is fully specified, fully implemented, and yet impermanent.
> It is available in a JDK feature release to provoke developer feedback based 
> on real world use; this may lead to it becoming permanent in a future Java SE
> Platform.

# Code Structure
For this article I will be using following enum named `Shape`.

{% highlight java %}
public enum Shape {
    CIRCLE, TRIANGLE, RECTANGLE, TRAPEZIUM, RHOMBUS, PENTAGON, HEXAGON, UNKNOWN
}
{% endhighlight %}

I have a simple interface with single method `int getSides(Shape shape)` which
returns number of sides given a `Shape`.

{% highlight java %}
public interface SwitchDemo {
    int getSides(Shape shape);
}
{% endhighlight %}

# Old Style Switch Statement

Lets first implement the code with old style switch case. Following is the code:

{% highlight java %}
public class SwitchCaseSwitchDemo implements SwitchDemo {

    @Override
    public int getSides(Shape shape) {
        int sides;
        switch (shape) {
            case CIRCLE:
                sides = 0;
                break;
            case TRIANGLE:
                sides = 3;
                break;
            case RECTANGLE:
            case TRAPEZIUM:
            case RHOMBUS:
                sides = 4;
                break;
            case PENTAGON:
                sides = 5;
                break;
            case HEXAGON:
                sides = 6;
                break;
            default: throw new IllegalStateException();
        }

        return sides;
    }
}
{% endhighlight %}

If we observe closely we can see 3 issues with the switch case:

1. **Verbose**: Switch case is quite verbose as default behavior is fall-through. Although
                fall-through behaviour helped in case of **RECTANGLE**, **TRAPEZIUM** and
                **RHOMBUS** but in other cases had to add `break`.

2. **Statemnet**: Switch case is a statement not expression. For that had to set `sides`
                  variable everywhere.

3. **Scope**: Switch case has a single block. We can not define homonymous local variable
              in multiple case blocks. Following code will not compile:

{% highlight java %}
case CIRCLE:
    String message = "Circle";
    break;
case TRIANGLE:
    String message = "Triangle";
    break;
{% endhighlight %}

# New Switch Expression
There is nothing wrong with old style `switch-case` and it will continue to work in future version
of Java. As this style of `switch-case` was inspired from `C/C++`, switch expression is more modern
alternative to do the same.

{% highlight java %}
public class SwitchExpressionSwitchDemo implements SwitchDemo {

    @Override
    public int getSides(Shape shape) {
        int sides = switch(shape) {
            case CIRCLE -> 0;
            case TRIANGLE -> 3;
            case RECTANGLE, TRAPEZIUM, RHOMBUS -> 4;
            case PENTAGON -> 5;
            case HEXAGON -> 6;
            default -> throw new IllegalStateException();
        };

        return sides;
    }
}
{% endhighlight %}

Case block doesn't have to be a single statement. It can use a block and return using `yield`.

{% highlight java %}
case PENTAGON -> {
    System.out.println("Some Debug Message");
    yield 5;
}
{% endhighlight %}

In Java 12 it was first proposed as `break` but later in Java 13 `yield` keyword was introduced
for returning value from switch expression.

# Resource
* [JEP 12: Preview Features](https://openjdk.java.net/jeps/12)
* [JEP 325: Switch Expressions (Preview)](https://openjdk.java.net/jeps/325)
* [JEP 354: Switch Expressions (Second Preview)](https://openjdk.java.net/jeps/354)
* [JEP 361: Switch Expressions](https://openjdk.java.net/jeps/361)
* [Source Code](https://github.com/ronygomes/reference/tree/master/Java12SwitchExpression)
