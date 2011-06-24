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

HELP: extend
{ $values { "seq" "a sequence" } { "extended" "sequence extended" } }
{ $description "Take recursively all elements of given sequence, append non-sequence elements and extend the rest." }
{ $examples { $example "USING: complexity.tools ;" "{ 1 2 { 3 4 { 5 6 } 7 } 8 } extend" "{ 1 2 3 4 5 6 7 8 }" } } ;
