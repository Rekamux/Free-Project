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

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!             OPERATORS                    !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: C

SYMBOL: I

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!         LAST USED LIST                  !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: LUL

: reset-LUL ( -- )
    { C I } clone LUL set ;

: insert ( obj seq -- seq )
    2 cut [ swap suffix ] dip append ;

: generic-use ( obj -- obj )
    3 dupn LUL get remove
    insert LUL set ;

GENERIC: use ( obj -- obj )

M: sequence use
    dup empty? [ ]
    [ [ unclip [ use drop ] bi@ ] keep ] if ;

M: integer use generic-use ;

M: word use ;

: 2use ( obj1 obj2 -- obj1 obj2 )
    [ use ] bi@ ;

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
    [ [ dup length ] dip swap cut [ [ = ] keep ] dip rot
    [ nip t ] [ append f ] if ] if ;

: test-max-times-copy
( max-times times what rest -- max-times times' what rest' )
    [ 2dup > ] 2dip rot
    [ [ dup ] dip is-copy?
    [ [ 1 + ] 2dip test-max-times-copy ] when ] when ;

: create-copy ( what times -- seq )
    [ dup length 1 = [ first ] when ] dip C 3array ;

: search-copy ( max-times seq what -- seq' )
    swap [ 1 ] 2dip test-max-times-copy
    -rot swap create-copy swap append nip ;

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

: find-where-reduce-quot ( to from -- seq )
    dup word? [ 2drop { } ]
    [ 1 - =
    [ { } helper get inc-helper prefix ] [ { } ] if ] if ;

: find-where ( from to -- where )
    0 helper set
    [ extend ] bi@
    [ find-where-reduce-quot ] [ append ] 2map-reduce ;

: prepare-where ( seq what -- what where seq )
    swap 2dup fit? [ 2dup extract-same-size nip
    [ nip find-where ] 3keep drop [ swap ] dip ]
    [ { } swap ] if ;
PRIVATE>

: treat-no-increment ( what where seq -- seq' )
    nip [ 0 1 I 3array append ] dip append ;

: create-increment ( what where times -- seq )
    [ [ dup length 1 = [ first ] when ] bi@ ] dip I 4array ;

: prepare-sequence
( first max-times times what where seq -- seq' )
    [ drop nip ] 2dip
    [ swap create-increment ] dip
    append ;

: treat-increment ( first max-times what where seq -- seq' )
    [ 1 ] 3dip test-max-times-increment
    prepare-sequence ;

: search-increment ( max-times seq what -- seq' )
    [ 2nip deep-clone ] 3keep prepare-where [ drop empty? ]
    2keep rot
    [ treat-no-increment 2nip ] [ treat-increment ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!           COMPRESSION              !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: sizes-list ( seq -- seq sizes )
    dup length 1 swap [a,b] >array ;

: try-size ( max-times seq op -- seq' )
    used [ sizes-list amb cut swap ] dip
    { { C [ search-copy ] } { I [ search-increment ] } } case
    use ;

: times-list ( seq -- seq times )
    dup length 1 [a,b] >array ;

: try-times ( seq op -- seq' )
   [ times-list amb swap ] dip 
   try-size ;

: begins-with-C? ( seq -- list-op rest ? )
    dup length 3 < [ { } swap f ]
    [ dup third C = [ 3 cut t ]
    [ { } swap f ] if ] if ;

: begins-with-I? ( seq -- list-op rest ? )
    dup length 4 < [ { } swap f ]
    [ dup fourth I = [ 4 cut t ]
    [ { } swap f ] if ] if ;

: begins-with-op? ( seq -- list-op rest ? )
    begins-with-C? [ t ]
    [ nip begins-with-I? ] if ;

DEFER: try-on-list

: try-on-list-unsafe ( done rest op -- done' rest' op )
    [ try-times begins-with-op? ] keep swap
    [ [ append ] 2dip try-on-list ] [ rot drop ] if ;

: try-on-list ( done rest op -- done' rest' op )
    [ dup empty? ] dip swap [ ] 
    [ try-on-list-unsafe ] if ;

: try-operator ( seq -- seq' )
    { } swap { C I } amb try-on-list 2drop ;

: c-max? ( seq -- ? )
    dup length 2 = [ last integer? ] [ drop f ] if ;

: i-max? ( seq -- ? )
    dup length 3 =
    [ [ last integer? ] [ second dup sequence? [ [ integer? ]
    all? ] [ integer? ] if ] bi and ] [ drop f ] if ;

: is-max-compressed? ( seq -- ? )
    dup empty? [ drop f ] [ unclip-last dup word?
    [ { { C [ c-max? ] } { I [ i-max? ] } [ 2drop f ] } case ]
    [ 2drop f ] if ] if ;

: compress ( seq -- seq' )
    dup is-max-compressed?
    [ dup deep-clone try-operator 2dup [ cost>> ] bi@ >
    [ nip compress ] [ fail ] if ] unless ;
