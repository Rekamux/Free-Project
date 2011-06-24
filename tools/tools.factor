IN: complexity.tools
USING:
    kernel
    sequences
    sequences.generalizations
    prettyprint io
    macros
    math
    ;

MACRO: nunclip ( n -- quot )
    [ [ cut* ] keep firstn ] curry ;

: 2unclip ( list -- rest second first )
    2 nunclip ;

: 3unclip ( list -- rest third second first )
    3 nunclip ;

: (extend) ( done rest -- done' rest' )
    dup empty? [ ]
    [ unclip dup sequence? [ { } swap (extend) drop swap 
    [ append ] dip ] [ swap [ suffix ] dip ] if (extend) ] if ;

: extend ( seq -- extended )
    { } swap (extend) drop ;

: extd-length ( seq -- n )
    extend length ;

: none-sequence? ( seq -- ? )
    [ sequence? not ] all? ;

: first-sequence-index ( seq -- n )
    dup empty? [ drop f ]
    [ unclip sequence? [ drop 0 ] [ first-sequence-index 1 + ]
    if ] if ;

DEFER: containing-sequence

<PRIVATE
: continue-and-append ( n-xl+1 bef m cs aft -- n' seq' )
    "" print
    "continue and append start" print
    [ [ dup . ] tri@ ] 2dip [ dup . ] bi@
    2dup =
    [ [ 2drop ] dip append ]
    [ drop [ 2drop ] 2dip ] if
    "-----caa end" print [ dup . ] bi@ ;

: continue-and-test ( n-xl+1 n-i-xl bef aft -- n' seq' )
    "" print
    "continue and test start" print
    [ [ dup . ] bi@ ] 2dip [ dup . ] bi@
    [ swap ] dip [ containing-sequence ] keep
    continue-and-append
    "-----cat end" print [ dup . ] bi@ ;

: cut-and-continue ( n-i seq i -- n' seq' )
    "" print
    "tail and continue start" print
    [ dup . ] tri@
    [ [ nip + 1 + ] [ swap nth extd-length ] 3bi
    [ - ] curry bi@ ]
    [ 1 + cut [ nip ] dip ] 3bi continue-and-test
    "-----tac end" print [ dup . ] bi@ ;

: go-into ( n-i seq i -- n' seq' )
    "" print
    "go into start" print
    [ dup . ] tri@
    swap nth containing-sequence
    "-----gi end" print [ dup . ] bi@ ;

: try-on-first ( n-i seq i -- n' seq' )
    "" print
    "try on first start" print
    [ dup . ] tri@
    3dup swap nth extd-length >=
    [ cut-and-continue ] [ go-into ] if
    "-----try of end" print [ dup . ] bi@ ;

: test-on-first ( n seq -- n' seq' )
    "" print
    "test on first start" print
    [ dup . ] bi@
    2dup first-sequence-index
    dup rot > [ drop ] [ [ swap [ - ] dip ] keep
    try-on-first ] if
    "-----test of end" print [ dup . ] bi@ ;
PRIVATE>

: containing-sequence ( n seq -- n' seq' )
    dup none-sequence? [ ] [ test-on-first ] if ;

: set-extended-nth ( n seq quot -- )
    3drop ; ! TODO

: change-extended-nth ( n seq quot -- seq )
    [ [ nth ] dip call ] 3keep drop set-nth ; inline
