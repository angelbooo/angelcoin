;; AngelCoin - SIP-010 fungible token implementation
;; Implements the local sip-010-trait defined in ./sip-010-trait.clar

(use-trait sip010 .sip-010-trait.sip-010-trait)
(impl-trait .sip-010-trait.sip-010-trait)

(define-constant ERR-UNAUTHORIZED u100)
(define-constant ERR-INSUFFICIENT-BALANCE u101)
(define-constant ERR-INSUFFICIENT-ALLOWANCE u102)
(define-constant ERR-ZERO-AMOUNT u103)

(define-constant TOKEN-NAME "AngelCoin")
(define-constant TOKEN-SYMBOL "ANGEL")
(define-constant TOKEN-DECIMALS u6)

(define-data-var total-supply uint u0)
(define-data-var token-admin (optional principal) none)

(define-map balances { account: principal } { amount: uint })
(define-map allowances { owner: principal, spender: principal } { amount: uint })

;; helpers
(define-read-only (balance-of (who principal))
  (match (map-get? balances { account: who })
    balance (get amount balance)
    u0))

(define-read-only (allowance-of (owner principal) (spender principal))
  (match (map-get? allowances { owner: owner, spender: spender })
    a (get amount a)
    u0))

(define-private (debit (who principal) (amount uint))
  (let ((bal (balance-of who)))
    (if (< bal amount)
        (err ERR-INSUFFICIENT-BALANCE)
        (begin
          (map-set balances { account: who } { amount: (- bal amount) })
          (ok true)))))

(define-private (credit (who principal) (amount uint))
  (let ((bal (balance-of who)))
    (begin
      (map-set balances { account: who } { amount: (+ bal amount) })
      true)))

;; SIP-010 trait functions
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (let (
        (is-self (is-eq sender tx-sender))
        (allow (allowance-of sender tx-sender))
        (bal   (balance-of sender))
        (err-code
          (if (is-eq amount u0)
              (some ERR-ZERO-AMOUNT)
              (if (and (not is-self) (< allow amount))
                  (some ERR-INSUFFICIENT-ALLOWANCE)
                  (if (< bal amount)
                      (some ERR-INSUFFICIENT-BALANCE)
                      none)))))
    (match err-code
      e (err e)
      (begin
        (if (not is-self)
            (begin (map-set allowances { owner: sender, spender: tx-sender } { amount: (- allow amount) }) true)
            true)
        (map-set balances { account: sender } { amount: (- bal amount) })
        (credit recipient amount)
        (ok true)))))

(define-read-only (get-name)
  (ok TOKEN-NAME))

(define-read-only (get-symbol)
  (ok TOKEN-SYMBOL))

(define-read-only (get-decimals)
  (ok TOKEN-DECIMALS))

(define-read-only (get-balance (who principal))
  (ok (balance-of who)))

(define-read-only (get-total-supply)
  (ok (some (var-get total-supply))))

(define-read-only (get-token-uri)
  (ok none))

(define-read-only (get-allowance (owner principal) (spender principal))
  (ok (allowance-of owner spender)))

(define-public (approve (spender principal) (amount uint))
  (begin
    (map-set allowances { owner: tx-sender, spender: spender } { amount: amount })
    (ok true)))

;; administrative
(define-public (set-admin (p principal))
  (if (is-none (var-get token-admin))
      (begin
        (var-set token-admin (some p))
        (ok true))
      (err ERR-UNAUTHORIZED)))

(define-public (mint (recipient principal) (amount uint))
  (match (var-get token-admin)
    admin (let ((err-code (if (is-eq amount u0) (some ERR-ZERO-AMOUNT) none)))
            (match err-code
              e (err e)
              (if (is-eq tx-sender admin)
                  (begin
                    (credit recipient amount)
                    (var-set total-supply (+ (var-get total-supply) amount))
                    (ok true))
                  (err ERR-UNAUTHORIZED))))
    (err ERR-UNAUTHORIZED)))

(define-public (burn (amount uint))
  (let ((bal (balance-of tx-sender)))
    (if (< bal amount)
        (err ERR-INSUFFICIENT-BALANCE)
        (begin
          (map-set balances { account: tx-sender } { amount: (- bal amount) })
          (var-set total-supply (- (var-get total-supply) amount))
          (ok true)))))
