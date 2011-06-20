USING:
    tools.test
    complexity
    complexity.tools
    accessors
    sequences
    kernel
    prettyprint
    ;

{ 4 }
[ <operator> 5 >>times decrement-times times>> ]
unit-test

{ 4 }
[ <operator> 3 >>times increment-times times>> ]
unit-test

{ 8 }
[ <operator> 8 >>times 16 >>argument cost>> ]
unit-test

{ 7 }
[ <increment-operator> 7 >>times 15 >>argument cost>> ]
unit-test

{ 11 }
[ <increment-operator> 7 >>times <operator> 8 >>times 16
>>argument >>argument cost>> ]
unit-test

{ 20 }
[
    { }
    <increment-operator> 7 >>times
    <operator> 8 >>times 16 >>argument
    dup clone [ >>argument prefix ] dip
    prefix 1 prefix cost>>
] unit-test

{ ARGUMENT }
[
    <increment-operator> 5 >>argument BOTH set-how how>>
] unit-test

{ TIMES }
[
    <increment-operator>
    <operator> <operator> >>argument
    >>argument BOTH set-how how>>
] unit-test

{ BOTH }
[
    <increment-operator>
    <operator> 5 >>argument
    >>argument BOTH set-how how>>
] unit-test

{ { 5 } 6 }
[
    <increment-operator> 5 >>argument
    [ apply-once ] [ argument>> ] bi
] unit-test

{ 5 10 6 11 }
[
    <increment-operator>
    <operator> 5 >>times 10 >>argument
    >>argument BOTH set-how
    [ apply-once [ length ] [ first ] bi ]
    [ argument>> [ times>> ] [ argument>> ] bi ]
    bi
] unit-test

{ 5 6 }
[
    <increment-operator>
    <operator>
    <operator> 1 >>argument 1 >>times
    >>argument 5 >>times
    >>argument TIMES set-how
    [ apply-once length ]
    [ argument>> apply length ] bi
] unit-test

{ t }
[ <operator> 1 >>argument 1 argument-equals ] unit-test

{ t }
[ <operator> 1 >>argument { 1 2 3 4 } first-argument-equals ]
unit-test

{ T{ operator f 5 1 } { 2 3 4 } }
[
    <operator> 1 >>argument { 1 1 1 1 1 2 3 4 }
    (search-operator)
] unit-test

{ { T{ operator f 5 1 } 2 3 4 } }
[ <operator> { 1 1 1 1 1 2 3 4 } search-operator ] unit-test

{ { T{ increment-operator f 6 1 ARGUMENT } 6 } }
[
    <increment-operator> { 1 2 3 4 5 6 6 }
    search-increment-operator
] unit-test

{ {
    T{ increment-operator
        { times 5 }
        { argument 1 }
        { how ARGUMENT }
    }
    T{ increment-operator
        { times 1 }
        { argument 7 }
        { how ARGUMENT }
    }
} }
[ { 1 2 3 4 5 7 } compress ] unit-test

{ t }
[ { 1 2 2 3 3 3 } dup compress decompress = ] unit-test
