---
layout: post
title: Java Records
date: 2021-08-08 18:00:00 +0600
tags: java, java14, record
---

# Introduction

`Java Records` allows to create transparent carrier for immutable data. It was
first introduced as `Preivew Featuer` in Java 14, with minor update in Java 15,
this feature was finalized in Java 16.

# Syntax

For defining `Java Record` new keyword `record` is introduced. Lets define a simple records `Person`
with `name`, `email` and `age` components (i.e. property)

```java
package me.ronygomes.reference;

public record Person(String name, String email, int age) {
}
```
Now if we run `javap` on the generated `.class` file, will get following output:

```shell
$ javap -private Person.class

Compiled from "Person.java"
public final class me.ronygomes.reference.Person extends java.lang.Record {
  private final java.lang.String name;
  private final java.lang.String email;
  private final int age;
  public me.ronygomes.reference.Person(java.lang.String, java.lang.String, int);
  public final java.lang.String toString();
  public final int hashCode();
  public final boolean equals(java.lang.Object);
  public java.lang.String name();
  public java.lang.String email();
  public int age();
}
```
This is equivalent of following class:

```java
package me.ronygomes.reference;

public final class Person extends Record {

    private final String name;
    private final String email;
    private final int age;

    public Person(String name, String email, int age) {
        this.name = name;
        this.email = email;
        this.age = age;
    }

    public String name() {
        return name;
    }

    public String email() {
        return email;
    }

    public int age() {
        return age;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Person person = (Person) o;
        return age == person.age
                && Objects.equals(name, person.name)
                && Objects.equals(email, person.email);
    }

    @Override
    public int hashCode() {
        return Objects.hash(name, email, age);
    }

    @Override
    public String toString() {
        return "Person[" +
                "name=" + name +
                ", email=" + email +
                ", age=" + age +
                ']';
    }
}
```
Following things need to be noted for `record`:

1. `record` class is `final` and extends `java.lang.Record`, so it is not
   possible to extend another record or class. But `records` can `implement`
   interface.
2. All components (i.e. properties) in `record` are `final` and must be provided
   while declaration. It is not possible to define property in `record` class.
3. Getter/Accessors methods doesn't follow Java Getter Convention. Its same as component name
4. `equals()`, `hashCode()`, `toString()` methods are generated with/for all properties
5. Regular `class` can't extend `java.lang.Record`.

# Canonical & Non-Canonical Constructor

Default or all component constructor is called canonical constructor. For `Person` record following
constructor will be generated:

```java
public Person(String name, String email, int age) {
    this.name = name;
    this.email = email;
    this.age = age;
}
```

If this constructor is defined, will not be auto generated. If custom logic is needed for construction there is
also an alternative syntax. This will called with canonical constructor.

```java
public Person {
    if (age < 0) {
        throw new IllegalArgumentException("Age can't be negative");
    }
}
```

Non-canonical constructor can also be defined but it must always invoke canonical constructor:

```java
public Person(String name, int age) {
    this(name, name + "@gmail.com", age);
    // Some more code
}
```

# Local Record (Java 15)

With Java 15, `record` (also `enum` and `interface`) can be defined locally. This can improve readability:

```java
public boolean isEmailPrefixAndNameSame() {
    record EmailParts(String prefix, String suffix) {
        public boolean isPrefixEqualsTo(String name) {
            return prefix().equalsIgnoreCase(name);
        }
    }

    String[] parts = email.split("@");
    EmailParts emailParts = new EmailParts(parts[0], parts[1]);

    return emailParts.isPrefixEqualsTo(name);
}
```

# Annotation Propagation

As accessors and constructor are generated automatically, annotation given in components are
propagated to respective parameters or methods based on annotation type. Lets consider a simple
field level annotation `FieldAnnotation` and method level annotation `MethodAnnotation`

```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.FIELD)
public @interface FieldAnnotation {
}

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface MethodAnnotation {
}
```

Now if same `record` is defined with annotations:

```java
package me.ronygomes.reference;

public record Person(@FieldAnnotation String name,
                     @MethodAnnotation String email,
                     int age) {
}
```

Generated code will be equivalent to following:

```java
package me.ronygomes.reference;

public final class Person extends Record {

    @FieldAnnotation
    private final String name;

    private final String email;
    private final int age;

    public Person(String name, String email, int age) {
        this.name = name;
        this.email = email;
        this.age = age;
    }

    public String name() {
        return name;
    }

    @MethodAnnotation
    public String email() {
        return email;
    }

    public int age() {
        return age;
    }

    // equals, hashCode, toString same as before
}
```

# Reflection API

Java also updated reflection API for querying about `record` and components. `Class#isRecord` and
`Class#getRecordComponents` can be used for querying about `record`. 

Following test will all pass:

```java
assertTrue(Person.class.isRecord());

RecordComponent[] components = Person.class.getRecordComponents();
assertEquals(3, components.length);

assertEquals("name", components[0].getName());
assertSame(java.lang.String.class, components[0].getType());

assertEquals("email", components[1].getName());
assertSame(java.lang.String.class, components[1].getType());

assertEquals("age", components[2].getName());
assertSame(int.class, components[2].getType());

```
# Resource
* [JEP 359: Records (Preview)](https://openjdk.java.net/jeps/359)
* [JEP 384: Records (Second Preview)](https://openjdk.java.net/jeps/384)
* [JEP 395: Records](https://openjdk.java.net/jeps/395)
* [Source Code](https://github.com/ronygomes/reference/tree/master/JavaRecords)
