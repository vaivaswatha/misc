# Unpacking the C++17 Variant

## Introduction

`std::variant` was introduced in the C++17 standard and is intended to
provide [tagged unions](https://en.wikipedia.org/wiki/Tagged_union) to C++.
Tagged unions are a safer alternative to the native `union` in C++.
The safety advantage of tagged unions (as against plain `union`) comes from
the type of the constituent object being automatically tagged within
the object, and any access is checked for being of the right type.

## Motivation

Consider this [example](https://www.bfilipek.com/2018/09/visit-variants.html)
using a plain C++ `union`

```cpp

struct Fluid { float fluidity; };
struct Light { int weight; };
struct Heavy { int weight; };
struct Fragile { float density; };

struct Package {
  enum PackageKind {
    Kind_Fluid,
    Kind_Light,
    Kind_Heavy,
    Kind_Fragile
  } tag;

  union {
    Fluid fluid;
    Light lightItem;
    Heavy heavyItem;
    Fragile fragileItem;
  } P;
};

int main()
{
  Package p;
  p.tag = Package::Kind_Fragile;
  p.P.fragile = Fragile();
  p.P.fragile.density = 1.0;

  switch (p.tag) {
  case Package::Kind_Fluid:
    std::cout << "fluid: fluidity=" << p.P.fluid.fluidity << "\n";
    break;
  case Package::Kind_Light:
    std::cout << "light: weight=" << p.P.light.weight << "\n";
    break;
  case Package::Kind_Heavy:
    std::cout << "heavy: weight=" << p.P.heavy.weight << "\n";
    break;
  case Package::Kind_Fragile:
    std::cout << "fragile: density=" << p.P.fragile.density << "\n";
    break;
  }

  return 0;
}

```

A typical design pattern (in C++ prior to C++17) is to use a `struct` that contains a
union to hold different possible types, and a tag to identify the type that is currently
held in the union. This however has the following issues
  * Setting the union does not automatically set the tag.
  * Accessing the union does not mandate checking for the tag.

## Variants in funtional programming
Variants (aka tagged unions) are extensively used in functional programming. Let's see
our previous example in OCaml.

```ocaml

type package =
  | Fluid of float
  | Light of int
  | Heavy of int
  | Fragile of float

let () =
  let p = Fragile 1.0 in
  match p with
  | Fluid fluidity -> printf "fluid: fluidity=%f\n" fluidity;
  | Light weight -> printf "light: weight=%d\n" weight;
  | Heavy weight -> printf "heavy: weight=%d\n" weight;
  | Fragile density -> printf "fragile: density=%f\n" density;

```

The language guarentees that we cannot create a `package` without specifying its kind
and also, accessing the contents can only be done through a `match` which enforces
handling the right "tag", solving both the problems with C++ unions. The `match` also
checks that all cases are handled. With the right warnings switched on, this is true
in our C++ example also.

## Variants in C++17
Let us now explore how to create `std::variant` objects and unpack (visit) them.
A complete working source is provided at the end of this article.

### Using functors to unpack
In this example we use functors (function objects) that define a function (handler)
for each constituent type of the variant.

```cpp
#include <iostream>
#include <variant>

struct Fluid { float fluidity; };
struct Light { int weight; };
struct Heavy { int weight; };
struct Fragile { float density; };

typedef std::variant<Fluid, Light, Heavy, Fragile> Package;

struct VisitPackage
{
  void operator()(Fluid& f) { std::cout << "fluid: fluidity=" << f.fluidity << "\n"; }
  void operator()(Light& l) { std::cout << "light: weight=" << l.weight << "\n"; }
  void operator()(Heavy& h) { std::cout << "heavy: weight=" << h.weight << "\n"; }
  void operator()(Fragile& f) { std::cout << "fragile: density=" << f.density << "\n"; }
};

int main()
{
  Package package{ Fragile() };
  std::get<Fragile>(package).density = 1.0;

  std::cout << "Visiting variant using a functor\n";
  // safe visitor pattern using functors.
  std::visit(VisitPackage(), package);

  return 0;
}
```

If a handler for any of the constituent type is missing, the compiler flags an error.
While this example works, we would, many a times, prefer to unpack the variant "inline",
i.e., in this example, at the point where we call `std::visit`, without having to define
handlers elsewhere, Similar to the plain `union` example or the OCaml example.

### Using lambdas to unpack

Having defined these utilities at a global scope

```cpp
template<class... Ts> struct overload : Ts... { using Ts::operator()...; };
template<class... Ts> overload(Ts...) -> overload<Ts...>;
```

we can now unpack the variant "inline", in a manner that now resembles the `match`
we used in the OCaml example.

```cpp
  std::cout << "Visiting variant using lambdas\n";
  // safe visitor pattern using lambdas.
  std::visit(overload {
      [] (Fluid& f) { std::cout << "fluid: fluidity=" << f.fluidity << "\n"; },
      [] (Light& l) { std::cout << "light: weight=" << l.weight << "\n"; },
      [] (Heavy& h) { std::cout << "heavy: weight=" << h.weight << "\n"; },
      [] (Fragile& f) { std::cout << "fragile: density=" << f.density << "\n"; }
    }, package);
```

### The need for unpacking using a `switch` statement
So far, so good. What prompted me to write this article was that, although using the
`overload` above to define a simple visitor pattern using lambdas works, and indeed
looks good, it seems like an overkill.
  * Using functions (lambdas) has overheads.
  * Manoeuvring around templated lambdas in the debugger is painful.
  * [Code bloat](https://www.reddit.com/r/cpp/comments/9khij8/stdvariant_code_bloat_looks_like_its_stdvisit/)
  with current implementations.
  * There's an entire [article](https://bitbashing.io/std-visit.html) on this.

To be able to use plain `switch` statements, we need to ensure the following
  1. The safety provided by `std::variant` in packing (creating) and unpacking
  objects must be retained.
  2. Each `case` of the `switch` must use a symbolic name, rather than integers.
  This means that switching over to `std::variant::index` is not an option.
  3. The compiler must warn or error out when we have unhandled alternatives.

Ensuring 1. is simple as long as we continue to use `std::variant`. So let's start
with 2. To have each `case` of the `switch` be a symbolic name, we need a way to
translate the constituent type (assume all unique types in the variant) into an
integer. The standard does not provide for such a utility, and hence after some 
searching around, I found [this](https://stackoverflow.com/a/52303671/2128804).

By defining a variadic function template `indexof` as below

```cpp
// Given a VariantType and one of its constituent type,
// return the index of the constituent type.
// https://stackoverflow.com/a/52303671/2128804
template<typename VariantType, typename T, std::size_t index = 0>
constexpr std::size_t indexof() {
  if constexpr (index == std::variant_size_v<VariantType>) {
      return index;
    } else if constexpr (std::is_same_v<std::variant_alternative_t<index, VariantType>, T>) {
      return index;
    } else {
    return indexof<VariantType, T, index + 1>();
  }
}

```

we can now translate a variant's constituent type into a constexpr integer index,
enabling us to use symbolic names in each `case` of our `switch`.

```cpp
  std:: cout << "Visiting variant using a switch statement\n";
  // Unsafe: no compiler warning / error if one of the variant constituents is missed in the switch.
  switch (package.index()) {
  case std::variant_npos:
    std::cout << "variant not initialized\n";
    break;
  case indexof<Package, Fluid>():
  {
    auto f = std::get<Fluid>(package);
    std::cout << "fluid: fluidity=" << f.fluidity << "\n";
    break;
  }
  case indexof<Package, Light>():
  {
    auto l = std::get<Light>(package);
    std::cout << "light: weight=" << l.weight << "\n";
    break;
  }
  case indexof<Package, Heavy>():
  {
    auto h = std::get<Heavy>(package);
    std::cout << "heavy: weight=" << h.weight << "\n";
    break;
  }
  case indexof<Package, Fragile>():
  {
    auto f = std::get<Fragile>(package);
    std::cout << "fragile: density=" << f.density << "\n";
    break;
  }
  default:
    std::cout << "Unhandled variant member\n";
    break;
  }
```

As pointed out in the code comment, this does not however achieve 3. If we miss handling
a constituent type in the `switch`, no warning or error gets thrown. This is because the
compiler can only throw warnings on missing switch clauses when the operand is an `enum`.
It cannot do so for integers, which is the case here.

As a natural progression, I tried to see if we can "generate" an `enum` as part of a
wrapper class around `std::variant` that, in combination with `indexof` will allow us
to `switch` over `enum`s instead of over integers. Though there is such a
[solution](https://stackoverflow.com/a/32825375/2128804) for when the number of
alternatives in the variant is known beforhand, I couldn't figure out a full solution.

I end this article, with a hope that native (and not through library headers) variant
support for C++ gets implemented, as described 
[here](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2016/p0095r1.html).

## Source code for the example
Compile this file as `g++ -std=c++17 -Wall visitor.cpp -o visitor.exe`
<details><summary>visitor.cpp</summary>

```cpp
#include <iostream>
#include <variant>

// Given a VariantType and one of its constituent type,
// return the index of the constituent type.
// https://stackoverflow.com/a/52303671/2128804
template<typename VariantType, typename T, std::size_t index = 0>
constexpr std::size_t indexof() {
  if constexpr (index == std::variant_size_v<VariantType>) {
      return index;
    } else if constexpr (std::is_same_v<std::variant_alternative_t<index, VariantType>, T>) {
      return index;
    } else {
    return indexof<VariantType, T, index + 1>();
  }
} 

template<class... Ts> struct overload : Ts... { using Ts::operator()...; };
template<class... Ts> overload(Ts...) -> overload<Ts...>;

struct Fluid { float fluidity; };
struct Light { int weight; };
struct Heavy { int weight; };
struct Fragile { float density; };

typedef std::variant<Fluid, Light, Heavy, Fragile> Package;

// Taken from https://www.bfilipek.com/2018/09/visit-variants.html
struct VisitPackage
{
  void operator()(Fluid& f) { std::cout << "fluid: fluidity=" << f.fluidity << "\n"; }
  void operator()(Light& l) { std::cout << "light: weight=" << l.weight << "\n"; }
  void operator()(Heavy& h) { std::cout << "heavy: weight=" << h.weight << "\n"; }
  void operator()(Fragile& f) { std::cout << "fragile: density=" << f.density << "\n"; }
};

int main()
{
  Package package{ Fragile() };
  std::get<Fragile>(package).density = 1.0;

  std::cout << "Visiting variant using a functor\n";
  // safe visitor pattern using functors.
  std::visit(VisitPackage(), package);

  std::cout << "Visiting variant using lambdas\n";
  // safe visitor pattern using lambdas.
  std::visit(overload {
      [] (Fluid& f) { std::cout << "fluid: fluidity=" << f.fluidity << "\n"; },
      [] (Light& l) { std::cout << "light: weight=" << l.weight << "\n"; },
      [] (Heavy& h) { std::cout << "heavy: weight=" << h.weight << "\n"; },
      [] (Fragile& f) { std::cout << "fragile: density=" << f.density << "\n"; }
    }, package);

  std:: cout << "Visiting variant using a switch statement\n";
  // Unsafe: no compiler warning / error if one of the variant constituents is missed in the switch.
  switch (package.index()) {
  case std::variant_npos:
    std::cout << "variant not initialized\n";
    break;
  case indexof<Package, Fluid>():
  {
    auto f = std::get<Fluid>(package);
    std::cout << "fluid: fluidity=" << f.fluidity << "\n";
    break;
  }
  case indexof<Package, Light>():
  {
    auto l = std::get<Light>(package);
    std::cout << "light: weight=" << l.weight << "\n";
    break;
  }
  case indexof<Package, Heavy>():
  {
    auto h = std::get<Heavy>(package);
    std::cout << "heavy: weight=" << h.weight << "\n";
    break;
  }
  case indexof<Package, Fragile>():
  {
    auto f = std::get<Fragile>(package);
    std::cout << "fragile: density=" << f.density << "\n";
    break;
  }
  default:
    std::cout << "Unhandled variant member\n";
    break;
  }

  return 0;
}
```
</details>
