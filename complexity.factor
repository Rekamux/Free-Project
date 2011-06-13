IN: complexity
USING:
    kernel
    math
    sequences
    sequences.generalizations
    generalizations
    accessors
    summary
    classes
    namespaces
    ;

SYMBOL: fail*

: fail ( -- * )
    fail* get [ failure ] or
    call( -- * ) ;

: reset ( -- )
    f fail* set ;

: set-fail ( quot: ( -- * ) -- )
    fail* get
    [ fail* set call ] 2curry
    fail* set ;

: amb ( seq -- x )
    dup empty? [
        fail
    ] [
        [
            unclip
            [
                [ amb swap continue-with ]
                2curry set-fail
            ] dip
        ] curry callcc1
    ] if ;

: bag-of ( quot: ( -- x ) -- seq )
    [ V{ } clone ] dip
    [ call( -- x ) swap push fail ] curry
    [ ] bi-curry
    [ { t f } amb ] 2dip if ;

TUPLE: operator times ;

GENERIC: cost>> ( operator -- cost )

: decrement-times ( operator -- operator )
    [ 1 - ] change-times ;

: increment-times ( operator -- operator )
    [ 1 + ] change-times ;

: extract-cost ( arg -- cost )
    dup operator instance?
    [ cost>> ]
    [ 
        dup 0 =
        [ 1 + ]
        [ log2 1 + ]
        if
    ] if ;

: (complexity) ( cost list -- newcost rest )
    [ { } ]
    [ unclip extract-cost rot + swap (complexity) ]
    if-empty ;

: complexity ( list -- cost )
    0 swap (complexity) drop ;

GENERIC: apply ( argument operator -- result )

GENERIC: apply-on-one ( argument operator -- result operator )

: check-compatibility ( argument result operator -- ? )
    swap [ apply-on-one drop ] dip = ;

GENERIC: (search-operator) ( list operator -- rest operator )

GENERIC: search-operator ( list operator -- compressed )


TUPLE: copy-operator < operator ;

: <copy-operator> ( -- copy-operator )
    copy-operator new 0 >>times
    ;

M: operator cost>>
    times>> extract-cost ;

M: copy-operator apply-on-one
    decrement-times
    [
        dup operator instance? [ clone ] when
    ] dip ;

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
    
M: copy-operator search-operator
    (search-operator) prefix ;

TUPLE: increment-operator < operator ;

: <increment-operator> ( -- increment-operator )
    increment-operator new 0 >>times ;

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

M: increment-operator apply
    { } -rot (increment-operator-apply) drop append ;
    
M: increment-operator (search-operator)
    swap dup 1 tail empty?
    [ swap ]
    [
        reverse dup 
        [ first ] 
        [ 
            second
            dup operator instance?
            [ increment-times ]
            [ 1 + ]
            if
        ] bi =
        [
            1 tail reverse swap
            increment-times
            (search-operator)
        ]
        [ swap ] if
    ] if ;

M: increment-operator search-operator
    (search-operator) prefix ;

TUPLE: step-operator < operator operator gap ;

: <step-operator> ( -- step-operator )
    step-operator new 0 >>times 0 >>operator 0 >>gap ;

M: step-operator cost>>
    [ times>> extract-cost ]
    [ operator>> extract-cost ]
    [ gap>> extract-cost ] tri + + ;

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

M: step-operator apply
    dup operator>> increment-times drop
    [ unclip { } swap prefix swap { } swap ] dip
    (step-operator-apply)
    drop append swap drop ;

! Try a list of operator on a sequence and keep the first
! efficient
: which-operator ( operator-list list -- result )
        swap [ search-operator ] 2map
        { T{ operator f 0 } }
        [
            [ dup first times>> ] bi@ rot <
            [ [ drop ] dip ]
            [ drop ] if
        ] reduce ;

: (iter-compress) ( list rest -- list' rest' )
    dup empty?
    [ ]
    [
        dup { copy-operator increment-operator } swap
        which-operator
        dup first times>> 0 =
        [ drop unclip swap [ prefix ] dip ]
        [ [ drop ] dip 2 cut [ append ] dip ] if
        (iter-compress)
    ]
    if ;

: iter-compress ( list -- list' )
    { } swap (iter-compress) drop ;

SYMBOL: current-result
SYMBOL: current-cost

: (compress) ( -- )
    current-result get
    iter-compress
    dup extract-cost current-cost get <
    [
        [ extract-cost current-cost swap set ]
        [ current-result swap set ] bi
        (compress)
    ]
    [ drop ] if ; 

: compress ( list -- result )
    [ extract-cost current-cost swap set ]
    [ current-result swap set ]
    bi
    (compress) current-cost get ;
