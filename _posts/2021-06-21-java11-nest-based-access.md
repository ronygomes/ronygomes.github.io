---
layout: post
title: Java 11 Nest-Based Access Control
date: 2021-06-21 20:00:00 +0600
tags: java11
---

# Overview
Java 11 redesigned how nested class access surrounding class's private methods.
Previously JDK used to generate package protected access methods in compile
time. But now a new abstraction `Nest` is introduced and nest members can access
private methods within a nest.

# Project Structure
For this article will use following class:

`SolarSystem` class has 3 inner class `Earth`, `Uranus`, `Saturn` (skipped others
for brevity). `Earth` class has 2 inner class `Asia` and `Europe`.

Class `Asia` uses `private` methods from both `Earth` and `SolarSystem` and
`Uranus` uses `private` method of `SolarSystem`.

{% highlight java %}

public class SolarSystem {

    public String solarSystemPublic() {
        return "solarSystemPublic";
    }

    private String solarSystemPrivateNoCall() {
        return "solarSystemPrivateNoCall";
    }

    private String solarSystemPrivateForUranus() {
        return "solarSystemPrivateForUranus";
    }

    private String solarSystemPrivateForAsia() {
        return "solarSystemPrivateForAsia";
    }

    class Earth {

        private String earthPrivateForAsia() {
            return "earthPrivateForAsia";
        }

        class Asia {
            public String asiaPublicCallsSolarSystemPrivateForAsia() {
                return "asiaPublicCallsSolarSystemPrivateForAsia -> " 
                        + solarSystemPrivateForAsia();
            }

            public String asiaPublicCallsEarthPrivateForAsia() {
                return "asiaPublicCallsEarthPrivateForAsia -> "
                        + earthPrivateForAsia();
            }
        }

        class Europe {
            public String europePublicCallsSolarSystemPublic() {
                return "europePublicCallsSolarSystemPublic -> " 
                        + solarSystemPublic();
            }
        }
    }

    class Uranus {
        public String uranusPublicCallsSolarSystemPrivateForUranus() {
            return "uranusPublicCallsSolarSystemPrivateForUranus -> " 
                    + solarSystemPrivateForUranus();
        }
    }

    class Saturn {
        public String saturnPublic() {
            return "saturnPublic";
        }
    }
}

{% endhighlight %}

# Pre Java 11 Mechanism
Compiling `SolarSystem.java` with Java 8 (or any other JDK) will create 6
separate `.class` files. One class file for each `class`.

* `SolarSystem.class`
* `SolarSystem$Earth.class`
* `SolarSystem$Uranus.class`
* `SolarSystem$Saturn.class`
* `SolarSystem$Earth$Asia.class`
* `SolarSystem$Earth$Europe.class`

{% highlight shell %}

$ ls
SolarSystem.java

$ java -version
java version "1.8.0_221"
Java(TM) SE Runtime Environment (build 1.8.0_221-b11)
Java HotSpot(TM) 64-Bit Server VM (build 25.221-b11, mixed mode)

$ javac SolarSystem.java 
$ ls *.class
SolarSystem$Earth$Asia.class	SolarSystem$Earth.class		SolarSystem$Uranus.class
SolarSystem$Earth$Europe.class	SolarSystem$Saturn.class	SolarSystem.class

{% endhighlight %}

Note `SolarSystem.java` has 3 `private` methods (solarSystemPrivateNoCall,
solarSystemPrivateForUranus solarSystemPrivateForAsia) and 1 `public` methods
(solarSystemPublic). Now if we see the methods generated in byte-code using
`javap`, we will see 2 additional methods.

**-p** switch includes `private` methods and **-c** shows disassembled code.

{% highlight shell %}
$ javap -p SolarSystem.class 
Compiled from "SolarSystem.java"
public class SolarSystem {
  public SolarSystem();
  public java.lang.String solarSystemPublic();
  private java.lang.String solarSystemPrivateNoCall();
  private java.lang.String solarSystemPrivateForUranus();
  private java.lang.String solarSystemPrivateForAsia();
  static java.lang.String access$000(SolarSystem);
  static java.lang.String access$200(SolarSystem);
}

$ javap -p -c SolarSystem.class

Compiled from "SolarSystem.java"
public class SolarSystem {
  public SolarSystem();
    Code:
       0: aload_0
       1: invokespecial #3                  // Method java/lang/Object."<init>":()V
       4: return

  public java.lang.String solarSystemPublic();
    Code:
       0: ldc           #4                  // String solarSystemPublic
       2: areturn

