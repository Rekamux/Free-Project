IN: complexity.tools
USING:
    kernel
    sequences
    sequences.generalizations
    generalizations
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

DEFER: deep-clone

: deep-clone-sequence ( seq -- seq' )
    dup empty? [ ]
    [ unclip dup sequence? [ [ deep-clone ] bi@ prefix ]
    [ [ deep-clone ] dip clone prefix ] if ] if ;

: deep-clone ( obj -- obj' )
    dup sequence? [ deep-clone-sequence ] [ clone ] if ;
