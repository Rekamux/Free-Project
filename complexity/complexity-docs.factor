 USING: help
        help.markup
        help.syntax
        complexity
        complexity.private
        complexity.tools
        complexity.tools.private
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




HELP: try
{ $values { "seq" "a sequence" } { "size" "a digit" } { "op" "a operator word" } }
{ $description "Take 'size' first elements of 'seq' and search given operator on the rest." } ;

HELP: no-op
{ $description "Used in case there is no operator in given sequence." } ;

HELP: begins-with-C?
{ $values { "seq" "a sequence" } { "list-op" "a sequence" } { "rest" "a sequence" } { "?" "a boolean" } }
{ $description "Check if given sequence begins with a C and its arguments in a suffixed way. Return extracted operator, rest and true if found, or an empty sequence, the same sequence and false if not." } ;

HELP: begins-with-I?
{ $values { "seq" "a sequence" } { "list-op" "a sequence" } { "rest" "a sequence" } { "?" "a boolean" } }
{ $description "Check if given sequence begins with a I and its arguments in a suffixed way. Return extracted operator, rest and true if found, or an empty sequence, the same sequence and false if not." } ;

HELP: begins-with-op?
{ $values { "seq" "a sequence" } { "list-op" "a sequence" } { "rest" "a sequence" } { "?" "a boolean" } }
{ $description "Check if given sequence begins with an operator and its arguments in a suffixed way. Return extracted operator, rest and true if found, or an empty sequence, the same sequence and false if not." } ;

{ begins-with-C? begins-with-I? begins-with-C? } related-words




HELP: try-on-list-unsafe
{ $values { "done" "a sequence" } { "rest" "a sequence" } { "size" "a digit" } { "op" "a word, " { $link C } " or " { $link I } } }
{ $description "Call recursively " { $link try-on-list } " until 'rest' doesn't contain an operator." } ;

HELP: try-on-list
{ $values { "done" "a sequence" } { "rest" "a sequence" } { "size" "a digit" } { "op" "a word, " { $link C } " or " { $link I } } }
{ $description "Check if 'rest' is empty and then call " { $link try-on-list-unsafe } "." } ;

HELP: sizes-list
{ $values { "seq" "a sequence" } { "sizes" "a sequence of digits" } }
{ $description "Extract all sizes that have to be tested." } ;

HELP: try-sizes
{ $values { "seq" "a sequence" } { "op" "a word, " { $link C } " or " { $link I } } }
{ $description "Extract sizes to be tested and test them with " { $link amb } "." } ;

HELP: try-operator
{ $values { "seq" "a sequence" } }
{ $description "Run " { $link amb } " on " { $link C } " and " { $link I } "." } ;

HELP: c-max?
{ $values { "seq" "a sequence" } { "?" "a boolean" } }
{ $description "Check if a sequence is reduced to a single " { $link C } " operator." } ;

HELP: i-max?
{ $values { "seq" "a sequence" } { "?" "a boolean" } }
{ $description "Check if a sequence is reduced to a single " { $link I } " operator." } ;

HELP: is-max-compressed?
{ $values { "seq" "a sequence" } { "?" "a boolean" } }
{ $description "Check if a sequence is reduced to a single " { $link C } " or " { $link I } "  operator." } ;

HELP: is-interesting?
{ $values { "seq" "a sequence" } { "?" "a boolean" } }
{ $description "Check if a sequence is max compressed and if its main operator doesn't apply only once." } ;

HELP: compare-costs
{ $values { "before" "a sequence" } { "after" "a sequence" } { "best" "a sequence" } { "after-best?" "a boolean" } }
{ $description "Compare two sequences using " { $link cost>> } " and return best one indicating if it was the second one." } ;

HELP: compare-costs-verbose
{ $values { "before" "a sequence" } { "after" "a sequence" } { "best" "a sequence" } { "after-best?" "a boolean" } }
{ $description "Call " { $link compare-costs } " in verbose mode." } ;

HELP: compress
{ $values { "seq" "a sequence" } }
{ $description "Compress a sequence using " { $link compare-costs } " to choose what to keep or " { $link fail } " if all tested possibilities failed." } ;

HELP: compress-regarding
{ $values { "searched" "a sequence" } { "seq" "a sequence" } }
{ $description "Work as " { $link compress } " but using " { $link compare-costs-verbose } " and stopping as soon it obtains 'searched': this is mainly used to precisely why it rejected a special compressed form by printing obtained costs." } ;

