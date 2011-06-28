 USING: help
        help.markup
        help.syntax
        complexity.tools
        complexity.tools.private
        ;

HELP: verbose
{ $description "Used to store whereas verbose mode is activated or not." } ;

HELP: set-verbose
{ $description "Activate " { $link verbose } " mode." } ;

HELP: reset-verbose
{ $description "Deactivate " { $link verbose } " mode." } ;

HELP: print-verbose
{ $values { "string" "a string" } }
{ $description "Output given string followed by a not consumed sequence if " { $link verbose } " mode is activated." } ;

{ set-verbose reset-verbose print-verbose } related-words




HELP: fail*
{ $description "Used to store failure action." } ;

HELP: failure
{ $description "Error called whenever nothing left is possible." } ;

HELP: fail
{ $description "Call next " { $link fail* } " action, or throw " { $link failure } " if nothing left is possible." } ;

HELP: reset
{ $description "Reset " { $link fail* } ". Any call to " { $link fail } " will throw an exception until " { $link amb } " is called." } ;

HELP: amb
{ $values { "seq" "a sequence" } { "x" "an element" } }
{ $description "Try all elements of given sequence at each " { $link fail } " call. Fail when sequence is empty." } ;

HELP: bag-of
{ $values { "quot" "a quotation with ( -- x ) stack-effect" } { "seq" "a results sequence" } }
{ $description "Try all possibilities of a quotation, normally using " { $link amb } "." } ;

{ fail reset amb bag-of } related-words




HELP: nunclip
{ $values { "n" "count of elements to be taken out" } }
{
    $description
    "Generalization of unclip: get n first elements of a list and place them on the stack"
} ;

HELP: 2unclip
{
    $values
    { "seq" "a sequence" }
    { "rest" "without its two first elements" }
    { "second" "second element" }
    { "first" "first element" }
}
{
    $description
    "Take two first elements and place them on the stack"
} ;

HELP: 3unclip
{
    $values
    { "seq" "a sequence" }
    { "rest" "without its three first elements" }
    { "third" "third element" }
    { "second" "second element" }
    { "first" "first element" }
}
{ $description "Take three first elements and place them on the stack" } ;

{ nunclip 2unclip 3unclip } related-words




HELP: (extend)
{ $values { "done" "treated part" } { "rest" "to be done" } { "done'" "new treated part" } { "rest'" "nnew rest" } }
{ $description "Recursive version used by " { $link extend } "." } ;

HELP: extend
{ $values { "seq" "a sequence" } { "extended" "sequence extended" } }
{ $description "Take recursively all elements of given sequence, append non-sequence elements and extend the rest." }
{ $examples { $example "USING: complexity.tools ;" "{ 1 2 { 3 4 { 5 6 } 7 } 8 } extend" "{ 1 2 3 4 5 6 7 8 }" } } ;

HELP: extd-length
{ $values { "seq" "a sequence" } { "n" "length" } }
{ $description "Return extended list's length." } ;

{ extend extd-length } related-words




HELP: containing-sequence
{ $values { "n" "index of extended sequence" } { "seq" "a sequence" } }
{
    $description
    "Return the smallest sequence containing extended list nth element, and its real index."
} ;

HELP: set-extended-nth
{ $values { "elt" "new value" } { "n" "index of extended sequence" } { "seq" "a sequence" } }
{ $description "Change a value in a list using its decompressed index." } ;

HELP: change-extended-nth
{
    $values
    { "n" "index of extended sequence" }
    { "seq" "a sequence" }
    { "quot" "a quotation with stack-effect ( x -- x )" }
}
{ $description "Apply given quotation on extended indexed element." } ;

{ extend extd-length set-extended-nth change-extended-nth } related-words

HELP: deep-clone-sequence
{ $values { "seq" "a sequence" } { "seq'" "deep copied sequence" } }
{ $description "Copy a sequence and all contained sequences." } ;

HELP: deep-clone
{ $values { "obj" "an object" } { "obj'" "deep copied object if sequence" } }
{ $description "Clone an object or " { $link deep-clone } "a sequence and all contained sequences." } ;

HELP: contains-words?
{ $values { "seq" "a sequence" } { "?" "a boolean" } }
{ $description "Return false iff all elements of this sequence are not words." } ;
