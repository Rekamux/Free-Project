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
    } case ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!           TIMES SETTERS                 !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Decrement an operator's times
: decrement-times ( operator -- operator )
    [ 1 - ] change-times ;

! Increment an operator's times
: increment-times ( operator -- operator )
    [ 1 + ] change-times ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!      ARGUMENT SETTER                !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! An increment operator is restricted in thoses cases:
!   - if argument is a digit, it can only apply on its argument
!   - if argument is an operator which argument is an operator,
! it can only apply on its times
!   - else, it can apply on one or both
: set-how ( inc-op how -- inc-op )
    swap dup argument>> dup operator instance?
    [ argument>> operator instance? [ [ drop TIMES ] dip ] when
    ] [ drop [ drop ARGUMENT ] dip ] if swap >>how ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!             COMPLEXITY                    !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Compute an operator's cost
GENERIC: cost>> ( operator -- cost )

! Operator cost : sum its times and argument cost.
M: operator cost>>
    [ times>> cost>> ]
    [ argument>> cost>> ] bi + ;

! An increment-operator costs 2 more bits if its argument is an
! operator, in which case it needs to know where it applies
M: increment-operator cost>>
    [ call-next-method ] [ argument>> ] bi
    operator instance? [ 2 + ] when ;

! Bits needed to store an integer
M: integer cost>>
   dup 0 =
   [ ] [ log2 1 + ] if ;

! Compute the cost of a list of digits and operators
M: sequence cost>>
    0 [ cost>> + ] reduce ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!               APPLY ON ONE                    !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

DEFER: apply

! Apply the operator once and decompress under levels
GENERIC: apply-once ( op -- res )

! Copy operator's version of apply-once
M: operator apply-once
    decrement-times argument>> clone apply ;

