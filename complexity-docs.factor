 USING: help
        help.markup
        help.syntax
        complexity
        complexity.private
        complexity.tools
        ;

HELP: LUL
{
    $description
    "Contain recent used words and digits called with " { $link use } " in call order."
} ;

HELP: reset-LUL
{
    $description
    "Set an empty list into "
    { $link LUL }
    "."
} ;

HELP: insert
{ $values { "obj" "an object" } { "seq" "a sequence" } }
{ $description "Insert an element at the third position of the list." } ;

HELP: generic-use
{ $values { "obj" "an object" } }
{ $description "Add an object to the " { $link LUL } "." } ;

HELP: use
{ $values { "obj" "object used" } }
{ $description "Place an object on the top of " { $link LUL } } ;

HELP: 2use
{ $values { "obj2" "second object used" } { "obj1" "first object used" } }
{ $description "Place two objects on the top of " { $link LUL } } ;

HELP: used
{ $values { "obj" "object to be used" } { "garb" "anything" } }
{ $description "Place second object on the top of " { $link LUL } } ;

{ LUL LUL-cost>> reset-LUL use 2use used } related-words




HELP: bits-cost
{ $values { "val" "an integer" } { "bits" "an integer" } }
{ $description "Number of bits needed to code an iteger (here 0 is free)" } ;

HELP: generic-cost
{ $values { "obj" "object to be evaluated" } { "cost" "result cost" } }
{ $description "Cost of an object regarding its position in " { $link LUL } } ;

HELP: remove-second
{ $values { "seq" "a sequence" } { "seq'" "a new sequence" } }
{ $description "Drop second element of a list." } ;

HELP: continue-preparing
{ $values { "seq" "a sequence" } { "seq'" "a new sequence" } }
{ $description "Prepare the sequence but the first element and prefix it." } ;

HELP: delete-where
{ $values { "seq" "a sequence" } { "seq'" "a new sequence" } }
{ $description "Check if sequence begins with an " { $link I } " operator and delete 'where' argument. Then continue preparation of the rest of the sequence." } ;

HELP: prepare-sequence-cost
{ $values { "seq" "a sequence" } { "seq'" "a new sequence" } }
{ $description "Check size and call " { $link delete-where } " if sequence is long enough." } ;

HELP: LUL-cost>>
{ $values { "arg" "object to be evaluated" } { "cost" "result cost" } }
{ $description "Return the cost of an object regarding its position in " { $link LUL } "." } ;

HELP: cost>>
{ $values { "arg" "object to be evaluated" } { "cost" "result cost" } }
{ $description "Return the cost of an object, using reducing " { $link cost>> } " call on a sequence or " { $link generic-cost } " on any other element." } ;




HELP: C
{ $description "Used to apply do-copy on the rest of the list." } ;

HELP: copy
{ $values { "what" "what to copy" } { "times" "times applied" } }
{ $description "Copy what times and append them if they are sequences" } ;

HELP: apply-copy
{ $values { "list" "a sequence" } { "decompressed" "decompressed sequence using copy" } }
{ 
    $description
    "Apply copy on given list when possible." $nl
    "Use first element as 'how many times' and second as 'what to copy'." $nl
    "Append the result to the list."
} ;

{ C apply-copy copy } related-words




HELP: suffix-or-append
{ $values { "seq" "a sequence" } { "obj" "an object" } }
{ $description "Consider if given object is a sequence or not and append it or suffix it." } ;

HELP: increment-somewhere
{ $values { "what" "sequence or object to be incremented" } { "where" "extended indexes" } }
{ $description "Increment 'what' at " { $link extend } "ed indexes given by 'where'." } ;

HELP: increment-and-append
{ $values { "done" "treated sequence" } { "what" "sequence or object to be incremented" } { "where" "extended indexes" } }
{ $description "Increment given 'what' at 'where', append it to 'done' and decrement times." } ;

HELP: decrement-times
{ $values { "done" "treated sequence" } { "what" "sequence or object to be incremented" } { "where" "extended indexes" } { "times" "remaining times" } }
{ $description "Decrement application times of the increment operator" } ;

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

HELP: apply-increment
{ $values { "list" "a sequence" } { "decompressed" "decompressed sequence" } }
{ $description "Use three first elements of the list, call " { $link increment } " on them and append the result on the list." } ;

{ I apply-increment increment } related-words




HELP: apply
{ $values { "seq" "a sequence" } { "word" "C or I" } { "seq'" "decompressed" } }
{ $description "Apply an word on the list. It must be " { $link C } " or " { $link I } "." } ;

HELP: decompress-last
{ $values { "seq" "a sequence" } { "seq'" "decompressed" } }
{ $description "Apply last element on the rest of the list. It must be " { $link C } " or " { $link I } ", or a digit." } ;

