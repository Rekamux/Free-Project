IN: complexity
USING:
    kernel
    math
    sequences
    accessors
    classes
    prettyprint io
    complexity.tools
    ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!             OPERATORS                    !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! An 1-unary operator, usable on digits or operators
TUPLE: operator times ;

! Copy an operator or a digit
TUPLE: copy-operator < operator ;

! Increment a digits or times of an operator
TUPLE: increment-operator < operator ;

! Use an operator 'times' times on a list with a gap
TUPLE: step-operator < operator operator gap ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!              CONSTRUCTORS               !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Construct a non-effective copy-operator
: <copy-operator> ( -- copy-operator )
    copy-operator new 0 >>times
    ;

! Construct a non-effective increment-operator
: <increment-operator> ( -- increment-operator )
    increment-operator new 0 >>times ;

! Construct a non-effective step-operator
: <step-operator> ( -- step-operator )
    step-operator new 0 >>times 0 >>operator 0 >>gap ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!           TIMES SETTERS                 !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Decrement an operator's times
: decrement-times ( operator -- operator )
    [ 1 - ] change-times ;

! Increment an operator's times
: increment-times ( operator -- operator )
    [ 1 + ] change-times ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!             COMPLEXITY                    !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

DEFER: extract-cost

! Compute an operator's cost
GENERIC: cost>> ( operator -- cost )

! Standard operator cost
M: operator cost>>
    times>> extract-cost ;

! Step-ooperator's cost version
M: step-operator cost>>
    [ times>> extract-cost ]
    [ operator>> extract-cost ]
    [ gap>> extract-cost ] tri + + ;

! Compute the cost of a digit or an operator
: extract-cost ( arg -- cost )
    dup operator instance?
    [ cost>> ]
    [ 
        dup 0 =
        [ 1 + ]
        [ log2 1 + ]
        if
    ] if ;

! Compute the cost of a list of digits and operators
! (recursive version)
: (complexity) ( cost list -- newcost rest )
    [ { } ]
    [ unclip extract-cost rot + swap (complexity) ]
    if-empty ;

! Compute the cost of a list of digits and operators
: complexity ( list -- cost )
    0 swap (complexity) drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!               APPLY ON ONE                    !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Apply the operator on a single digit or operator
GENERIC: apply-on-one ( argument operator -- result operator )

! Copy-operator's version of apply-on-one
M: copy-operator apply-on-one
    decrement-times
    [
        dup operator instance? [ clone ] when
    ] dip ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!                   APPLY                        !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Apply the operator on a list of digits or operators
GENERIC: apply ( argument operator -- result )

! Copy-operator's version of apply
M: copy-operator apply
    dup times>> 0 =
    [ drop ]
    [
        swap
        dup empty?
        [ nip ]
        [
            dup first rot
            apply-on-one
            [ prefix ] dip
            apply
        ] if
    ] if ;

! Recursive version of increment-operator's apply version
: (increment-operator-apply)
( computed rest operator -- computed' rest' operator )
    dup times>> 0 =
    [ ]
    [
        [
            unclip 
            dup operator instance?
            [ dup clone increment-times ]
            [ dup 1 + ]
            if
            [ swap [ suffix ] dip ] dip 
            prefix
        ] dip
        decrement-times (increment-operator-apply)
    ] if ;

! Increment-operator's version of apply
M: increment-operator apply
    { } -rot (increment-operator-apply) drop append ;

! Recursive version of step-operator's apply version
: (step-operator-apply)
( arg computed rest op -- arg' computed' rest' op )
    dup times>> 0 = not
    [
        decrement-times
        dup operator>> clone swap ! arg beg rest oop op
        [
            [ rot ] dip apply ! beg rest aarg
            swap
            [
                append unclip-last { } swap prefix swap
            ] dip
        ] dip
        dup times>> 0 = not
        [
            dup gap>> swap ! arg b e gap op
            [ cut ] dip ! arg b eb ee op
            [ append ] 2dip ! arg newb ee op
            (step-operator-apply)
        ]
        when
    ]
    when ;

! Step-operator's apply version
M: step-operator apply
    dup operator>> increment-times drop
    [ unclip { } swap prefix swap { } swap ] dip
    (step-operator-apply)
    drop append swap drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!                SEARCH (RECURSIVE)               !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Search if the beginning of a list suits given operator
! Each iteration compresses list and increments operator
GENERIC: (search-operator) ( list operator -- rest operator )

! Copy-operator's recursive search version
M: copy-operator (search-operator)
    swap dup 1 tail empty?
    [ swap ]
    [
        dup [ first ] [ second ] bi =
        [
            1 tail swap
            increment-times
            (search-operator)
        ]
        [ swap ] if
    ] if ;

! Decrement a digit or an operator
: -(increment-operator-apply-once) ( obj -- obj' )
    dup operator instance?
    [ decrement-times ]
    [ 1 - ]
    if ;

! Decrement a digit or an operator as much as op's times
! eg T{ increment-operator f 4 } 5 => 1
: find-seed-increment-operator ( op obj -- obj' )
    dup operator instance?
    [ [ swap times>> - ] change-times ]
    [ swap times>> - ] if ;

! Increment-operator's recursive search version
M: increment-operator (search-operator)
    [ dup 1 tail empty? ] dip swap
    [ ]
    [
        swap dup [ first ] 
        [ second clone -(increment-operator-apply-once) ] bi =
        [
            1 tail swap
            increment-times
            (search-operator)
        ]
        [ swap ] if
    ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!                 SEARCH                   !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Same as above in a non-recursive version
GENERIC: search-operator ( list operator -- compressed )

! Copy-operator's version of search
M: copy-operator search-operator
    (search-operator) prefix ;

! Increment-operator's version of search
M: increment-operator search-operator
    (search-operator)
    dup rot unclip swap
    [ find-seed-increment-operator ] dip swap prefix
    swap prefix ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!                  COMPRESSION                    !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Try a list of operator on a sequence and keep the first
! efficient or return original list if no-one found
: which-operator ( operator-list list -- result )
    { t f } amb
    [ [ swap search-operator ] curry map 
    amb 
    dup first times>> 0 =
    [ fail ]
    [ reset ] if ] [ [ drop ] dip ] if ;

! Search once on a list for operators (recursive version)
: (iter-compress) ( list rest -- list' rest' )
    dup empty?
    [ ]
    [
        { } <copy-operator> prefix <increment-operator> prefix
        swap which-operator
        dup first operator instance?
        [ 2 cut [ append ] dip ]
        [ unclip swap [ suffix ] dip ] if
        (iter-compress)
    ]
    if ;

! Search once on a list for operators
: iter-compress ( list -- list' )
    { } swap (iter-compress) drop ;

! Compress current-result's list as far as its cost doesn't
! exceed current one
: compress ( list -- compressed )
    [ dup clone iter-compress dup complexity ]
    [ complexity ] bi <
    [ [ drop ] dip compress ]
    [ drop ] if ; 

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!               LIST EXTENSION                   !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Count operators in a list
: count-operators ( list -- count )
    [ 0 ]
    [
        unclip [ count-operators ] dip
        operator instance? [ 1 + ] when
    ] if-empty ;

! Decompress all operators (recursive version)
: (decompress) ( list rest -- decompressed rest' )
    dup empty?
    [ ]
    [
        unclip dup operator instance?
        [ apply ]
        [ swap [ suffix ] dip ] if
        (decompress)
    ] if ;

! Decompress all operators
: decompress ( list -- decompressed )
    { } swap (decompress) drop ;
