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

{ 9 }
[ <operator> 8 >>times 16 >>argument cost>> ]
unit-test

{ 7 }
[ <increment-operator> 7 >>times 15 >>argument cost>> ]
unit-test

{ 14 }
[ <increment-operator> 7 >>times <operator> 8 >>times 16
>>argument >>argument cost>> ]
unit-test

{ 24 }
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

! { {
!     T{ increment-operator f 0 }
!     T{ increment-operator f 1 }
!     T{ increment-operator f 2 }
!     T{ increment-operator f 3 }
!     T{ increment-operator f 4 }
!     T{ increment-operator f 5 }
! } }
! [
!     { } <increment-operator> prefix
!     <increment-operator> 5 >>times
!     apply
! ]
! unit-test
! 
! { {
!     T{ increment-operator f 5 }
!     T{ increment-operator f 0 }
! } }
! [
!     { } <increment-operator> prefix
!     <increment-operator> 5 >>times
!     apply
!     <increment-operator> search-operator
! ]
! unit-test
! 
! { { T{ increment-operator f 4 } 1 } }
! [ { 1 2 3 4 5 } <increment-operator> search-operator ]
! unit-test
! 
! { { T{ increment-operator f 4 } 1 5 } }
! [ { 1 2 3 4 5 5 } <increment-operator> search-operator ]
! unit-test
! 
! { { 3 3 3 4 5 3 3 3 6 7 3 3 3 } }
! [
!     { 3 4 5 6 7 }
!     <step-operator> 3 >>times 2 >>gap
!     <copy-operator> 2 >>times >>operator
!     apply
! ]
! unit-test
! 
! { { 3 4 5 6 3 7 8 9 10 3 3 3 } }
! [
!     { 3 3 3 3 3 }
!     <step-operator> 2 >>times 1 >>gap
!     <increment-operator> 3 >>times >>operator
!     apply
! ]
! unit-test
! 
! { {
!     T{ increment-operator f 2 }
!     0
! } }
! [ { 0 1 2 } iter-compress ] unit-test
! 
! { { 0 1 2 2 2 } }
! [ reset { 0 1 2 2 2 } { t f } amb [ compress ] when ] unit-test
! 
! { 3 }
! [
!     { 1 2 T{ operator f f } 3 4 5
!     T{ operator f f } 6 T{ operator f f } }
!     count-operators
! ] unit-test
! 
! { t }
! [ 
!     { 1 2 2 3 3 3 4 4 4 4 }
!     dup compress dup . decompress dup . =
! ] unit-test
! 
! { { 1 2 3 4 5 } { 6 7 8 9 } }
! [ { } { } { 1 6 2 7 3 8 4 9 5 } (step-operator-reduce) drop ]
! unit-test
