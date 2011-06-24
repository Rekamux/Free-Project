 USING: help
        help.markup
        help.syntax
        complexity.tools
        ;

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

HELP: extend
{ $values { "seq" "a sequence" } { "extended" "sequence extended" } }
{ $description "Take recursively all elements of given sequence, append non-sequence elements and extend the rest." }
{ $examples { $example "USING: complexity.tools ;" "{ 1 2 { 3 4 { 5 6 } 7 } 8 } extend" "{ 1 2 3 4 5 6 7 8 }" } } ;

HELP: extd-length
{ $values { "seq" "a sequence" } { "n" "length" } }
{ $description "Return extended list's length." } ;

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

{ extend extd-length containing-sequence set-extended-nth change-extended-nth } related-words

HELP: deep-clone
{ $values { "seq" "a sequence" } { "seq'" "deep copied sequence" } }
{ $description "Copy a sequence and all contained sequences." } ;
