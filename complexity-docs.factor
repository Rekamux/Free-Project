 USING: help
        help.markup
        help.syntax
        complexity
        ;

HELP: LUL
{
    $description
    "Contain recent used words and digits called with " { $link use } " in call order."
} ;

HELP: resetLUL
{
    $description
    "Set an empty list into "
    { $link LUL }
    "."
} ;

HELP: use
{ $values { "obj" "object used" } }
{ $description "Place an object on the top of " { $link LUL } } ;

HELP: 2use
{ $values { "obj2" "second object used" } { "obj1" "first object used" } }
{ $description "Place two objects on the top of " { $link LUL } } ;

HELP: used
{ $values { "obj" "object to be used" } { "garb" "anything" } }
{ $description "Place second object on the top of " { $link LUL } } ;

{ LUL cost>> resetLUL use 2use used } related-words

HELP: bits-cost
{ $values { "val" "an integer" } { "bits" "an integer" } }
{ $description "Number of bits needed to code an iteger (here 0 is free)" } ;

HELP: generic-cost
{ $values { "obj" "object to be evaluated" } { "cost" "result cost" } }
{ $description "Cost of an object regarding its position in " { $link LUL } } ;

HELP: cost>>
{ $values { "arg" "object to be evaluated" } { "cost" "result cost" } }
{ $description "Return the cost of an object" } ;

HELP: C
{ $description "Used to apply do-copy on the rest of the list." } ;

HELP: copy
{ $values { "what" "what to copy" } { "times" "times applied" } }
{ $description "Copy what times and concat them if they are sequences" } ;

HELP: apply-copy
{ $values { "list" "a sequence" } { "decompressed" "decompressed sequence using copy" } }
{ 
    $description
    "Apply copy on given list when possible." $nl
    "Use first element as 'how many times' and second as 'what to copy'." $nl
    "Append the result to the list."
} ;

{ C apply-copy copy } related-words

HELP: I
{ $description "Used to apply do-increment on the rest of the list." } ;

HELP: increment
{ 
    $values
    { "what" "what to increment" }
    { "where" "extended indexes list of where to increment" }
    { "times" "times to apply" } { "seq" "result" }
} 
{ $description "Copy and then increment what times on where it is specified. Append results if what is a list" } ;

{ I apply-increment } related-words
