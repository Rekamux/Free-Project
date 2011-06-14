IN: complexity.tools
USING:
    kernel
    continuations
    summary
    sequences
    math.order
    random
    namespaces
    ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!               CONTINUATIONS             !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Used to store next failure action
SYMBOL: fail*

! Error definition
ERROR: failure ;

! In case of final failure
M: failure summary drop "No more alternatives" ;

! What to do in case of failure
: fail ( -- * )
    fail* get [ failure ] or
    call( -- * ) ;

! Failure reset
: reset ( -- )
    f fail* set ;

! Failure setter
: set-fail ( quot: ( -- * ) -- )
    fail* get
    [ fail* set call ] 2curry
    fail* set ;

! Try all elements of a sequence and tries the next one in
! case of failure
: amb ( seq -- x )
    dup empty? [
        fail
    ] [
        [
            unclip
            [
                [ amb swap continue-with ]
                2curry set-fail
            ] dip
        ] curry callcc1
    ] if ;

! Try all alternatives of a quotation
: bag-of ( quot: ( -- x ) -- seq )
    [ V{ } clone ] dip
    [ call( -- x ) swap push fail ] curry
    [ ] bi-curry
    [ { t f } amb ] 2dip if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!             OTHERS             !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Return the max of a list of positive numbers
: lmax ( list -- max )
    0 [ max ] reduce ;

! Generate a random digit if no operator is found
: generate-random ( list -- list+random )
    dup empty? [ 0 ] [ dup lmax random ] if suffix ;
