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
    { } clone LUL set ;

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

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!             APPLY COPY                   !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: copy ( what times -- seq )
    swap [ ] curry replicate
    dup empty? [ dup first sequence? [ concat ] when ] unless ;

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

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!           DECOMPRESSION              !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: apply ( seq word -- seq' )
    {
        { C [ apply-copy ] }
        { I [ apply-increment ] }
    } case ;

DEFER: decompress

: decompress-last ( seq -- seq' )
    unclip-last dup word? [ apply ]
    [ [ decompress ] dip suffix ] if ;

: decompress ( seq -- seq' )
    dup empty? [ ]
    [ decompress-last ] if
    dup contains-words? [ decompress ] when ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!            COPY SEARCH             !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: is-copy? ( what rest -- rest' found )
    [ dup length ] bi@ rot < [ nip f ]
    [ [ dup length ] dip swap cut [ = ] dip swap ] if ;

: test-max-times-copy
( max-times times what rest -- max-times times' what rest' )
    [ 2dup > ] 2dip rot
    [ [ dup ] dip is-copy?
    [ [ 1 + ] 2dip test-max-times-copy ] when ] when ;

! TODO handle optimization eg modify 3array
: search-copy ( max-times seq what -- seq' )
    swap [ 1 ] 2dip test-max-times-copy
    -rot swap C 3array swap append nip ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!        INCREMENT SEARCH             !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

<PRIVATE
: fit? ( what rest -- ? )
    [ length ] bi@ <= ;

: extract-same-size ( what rest -- rest' fitting )
    [ length ] dip swap cut swap ;

: extract-increment ( what where -- incremented )
    [ { } ] 2dip increment-and-append
    drop nip ;

: is-increment? ( what where rest -- rest' found )
    3dup nip fit? [ [ nip extract-same-size ]
    [ drop extract-increment ] 3bi = ] [ 2nip f ] if ;

: test-max-times-increment
( max-times times what where rest --
max-times times' what where rest' )
    [ 2dup > ] 3dip [ rot ] dip swap
    [ [ 2dup ] dip is-increment?
    [ [ 1 + ] 3dip test-max-times-increment ] when ] when ;

SYMBOL: helper

: inc-helper ( -- )
    helper get 1 + helper set ;

: find-where ( from to -- where )
    0 helper set
    [ extend ] bi@ [ 1 - = [ { } helper get inc-helper prefix ]
    [ { } ] if ] [ append ] 2map-reduce ;

: prepare-where ( seq what -- what where seq )
    swap 2dup fit? [ 2dup extract-same-size nip
    [ nip find-where ] 3keep drop [ swap ] dip ]
    [ { } swap ] if ;
PRIVATE>

! TODO handle optimization eg modify 3array
: search-increment ( max-times seq what -- seq' )
    [ 2nip deep-clone ] 3keep prepare-where [ drop empty? ]
    2keep rot [ 4 nnip ] [ [ 1 ] 3dip test-max-times-increment
    [ [ drop rot ] dip rot I 4array ] dip swap append nip ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!           COMPRESSION              !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: sizes-list ( seq -- seq sizes )
    dup length 2 / 2 swap [a,b] >array ;

: try-size ( max-times seq op -- seq' )
    [ sizes-list amb ] dip
    { { C [ search-copy ] } { I [ search-increment ] } } case ;

