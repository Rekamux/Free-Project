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

{ set-verbose reset-verbose print-verbose verbose } related-words




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




HELP: nunclip-last
{ $values { "n" "count of elements to be taken out" } }
{
    $description
    "Generalization of unclip-last: get n last elements of a list and place them on the stack"
} ;

HELP: 2unclip-last
{
    $values
    { "seq" "a sequence" }
    { "rest" "without its two last elements" }
    { "second" "second element" }
    { "first" "first element" }
}
{
    $description
    "Take two last elements and place them on the stack"
} ;

HELP: 3unclip-last
{
    $values
    { "seq" "a sequence" }
    { "rest" "without its three last elements" }
    { "third" "third element" }
    { "second" "second element" }
    { "first" "first element" }
}
{ $description "Take three last elements and place them on the stack" } ;

{ nunclip-last 2unclip-last 3unclip-last } related-words




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




HELP: none-sequence?
{ $values { "seq" "a sequence" } { "?" "a boolean" } }
{ $description "Return if all elements are not a sequence." } ;

HELP: first-sequence-index
{ $values { "seq" "a sequence" } { "n" "index" } }
{ $description "Return first sequence's index or false if none is a sequence." } ;

HELP: continue-and-append
{ $values { "seq" "a sequence" } { "bef" "sequence before first sequence" } { "m" "previous index" } { "cs" "result of containing-sequence" } { "aft" "rest of the sequence" } { "n'" "new index" } { "seq'" "new sequence" } }
{ $description "Check if requested index is in current sequence or not. If so, return the current sequence, and if not return " { $link containing-sequence } " given result." } ;

HELP: continue-and-test
{ $values { "seq" "a sequence" } { "n-i-xl" "index minus first sequence index minus first sequence extended length" } { "bef" "sequence before first sequence" } { "aft" "sequence after" } }
{ $description "Call " { $link containing-sequence } " on the rest of the list and append the result to before sequence." } ;

HELP: cut-and-continue
{ $values { "n-i" "index minus first sequence index" } { "seq" "a sequence" } { "i" "first sequence index" } { "n'" "new index" } { "seq'" "new sequence" } }
{ $description "Extract first sequence of the list, remove its length from the index and continue on the rest." } ;

HELP: go-into
{ $values { "n-i" "index minus first sequence index" } { "seq" "a sequence" } { "i" "first sequence index" } { "n'" "new index" } { "seq'" "new sequence" } }
{ $description "Call " { $link containing-sequence } " on the first sequence." } ;

HELP: try-on-first
{ $values { "n-i" "index minus first sequence index" } { "seq" "a sequence" } { "i" "index of the first sequence" } { "n'" "new index" } { "seq'" "new sequence" } }
{ $description "Check if first sequence's extended length is greater than n-i, which is the index of the rest of the list starting the first sequence." } ;

HELP: test-on-first
{ $values { "n" "index" } { "seq" "a sequence" } { "n'" "new index" } { "seq'" "new sequence" } }
{ $description "Test if first sequence is far enough to be able to return n and try on it if not." } ;

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
{ $description "Apply given quotation on extended indexed element." }
{ $examples { $example "USING: complexity.tools ;" "5 { 0 1 2 { 3 4 { 5 6 } 7 } 8 } [ 1 + ] [ change-extended-nth ] 2keep drop ." "{ 0 1 2 { 3 4 { 6 6 } 7 } 8 }" } } ;

{ extend extd-length set-extended-nth change-extended-nth containing-sequence } related-words




HELP: deep-clone-sequence
{ $values { "seq" "a sequence" } { "seq'" "deep copied sequence" } }
{ $description "Copy a sequence and all contained sequences." } ;

HELP: deep-clone
{ $values { "obj" "an object" } { "obj'" "deep copied object if sequence" } }
{ $description "Clone an object or " { $link deep-clone } "a sequence and all contained sequences." } ;




HELP: contains-words?
{ $values { "seq" "a sequence" } { "?" "a boolean" } }
{ $description "Return false iff all elements of this sequence are not words." } ;
