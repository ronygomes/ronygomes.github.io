---
layout: post
title: Java 6 Service Loader
date: 2020-11-25 10:00:00 +0600
tags: java java6
---

# Introduction

I was curious how Java finds `JSR 303` implementation from class path. After searchings I was amazed that Java has a
feature named Service Loader from Java 6. It providers a way to automatically find the implementation of a spec from
class path. All modern specs like JDBC, bean validation loads implementation like this way.

# Project Structure
For understating service loader we need 3 separate projects.

- `greeter-api` - Service Specification
- `greeter-impl`- Service Provider/Implementation
- `greeter-client` - Service Consumer

# Specification

Lets say we have a very complicated library and we want some part of it to be configurable at runtime. So we wrote an
spec and wants other developers to write provider i.e. their custom implementation.

Following is the specification.

{% highlight java %}
// greeter-api/**/Greeter.java
package me.ronygomes.greeter.spi;

public interface Greeter {
    String greet();
}
{% endhighlight %}

We also wrote another interface for creating the implementation of the `Greeter` class.

{% highlight java %}
// greeter-api/**/GreeterProvider.java
package me.ronygomes.greeter.spi;

public interface GreeterProvider {
    Greeter create();
    }
}
{% endhighlight %}

# Implementation

For making a `Service Provider` for the `greeter-api`, other developer needs to add our spec as dependency. Lets see
the `build.gralde` file of `greeter-impl`. As all projects are local we have added `project` dependency.

{% highlight groovy %}
// greeter-implementation/build.gradle
plugins {
    id 'java-library'
}

dependencies {
    implementation project(':greeter-api')
}
{% endhighlight %}

Now lets say the developer wrote all related implementation for `greeter-api`.
{% highlight java %}
// greeter-impl/**/HelloGreeter.java
package me.ronygomes.greeter;

import me.ronygomes.greeter.spi.Greeter;

public class HelloGreeter implements Greeter {

    @Override
    public String greet() {
        return "Hello World!";
    }
}
{% endhighlight %}

{% highlight java %}
// greeter-impl/**/HelloGreeter.java
package me.ronygomes.greeter;

import me.ronygomes.greeter.spi.Greeter;
import me.ronygomes.greeter.spi.GreeterProvider;

public class HelloGreeterProvider implements GreeterProvider {

    @Override
    public Greeter create() {
        return new HelloGreeter();
    }
}
{% endhighlight %}

Now the developer has to create a special file which is the glue between our specification and this provider.  That file
must be named `me.ronygomes.greeter.spi.GreeterProvider` same as our specification name and put in `META-INF/services`
folder. In that file developer will list all the provides, one in each line. In this case we have only one provider so
the content of the file will be following

{% highlight text %}
# greeter-impl/**/META-INF/services/me.ronygomes.greeter.spi.GetterProvider
me.ronygomes.greeter.HelloGreeterProvider
{% endhighlight %}

# Client
Now we want to use the greeter provider thought greeter specification. For client the `greeter-api` is compile time
dependency and `greeter-impl` is runtime dependency. Also added application plugin for easily running from command line.

{% highlight groovy %}
// greeter-client/build.gradle
plugins {
    id 'java-library'
    id 'application'
}

dependencies {
    implementation project(':greeter-api')
    runtime project(':greeter-impl')
}
{% endhighlight %}

{% highlight java %}
// greeter-client/**/Main.java
package me.ronygomes.greeter.client;

import me.ronygomes.greeter.spi.Greeter;
import me.ronygomes.greeter.spi.GreeterProvider;

import java.util.ServiceLoader;

public class Main {
    public static void main(String[] args) {

        for (GreeterProvider provider : ServiceLoader.load(GreeterProvider.class)) {
            Greeter greeter = provider.create();

            System.out.printf("%s - %s\n", greeter.getClass().getCanonicalName(), greeter.greet());
        }
    }
}
{% endhighlight %}

Now if we run the following command from console code from service provider will execute.

{% highlight shell %}
$ cd greeter-client
$ gradle run

> Task :run
me.ronygomes.greeter.HelloGreeter - Hello World!
{% endhighlight %}

# Tools Version
* Gradle 5.6.4
* java version "1.8.0_221"

# Bookmarks
* [Source Code - GitHub](https://github.com/ronygomes/reference/tree/master/Java6ServiceLoader)
* [ServiceLoader Docs](https://docs.oracle.com/javase/7/docs/api/java/util/ServiceLoader.html)
