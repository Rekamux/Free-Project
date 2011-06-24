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

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!    SEQUENCE EXTENSION                !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: (extend) ( done rest -- done' rest' )
    dup empty? [ ]
    [ unclip dup sequence? [ { } swap (extend) drop swap 
    [ append ] dip ] [ swap [ suffix ] dip ] if (extend) ] if ;

: extend ( seq -- extended )
    { } swap (extend) drop ;

<PRIVATE
: extd-length ( seq -- n )
    extend length ;

: none-sequence? ( seq -- ? )
    [ sequence? not ] all? ;

: first-sequence-index ( seq -- n )
    dup empty? [ drop f ]
    [ unclip sequence? [ drop 0 ] [ first-sequence-index 1 + ]
    if ] if ;

: continue-and-append ( seq bef m cs aft -- n' seq' )
    2dup =
    [ 2drop swap length + swap ]
    [ drop [ 2drop ] 2dip ] if ;
PRIVATE>

DEFER: containing-sequence

<PRIVATE
: continue-and-test ( seq n-i-xl bef aft -- n' seq' )
    [ swap ] dip [ containing-sequence ] keep
    continue-and-append ;

: cut-and-continue ( n-i seq i -- n' seq' )
    [ drop nip ]
    [ swap nth extd-length - ]
    [ 1 + cut [ nip ] dip ] 3tri continue-and-test ;

: go-into ( n-i seq i -- n' seq' )
    swap nth containing-sequence ;

: try-on-first ( n-i seq i -- n' seq' )
    3dup swap nth extd-length >=
    [ cut-and-continue ] [ go-into ] if ;

: test-on-first ( n seq -- n' seq' )
    2dup first-sequence-index
    dup rot > [ drop ] [ [ swap [ - ] dip ] keep
    try-on-first ] if ;
PRIVATE>

: containing-sequence ( n seq -- n' seq' )
    dup none-sequence? [ ] [ test-on-first ] if ;

: set-extended-nth ( elt n seq -- )
    containing-sequence set-nth ;

: change-extended-nth ( n seq quot -- )
    [ [ extend nth ] dip call ] 3keep
    drop set-extended-nth ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!             OPERATORS                    !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: C

SYMBOL: I

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!             APPLY COPY                   !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: copy ( what times -- seq )
    swap [ ] curry replicate
    dup first sequence? [ concat ] when ;

: apply-copy ( list -- decompressed )
    2unclip copy append ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!           APPLY INCREMENT               !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

<PRIVATE
: suffix-or-append ( seq obj -- seq' )
    dup sequence? [ append ] [ suffix ] if ;

: increment-somewhere ( what where -- what )
    [ dup sequence? ] dip swap
    [ swap [ 1 + ] [ change-extended-nth ] 2keep drop ]
    [ drop 1 + ] if ;

: increment-and-append ( done what where -- done' what' where )
    [ [ deep-clone suffix-or-append ] keep ] dip
    dup sequence? [ [ [ increment-somewhere ] each ]
    2keep nip ] [ [ increment-somewhere ] keep ] if ;

: decrement-times
( done what where times -- done' what' where times' )
    dup zero? [ ]
    [ 1 - [ increment-and-append ] dip decrement-times ] if ;
PRIVATE>

: increment ( what where times -- seq )
    [ { } ] 3dip decrement-times 3drop ;

: apply-increment ( list -- decompressed )
    3unclip increment append ;