: increment-argument ( arg how -- arg' )
    [ [ 1 + ] ] dip
    {
      { ARGUMENT [ change-argument ] }
      { TIMES [ change-times ] }
      { BOTH [ [ change-argument ] [ change-times ] bi ] }
    } case ;

: increment ( increment-operator -- )
    dup argument>> operator instance?
    [ [ argument>> ] [ how>> ] bi increment-argument ]
    [ [ 1 + ] change-argument ] if drop ;

! Increment operator's version of apply-once
M: increment-operator apply-once
    [ call-next-method ] [ increment ] bi ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!                   APPLY                        !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Apply the operator: decompress it at any level
GENERIC: apply ( operator -- list )

! An integer will be put in a list
M: integer apply
    { } swap prefix ;

! An operator will be decompressed
M: operator apply
    dup times>> 0 =
    [ drop { } ]
    [ [ apply-once ] [ apply ] bi append ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!                COPY OPERATOR SEARCH             !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Search if the beginning of a list suits given operator
! Each iteration compresses list and increments operator

! Return if a argument is identical to operator's one
: argument-equals ( operator argument -- ? )
    swap argument>> = ;

! Check if the first argument is identical to the operator's one
: first-argument-equals ( operator list -- ? )
    dup empty? [ 2drop f ] [ first argument-equals ] if ;

! Copy-operator's recursive search version
: (search-operator) ( operator list -- operator rest )
    2dup first-argument-equals
    [ 1 tail [ increment-times ] dip (search-operator) ] when ;

! Copy-operator's version of search
: search-operator ( operator list -- compressed )
    dup empty? [ 2drop { } ] [ [ first >>argument ]
    keep (search-operator) swap prefix ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!             INCREMENT OPERATOR SEARCH             !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Return if a digit is an other's increment
: is-increment? ( before after -- ? )
    1 - = ;

! Return if both before and after are operators
: are-operators? ( operator after -- ? )
    [ operator instance? ] bi@ and ;

! Return if an operator's times is another increment
: is-times-increment? ( op-before op-after -- ? )
    [ times>> ] bi@ is-increment? ;

! Return if an operator's times is a copy
: is-times-copy? ( op-before op-after -- ? )
    [ times>> ] bi@ = ;

! Return if an operator's argument is another's increment
: is-argument-increment? ( op-before op-after -- ? )
    [ argument>> ] bi@ dup operator instance?
    [ 2drop f ] [ is-increment? ] if ;

! Return if an operator's argument is another's copy
: is-argument-copy? ( op-before op-after -- ? )
    [ argument>> ] bi@ dup operator instance?
    [ 2drop f ] [ = ] if ;

! Init a increment-operator using a list's first as argument
: init-first-increment-operator
( operator list -- operator rest )
    dup empty? [ ]
    [ unclip swap [ >>argument increment-times ] dip ] if ;

! Return if an operator can be another's increment
! transformation
: operators-increment-possible ( before after -- ? )
    [ [ is-times-increment? ] [ is-times-copy? ] 2bi or ]
    [ [ is-argument-increment? ] [ is-argument-copy? ] 2bi or ]
    2bi and ;

! If no way has been found
SYMBOL: NONE

! Find how it comes from an operator to another when it is
! possible
: find-how-if-possible ( before after -- how )
    [ is-times-increment? ] [ is-argument-increment? ] 2bi
    [ [ BOTH ] [ ARGUMENT ] if ] [ [ TIMES ] [ NONE ] if ] if ;

! find how it comes from an operator to another
: find-how-operators ( before after -- how )
    [ find-how-if-possible ] [ operators-increment-possible ]
    2bi [ drop NONE ] unless ;

! Find how method using an argument and return if found
: find-how ( before after -- how )
    2dup are-operators? [ find-how-operators ]
    [ is-increment? [ ARGUMENT ] [ NONE ] if ] if ;

! Init an operator using find-how return value
: init-how ( operator how -- operator found )
    dup NONE = [ drop f ] [ >>how increment-times t ] if ;

! Same as following but without empty check
: init-first-how-unsafe
( operator list -- operator rest found )
    unclip swap
    [ [ dup argument>> ] dip find-how init-how ] dip swap ;

! Set how method using a list's first argument and return if
! found
: init-first-how ( operator list -- last operator rest found )
    dup empty? [ <operator> -rot f ]
    [ [ nip first ] [ init-first-how-unsafe ] 2bi ] if ;

! Treat init-first-how return considering whereas it is because
! list was empty or because increment wasn't possible
: treat-init-first-how-negative
( last operator rest -- compressed )
    rot dup <operator> = [ drop swap prefix ]
    [ prefix swap prefix ] if ;

! Determine how last could be incremented into list's first
! element
: find-list-how ( before list -- how first rest )
    dup empty? [ 2drop NONE <operator> { } ]
    [ unclip swap [ [ find-how ] keep ] dip ] if ;

! Recursive search of increment operator
: (search-increment-operator)
( operator last list -- operator last' rest )
    find-list-how [ dup how>> ] 3dip [ = ] 2dip rot
    [ [ increment-times ] 2dip (search-increment-operator) ]
    when ;

! Search an increment operator
: search-increment-operator ( operator list -- compressed )
    init-first-increment-operator init-first-how
    [ [ swap ] dip (search-increment-operator)
    swap dup <operator> = [ drop ] [ prefix ] if swap prefix ]
    [ treat-init-first-how-negative ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!                  COMPRESSION                    !
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Search given operator into a list
: search-given-operator ( operator list -- compressed )
    swap {
      { operator [ <operator> swap search-operator ] }
      { increment-operator 
      [ <increment-operator> swap search-increment-operator ] }
    } case ;

! Search once for an operator (recursive version)
: (iter-compress) ( op list rest -- op' list' rest' )
    dup empty? [ ]
    [ [ dup ] 2dip [ swap ] dip search-given-operator
    unclip swap [ suffix ] dip (iter-compress) ] if ;

! Search once on a list for operators
: iter-compress ( list -- list' )
    { } swap { operator increment-operator } amb -rot
    (iter-compress) drop nip ;

! Compress current-result's list as far as its cost doesn't
! exceed current one
: compress ( list -- compressed )
    dup .
    { t f } amb
    [ [ dup clone iter-compress dup cost>> ] [ cost>> ] bi <
    [ [ drop ] dip compress ] [ fail ] if ] when ; 

! ! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! !               LIST EXTENSION                   !
! ! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 
! ! Count operators in a list
! : count-operators ( list -- count )
!     0 [ operator instance? [ 1 + ] when ] reduce ;
! 
! ! Decompress all operators (recursive version)
! : (decompress) ( list rest -- decompressed rest' )
!     dup length 2 <
!     [ ]
!     [
!         unclip-last { } swap prefix
!         [ unclip-last ] dip swap
!         dup operator instance?
!         [ apply ]
!         [ prefix ] if
!         swap [ swap append ] dip 
!         (decompress)
!     ] if ;
! 
! ! Decompress all operators
! : decompress ( list -- decompressed )
!     { } swap (decompress) drop ;
