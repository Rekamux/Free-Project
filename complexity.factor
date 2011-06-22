IN: complexity
USING:
    kernel
    math
    sequences
    accessors
    classes
    prettyprint io
    complexity.tools
    combinators
    namespaces
    generalizations
    ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!             OPERATORS                    !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Apply only on times
SYMBOL: TIMES

! Apply only on argument
SYMBOL: ARGUMENT

! Apply on both
SYMBOL: BOTH

! An 1-unary copy operator, usable on digits or operators
TUPLE: operator times argument ;

! Increment a digits or an operator using specified field
TUPLE: increment-operator < operator how ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!         LAST USED LIST                  !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: short-memory

! Short memory initialization
: resetMemory ( -- )
    [ ] short-memory set ;

! Place an object on the top of the list
: use ( obj -- obj )
    3 dupn short-memory get remove
    swap prefix short-memory set ;

! Place 2 objects on the top of the list
: 2use ( obj1 obj2 -- obj1 obj2 )
    [ use ] dip use ;

! Place second object on the top of the list
: used ( obj garb -- obj garb )
    [ use ] dip ;

GENERIC: cost>> ( arg -- cost )

M: sequence cost>>
   0 [ cost>> + ] reduce ; 

! Return an element's cost
: generic-cost>> ( obj -- cost )
    short-memory get index dup
    [ "Object not learned !" print drop short-memory get
    length ] unless dup 0 = [ ] [ log2 1 + ] if ;

M: integer cost>>
    generic-cost>> ;

M: operator cost>>
    generic-cost>> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!              CONSTRUCTORS               !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Operator initialization
: operator-initialization ( op -- op )
    0 >>times 0 >>argument ;

! Construct a non-effective operator
: <operator> ( -- operator )
    operator new operator-initialization ;

! Construct a non-effective increment-operator
: <increment-operator> ( -- increment-operator )
    increment-operator new operator-initialization
    ARGUMENT >>how ;

! Construct given operator
: construct ( operator -- instance )
    {
    { operator [ <operator> ] }
    { increment-operator [ <increment-operator> ] }
    } case use ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!           TIMES SETTERS                 !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Decrement an operator's times
: decrement-times ( operator -- operator )
    use [ 1 - ] change-times use ;

! Increment an operator's times
: increment-times ( operator -- operator )
    use [ 1 + ] change-times use ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!      ARGUMENT SETTER                !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! An increment operator is restricted in thoses cases:
!   - if argument is a digit, it can only apply on its argument
!   - if argument is an operator which argument is an operator,
! it can only apply on its times
!   - else, it can apply on one or both
: set-how ( inc-op how -- inc-op )
    used swap dup argument>> use dup operator instance?
    [ argument>> use operator instance? [ [ drop TIMES ] dip ] when
    ] [ drop [ drop ARGUMENT ] dip ] if swap >>how use ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!               APPLY ON ONE                    !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

DEFER: apply

! Apply the operator once and decompress under levels
GENERIC: apply-once ( op -- res )

! Copy operator's version of apply-once
M: operator apply-once
    use decrement-times argument>> clone apply use ;

