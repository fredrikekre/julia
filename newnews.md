Julia v0.7.0 Release Notes
==========================

Release highlights
------------------

  * Pkg3
  * stdlib
  * ???


New language features
---------------------

  * Many of the submodules in `Base` have moved to standalone "standard library modules".
    In the future it will be possible to update those modules independently of Julia's
    release schedule, much like regular packages. Changes to functionality in those
    standard library modules are listed in their own sections further down.

  * Named tuples, with the syntax `(a=1, b=2)`, have been added. These behave very
    similarly to tuples, except components can also be accessed by name using
    dot syntax `t.a` ([#22194]).

  * The `missing` singleton object (of type `Missing`) has been added to represent
    missing values ([#24653]). It propagates through standard operators and mathematical functions,
    and implements three-valued logic, similar to SQLs `NULL` and R's `NA`.

   * Field access via dot-syntax can now be overloaded by adding methods to
    `Base.getproperty` and `Base.setproperty!` ([#1974]), optionally along with
    a corresponding `Base.propertynames` method for reflection ([#25311]).

  * Destructuring in function arguments: when an expression such as `(x, y)` is used as
    a function argument name, the argument is unpacked into local variables `x` and `y`
    as in the assignment `(x, y) = arg` ([#6614]).

  * Keyword argument containers (`kw` in `f(; kw...)`) are now named tuples. Dictionary
    functions like `haskey` and indexing can be used on them, and name-value pairs can be
    iterated using `pairs(kw)`. `kw` can no longer contain multiple entries for the same
    argument name ([#4916]).

  * Keyword arguments can be required: if a default value is omitted, then an
    exception is thrown if the caller does not assign the keyword a value ([#25830]).

  * The construct `if @generated ...; else ...; end` can be used to provide both
    `@generated` and normal implementations of part of a function. Surrounding code
    will be common to both versions ([#23168]).

  * Local variables can be tested for being defined
    using the new `@isdefined variable` macro ([#22281]).

  * Custom infix operators can now be defined by appending Unicode
    combining marks, primes, and sub/superscripts to other operators.
    For example, `+̂ₐ″` is parsed as an infix operator with the same
    precedence as `+` ([#22089]).

  * The macro call syntax `@macroname[args]` is now available and is parsed
    as `@macroname([args])` ([#23519]).

  * Values for `Enum`s can now be specified inside of a `begin` block when using the
    `@enum` macro ([#25424]).

Syntax changes
--------------

  * The syntax for parametric methods, `function f{T}(x::T)`, has been
    changed to `function f(x::T) where {T}` ([#11310]).

  * The syntax `1.+2` is deprecated, since it is ambiguous: it could mean either
    `1 .+ 2` (the current meaning) or `1. + 2` ([#19089]).

  * The syntax `(x...)` for constructing a tuple is deprecated;
    use `(x...,)` instead ([#24452]).

  * The syntax `using A.B` can now only be used when `A.B` is a module, and the syntax
    `using A: B` can only be used for adding single bindings ([#8000]).

  * `begin` is disallowed inside indexing expressions, in order to enable the syntax
    `a[begin]` (for selecting the first element) in the future ([#23354]).

  * Assignment syntax (`a=b`) inside square bracket expressions (e.g. `A[...]`, `[x, y]`)
    is deprecated. It will likely be reclaimed in a later version for passing keyword
    arguments. Note this does not affect updating operators like `+=` ([#25631]).


Parsing/AST changes
-------------------

  * In string and character literals, backslash `\` may no longer
    precede unrecognized escape characters ([#22800]).

   * Juxtaposing binary, octal, and hexadecimal literals is deprecated, since it can lead to
    confusing code such as `0xapi == 0xa * pi` ([#16356]).

  * The parsing of `1<<2*3` as `1<<(2*3)` is deprecated, and will change to
    `(1<<2)*3` in a future version ([#13079]).

  * The parsing of `<|` is now right associative. `|>` remains left associative ([#24153]).

  * `:` now parses like other operators, as a call to a function named `:`, instead of
    calling `colon` ([#25947]).

  * `let` blocks now parse the same as `for` loops; the first argument is either an
    assignment or `block` of assignments, and the second argument is a block of
    statements ([#21774]).

  * `{ }` expressions now use `braces` and `bracescat` as expression heads instead
    of `cell1d` and `cell2d`, and parse similarly to `vect` and `vcat` ([#8470]).

  * Nested `if` expressions that arise from the keyword `elseif` now use `elseif`
    as their expression head instead of `if` ([#21774]).

  * `do` syntax now parses to an expression with head `:do`, instead of as a function
    call ([#21774]).

  * Parsed and lowered forms of type definitions have been synchronized with their
    new keywords ([#23157]). Expression heads are renamed as follows:

    + `type`           => `struct`

    + `bitstype`       => `primitive` (order of arguments is also reversed, to match syntax)

    + `composite_type` => `struct_type`

    + `bits_type`      => `primitive_type`

  * All line numbers in ASTs are represented by `LineNumberNode`s; the `:line` expression
    head is no longer used. `QuoteNode`s are also consistently used for quoted symbols instead
    of the `:quote` expression head (though `:quote` `Expr`s are still used for quoted
    expressions) ([#23885]).

  * Raw string literal escaping rules have been changed to make it possible to write all strings.
    The rule is that backslashes escape both quotes and other backslashes, but only when a sequence
    of backslashes precedes a quote character. Thus, 2n backslashes followed by a quote encodes n
    backslashes and the end of the literal while 2n+1 backslashes followed by a quote encodes n
    backslashes followed by a quote character ([#22926]).

  * Non-parenthesized interpolated variables in strings, e.g. `"$x"`, must be followed
    by a character that will never be an allowed identifier character (currently
    operators, space/control characters, or common punctuation characters) ([#25231]).

  * The conditions under which unary operators followed by `(` are parsed as prefix function
    calls have changed ([#26154]).

  * Added `⟂` (`\perp`) operator with comparison precedence ([#24404]).

  * `…` (`\dots`) and `⁝` (`\tricolon`) are now parsed as binary operators ([#26262]).


Language changes
----------------

  * The fallback constructor that calls `convert` is deprecated. Instead, new types should
    prefer to define constructors, and add `convert` methods that call those constructors
    only as necessary ([#15120]).

  * Mutable structs with no fields are no longer singletons; it is now possible to make
    multiple instances of them that can be distinguished by `===` ([#25854]).
    Zero-size immutable structs are still singletons.

  * Declaring arguments as `x::ANY` to avoid specialization has been replaced
    by `@nospecialize x`. ([#22666]).

  * Keyword argument default values are now evaluated in successive scopes ---
    the scope for each expression includes only previous keyword arguments, in
    left-to-right order ([#17240]).

  * The `global` keyword now only introduces a new binding if one doesn't already exist
    in the module.
    This means that assignment to a global (`global sin = 3`) may now throw the error:
    "cannot assign variable Base.sin from module Main", rather than emitting a warning.
    Additionally, the new bindings are now created before the statement is executed.
    For example, `f() = (global sin = "gluttony"; nothing)` will now resolve which module
    contains `sin` eagerly, rather than delaying that decision until `f` is run. ([#22984]).

  * `global const` declarations may no longer appear inside functions ([#12010]).

  * `const` declarations on local variables were previously ignored. They now give a
    warning, so that this syntax can be disallowed or given a new meaning in a
    future version ([#5148]).

  * Dispatch rules have been simplified:
    method matching is now determined exclusively by subtyping;
    the rule that method type parameters must also be captured has been removed.
    Instead, attempting to access the unconstrained parameters will throw an `UndefVarError`.
    Linting in package tests is recommended to confirm that the set of methods
    which might throw `UndefVarError` when accessing the static parameters
    (`need_to_handle_undef_sparam = Set{Any}(m.sig for m in Test.detect_unbound_args(Base, recursive=true))`)
    is equal (`==`) to some known set (`expected = Set()`). ([#23117])

  * Placing an expression after `catch`, as in `catch f(x)`, is deprecated.
    Use `catch; f(x)` instead ([#19987]).

  * In `for i = ...`, if a local variable `i` already existed it would be overwritten
    during the loop. This behavior is deprecated, and in the future `for` loop variables
    will always be new variables local to the loop ([#22314]).
    The old behavior of overwriting an existing variable is available via `for outer i = ...`.

  * In `for i in x`, `x` used to be evaluated in a new scope enclosing the `for` loop.
    Now it is evaluated in the scope outside the `for` loop.

  * In `for i in x, j in y`, all variables now have fresh bindings on each iteration of the
    innermost loop. For example, an assignment to `i` will not be visible on the next `j`
    loop iteration ([#330]).

  * Variable bindings local to `while` loop bodies are now freshly allocated on each loop iteration,
    matching the behavior of `for` loops.

  * Prefix `&` for by-reference arguments to `ccall` has been deprecated in favor of
    `Ref` argument types ([#6080]).

  * The constructor `Ref(x::T)` now always returns a `Ref{T}` ([#21527]).

  * The keyword `importall` is deprecated. Use `using` and/or individual `import` statements
    instead ([#22789]).

  * `reduce(+, [...])` and `reduce(*, [...])` no longer widen the iterated over arguments to
    system word size. `sum` and `prod` still preserve this behavior. ([#22825])

  * Like `_`, variable names consisting only of underscores can be assigned,
    but accessing their values is deprecated ([#24221]).

  * `reprmime(mime, x)` has been renamed to `repr(mime, x)`, and along with `repr(x)`
    and `sprint` it now accepts an optional `context` keyword for `IOContext` attributes.
    `stringmime` has been moved to the Base64 stdlib package ([#25990]).

  * `=>` now has its own precedence level, giving it strictly higher precedence than
    `=` and `,` ([#25391]).


Breaking changes
----------------

This section lists changes that do not have deprecation warnings.

  * [*Breaking*] `replace(s::AbstractString, pat=>repl)` for function `repl` arguments formerly
    passed a substring to `repl` in all cases.  It now passes substrings for
    string patterns `pat`, but a `Char` for character patterns (when `pat` is a
    `Char`, collection of `Char`, or a character predicate) ([#25815]).

  * `readuntil` now does *not* include the delimiter in its result, matching the
    behavior of `readline`. Pass `keep=true` to get the old behavior ([#25633]).



Deprecated or removed
---------------------

Compiler/Runtime improvements
-----------------------------

Command-line option changes
---------------------------