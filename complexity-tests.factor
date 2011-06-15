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
[ T{ operator f 5 } decrement-times times>> ]
unit-test

{ 4 }
[ T{ operator f 3 } increment-times times>> ]
unit-test

{ {
    T{ copy-operator f 1 }
    T{ copy-operator f 1 }
    T{ copy-operator f 1 }
    T{ copy-operator f 1 }
    T{ copy-operator f 1 } 
    2 3 4 5
} }
[
    { T{ copy-operator f 1 } 2 3 4 5 }
    T{ copy-operator f 4 }
    apply
]
unit-test

{ { 1 1 1 1 1 2 3 4 5 } }
[ { 1 2 3 4 5 } <copy-operator> 4 >>times apply ]
unit-test

{ { T{ copy-operator f 4 } 1 2 3 4 5 } }
[ { 1 1 1 1 1 2 3 4 5 } <copy-operator> search-operator ]
unit-test


{ { 1 2 3 4 5 } }
[ { 1 } <increment-operator> 4 >>times apply ]
unit-test

{ {
    T{ increment-operator f 0 }
    T{ increment-operator f 1 }
    T{ increment-operator f 2 }
    T{ increment-operator f 3 }
    T{ increment-operator f 4 }
    T{ increment-operator f 5 }
} }
[
    { } <increment-operator> prefix
    <increment-operator> 5 >>times
    apply
]
unit-test

{ {
    T{ increment-operator f 5 }
    T{ increment-operator f 0 }
} }
[
    { } <increment-operator> prefix
    <increment-operator> 5 >>times
    apply
    <increment-operator> search-operator
]
unit-test

{ { T{ increment-operator f 4 } 1 } }
[ { 1 2 3 4 5 } <increment-operator> search-operator ]
unit-test

{ { T{ increment-operator f 4 } 1 5 } }
[ { 1 2 3 4 5 5 } <increment-operator> search-operator ]
unit-test

{ { 3 3 3 4 5 3 3 3 6 7 3 3 3 } }
[
    { 3 4 5 6 7 }
    <step-operator> 3 >>times 2 >>gap
    <copy-operator> 2 >>times >>operator
    apply
]
unit-test

{ { 3 4 5 6 3 7 8 9 10 3 3 3 } }
[
    { 3 3 3 3 3 }
    <step-operator> 2 >>times 1 >>gap
    <increment-operator> 3 >>times >>operator
    apply
]
unit-test

{ 4 }
[ 10 extract-cost ] unit-test

{ 1 }
[ <copy-operator> extract-cost ] unit-test

{ 5 }
[ { 1 } <increment-operator> prefix 7 prefix complexity ]
unit-test

{ {
    T{ increment-operator f 2 }
    0
} }
[ { 0 1 2 } iter-compress ] unit-test

{ { 0 1 2 2 2 } }
[ reset { 0 1 2 2 2 } { t f } amb [ compress ] when ] unit-test

{ 3 }
[
    { 1 2 T{ operator f f } 3 4 5
    T{ operator f f } 6 T{ operator f f } }
    count-operators
] unit-test

{ t }
[ 
    { 1 2 2 3 3 3 4 4 4 4 }
    dup compress dup . decompress dup . =
] unit-test

{ { 1 2 3 4 5 } { 6 7 8 9 } }
[ { } { } { 1 6 2 7 3 8 4 9 5 } (step-operator-reduce) drop ]
unit-test