  private java.lang.String solarSystemPrivateNoCall();
    Code:
       0: ldc           #5                  // String solarSystemPrivateNoCall
       2: areturn

  private java.lang.String solarSystemPrivateForUranus();
    Code:
       0: ldc           #6                  // String solarSystemPrivateForUranus
       2: areturn

  private java.lang.String solarSystemPrivateForAsia();
    Code:
       0: ldc           #7                  // String solarSystemPrivateForAsia
       2: areturn

  static java.lang.String access$000(SolarSystem);
    Code:
       0: aload_0
       1: invokespecial #2                  // Method solarSystemPrivateForAsia:()Ljava/lang/String;
       4: areturn

  static java.lang.String access$200(SolarSystem);
    Code:
       0: aload_0
       1: invokespecial #1                  // Method solarSystemPrivateForUranus:()Ljava/lang/String;
       4: areturn
}
{% endhighlight %}

`static java.lang.String access$000(SolarSystem)` and `static java.lang.String
 access$200(SolarSystem)` is generated by complier and from generated comment we
 can see it is created for **solarSystemPrivateForAsia** and
 **solarSystemPrivateForUranus** respectively. No access method was generated
 for **solarSystemPrivateNoCall** as it doesn't have any usage in child class.

# Java 11 Mechanism
Now if same `SolarSystem.java` is compiled with Java 11 or later. Same 6
`.class` files are generated, but now if `javap` is executed then prints only
declared methods. No auto-generated access methods.

{% highlight shell %}
$ javap -p SolarSystem.class 
Compiled from "SolarSystem.java"
public class SolarSystem {
  public SolarSystem();
  public java.lang.String solarSystemPublic();
  private java.lang.String solarSystemPrivateNoCall();
  private java.lang.String solarSystemPrivateForUranus();
  private java.lang.String solarSystemPrivateForAsia();
}

{% endhighlight %}

Internally JVM maintains a NestHost (SolarSystem.class) with all classes as nest members.

# Reflection API
Java 11 provided following reflection API to query about nest membership:

| Method                          | Description                         |
|:-------------------------------:|:-----------------------------------:|
| Class#getNestHost()             | Returns Host Class of target class  |
| Class#getNestMembers()          | Returns all the members in the nest |
| Class#isNestmateOf(Class<?> c)  | Returns `true` if in same nest      |

Following JUnit 5 test code demonstrates Nest API:

{% highlight java %}

private static final Class<?>[] SOLAR_SYSTEM_NEST_MEMBERS = {
        SolarSystem.class,
        SolarSystem.Earth.class, SolarSystem.Uranus.class, SolarSystem.Saturn.class,
        SolarSystem.Earth.Asia.class, SolarSystem.Earth.Europe.class
};

@Test
void testNestHost() {
    assertSame(SolarSystem.class.getNestHost(), SolarSystem.class);
    assertSame(SolarSystem.Earth.class.getNestHost(), SolarSystem.class);
    assertSame(SolarSystem.Earth.Asia.class.getNestHost(), SolarSystem.class);
    assertSame(SolarSystem.Earth.Europe.class.getNestHost(), SolarSystem.class);
    assertSame(SolarSystem.Uranus.class.getNestHost(), SolarSystem.class);
    assertSame(SolarSystem.Saturn.class.getNestHost(), SolarSystem.class);
}

@Test
void testNestMember() {
    assertEquals(6, SolarSystem.class.getNestMembers().length);

    List<Class<?>> nestMembers = List.of(SolarSystem.class.getNestMembers());
    assertTrue(nestMembers.containsAll(asList(SOLAR_SYSTEM_NEST_MEMBERS)));
}

@Test
void testNestMate() {
    assertTrue(SolarSystem.Earth.Asia.class.isNestmateOf(SolarSystem.Uranus.class));
    assertTrue(SolarSystem.Earth.Europe.class.isNestmateOf(SolarSystem.class));
    assertTrue(SolarSystem.Earth.Europe.class.isNestmateOf(SolarSystem.Earth.class));
    assertTrue(SolarSystem.Earth.Europe.class.isNestmateOf(SolarSystem.Earth.Asia.class));
    assertTrue(SolarSystem.Uranus.class.isNestmateOf(SolarSystem.Saturn.class));
}
{% endhighlight %}


# Link
* [JEP 181: Nest-Based Access Control](https://openjdk.java.net/jeps/181)
* [Java 11 java.lang.Class Documentation](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/lang/Class.html#getNestHost())
* [Source Code](https://github.com/ronygomes/reference/tree/master/Java11NestBasedAccess)