! Increment an argument regarding how
: increment-argument ( arg how -- arg' )
    used [ [ 1 + ] ] dip
    {
      { ARGUMENT [ change-argument ] }
      { TIMES [ change-times ] }
      { BOTH [ [ change-argument ] [ change-times ] bi ] }
    } case use ;

: increment ( increment-operator -- )
    use dup argument>> operator instance?
    [ [ argument>> ] [ how>> ] bi increment-argument ]
    [ [ 1 + ] change-argument ] if drop ;

! Increment operator's version of apply-once
M: increment-operator apply-once
    use [ call-next-method ] [ increment ] bi use ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!                   APPLY                        !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Apply the operator: decompress it at any level
GENERIC: apply ( operator -- list )

! An integer will be put in a list
M: integer apply
    use { } swap prefix ;

! An operator will be decompressed
M: operator apply
    use dup times>> 0 =
    [ drop { } ]
    [ [ apply-once use ] [ apply ] bi append ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!                COPY OPERATOR SEARCH             !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Search if the beginning of a list suits given operator
! Each iteration compresses list and increments operator

! Return if a argument is identical to operator's one
: argument-equals ( operator argument -- ? )
    2use swap argument>> = ;

! Check if first argument is identical to the operator's one
: first-argument-equals ( operator list -- ? )
    used dup empty? [ 2drop f ] [ first argument-equals ] if ;

! Copy-operator's recursive search version
: (search-operator) ( operator list -- operator rest )
    used 2dup first-argument-equals
    [ 1 tail [ increment-times ] dip (search-operator) ] when ;

! Copy-operator's version of search
: search-operator ( operator list -- compressed )
    used dup empty? [ 2drop { } ] [ [ first >>argument ]
    keep (search-operator) swap prefix ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!             INCREMENT OPERATOR SEARCH             !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Return if a digit is an other's increment
: is-increment? ( before after -- ? )
    2use 1 - = ;

! Return if both before and after are operators
: are-operators? ( operator after -- ? )
    2use [ operator instance? ] bi@ and ;

! Return if an operator's times is another increment
: is-times-increment? ( op-before op-after -- ? )
    2use [ times>> ] bi@ is-increment? ;

! Return if an operator's times is a copy
: is-times-copy? ( op-before op-after -- ? )
    2use [ times>> ] bi@ = ;

! Return if an operator's argument is another's increment
: is-argument-increment? ( op-before op-after -- ? )
    2use [ argument>> ] bi@ dup operator instance?
    [ 2drop f ] [ is-increment? ] if ;

! Return if an operator's argument is another's copy
: is-argument-copy? ( op-before op-after -- ? )
    2use [ argument>> ] bi@ dup operator instance?
    [ 2drop f ] [ = ] if ;

! Init a increment-operator using a list's first as argument
: init-first-increment-operator
( operator list -- operator rest )
    used dup empty? [ ]
    [ unclip swap [ >>argument increment-times ] dip ] if used ;

! Return if an operator can be another's increment
! transformation
: operators-increment-possible ( before after -- ? )
    2use [ [ is-times-increment? ] [ is-times-copy? ] 2bi or ]
    [ [ is-argument-increment? ] [ is-argument-copy? ] 2bi or ]
    2bi and ;

! If no way has been found
SYMBOL: NONE

! Find how it comes from an operator to another when it is
! possible
: find-how-if-possible ( before after -- how )
    2use [ is-times-increment? ] [ is-argument-increment? ] 2bi
    [ [ BOTH ] [ ARGUMENT ] if ] [ [ TIMES ] [ NONE ] if ] if ;

! find how it comes from an operator to another
: find-how-operators ( before after -- how )
    2use [ find-how-if-possible ] [ operators-increment-possible ]
    2bi [ drop NONE ] unless ;

! Find how method using an argument and return if found
: find-how ( before after -- how )
    2use 2dup are-operators? [ find-how-operators ]
    [ is-increment? [ ARGUMENT ] [ NONE ] if ] if ;

! Init an operator using find-how return value
: init-how ( operator how -- operator found )
    used dup NONE = [ drop f ] [ >>how increment-times t ] if
    used ;

! Same as following but without empty check
: init-first-how-unsafe
( operator list -- operator rest found )
    used unclip swap
    [ [ dup argument>> ] dip find-how init-how ] dip swap [ used
    ] dip ;

! Set how method using a list's first argument and return if
! found
: init-first-how ( operator list -- last operator rest found )
    used dup empty? [ <operator> -rot f ]
    [ [ nip first ] [ init-first-how-unsafe ] 2bi ] if [ 2use ]
    2dip ;

! Treat init-first-how return considering whereas it is because
! list was empty or because increment wasn't possible
: treat-init-first-how-negative
( last operator rest -- compressed )
    [ 2use ] dip rot dup <operator> = [ drop swap prefix ]
    [ prefix swap prefix ] if ;

! Determine how last could be incremented into list's first
! element
: find-list-how ( before list -- how first rest )
    used dup empty? [ 2drop NONE <operator> { } ]
    [ unclip swap [ [ find-how ] keep ] dip ] if used ;

! Recursive search of increment operator
: (search-increment-operator)
( operator last list -- operator last' rest )
    [ 2use ] dip find-list-how [ dup how>> ] 3dip [ = ] 2dip rot
    [ [ increment-times ] 2dip (search-increment-operator) ]
    when [ 2use ] dip ;

! Search an increment operator
: search-increment-operator ( operator list -- compressed )
    used init-first-increment-operator init-first-how
    [ [ swap ] dip (search-increment-operator)
    swap dup <operator> = [ drop ] [ prefix ] if swap prefix ]
    [ treat-init-first-how-negative ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!                  COMPRESSION                    !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Search given operator into a list
: search-given-operator ( operator list -- compressed )
    used swap {
      { operator [ <operator> swap search-operator ] }
      { increment-operator 
      [ <increment-operator> swap search-increment-operator ] }
    } case ;

! Search once for an operator (recursive version)
: (iter-compress) ( op list rest -- op' list' rest' )
    [ used ] dip dup empty? [ ]
    [ [ dup ] 2dip [ swap ] dip search-given-operator
    unclip swap [ suffix ] dip (iter-compress) ] if [ used ] dip ;

! Search once on a list for operators
: iter-compress ( list -- list' )
    { } swap { operator increment-operator } amb -rot
    (iter-compress) drop nip ;

! Return true iff all operators have 1 times (they are
! therefore useless)
: all-times-1? ( list -- ? )
    [ dup operator instance? [ times>> 1 = ] [ drop t ] if ]
    all? ;

! Return true iff compressed cost is less or equal than
! previous one
: is-compressed-better? ( list -- list compressed ? )
    [ dup clone iter-compress dup cost>> ]
    [ cost>> ] bi
    <= ;

DEFER: compress

! Return compressed list if all operators are not useless
! Fail elsewise
: compress-if-useful ( list -- compressed )
    dup all-times-1?
    [ fail ]
    [ compress ] if ;

! Treat lists if compressed is better
: treat-compressed ( list compressed -- compressed' )
    nip dup length 1 = [ compress-if-useful ] unless ;

! Compress current-result's list as far as its cost doesn't
! exceed current one
: compress ( list -- compressed )
    { t f } amb
    [ is-compressed-better? [ treat-compressed ] [ fail ] if
    ] when ; 

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!               LIST EXTENSION                   !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Count operators in a list
: count-operators ( list -- count )
    0 [ operator instance? [ 1 + ] when ] reduce ;

! Return a list containing an operator decompression or a
! single digit
: large-apply ( op-or-dig -- compressed )
    use dup operator instance?
    [ apply ] [ { } swap prefix ] if ;

! Decompress all operators (recursive version)
: (decompress) ( list rest -- decompressed rest' )
    dup empty? [ ]
    [ unclip large-apply swap [ append ] dip 
    (decompress) ] if ;

! Decompress all operators
: decompress ( list -- decompressed )
    { } swap (decompress) drop ;

! Try to extend a list
: extend ( list -- extended )
    reset { t f } amb
    [ compress dup length 1 =
    [ first dup operator instance?
    [ increment-times { } swap prefix ] [ fail ] if ] [ fail ]
    if decompress ] [ ] if ;
