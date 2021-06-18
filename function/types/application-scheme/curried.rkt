#lang racket/base

(require (except-in racket/contract/base
                    predicate/c)
         racket/generic
         racket/hash
         racket/set
         arguments
         relation/logic
         (prefix-in b: racket/base)
         (only-in relation/equivalence
                  in?)
         ionic)

(require "interface.rkt"
         "../interface.rkt"
         "../base.rkt"
         "../util.rkt"
         "../../../private/util.rkt")

(provide (contract-out
          [struct curried-arguments
            ((f procedure?)
             (chirality symbol?)
             (left list?)
             (right list?)
             (kw hash?))]
          [make-curried-arguments (-> b:procedure?
                                      symbol?
                                      arguments?
                                      curried-arguments?)]))

(define-switch (~min-arity-value arity)
  [number? arity]
  [arity-at-least? (call arity-at-least-value)]
  [list? (call (~>> (map ~min-arity-value) (apply min)))]
  [else (raise-argument-error 'min-arity
                              "normalized-arity?"
                              arity)])

(define (~min-arity f)
  (~min-arity-value (arity f)))

;; TODO: maybe rename to curried-application
;; or curried-function
;; TODO: check function arity in pass and reject if incompatible
(struct curried-arguments function (f chirality left right kw)
  #:transparent

  #:methods gen:application-scheme
  [(define (pass this args)
     ;; incorporate fresh arguments into the partial application,
     ;; retaining existing arg positions and appending the fresh ones
     ;; at the positions implied by the chirality
     (let ([f (curried-arguments-f this)]
           [chirality (curried-arguments-chirality this)])
       (let ([left-args (if (eq? chirality 'left)
                            (append (curried-arguments-left this)
                                    (arguments-positional args))
                            (curried-arguments-left this))]
             [right-args (if (eq? chirality 'right)
                             ;; note order reversed for right args
                             (append (arguments-positional args)
                                     (curried-arguments-right this))
                             (curried-arguments-right this))])
         (curried-arguments f
                            chirality
                            left-args
                            right-args
                            (hash-union (curried-arguments-kw this)
                                        (arguments-keyword args))))))
   (define (flat-arguments this)
     (make-arguments (curried-arguments-positional this)
                     (curried-arguments-kw this)))]

  ;; do we want to fail at the pass level? or if we bypass pass
  ;; altogether, it would simply flat-arguments and see what happens
  ;; the latter is simpler, but the former separates concerns
  #:methods gen:procedure
  [(define/generic -procedure-apply procedure-apply)
   (define/generic -arity arity)
   (define/generic -keywords keywords)
   (define (procedure-apply this invocation-args)
     ;; attempt to eval the function. If it fails, return a new
     ;; function with a modified applier
     (let* ([f (curried-arguments-f this)]
            [updated-application (pass this invocation-args)]
            [args (flat-arguments updated-application)]
            [pos-args (arguments-positional args)]
            [kw-args (arguments-keyword args)])
       (with-handlers ([recoverable-apply-error?
                        ;; if it gets to the eval stage, the application scheme
                        ;; at this level has already signed off on it, but a nested
                        ;; application scheme is not yet fulfilled. The application
                        ;; scheme determines what happens here
                        (λ (exn) updated-application)]
                       [exn:fail:contract:arity?
                        (λ (exn)
                          (if (> (length pos-args)
                                 (~min-arity f)) ; should this be updated-application?
                              (raise exn)
                              updated-application))]
                       [exn:fail:contract?
                        ;; presence of a keyword argument results in a premature
                        ;; contract failure that's not the arity error, even though
                        ;; that's probably what it should be since providing additional
                        ;; positional arguments results in expected behavior
                        ;; additionally, also handle invalid keyword arg here
                        (λ (exn)
                          (let-values ([(req-kw opt-kw)
                                        (keywords f)])
                            (if (or (hash-empty? kw-args)
                                    ;; the arity error is masked in the presence of keyword
                                    ;; args so we check for it again here
                                    (> (length pos-args)
                                       (~min-arity f))
                                    ;; any unexpected keywords?
                                    (any?
                                     (map (!! (in? (append req-kw opt-kw)))
                                          (hash-keys kw-args)))
                                    ;; all required arguments received?
                                    (and (subset? req-kw (hash-keys kw-args))
                                         (>= (length pos-args)
                                             (~min-arity f))))
                                (raise exn)
                                updated-application)))])
         (-procedure-apply f args))))
   (define (arity this)
     ;; TODO: subtract args already supplied
     (-arity (curried-arguments-f this)))
   (define (keywords this)
     ;; TODO: subtract args already supplied
     (-keywords (curried-arguments-f this)))]

  #:methods gen:custom-write
  [(define (write-proc self port mode)
     (define recur
       (case mode
         [(#t) write]
         [(#f) display]
         [else (λ (p port) (print p port mode))]))
     (let ([left (curried-arguments-left self)]
           [right (curried-arguments-right self)]
           [kw (curried-arguments-kw self)])
       (cond [(null? right)
              (recur (append left (list '_)) port)]
             [(null? left)
              (recur (append (list '_) right) port)]
             [else (recur (append left
                                  (list '_)
                                  right
                                  (kwhash->altlist kw))
                          port)])))])

(define (curried-arguments-positional args)
  (append (curried-arguments-left args)
          (curried-arguments-right args)))

(define (make-curried-arguments f chirality args)
  (let ([pos (arguments-positional args)]
        [kw (arguments-keyword args)])
    (if (eq? 'left chirality)
        (curried-arguments f 'left pos null kw)
        (curried-arguments f 'right null pos kw))))
