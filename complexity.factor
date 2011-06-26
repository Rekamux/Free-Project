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

SYMBOL: debug

: set-debug ( -- )
    t debug set ;

: reset-debug ( -- )
    f debug set ;

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

: use ( obj -- obj ) ;
! GENERIC: use ( obj -- obj )
! 
! M: sequence use
!     dup empty? [ ]
!     [ [ unclip [ use drop ] bi@ ] keep ] if ;
! 
! M: integer use generic-use ;
! 
! M: word use ;

: 2use ( obj1 obj2 -- obj1 obj2 )
    [ use ] bi@ ;

: used ( obj garb -- obj garb )
    [ use ] dip ;

: bits-cost ( val -- bits )
    dup 0 = [ ] [ log2 1 + ] if ;

: generic-cost ( obj -- cost )
    LUL get index bits-cost ;

: remove-second ( seq -- seq' )
    unclip [ unclip drop ] dip prefix ;

DEFER: prepare-sequence-cost

: continue-preparing ( seq -- seq' )
    unclip [ prepare-sequence-cost ] dip prefix ;

: delete-where ( seq -- seq' )
    [ dup fourth I = ]
    [ first dup sequence? [ length 1 = ] [ drop t ] if ] bi and
    [ remove-second 3 cut prepare-sequence-cost append ]
    [ continue-preparing ] if ;
    
: prepare-sequence-cost ( seq -- seq' )
    dup length 4 >=
    [ delete-where ]
    [ dup empty? [ ] [ continue-preparing ] if ] if ;

GENERIC: cost>> ( arg -- cost )

M: sequence cost>>
    deep-clone extend prepare-sequence-cost
    0 [ cost>> + ] reduce ; 

M: integer cost>>
    ! generic-cost ;
    bits-cost ;

M: word cost>>
    ! generic-cost ;
    { { C [ 0 ] } { I [ 0 ] } } case ;

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

: test-copy
( times what rest -- times' what rest' )
    [ dup ] dip is-copy?
    [ [ 1 + ] 2dip test-copy ] when ;

: create-copy ( what times -- seq )
    [ dup length 1 = [ first ] when ] dip C 3array ;

: search-copy ( seq what -- seq' )
    swap [ 1 ] 2dip test-copy
    -rot swap create-copy swap append ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!        INCREMENT SEARCH             !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

<PRIVATE
: fit? ( what rest -- ? )
    [ length ] bi@ <= ;

: extract-same-size ( what rest -- rest' fitting )
    [ length ] dip swap cut swap ;

: incrementable? ( what where -- ? )
    [ [ dup extend ] dip swap nth integer? ] all? nip ;

: extract-increment ( what where -- incremented )
    2dup incrementable?
    [ [ { } ] 2dip increment-and-append drop nip ]
    [ 2drop f ] if ;

: is-increment? ( what where rest -- rest' found )
    3dup nip fit? [ [ 2nip ] [ nip extract-same-size ]
    [ drop extract-increment ] 3tri = 
    [ nip t ] [ drop f ] if ] [ 2nip f ] if ;

: find-increment
( times what where rest -- times' what where rest' )
    [ 2dup ] dip is-increment?
    [ [ 1 + ] 3dip find-increment ] when ;

SYMBOL: helper

: inc-helper ( -- )
    helper get 1 + helper set ;

: find-where-map ( to from -- seq )
    dup word? [ 2drop { } ] [ 1 - =
    [ { } helper get prefix ] [ { } ] if ] if
    inc-helper ;

: find-where ( from to -- where )
    0 helper set
    [ extend ] bi@
    [ find-where-map ] [ append ] 2map-reduce ;

: prepare-where ( seq what -- what where seq )
    swap 2dup fit? [ 2dup extract-same-size nip
    [ nip find-where ] 3keep drop [ swap ] dip ]
    [ { } swap ] if ;

: treat-no-increment ( first what where seq -- seq' )
    [ 2drop dup length 1 = [ 1array ] unless 0 1 I 3array
    append ] dip append ;

: create-increment ( what where times -- seq )
    [ [ dup length 1 = [ first ] when ] bi@ ] dip I 4array ;

: prepare-sequence
( first times what where seq -- seq' )
    [ drop ] 2dip
    [ swap create-increment ] dip
    append ;

: treat-increment ( first what where seq -- seq' )
    [ 1 ] 3dip find-increment
    prepare-sequence ;
PRIVATE>

: search-increment ( seq what -- seq' )
    dup deep-clone -rot prepare-where
    [ [ empty? ] bi@ or ] 2keep rot
    [ treat-no-increment ] [ treat-increment ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!           COMPRESSION              !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: try ( seq size op -- seq' )
    3dup drop swap length > [ 2drop ]
    [ [ cut swap ] dip 
    { { C [ search-copy ] } { I [ search-increment ] } }
    case ] if ;

: no-op ( seq -- empty seq f )
    { } swap f ;

: begins-with-C? ( seq -- list-op rest ? )
    dup length 3 < [ no-op ]
    [ dup third C = [ 3 cut t ]
    [ no-op ] if ] if ;

: begins-with-I? ( seq -- list-op rest ? )
    dup length 4 < [ no-op ]
    [ dup fourth I = [ 4 cut t ]
    [ no-op ] if ] if ;

: begins-with-op? ( seq -- list-op rest ? )
    begins-with-C? [ t ]
    [ nip begins-with-I? ] if ;

DEFER: try-on-list

: try-on-list-unsafe
( done rest size op -- done' rest' size op )
    [ try begins-with-op? ] 2keep rot
    [ [ append ] 3dip try-on-list ] [ [ drop ] 3dip ] if ;

: try-on-list ( done rest size op -- done' rest' size op )
    [ dup empty? ] 2dip rot [ ]
    [ try-on-list-unsafe ] if ;

: sizes-list ( seq -- seq sizes )
    dup length 2 / 1 swap [a,b] >array ;

: try-sizes ( seq op -- seq' )
    [ sizes-list amb ] dip
    [ { } ] 3dip
    try-on-list 2drop append ;

: try-operator ( seq -- seq' )
    { C I } amb 
    try-sizes ;

: c-max? ( seq -- ? )
    dup length 2 = [ last integer? ] [ drop f ] if ;

: i-max? ( seq -- ? )
    dup length 3 =
    [ [ last integer? ] [ second dup sequence? [ [ integer? ]
    all? ] [ integer? ] if ] bi and ] [ drop f ] if ;

: is-interessant? ( seq -- ? )
    dup empty? [ drop f ] [ unclip-last dup word?
    [ { { C [ c-max? ] } { I [ i-max? ] } [ 2drop f ] } case ]
    [ 2drop f ] if ] if ;

: is-max-compressed? ( seq -- ? )
    dup is-interessant?
    [ 2 cut* nip first 1 = not ]
    [ drop f ] if ;

: compare-costs ( before after -- best after-best? )
    debug get
    [ nl "Comparing " print [ dup . ] bi@ "Sizes are" print ]
    when
    2dup [ cost>> 
    debug get [ dup . ] when
    ] bi@ > [ nip t ] [ drop f ] if 
    debug get [ "Best is" print [ dup . ] dip ] when ;

: compress ( seq -- seq' )
    dup is-max-compressed? [ dup deep-clone try-operator
    dup is-max-compressed? [ nip ] [ compare-costs [ compress ]
    [ fail ] if ] if ] unless ;

! : compress-regarding ( searched seq -- seq' )
!     dup is-max-compressed? [ dup deep-clone try-operator
!     dup is-max-compressed? [ nip ] [ 
!     3dup nip = [ set-debug compare-costs reset-debug drop ]
!     [ compare-costs [ [ compress-regarding ] 2keep drop ]
!     [ fail ] if ] if ] if ] unless nip ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!          CONTINUING            !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: increment-times ( optimal -- incremented )
    2 cut* unclip 1 + prefix append ;

: logic-extend ( seq -- seq' )
    { t f } amb
    [ compress ] when dup is-max-compressed?
    [ increment-times decompress ] when ;
