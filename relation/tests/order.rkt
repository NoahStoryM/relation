#lang racket/base

(require rackunit
         rackunit/text-ui
         relation
         (prefix-in b: racket/base)
         racket/set
         racket/stream
         racket/sequence
         "private/util.rkt")

(define tests
  (test-suite
   "Tests for order relations"

   (test-suite
    "less than"
    (check-true (< 1 2 3) "monotonically increasing")
    (check-false (< 1 1 2) "monotonically nondecreasing")
    (check-false (< 3 3 3) "equal")
    (check-false (< 3 3 1) "monotonically nonincreasing")
    (check-false (< 3 2 1) "monotonically decreasing")
    (check-false (< 3 2 4) "disordered")
    (check-true (< 3) "trivial case")
    (check-exn exn:fail?
               (lambda ()
                 (<)) "generic relations require at least one argument")
    (check-true (< "apple" "banana" "cherry"))
    (check-false (< "apple" "apple" "apple"))
    (check-false (< "cherry" "banana" "apple"))
    (check-true (< #"apple" #"banana" #"cherry"))
    (check-false (< #"apple" #"apple" #"apple"))
    (check-false (< #"cherry" #"banana" #"apple"))
    (check-true (< #\a #\b #\c))
    (check-false (< #\a #\a #\a))
    (check-false (< #\c #\b #\a))
    (check-true (< (set) (set 1) (set 1 2)))
    (check-false (< (set 1 2) (set 1 2) (set 1 2)))
    (check-false (< (set 1 2) (set 1) (set)))
    (check-false (< (set 1 2) (set 1 3)) "incomparable sets")
    (check-false (< (set 1 2) (set 3 4)) "incomparable sets")
    (check-true (< #:key string-length "z" "yy" "xxx"))
    (check-false (< #:key string-length "xxx" "zzz" "yyy"))
    (check-false (< #:key string-length "xxx" "yy" "z"))
    (check-true (< #:key car (cons 1 2) (cons 3 1) (cons 4 1)) "contract accepts unorderable values"))

   (test-suite
    "less than or equal to"
    (check-true (≤ 1 2 3) "monotonically increasing")
    (check-true (≤ 1 1 2) "monotonically nondecreasing")
    (check-true (≤ 3 3 3) "equal")
    (check-false (≤ 3 3 1) "monotonically nonincreasing")
    (check-false (≤ 3 2 1) "monotonically decreasing")
    (check-false (≤ 3 2 4) "disordered")
    (check-true (≤ 3) "trivial case")
    (check-exn exn:fail?
               (lambda ()
                 (≤)) "generic relations require at least one argument")
    (check-true (≤ "apple" "banana" "cherry"))
    (check-true (≤ "apple" "apple" "apple"))
    (check-false (≤ "cherry" "banana" "apple"))
    (check-true (≤ #"apple" #"banana" #"cherry"))
    (check-true (≤ #"apple" #"apple" #"apple"))
    (check-false (≤ #"cherry" #"banana" #"apple"))
    (check-true (≤ #\a #\b #\c))
    (check-true (≤ #\a #\a #\a))
    (check-false (≤ #\c #\b #\a))
    (check-true (≤ (set) (set 1) (set 1 2)))
    (check-true (≤ (set 1 2) (set 1 2) (set 1 2)))
    (check-false (≤ (set 1 2) (set 1) (set)))
    (check-false (≤ (set 1 2) (set 1 3)) "incomparable sets")
    (check-false (≤ (set 1 2) (set 3 4)) "incomparable sets")
    (check-true (≤ #:key string-length "z" "yy" "xxx"))
    (check-true (≤ #:key string-length "xxx" "zzz" "yyy"))
    (check-false (≤ #:key string-length "xxx" "yy" "z"))
    (check-true (<= 2 3))
    (check-false (<= 3 2))
    (check-true (≤ #:key car (cons 1 2) (cons 3 1) (cons 4 1)) "contract accepts unorderable values"))

   (test-suite
    "greater than or equal to"
    (check-false (≥ 1 2 3) "monotonically increasing")
    (check-false (≥ 1 1 2) "monotonically nondecreasing")
    (check-true (≥ 3 3 3) "equal")
    (check-true (≥ 3 3 1) "monotonically nonincreasing")
    (check-true (≥ 3 2 1) "monotonically decreasing")
    (check-false (≥ 3 2 4) "disordered")
    (check-true (≥ 3) "trivial case")
    (check-exn exn:fail?
               (lambda ()
                 (≥)) "generic relations require at least one argument")
    (check-false (≥ "apple" "banana" "cherry"))
    (check-true (≥ "apple" "apple" "apple"))
    (check-true (≥ "cherry" "banana" "apple"))
    (check-false (≥ #"apple" #"banana" #"cherry"))
    (check-true (≥ #"apple" #"apple" #"apple"))
    (check-true (≥ #"cherry" #"banana" #"apple"))
    (check-false (≥ #\a #\b #\c))
    (check-true (≥ #\a #\a #\a))
    (check-true (≥ #\c #\b #\a))
    (check-false (≥ (set) (set 1) (set 1 2)))
    (check-true (≥ (set 1 2) (set 1 2) (set 1 2)))
    (check-true (≥ (set 1 2) (set 1) (set)))
    (check-false (≥ (set 1 2) (set 1 3)) "incomparable sets")
    (check-false (≥ (set 1 2) (set 3 4)) "incomparable sets")
    (check-false (≥ #:key string-length "z" "yy" "xxx"))
    (check-true (≥ #:key string-length "xxx" "zzz" "yyy"))
    (check-true (≥ #:key string-length "xxx" "yy" "z"))
    (check-false (>= 2 3))
    (check-true (>= 3 2))
    (check-false (≥ #:key car (cons 1 2) (cons 3 1) (cons 4 1)) "contract accepts unorderable values"))

   (test-suite
    "greater than"
    (check-false (> 1 2 3) "monotonically increasing")
    (check-false (> 1 1 2) "monotonically nondecreasing")
    (check-false (> 3 3 3) "equal")
    (check-false (> 3 3 1) "monotonically nonincreasing")
    (check-true (> 3 2 1) "monotonically decreasing")
    (check-false (> 3 2 4) "disordered")
    (check-true (> 3) "trivial case")
    (check-exn exn:fail?
               (lambda ()
                 (>)) "generic relations require at least one argument")
    (check-false (> "apple" "banana" "cherry"))
    (check-false (> "apple" "apple" "apple"))
    (check-true (> "cherry" "banana" "apple"))
    (check-false (> #"apple" #"banana" #"cherry"))
    (check-false (> #"apple" #"apple" #"apple"))
    (check-true (> #"cherry" #"banana" #"apple"))
    (check-false (> #\a #\b #\c))
    (check-false (> #\a #\a #\a))
    (check-true (> #\c #\b #\a))
    (check-false (> (set) (set 1) (set 1 2)))
    (check-false (> (set 1 2) (set 1 2) (set 1 2)))
    (check-true (> (set 1 2) (set 1) (set)))
    (check-false (> (set 1 2) (set 1 3)) "incomparable sets")
    (check-false (> (set 1 2) (set 3 4)) "incomparable sets")
    (check-false (> #:key string-length "z" "yy" "xxx"))
    (check-false (> #:key string-length "xxx" "zzz" "yyy"))
    (check-true (> #:key string-length "xxx" "yy" "z"))
    (check-false (> #:key car (cons 1 2) (cons 3 1) (cons 4 1)) "contract accepts unorderable values"))

   (test-suite
    "custom types"
    (λ ()
      (struct amount (dollars cents)
        #:transparent
        #:methods gen:orderable
        [(define (less-than? comparable other)
           (or (< #:key amount-dollars
                  comparable
                  other)
               (and (= #:key amount-dollars
                       comparable
                       other)
                    (< #:key amount-cents
                       comparable
                       other))))])
      (check-true (< (amount 5 95) (amount 5 99)))
      (check-true (≤ (amount 5 95) (amount 5 99)))
      (check-false (≥ (amount 5 95) (amount 5 99)))
      (check-false (> (amount 5 95) (amount 5 99)))
      (check-false (< (amount 5 99) (amount 5 99)))
      (check-true (≤ (amount 5 99) (amount 5 99)))
      (check-true (≥ (amount 5 99) (amount 5 99)))
      (check-false (> (amount 5 99) (amount 5 99)))
      (check-false (< (amount 6 10) (amount 5 99)))
      (check-false (≤ (amount 6 10) (amount 5 99)))
      (check-true (≥ (amount 6 10) (amount 5 99)))
      (check-true (> (amount 6 10) (amount 5 99)))))

   (test-suite
    "sort"
    (check-equal? (sort < (list 1 2 3)) (list 1 2 3) "monotonically increasing")
    (check-equal? (sort < (list 1 1 2)) (list 1 1 2) "monotonically nondecreasing")
    (check-equal? (sort < (list 3 3 3)) (list 3 3 3) "equal")
    (check-equal? (sort < (list 3 3 1)) (list 1 3 3) "monotonically nonincreasing")
    (check-equal? (sort < (list 3 2 1)) (list 1 2 3) "monotonically decreasing")
    (check-equal? (sort < (list 3 2 4)) (list 2 3 4) "disordered")
    (check-equal? (sort < (list 3)) (list 3) "trivial case")
    (check-equal? (sort < (list)) (list) "null case")
    (check-equal? (sort < (stream 3 2 1)) (list 1 2 3) "non-list input")
    (check-equal? (sort < (list "apple" "banana" "cherry")) (list "apple" "banana" "cherry"))
    (check-equal? (sort < (list "cherry" "banana" "apple")) (list "apple" "banana" "cherry"))
    (check-equal? (sort < #:key string-length (list "z" "yy" "xxx")) (list "z" "yy" "xxx"))
    (check-equal? (sort < #:key string-length (list "xxx" "yy" "z")) (list "z" "yy" "xxx"))
    (check-equal? (sort > (list 1 2 3)) (list 3 2 1) "monotonically increasing")
    (check-equal? (sort > (list 1 1 2)) (list 2 1 1) "monotonically nondecreasing")
    (check-equal? (sort > (list 3 3 3)) (list 3 3 3) "equal")
    (check-equal? (sort > (list 3 3 1)) (list 3 3 1) "monotonically nonincreasing")
    (check-equal? (sort > (list 3 2 1)) (list 3 2 1) "monotonically decreasing")
    (check-equal? (sort > (list 3 2 4)) (list 4 3 2) "disordered")
    (check-equal? (sort > (list 3)) (list 3) "trivial case")
    (check-equal? (sort > (list)) (list) "null case")
    (check-equal? (sort > (stream 1 2 3)) (list 3 2 1) "non-list input")
    (check-equal? (sort > (list "apple" "banana" "cherry")) (list "cherry" "banana" "apple"))
    (check-equal? (sort > (list "cherry" "banana" "apple")) (list "cherry" "banana" "apple"))
    (check-equal? (sort > #:key string-length (list "x" "yy" "zzz")) (list "zzz" "yy" "x"))
    (check-equal? (sort > #:key string-length (list "zzz" "yy" "x")) (list "zzz" "yy" "x"))
    (check-equal? (sort < #:key car '((1 . 2) (4 . 1) (3 . 1))) '((1 . 2) (3 . 1) (4 . 1)) "contract accepts unorderable values"))

   (test-suite
    "min"
    (check-equal? (min 1 2 3) 1 "monotonically increasing")
    (check-equal? (min 1 1 2) 1 "monotonically nondecreasing")
    (check-equal? (min 3 3 3) 3 "equal")
    (check-equal? (min 3 3 1) 1 "monotonically nonincreasing")
    (check-equal? (min 3 2 1) 1 "monotonically decreasing")
    (check-equal? (min 3 2 4) 2 "disordered")
    (check-equal? (min 3) 3 "trivial case")
    (check-exn exn:fail?
               (lambda ()
                 (min)) "generic relations require at least one argument")
    (check-equal? (min "apple" "banana" "cherry") "apple")
    (check-equal? (min "apple" "apple" "apple") "apple")
    (check-equal? (min "cherry" "banana" "apple") "apple")
    (check-equal? (min #"apple" #"banana" #"cherry") #"apple")
    (check-equal? (min #"apple" #"apple" #"apple") #"apple")
    (check-equal? (min #"cherry" #"banana" #"apple") #"apple")
    (check-equal? (min #\a #\b #\c) #\a)
    (check-equal? (min #\a #\a #\a) #\a)
    (check-equal? (min #\c #\b #\a) #\a)
    (check-equal? (min (set) (set 1) (set 1 2)) (set))
    (check-equal? (min (set 1 2) (set 1 2) (set 1 2)) (set 1 2))
    (check-equal? (min (set 1 2) (set 1) (set)) (set))
    ;(check-equal? (min (set 1 2) (set 1 3)) "incomparable sets")
    ;(check-equal? (min (set 1 2) (set 3 4)) "incomparable sets")
    (check-equal? (min #:key string-length "z" "yy" "xxx") "z")
    (check memq (min #:key string-length "xxx" "zzz" "yyy") '("xxx" "yyy" "zzz"))
    (check-equal? (min #:key string-length "xxx" "yy" "z") "z")
    (check-equal? (apply min #:key car '((1 . 2) (0 . 1) (3 . 1))) '(0 . 1) "contract accepts unorderable values"))

   (test-suite
    "max"
    (check-equal? (max 1 2 3) 3 "monotonically increasing")
    (check-equal? (max 1 1 2) 2 "monotonically nondecreasing")
    (check-equal? (max 3 3 3) 3 "equal")
    (check-equal? (max 3 3 1) 3 "monotonically nonincreasing")
    (check-equal? (max 3 2 1) 3 "monotonically decreasing")
    (check-equal? (max 3 2 4) 4 "disordered")
    (check-equal? (max 3) 3 "trivial case")
    (check-exn exn:fail?
               (lambda ()
                 (max)) "generic relations require at least one argument")
    (check-equal? (max "apple" "banana" "cherry") "cherry")
    (check-equal? (max "apple" "apple" "apple") "apple")
    (check-equal? (max "cherry" "banana" "apple") "cherry")
    (check-equal? (max #"apple" #"banana" #"cherry") #"cherry")
    (check-equal? (max #"apple" #"apple" #"apple") #"apple")
    (check-equal? (max #"cherry" #"banana" #"apple") #"cherry")
    (check-equal? (max #\a #\b #\c) #\c)
    (check-equal? (max #\a #\a #\a) #\a)
    (check-equal? (max #\c #\b #\a) #\c)
    (check-equal? (max (set) (set 1) (set 1 2)) (set 1 2))
    (check-equal? (max (set 1 2) (set 1 2) (set 1 2)) (set 1 2))
    (check-equal? (max (set 1 2) (set 1) (set)) (set 1 2))
    ;(check-equal? (max (set 1 2) (set 1 3)) "incomparable sets")
    ;(check-equal? (max (set 1 2) (set 3 4)) "incomparable sets")
    (check-equal? (max #:key string-length "z" "yy" "xxx") "xxx")
    (check memq (max #:key string-length "xxx" "zzz" "yyy") '("xxx" "yyy" "zzz"))
    (check-equal? (max #:key string-length "xxx" "yy" "z") "xxx")
    (check-equal? (apply max #:key car '((1 . 2) (0 . 1) (3 . 1))) '(3 . 1) "contract accepts unorderable values"))))

(module+ test
  (just-do
   (run-tests tests)))
