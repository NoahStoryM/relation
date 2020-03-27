#lang scribble/doc
@require[scribble/manual
         scribble-abbrevs/manual
         scribble/example
         racket/sandbox
         @for-label[relation/equivalence
                    racket/generic
                    (except-in racket = equal? group-by)
                    (only-in racket (equal? b:equal?))]]

@title{Equivalence Relations}

@defmodule[relation/equivalence]

A generic interface and utilities for comparing data. By default, the built-in equivalence operator @racket[=] operates on @tech/reference{numbers} specifically, while the operators @racket[eq?], @racket[eqv?] and @racket[equal?] are more suitable for other comparisons depending on the type of the values being compared. Additionally, there are type-specific comparison operators, for instance @racket[char=?] and @racket[string=?], that could be used if the type is known. This module provides a generic interface that overrides the standard @racket[=] operator to allow its use for any comparable type and not only numbers, performing the most appropriate comparison depending on the type of the values being compared. It also supports additional parameters to express broader notions of equivalence than simple equality. You can also provide an implementation for the interface in custom types so that they can be compared using the same standard equality operator and the generic utilities available in this module.

@(define eval-for-docs
  (parameterize ([sandbox-output 'string]
                 [sandbox-error-output 'string]
                 [sandbox-memory-limit #f])
                 (make-evaluator 'racket/base
				                 '(require relation)
				                 '(require racket/function)
								 '(require racket/set)
								 '(require racket/stream))))

@section[#:tag "equivalence:interface"]{Interface}

@defthing[gen:comparable any/c]{

 A @tech/reference{generic interface} that represents any object that can be compared with other objects of the same type in terms of equivalence, that is, in cases where we seek to know, "are these values equal, for some definition of equality?" All built-in types have a default implementation for @racket[gen:comparable].

 @examples[
    #:eval eval-for-docs
    (= 1 1)
    (= 1 2)
    (= 1 (void))
    (= "apple" "APPLE")
    (= #:key string-upcase "apple" "APPLE")
    (= #:key ->number "42.0" "42/1")
  ]

@defproc[(comparable? [v any/c])
         boolean?]{

 Predicate to check if a value is comparable via the generic equivalence operators @racket[=] and @racket[/=].

@examples[
    #:eval eval-for-docs
    (comparable? 3)
    (comparable? #\a)
    (comparable? "cherry")
    (comparable? (set))
    (comparable? (hash))
  ]
}

 To implement this interface for custom types, the following method needs to be implemented:

 @defproc[(equal? [a comparable?]
                  [b comparable?])
          boolean?]{

 A function taking two arguments that tests whether the arguments are equal, where both arguments are instances of the structure type to which the generic interface is associated (or a subtype of the structure type). The function must return true if the arguments are to be considered equal, and false if not.

 All Racket types are @racket[gen:comparable]. If a struct type does not explicitly implement @racket[gen:comparable], the built-in @racketlink[b:equal? "equal?"] will be used for instances of that type, so @racket[=] may be treated as a drop-in replacement for @racketlink[b:equal? "equal?"].
 }

}

@section[#:tag "equivalence:utilities"]{Utilities}

 The following utilities are provided which work with any type that implements the @racket[gen:comparable] interface.

@defproc[(= [#:key key (-> comparable? comparable?) #f]
            [v comparable?] ...)
         boolean?]{

 True if the v's are equal. This uses the most appropriate equality check for the type. For instance, it uses the built-in @racket[=] operator for numeric data, and @racket[equal?] for some other types such as @tech/reference{structures}. If a transformation is provided via the @racket[#:key] argument, then this transformation is applied to the input values first, prior to performing the equality check.

@examples[
    #:eval eval-for-docs
    (= 1 1 1)
    (= 1 2)
    (= "apple" "apple" "apple")
    (= 3/2 1.5)
    (= #:key string-upcase "apple" "Apple" "APPLE")
    (= #:key ->number "42.0" "42/1" "42")
    (= #:key ->number "42" "42.1")
    (= #:key even? 12 20)
    (= #:key odd? 12 20)
    (= #:key (.. even? ->number) "12" "20")
  ]
}

@deftogether[(@defproc[(/= [#:key key (-> comparable? comparable?) #f]
                           [v comparable?]
                           ...)
                       boolean?]
              @defproc[(≠ [#:key key (-> comparable? comparable?) #f]
                          [v comparable?]
                          ...)
                       boolean?]
              @defproc[(!= [#:key key (-> comparable? comparable?) #f]
                           [v comparable?]
                           ...)
                       boolean?])]{

 True if the v's are not equal. This is simply a negation of the generic @racket[=]. If a transformation is provided via the @racket[#:key] argument, then it is applied to the arguments prior to comparing them.

@examples[
    #:eval eval-for-docs
    (≠ 1 1 2)
    (≠ 1 1)
    (≠ "apple" "Apple")
    (≠ 3/2 1.5)
    (≠ #:key string-length "cherry" "banana" "avocado")
  ]
}

@deftogether[(@defproc[(group-by [#:key key (-> comparable? comparable?) #f]
                                 [vs (listof comparable?)])
                       (listof list?)]
              @defproc[(=/classes [#:key key (-> comparable? comparable?) #f]
                                  [vs (listof comparable?)])
                       (listof list?)])]{

 Groups input values into equivalence classes induced by the specified equivalence relation (by default, @racket[=] is applied directly unless a key is specified).

@examples[
    #:eval eval-for-docs
    (group-by (list 1 2 1))
    (group-by (list 1 2 3))
    (group-by (list 1 1 1))
    (group-by (list 1 1 2 2 3 3 3))
    (group-by (list "cherry" "banana" "apple"))
    (group-by #:key string-length (list "apple" "banana" "cherry"))
  ]
}

@defproc[(generic-set [#:key key (-> comparable? comparable?) #f]
                      [v comparable?]
                      ...)
         list?]{

 Returns a @tech/reference{set} containing deduplicated input values using the provided equivalence relation as the test for equality (by default, @racket[=] is applied directly unless a key is specified).

@examples[
    #:eval eval-for-docs
    (generic-set 1 2 3)
    (generic-set 1 1 2 2 3 3 3)
    (generic-set "cherry" "banana" "apple")
    (generic-set #:key odd? 1 2 3 4 5)
    (generic-set #:key string-upcase "apple" "Apple" "APPLE" "banana" "Banana" "cherry")
    (define my-set (generic-set #:key string-upcase "cherry" "banana" "apple"))
	(set-add my-set "APPLE")
  ]
}

@defproc[(member? [#:key key (-> comparable? comparable?) #f]
                  [elem comparable?]
                  [col sequence?])
         boolean?]{

 A generic version of @racket[member] that operates on any sequence rather than lists specifically, and employs the generic @racket[=] relation rather than the built-in @racketlink[b:equal?]{equal?}. In the special case where @racket[col] is a @racket[generic-set], the @racket[key] provided to @racket[member?], if any, is ignored as it may conflict with the existing @racket[key] defining the equivalence relation in the generic set.

@examples[
    #:eval eval-for-docs
    (member? 4 (list 1 2 3))
    (member? 4 (list 1 4 3))
    (member? "cherry" (stream "apple" "banana" "cherry"))
    (member? "BANANA" (list "apple" "banana" "cherry"))
    (member? #:key string-upcase "BANANA" (list "apple" "banana" "cherry"))
    (member? "BANANA" (generic-set #:key string-upcase "apple" "banana" "cherry"))
    (member? "tomato" (generic-set #:key string-length "apple" "banana" "grape"))
  ]
}
