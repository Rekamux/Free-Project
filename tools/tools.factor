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

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!       UNCLIP GENERALIZATION       !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MACRO: nunclip ( n -- quot )
    [ [ cut* ] keep firstn ] curry ;

: 2unclip ( list -- rest second first )
    2 nunclip ;

: 3unclip ( list -- rest third second first )
    3 nunclip ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!         SEQUENCE EXTENSION           !
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

DEFER: containing-sequence

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

: containing-sequence ( n seq -- n' seq' )
    dup none-sequence? [ ] [ test-on-first ] if ;

PRIVATE>

: set-extended-nth ( elt n seq -- )
    containing-sequence set-nth ;

: change-extended-nth ( n seq quot -- )
    [ [ extend nth ] dip call ] 3keep
    drop set-extended-nth ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!          DEEP CLONE           !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

DEFER: deep-clone

: deep-clone-sequence ( seq -- seq' )
    dup empty? [ ]
    [ unclip dup sequence? [ [ deep-clone ] bi@ prefix ]
    [ [ deep-clone ] dip clone prefix ] if ] if ;

: deep-clone ( obj -- obj' )
    dup sequence? [ deep-clone-sequence ] [ clone ] if ;