HELP: compressable?
{ $values { "seq" "a sequence" } { "?" "a boolean" } }
{ $description "Call " { $link compress } " and return t if compressing succeeded." } ; 




HELP: increment-times
{ $values { "optimal" "a sequence" } { "incremented" "a sequence" } }
{ $description "Take a sequence optimally compressed and increments its main operator's times." } ;

HELP: extended-sub?
{ $values { "seq" "a sequence" } { "extended" "a sequence" } { "?" "a boolean" } }
{ $description "Return if 'seq' is a subsequence at the beginning of 'extended'." } ;

HELP: extend-enough
{ $values { "length" "a digit" } { "seq" "a sequence" } }
{ $description "Extend 'seq' until its length is bigger or equal than 'length." } ;

HELP: try-removing
{ $values { "orig-seq" "a sequence" } { "orig-length" "a digit" } { "seq" "a sequence" } { "drop-length" "a digit" } }
{ $description "Try to remove 'drop-length' to 'seq', compress it and test if extended enough result contains 'orig-seq'. " { $link fail } " if it fails." } ;

HELP: prepare-removing
{ $values { "seq" "a sequence" } }
{ $description "Call an " { $link  amb } " on all possible removable sizes and try them." } ;




HELP: extract-elements
{ $values { "list" "a sequence" } { "elements" "a sequence" } }
{ $description "Extract all elements contained in given sequence once, ordered from older to last used." } ;

HELP: several-amb
{ $values { "elements" "a sequence" } { "times" "a digit" } { "elements-to-add" "a sequence" } }
{ $description "Call " { $link amb } " on any combination of length 'times' from 'elements'." } ;

HELP: prepare-add
{ $values { "seq" "a sequence" } }
{ $description "Call an " { $link amb } " on all possible combinations' length, exxtract elements and then call " { $link several-amb } "." } ;

HELP: extend-logic
{ $values { "seq" "a sequence" } }
{ $description "Will try to extend using only copy and increment a given list. Will first try to remove from 0 to length minus 2 elements and then will try to add sequence's elements up to its initial length. This second part is quite expensive (~n! complexity), but chances are high that it will find something before and then return. Activate " { $link verbose } "-mode if you want to see more details about searched possibilities." }
{ $examples
    { $example "USING: complexity prettyprint ;" "{ 1 2 } extend-logic ." "{ 1 2 3 }" }
    { $example "USING: complexity prettyprint ;" "{ 1 1 } extend-logic ." "{ 1 1 1 }" }
    { $example "USING: complexity prettyprint ;" "{ 1 2 2 3 3 3 } extend-logic ." "{ 1 2 2 3 3 3 4 4 4 4 }" }
    { $example "USING: complexity prettyprint ;" "{ 1 2 2 3 } extend-logic ." "{ 1 2 2 3 3 4 }" }
    { $example "USING: complexity prettyprint ;" "{ 1 2 2 3 3 3 4 } extend-logic ." "{ 1 2 2 3 3 3 4 4 4 4 } " }
    { $example "USING: complexity prettyprint ;" "{ 1 1 2 1 2 3 1 1 2 1 2 3 1 2 3 4 } extend-logic ." "{ 1 1 2 1 2 3 1 1 2 1 2 3 1 2 3 4 1 1 2 1 2 3 1 2 3 4 1 2 3 4 5 }" }
} ;

HELP: extend-logic-all
{ $values { "seq" "a sequence" } { "all-seq" "a sequence of sequences" } }
{ $description "Construct a " { $link bag-of } " all " { $link extend-logic } " results. As its complexity is n!, this call may take a while, but all found possibilities are returned." }
{ $examples { $example "USING: complexity prettyprint ;" "{ 1 1 1 1 2 2 } extend-logic-all ." "Will contain among others: { 1 1 1  1 2 2  1 3 3 }, { 1 1 1 1  2 2 2 2  3 3 3 3 }, { 1 1 1 1  2 2 2 2 2  3 3 3 3 3 3 }, { 1 1 1 1  2 2 2 2 2 2  3 3 3 3 3 3 3 3 } and { 1 1 1 1  2 2 2 2 2 2 2 2  3 3 3 3 3 3 3 3 3 3 3 3 }." } } ;

{ extend-logic extend-logic-all } related-words
