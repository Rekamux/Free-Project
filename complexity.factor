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
    ;

TUPLE: operator cost times ;

: decrement-times ( operator -- operator )
    [ 1 - ] change-times ;

: increment-times ( operator -- operator )
    [ 1 + ] change-times ;

GENERIC: apply ( argument operator -- result )

GENERIC: apply-on-one ( argument operator -- result operator )

: check-compatibility ( argument result operator -- ? )
    swap [ apply-on-one drop ] dip = ;

GENERIC: (search-operator) ( list operator -- rest operator )

GENERIC: search-operator ( list operator -- compressed )

TUPLE: copy-operator < operator ;

: <copy-operator> ( -- copy-operator )
    copy-operator new 0 >>times 1 >>cost
    ;

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
            dup first
            dup operator instance? [ clone ] when
            prefix
            [ decrement-times ] dip
            swap apply
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
    increment-operator new 0 >>times 1 >>cost ;

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
    step-operator new 0
    >>times 1 >>cost 0 >>operator 0 >>gap ;

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
