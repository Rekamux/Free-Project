IN: complexity
USING:
    kernel
    math
    math.ranges
    arrays
    sequences
    sequences.generalizations
    accessors
    classes
    prettyprint io
    complexity.tools
    combinators
    namespaces
    generalizations
    words
    ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!         LAST USED LIST                  !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: LUL

: resetLUL ( -- )
    [ ] clone LUL set ;

: use ( obj -- obj )
    3 dupn LUL get remove
    swap prefix LUL set ;

: 2use ( obj1 obj2 -- obj1 obj2 )
    [ use ] dip use ;

: used ( obj garb -- obj garb )
    [ use ] dip ;

: bits-cost ( val -- bits )
    dup 0 = [ ] [ log2 1 + ] if ;

: generic-cost ( obj -- cost )
    LUL get index bits-cost ;

GENERIC: cost>> ( arg -- cost )

M: sequence cost>>
   0 [ cost>> + ] reduce ; 

M: integer cost>>
    generic-cost ;

M: word cost>>
    generic-cost ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!             OPERATORS                    !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: C

SYMBOL: I

: copy ( what times -- seq )
    swap [ ] curry replicate
    dup first sequence? [ concat ] when ;

: apply-copy ( list -- decompressed )
    2unclip copy append ;

: increment ( what where times -- seq )
    2drop ;

: apply-increment ( list -- decompressed )
    3unclip increment append ;
