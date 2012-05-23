USING:
    tools.test
    math
    complexity.tools
    complexity
    accessors
    sequences
    kernel
    prettyprint
    ;
    
{ { 0 1 2 { 3 5 { 5 6 } } 7 { 8 } 9 { 10 { 11 } 12 } 13 } }
[
    4 { 0 1 2 { 3 4 { 5 6 } } 7 { 8 } 9 { 10 { 11 } 12 } 13 }
    [ 1 + ] [ change-extended-nth ] 2keep drop
] unit-test
    
{ { 0 1 2 { 3 4 { 5 6 } } 7 { 9 } 9 { 10 { 11 } 12 } 13 } }
[
    8 { 0 1 2 { 3 4 { 5 6 } } 7 { 8 } 9 { 10 { 11 } 12 } 13 }
    [ 1 + ] [ change-extended-nth ] 2keep drop
] unit-test
    
{ { 0 1 2 { 3 4 { 5 6 } } 7 { 8 } 9 { 10 { 11 } 12 } 14 } }
[
    13 { 0 1 2 { 3 4 { 5 6 } } 7 { 8 } 9 { 10 { 11 } 12 } 13 }
    [ 1 + ] [ change-extended-nth ] 2keep drop
] unit-test

{ {
    1 { 2 { 3 } 4 } 5 { 6 }
    1 { 2 { 3 } 4 } 5 { 6 }
    1 { 2 { 3 } 4 } 5 { 6 } 
} }
[ { { 1 { 2 { 3 } 4 } 5 { 6 } } 3 } apply-copy ] unit-test

{ {
    1 { 2 { 3 } 4 } 5 { 6 }
    2 { 2 { 4 } 4 } 5 { 7 }
    3 { 2 { 5 } 4 } 5 { 8 } 
} }
[ { 
    { 1 { 2 { 3 } 4 } 5 { 6 } }
    { 0 2 5 }
    3 
} apply-increment ] unit-test

{ { 3 4 4 5 5 5 6 6 6 6 7 7 7 7 7 } }
[ { { 2 0 C } { 0 1 } 6 I } decompress ] unit-test

{ { 1 2 3 } }
[ { 1 2 } extend-logic ] unit-test

{ { 1 1 1 } }
[ { 1 1 } extend-logic ] unit-test

{ { 1 2 2 3 3 3 4 4 4 4 } }
[ { 1 2 2 3 3 3 } extend-logic ] unit-test

{ { 1 2 2 3 3 4 } }
[ { 1 2 2 3 } extend-logic ] unit-test

{ {
        1 1 2 1 2 3
        1 1 2 1 2 3 1 2 3 4
        1 1 2 1 2 3 1 2 3 4 1 2 3 4 5
} }
[ { 1 1 2 1 2 3 1 1 2 1 2 3 1 2 3 4 } extend-logic ] unit-test

{ {
    1 1 2
    1 1 2 1 2 3
    1 1 2 1 2 3 1 2 3 4
    1 1 2 1 2 3 1 2 3 4 1 2 3 4 5
} }
[ { 1 1 2 1 1 2 1 2 3 1 1 2 1 2 3 1 2 3 4 } extend-logic ]
unit-test
