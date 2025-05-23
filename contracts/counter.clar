(define-map counters principal uint)
(define-data-var total-count uint u0)
(define-data-var leader principal tx-sender)

(define-read-only (get-count (who principal))
  (default-to u0 (map-get? counters who))
)

(define-public (count-up)
  (let ((current (get-count tx-sender))
        (new-count (+ current u1)))
    (begin
      (map-set counters tx-sender new-count)
      (var-set total-count (+ (var-get total-count) u1))
      (let ((leader-current (get-count (var-get leader))))
        (if (> new-count leader-current)
            (var-set leader tx-sender)
            (ok true)))
      (ok new-count)
    )
  )
)

(define-public (count-down)
  (let ((current (get-count tx-sender)))
    (if (> current u0)
        (begin
          (map-set counters tx-sender (- current u1))
          (var-set total-count (if (> (var-get total-count) u0) (- (var-get total-count) u1) u0))
          (ok (- current u1))
        )
        (err u100)) 
  )
)

(define-public (reset-count)
  (let ((current (get-count tx-sender)))
    (begin
      (map-set counters tx-sender u0)
      (var-set total-count (if (> (var-get total-count) current) (- (var-get total-count) current) u0))
      (ok u0)
    )
  )
)

(define-read-only (get-total-count)
  (ok (var-get total-count))
)

(define-read-only (get-leader)
  (ok (var-get leader))
)