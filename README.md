# Scientific Computing and Simulation for Ecology and Evolution (LIFE70065) — Coursework

Coursework for LIFE70065 (Imperial College London, Autumn 2026). The project contains:

- **Part 1** – a stochastic vs deterministic demographic (stage-structured) population model, with extinction simulations run in parallel on the Imperial HPC cluster.
- **Part 2** – a neutral model of an ecological community, written from scratch as a reproducible simulation.
- **Part 3** – a microproject: an individual-based model of community assembly inspired by neutral theory.

## Requirements

- R 4.6.1 (local)
- No additional packages so far (will be listed here if added)
- Access to the Imperial HPC (CX3) for the cluster runs in Parts 1 and 3

## Project structure

```
.
├── code/        # R scripts, shell scripts for the HPC, and tests
├── data/        # simulation output (RDA files) and summary data
├── results/     # figures (PDF) produced by the code
└── README.md    # this file, including the development diary
```

## How to run

All scripts assume the **working directory is the root of this repository**, e.g.

```r
setwd("path/to/this/repository")
source("code/<script_name>.R")
```

| Part | Script | What it does |
|---|---|---|
| 1 | `code/Demographic.R` | Model functions (provided by the lecturer, with fixes — see diary) |
| 1 | TODO | Panel a: local time-series simulation |
| 1 | TODO | Panel b: HPC simulation script + `.sh` job script |
| 1 | TODO | Reads HPC output and plots the extinction probabilities |
| 2 | TODO | Neutral model; reproduces the Part 2 figure in under one minute |
| 3 | TODO | Microproject |

## Testing

Tests live in `code/` (e.g. `code/test_demographic.R`) and can be run with `source()`.

- **Deterministic functions** are tested against exact expected values.
- **Stochastic functions** are tested on properties that must always hold (output length, non-negative counts, totals not exceeding the input pool), and for reproducibility using `set.seed()`.

## HPC runs

The shell scripts and three sample `.e` and `.o` files from each cluster run are kept in `code/` (TODO: confirm final location).

## Use of AI

AI assistance (Claude) was used throughout, as permitted by the module. Each use is described in the development diary below.

---

# Development diary

Entries are in chronological order. Each entry is pushed when written and is not edited afterwards; any change of view is recorded in a new entry.

### 2026-11-22 19:45

**Catching up on Thursday 19 November (practical session)**
- Read through every function in `Demographic.R` and the document *matrix info for part 1.pdf*. I now understand what each function does, how the growth and reproduction matrices are used, and how stochasticity is added (multinomial draws for survival and maturation; a binomial draw for which adults recruit, followed by a clutch size drawn from `clutch_distribution`).
- Noticed that `multinomial()` calls `rmultinom(n=11, ...)` but only ever uses the first sample. I asked the lecturer during the practical, and he confirmed it is a typo and should be `n=1`.
- Found that `sum_vect()` is called in `survival_maturation()` but never defined, so the stochastic model cannot run as provided. The lecturer's Canvas announcement on 20 November confirmed this.

**Today**
- Set up the repository structure (`code/`, `data/`, `results/`, `README.md`) and copied the original, unmodified `Demographic.R` into `code/`. I am committing it unchanged first, so that my fixes show up as a separate commit in the Git history.
- **Plan for the fixes:** change `n=11` to `n=1` (with a comment explaining why), and define `sum_vect(x, y)`, which pads the shorter vector with zeros and then adds the two element-wise.
- **Testing plan:** deterministic functions such as `sum_vect()` will be checked against exact expected values using `stopifnot()`. Stochastic functions such as `multinomial()` cannot be checked against a fixed answer, so I will test properties that must always hold: the output has the right length, contains no negative values, sums to no more than the pool size, and gives zero for outcomes with probability zero. I will also check that the same `set.seed()` gives identical results.
- **AI usage:**
  - Asked Claude to explain the matrix returned by `rmultinom()` and how `as.vector()` unfolds a matrix column by column. This showed me exactly why only the first sample was being used.
  - Claude provided a short implementation of `sum_vect()`. I went through it line by line before using it, and I will write the tests myself.
  - Asked Claude to suggest a structure for this README and to polish the wording of this entry.
- **Next:** apply the fixes, write `code/test_demographic.R`, then start the Part 1 panel a time series.

### 2026-11-23 14：10

**Fixes and tests completed**
- Applied the two fixes planned yesterday in `code/Demographic.R`: changed `rmultinom(n=11)` to `n=1` (with a comment explaining why) and added `sum_vect()`. Checked in R that `sum_vect(c(1, 3), c(1, 0, 5, 2))` returns `2 3 5 2`.
- Wrote `code/test_demographic.R`. `sum_vect()` is tested against exact values (x shorter, y shorter, equal length). `multinomial()` is tested on properties that must always hold: output length 4, no negative values, total ≤ pool size, and zero counts where the probability is zero. All tests pass.
- Committed the fixes and the tests separately from the original file, so the Git history shows exactly what I changed.

**What I learned about testing stochastic code**
- `set.seed()` fixes the starting point of R's pseudo-random number generator, so the same seed and the same calls always give identical results. I used this to test reproducibility. This will matter for the HPC runs (`set.seed(iter)`) and for Part 2, which must reproduce exactly the same figure every time.
- At first I thought that without resetting the seed the two results "will be different". In fact they are only *likely* to differ: with small integer counts they can match by chance. So a test asserting that they differ would be unreliable (a "flaky" test). Tests for stochastic functions should only check properties that are guaranteed.

**AI usage**
- Claude gave me the test file skeleton and the `sum_vect()` tests; I wrote the five `multinomial()` tests myself. I needed an explanation of `set.seed()` for the reproducibility test, and Claude pointed out the flaw in my answer about unseeded runs.

**Next:** Part 1 panel a — local time series comparing deterministic and stochastic runs from 100 and 10 adults.