#lang racket/base

(require (prefix-in b: racket/base)
         (only-in racket/list
                  group-by)
         racket/function
         racket/stream
         data/collection)

(define (randoms n)
  (let ([num (random n)])
    (stream-cons num (randoms n))))

(define (check-numbers how-many)
  (for ([i (take how-many (in (cycle '(1 1 3))))]
        [j (take how-many (in (cycle '(1 3 1))))])
    (< i j)
    (> i j)))

(define (check-strings how-many)
  (for ([i (take how-many (in (cycle '("apple" "apple" "banana"))))]
        [j (take how-many (in (cycle '("apple" "banana" "apple"))))])
    (string<? i j)
    (string>? i j)))

(define (check-hash-codes how-many)
  (for ([i (take how-many (in (cycle (list (list 1 2)
                                           (list 1.0 2.0)
                                           (list (list 1 2))
                                           (list (list 1.0 2.0))
                                           (list "abc" 'abc #\a 1 (list 2.0 3))))))])
    (equal-hash-code i)))

(define (check-chars how-many)
  (for ([i (take how-many (in (cycle '(#\a #\a #\b))))]
        [j (take how-many (in (cycle '(#\a #\b #\a))))])
    (char<? i j)
    (char>? i j)))

(define (sort-numbers how-many)
  (for ([i (take how-many (in (cycle '((4 1 3 2 7 1 3 5)))))])
    (sort i <)))

(define (sort-strings how-many)
  (for ([i (take how-many (in (cycle '(("dragonfruit" "apple" "cherry" "banana" "guava" "apple" "cherry" "elderberry")))))])
    (sort i string<?)))

(define (check-min how-many)
  (for ([i (take how-many (in (cycle '((4 1 3 2 7 1 3 5)))))])
    (apply min i)))

(define (check-max how-many)
  (for ([i (take how-many (in (cycle '((4 1 3 2 7 1 3 5)))))])
    (apply max i)))

(check-numbers 10000)
(check-strings 10000)
(check-hash-codes 10000)
(check-chars 10000)
(sort-numbers 10000)
(sort-strings 10000)
(check-min 10000)
(check-max 10000)
