IN: complexity.tools
USING:
    kernel
    sequences
    sequences.generalizations
    macros
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
