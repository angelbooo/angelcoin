(define-trait sip-010-trait
  (
    ;; Transfers `amount` of tokens from `sender` to `recipient` with an optional memo.
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
    (get-name () (response (string-ascii 32) uint))
    (get-symbol () (response (string-ascii 10) uint))
    (get-decimals () (response uint uint))
    (get-balance (principal) (response uint uint))
    (get-total-supply () (response (optional uint) uint))
    (get-token-uri () (response (optional (string-utf8 256)) uint))
    (get-allowance (principal principal) (response uint uint))
    (approve (principal uint) (response bool uint))
  )
)
