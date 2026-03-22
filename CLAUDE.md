# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is an [Alfred](https://www.alfredapp.com) workflow that converts between currencies. The entire workflow logic lives in a single file: `Workflow/convert-currency`, a JXA (JavaScript for Automation) script run by `osascript`.

## No Build or Test System

There are no build steps, package managers, linters, or test suites. To test changes, install the workflow in Alfred and invoke it with the `cur` keyword, or run the script directly:

```sh
alfred_workflow_cache=/tmp osascript -l JavaScript Workflow/convert-currency "42 EUR to USD"
```

## Architecture

Everything is in `Workflow/convert-currency`. The script has three logical sections:

**Helpers**
- `envVar` — reads Alfred environment variables via ObjC bridge
- `findMissing` — array diff utility used for currency validation
- `matchCurrencies` — filters currencies by prefix match on code or coin name (e.g. `eur` matches `EUR`, `dollar` matches `USD`)

**`fetchRates`** — fetches exchange rates from `https://open.er-api.com/v6/latest/USD`, caches the result to `alfred_workflow_cache/ratesUSD.json` for 12 hours. On fetch it validates that the API response matches the hardcoded `currencyNames` map (throws if currencies are extraneous or missing), then enriches each currency with `country` and `coin` fields split from the full name. Popular currencies (EUR, USD, GBP, etc.) are bubbled to the top of the object.

**`run`** — the main entry point called by Alfred with `argv[0]` as the raw query string. Parsing flow:
1. Connector words (`to`, `in`, `as`) are stripped from the middle of the query
2. The leading number token is extracted — supports plain digits, decimals, comma-separated thousands (`1,000,000`), and `k/m/b/t` suffixes (`1.5m` → 1,500,000)
3. The remainder is split into `originCurrency` and `targetCurrency`
4. Output is Alfred JSON (`{ items: [...] }`) — autocomplete drives the multi-step UX

**Alfred UX flow** (driven by what `run` returns):
- No number → error prompt
- Number only → list all currencies
- Number + partial origin → autocomplete list
- Number + exact origin → list all conversion targets
- Number + origin + partial/full target → filtered conversion results

## Adding Currencies

When a new currency is added to the Exchange Rate API feed, add it to the `currencyNames` map inside `fetchRates` and add its flag image to `Workflow/images/flags/<CODE>.png`. The validation check will throw at runtime if the map and API response are out of sync.
