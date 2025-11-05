# AngelCoin (ANGEL)

AngelCoin is a SIP-010 compliant fungible token implemented in Clarity using Clarinet.

## Project layout
- `contracts/sip-010-trait.clar` — Local copy of the SIP-010 FT trait
- `contracts/angelcoin.clar` — AngelCoin token implementation
- `tests/angelcoin.test.ts` — Test scaffold (add tests here)
- `Clarinet.toml` — Project configuration

## Requirements
- Clarinet 3.x
- Node.js (for JS tests)

## Install Clarinet
If Clarinet isn’t installed:
- Using npm (recommended if you have Node installed):
  ```bash
  npm i -g @hirosystems/clarinet
  ```
- Or download a release binary: https://github.com/hirosystems/clarinet/releases

Verify:
```bash
clarinet --version
```

## Quick start
```bash
clarinet check
clarinet console
clarinet format
npm install
npm test
```

## SIP-010 Interface
The contract implements the following SIP-010 entrypoints:
- `transfer(amount, sender, recipient, memo?)` -> `(response bool uint)`
- `get-name()` -> `(response (string-ascii 32) uint)`
- `get-symbol()` -> `(response (string-ascii 10) uint)`
- `get-decimals()` -> `(response uint uint)`
- `get-balance(who)` -> `(response uint uint)`
- `get-total-supply()` -> `(response (optional uint) uint)`
- `get-token-uri()` -> `(response (optional (string-utf8 256)) uint)`
- `get-allowance(owner, spender)` -> `(response uint uint)`
- `approve(spender, amount)` -> `(response bool uint)`

Admin/helper functions:
- `set-admin(p)` — callable once to set the token admin
- `mint(recipient, amount)` — only the admin can call
- `burn(amount)` — any holder can burn their own tokens

## Common workflows
### Initialize admin (one-time)
In Clarinet console, as the deployer account (or desired admin):
```clarity
(contract-call? .angelcoin set-admin tx-sender)
```

### Mint tokens (admin only)
```clarity
(contract-call? .angelcoin mint 'ST3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA u1000000)
```

### Approve allowance and transfer on behalf
```clarity
(contract-call? .angelcoin approve 'SP2C2...SPENDER u500)
(contract-call? .angelcoin transfer u200 'SP3F4...OWNER 'SP2C2...RECIP none)
```

### Direct transfer
```clarity
(contract-call? .angelcoin transfer u100 tx-sender 'SP2C2...RECIP none)
```

## Notes
- Decimals: `6` (1 ANGEL = 1_000_000 base units)
- `get-token-uri` currently returns `none`. You can host metadata and update this function later.

## License
MIT