HELP: decompress
{ $values { "seq" "a sequence" } { "seq'" "decompressed" } }
{ $description "Decompress sequence while there are still words on it." } ;




HELP: is-copy?
{ $values { "what" "copied?" } { "rest" "a sequence" } { "rest'" "a new sequence" } { "found" "a boolean" } }
{ $description "Test if the beginning of given sequence is a copy of 'what', and return resulted boolean." } ;

HELP: test-copy
{ $values { "times" "times copied so far" } { "what" "that is copied" } { "rest" "a sequence" } }
{ $description "Find how much what is copied in given sequence and return the rest." } ;

HELP: create-copy
{ $values { "what" "that is copied" } { "times" "times copied" } { "seq" "a sequence" } } 
{ $description "Extract, when 'what' is a sequence of one element, its element and create an complete [WHAT] [WHERE] C compressed list." } ;

HELP: search-copy
{ $values { "seq" "a sequence" } { "what" "that is copied" } { "seq'" "a new sequence" } }
{ $description "Search how many times 'what' is copied at the beginning of the list and append resulting operator in front of it." }
{ $examples { $example "USING: complexity prettyprint ;" "{ 1 2 1 2 3 } { 1 2 } search-copy ." "{ { 1 2 } 3 C 3 }" } } ;




HELP: fit?
{ $values { "what" "a sequence" } { "rest" "a sequence" } { "?" "a boolean" } }
{ $description "Return whereas 'what' fits in terms of length in 'rest' or not." } ;

HELP: extract-same-size
{ $values { "what" "a sequence" } { "rest" "a sequence" } { "fitting" "a sequence " } }
{ $description "Extract a sequence of the same size as 'what' from 'rest'." } ;

HELP: incrementable?
{ $values { "what" "a sequence" } { "where" "extended indexes list" } { "?" "a boolean" } }
{ $description "Return if all asked elements from 'where' are incrementable, eg they are digits." } ;

HELP: extract-increment
{ $values { "what" "a sequence" } { "where" "extended indexes list" } { "incremented" "a sequence" } }
{ $description "Increment 'what' at given 'where' or return f if not possible." } ;

HELP: is-increment?
{ $values { "what" "a sequence" } { "where" "extended indexes list" } { "rest" "a sequence" } { "found" "a boolean" } }
{ $description "Extract increment from 'rest' and return the rest and t in case of success." } ;

HELP: find-increment
{ $values { "times" "a digit" } { "what" "a sequence" } { "where" "extended indexes list" } { "rest" "a sequence" } }
{ $description "Recursive function which searches for 'what' in 'where' and updates 'times' and 'rest' until failure." } ;

HELP: helper
{ $description "A variable containing current " { $link extend } "ed index. Used by " { $link find-where } "." } ;

HELP: inc-helper
{ $description "Increment " { $link helper } "." } ;

HELP: find-where-map
{ $values { "to" "a digit" } { "from" "a digit" } { "seq" "a sequence" } }
{ $description "Find out if 'to' is an increment of 'from' and return result in a list." } ;

HELP: find-where
{ $values { "from" "a sequence" } { "to" "a sequence" } { "where" "extended indexes list" } }
{ $description "Create an " { $link extend } "ed indexes list regarding increments." } ;

HELP: prepare-where
{ $values { "seq" "a sequence" } { "what" "a sequence" } { "where" "extended indexes list" } }
{ $description "Find " { $link extend } "ed indexes list and ordinate for further applications." } ;

HELP: treat-no-increment
{ $values { "first" "a sequence" } { "seq" "a sequence" } { "where" "a sequence" } { "where" "extended indexes list" } }
{ $description "Generate resulting sequence if no increment is found." } ;

HELP: create-increment
{ $values { "seq" "a sequence" } { "what" "a sequence" } { "where" "extended indexes list" } }
{ $description "Create a compressed list using " { $link I } " ." } ;

HELP: prepare-sequence
{ $values { "first" "a sequence" } { "times" "a digit" } { "seq" "a sequence" } { "what" "a sequence" } { "where" "extended indexes list" } }
{ $description "Create and append I list on given sequence." } ;

HELP: treat-increment
{ $values { "first" "a sequence" } { "seq" "a sequence" } { "what" "a sequence" } { "where" "extended indexes list" } }
{ $description "Treat sequence in case of increment found" } ;

HELP: search-increment
{ $values { "seq" "a sequence" } { "what" "a sequence" } { "seq'" "a new sequence" } }
{ $description "Search 'what' at the beginning of 'seq', extract and append compressed result at the beginning of 'seq'." }
{ $examples { $example "USING: complexity prettyprint ;" "{ { 0 1 } 2 C { 0 2 } 3 C } { { 0 0 } 1 C } search-increment ." "{ { { 0 0 } 1 C } { 1 2 } 3 I }" } } ;
