---
layout: post
title: Thought on Java 8 Optional
date: 2021-01-22 18:30:00 +0600
tags: java java8 optional
---

# Introduction

When Java 8 came and I learned about `Optional`, I was quite excited and started
to use it everywhere for denoting absence of value. But I was quite surprised to
read the API Note from Java 9 docs.

> `Optional` is primarily intended for use as a method return type where there is a
> clear need to represent "no result," and where using null is likely to cause
> errors. A variable whose type is `Optional` should never itself be null; it should
> always point to an Optional instance.

So `Optional` must be used as only return value. You shouldn't accept `Optional`
as method parameter. Let's explore the pitfalls and benefits in details.

# Optional Misuse

Everybody had their own preference about programming and majority times perfect way of coding is just a matter of taste. But in my experience if you use the API the way developer intended, there is less surprises. All misuse of Optional boils down to 3 cases:

* Property
* Getter
* Method Parameter

## Property

You can use `Optional` to denote null-able properties like below:

{% highlight java %}
public class Person {
    private Optional<String> additionalPhoneNumber;

    // getters and setters
}
{% endhighlight %}

But problem with this is `java.util.Optional` doesn't implement
`java.io.Serializable` as it wasn't intended to use as property. So when you
need to serialize data `Optional` property won't be serialized. Although modern
libraries and frameworks can change this behaviors using reflection or byte code
generation, but you have to depend on that specific library. Mixing multiple
libraries with different philosophy (Optional property Serializable vs not
Serializable) can make the code complicated.

## Getter

This is maybe tempting to declare nullable property normally and add a getter
with `Optional`. You are not violating any rule as documentation says it is only
intended to be used as return type.

{% highlight java %}
public class Person {
    private String additionalPhoneNumber;

    public Optional<String> getAdditionalPhoneNumber() {
        return Optional.ofNullable(this.additionalPhoneNumber);
    }
}
{% endhighlight %}

This code will work perfectly but tools like IDE or some code generator won't
recognize this as getter. Java tools like JSP EL expression depend heavily on
naming convention. Those don't support `Optional` getters (at least not yet).
You can declare another getter but that will also make code unnecessarily
complicated.  

## Method Parameter

Final misuse is to use `Optional` as method parameter. To be honest I find
following code more accessible then mentioning in documentation: 

{% highlight java %}
public void printGreetings(String name, Optional<String> salutation) {
    String salutaionText = salutation.orElse("");
    System.out.printf("Hello %s, Welcome!\n", salutationText + name);
}
{% endhighlight %}

First problem is calling this method now becomes a bit difficult. We can't call
with `null` and always have to wrap in `Optional`.

{% highlight java %}
// Will throw NullPointerException
printGreetings("John", null);

// Need to wrap with Optional even we have non-empty String
printGreetings("John", Optional.of("Mr"));
{% endhighlight %}

Another disadvantage using `Optional` here is Java tools already have better
support for solving this problem. Modern IDEs and libraries like `Lombok` has
support for annotation which can make code more readable.

{% highlight java %}
import lombok.NotNull

public void printGreetings(@NotNull String name, String salutation) {
    String salutaionText = Objects.nonNull(salutation) ? salutation : "";
    System.out.printf("Hello %s, Welcome!\n", salutationText + name);
}
{% endhighlight %}

# Optional Usage

To take the full advantage of `Optional` it is mandatory to learn it's API and
understand how it is intended to be used. Let's first see how you can create
`Optional` objects.

{% highlight java %}
import java.util.Optional;

// This will create an Optional with no value (Equivalent of null)
Optional<String> emptyTitle = Optional.empty();

// Use Optional.of() when you hava non-null value
Optional<String> titleOptional = Optional.of("Mr."); 
Optional<String> titleOptional = Optional.of(null); // Will throw NullPointerException

// Use Optional.ofNullable() when value can be null
Optional<String> titleOptional = Optional.ofNullable("Mr.");
Optional<String> titleOptional = Optional.ofNullable(null); // Will create Optional.empty() object;
{% endhighlight %}

Now for getting the value from `Optional` we have following method: 

{% highlight java %}
Optional<String> nameOptional = Optional.of("John");

String name = nameOptional.get();
System.out.println(name); // John
{% endhighlight %}

But we won't always know weather `Optional` has value or is empty. Following
methods can query for existence of value: 

{% highlight java %}
if (nameOptional.isPresent()) {
    System.out.println(nameOptional.get());
}

// Same code in functional style
nameOptional.ifPresent(System.out.println);
{% endhighlight %}

Following methods are used when `Optional` doesn't have value and we default
value for wants to throw exception

{% highlight java %}
Optional<String> loggedInUserOptional = Optional.empty();

String loggedInUserName = loggedInUserOptional.orElse("Guest");
System.out.println(loggedInUserName); // Guest

// Similar to orElse() but takes a java.util.function.Supplier
String loggedInUserName = loggedInUserOptional.orElseGet(() -> "Guest " + getGuestNumber());
System.out.println(loggedInUserName); // Guest 1, when getGuestNumber() returns 1

// Following code will throw IllegalStateException immediately if optional is empty
loggedInUserOptional.orElseThrow(IllegalStateException::new);
{% endhighlight %}

Filter is used to test for condition. It takes a `java.util.function.Predicate`
and returns empty `Optional` if condition doesn't met.

{% highlight java %}
Optional<User> user = findUserById(id);

if (author != null && user.isActive()) {
    System.out.println("Name: " + user.getName());
}

// Same code using filter()
user.filter(User::isActive).ifPresent(user -> {
    System.out.println("Name: " + user.getName());
});
{% endhighlight %}

These methods helps to manipulate value inside `Optional`. Both of them are
similar but takes different kind of `java.util.funciton.Function`. Suppose I
want to make`Optional<String>` uppercase both `map()` or `flatMap()` can be used
here.

{% highlight java %}
Optional<String> nameOptional = Optional.of("John");

// Here map() takes [String -> Something] function 
nameOptional.map(name -> name.toUpperCase()).ifPresent(System.out::println); // JOHN

// flatMap() takes [String -> Optional<Something>] function
// Same code written using flatMap()
nameOptional.flatMap(name -> Optional.of(name.toUpperCase())).ifPresent(System.out::println); // JOHN
{% endhighlight %}

# Resource
* <https://www.oracle.com/technical-resources/articles/java/java8-optional.html>
* <http://dolszewski.com/java/java-8-optional-use-cases>
* <https://blog.joda.org/2015/08/java-se-8-optional-pragmatic-approach.html>
* <https://stackoverflow.com/questions/31922866/why-should-java-8s-optional-not-be-used-in-arguments>
* <https://stackoverflow.com/questions/26327957/should-java-8-getters-return-optional-type>