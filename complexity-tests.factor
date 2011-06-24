USING:
    tools.test
    math
    complexity
    complexity.tools
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

