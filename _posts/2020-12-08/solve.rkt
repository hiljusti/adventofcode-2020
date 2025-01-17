#!/usr/bin/env racket
#lang racket

(define (extract-line line)
    (and (non-empty-string? line) (string-split line " ")))
(define (format-line entry index)
    (list index (first entry) (string->number (second entry))))
(define the-code
    (make-immutable-hash (sequence->list (sequence-map format-line
        (in-indexed (filter-map extract-line
            (file->lines "input")))))))

(define (compute-line addr acc code seen)
    (cond
        [(set-member? seen addr)
            (eprintf "Error: Attempted to traverse to already seen address.\n")
            (eprintf "addr: ~a\nacc: ~a\n\n" addr acc)
            #f]
        [(hash-has-key? code addr)
            (let* ([seen (set-add seen addr)]
                   [line (hash-ref code addr)]
                   [op (first line)]
                   [n (second line)])
                (printf "~a: ~a ~a | ~a\n" addr op n acc)
                (let ([addr (case op [("jmp") (+ addr n)] [else (add1 addr)])]
                      [acc (case op [("acc") (+ acc n)] [else acc])])
                    (compute-line addr acc code seen)))]
        [else (printf "Final result: ~a\n\n" acc) #t]))

; Part 1, expected to error out.
(compute-line 0 0 the-code (set))

(print "Type something to continue: ")
(read)

; Part 2, searching for a non-error case 
; We can flip one jmp to nop or one nop to jmp.
(define swap (hash "jmp" "nop" "nop" "jmp"))
(define swapped-codes
    (filter-map
        (lambda (line)
            (let ([add (first line)]
                  [op (second line)]
                  [n (third line)])
                (and (hash-has-key? swap op)
                     (hash-set the-code add (list (hash-ref swap op) n)))))
        (hash->list the-code)))

(define (run-variant swapped-code)
    (compute-line 0 0 swapped-code (set)))
(and
    (findf run-variant swapped-codes)
    (printf "Done.\n"))

