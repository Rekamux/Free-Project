USING: tools.test complexity accessors ;

{ 4 }
[ T{ operator f 0 5 } decrement-times times>> ]
unit-test

{ 4 }
[ T{ operator f 0 3 } increment-times times>> ]
unit-test

{ {
    T{ copy-operator f 0 1 }
    T{ copy-operator f 0 1 }
    T{ copy-operator f 0 1 }
    T{ copy-operator f 0 1 }
    T{ copy-operator f 0 1 } 
    2 3 4 5
} }
[
    { T{ copy-operator f 0 1 } 2 3 4 5 }
    T{ copy-operator f 0 4 }
    apply
]
unit-test

{ { 1 1 1 1 1 2 3 4 5 } }
[ { 1 2 3 4 5 } T{ copy-operator f 0 4 } apply ]
unit-test

{ { T{ copy-operator f 1 4 } 1 2 3 4 5 } }
[ { 1 1 1 1 1 2 3 4 5 } <copy-operator> search-operator ]
unit-test


{ { 1 2 3 4 5 } }
[ { 1 } T{ increment-operator f 0 4 } apply ]
unit-test

{ {
    T{ increment-operator f 0 1 }
    T{ increment-operator f 0 2 }
    T{ increment-operator f 0 3 }
    T{ increment-operator f 0 4 }
    T{ increment-operator f 0 5 }
} }
[
    { T{ increment-operator f 0 1 } }
    T{ increment-operator f 0 4 }
    apply
]
unit-test

{ { T{ increment-operator f 1 4 } 1 } }
[ { 1 2 3 4 5 } <increment-operator> search-operator ]
unit-test

{ { 3 3 3 4 5 3 3 3 6 7 3 3 3 } }
[
    { 3 4 5 6 7 }
    T{ step-operator f 1 3 T{ copy-operator f 1 2 } 2 }
    apply
]
unit-test

{ { 3 4 5 6 3 7 8 9 10 3 3 3 } }
[
    { 3 3 3 3 3 }
    T{ step-operator f 1 2 T{ increment-operator f 1 3 } 1 }
    apply
]
unit-test
