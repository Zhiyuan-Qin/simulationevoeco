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
| 1 | `code/part1_panel_a.R` | Panel a: local time-series simulation (deterministic vs stochastic) |
| 1 | `code/part1_hpc.R`, `code/part1_hpc.sh` | Panel b: simulation script and PBS array job script (`qsub -J 1-20`) for the HPC |
| 1 | `code/part1_panel_b.R` | Reads the HPC output in `data/`, estimates extinction probabilities with 95% CIs, plots panel b |
| 1 | `code/part1_figure.R` | **Reproduces the Part 1 figure**: runs both panel scripts and saves `results/part1_figure.pdf` |
| 2 | TODO | Neutral model; reproduces the Part 2 figure in under one minute |
| 3 | TODO | Microproject |

## Testing

Tests live in `code/` (e.g. `code/test_demographic.R`) and can be run with `source()`.

- **Deterministic functions** are tested against exact expected values.
- **Stochastic functions** are tested on properties that must always hold (output length, non-negative counts, totals not exceeding the input pool), and for reproducibility using `set.seed()`.

## HPC runs

The shell script is in `code/`. The results of the 20 array jobs (job 42037) are in `data/part1_hpc_output_*.rda`, and three sample `.e` and `.o` files are in `data/hpc_logs/`.

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

### 2026-11-23 14:10

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

### 2026-11-23 14:39

**Plan for Part 1 panel a (before writing the code)**
- Script `code/part1_panel_a.R`: source `Demographic.R`, define the matrices and clutch distribution, set a fixed seed, then for each initial state (`c(0,0,0,100)` and `c(0,0,0,10)`) run the deterministic model once and the stochastic model 5 times for 24 steps.
- Plot: time 0–24 on the x-axis, total population on a log y-axis; red = 100 adults, blue = 10 adults; solid = deterministic, dashed = stochastic. Save as a PDF in `results/`.
- Number of stochastic runs: about 5 per initial condition. Too many lines would make the plot unreadable; too few would not show how variable the runs are. I will use a fixed seed and not re-run to pick a "nice-looking" set.

**Predictions (before running)**
- Stochastic runs should fluctuate around the deterministic line, because the stochastic model has the same expected values.
- Runs starting from 10 adults should spread out much more than runs from 100, because random births and deaths matter more in a small population.
- Because the deterministic model is linear, the run from 10 adults should be exactly 1/10 of the run from 100, so the two solid lines should be parallel on the log scale.
- Some runs from 10 adults may go extinct within 24 steps. Zero cannot be shown on a log axis, so I plan to replace 0 with `NA` (so the line stops) and mark the extinction with a symbol, rather than plotting log(N+1), which would change the meaning of the axis.

**AI usage**
- Discussed these predictions with Claude. My own answers were that the 10-adult runs would spread more, that extinction was possible and needed separate handling, and that about 5 runs was a sensible number. Claude explained why (relative fluctuations scale roughly as 1/√N), pointed out the parallel deterministic lines, and compared three ways to handle zeros on a log axis.

### 2026-11-23 19:00

**Part 1 panel a — results vs predictions**
- Wrote `code/part1_panel_a.R` and saved the figure to `results/part1_panel_a.pdf`.
- Checked the deterministic runs before plotting: 100 → 300 → 276 and 10 → 30 → 27.6, and `det_small / det_large` is exactly 0.1 at every step. This confirms my prediction that the two deterministic lines are parallel on the log scale.
- As predicted, the stochastic runs fluctuate around the deterministic lines, and the runs from 10 adults spread out much more (39 to 126 at step 24, compared with 46.6 for the deterministic run) than the runs from 100 adults.
- None of the 5 runs from 10 adults went extinct with `set.seed(1)`. Five runs are far too few to estimate how likely extinction is; panel b, with 800 runs per initial size on the HPC, will answer that. I did not change the seed to force an extinction into the figure. The code still replaces zeros with `NA`, so it will handle extinctions if they occur.
- Unexpected result: the deterministic population falls from 300 to about 195 over steps 1–4, even though the long-run growth rate is above 1 (λ ≈ 1.039). This is a transient effect. Starting with only adults produces a pulse of newborns at step 1, many of which die before maturing, so the population declines until the stage structure settles and steady growth begins. This could be a good finding to discuss in the report.

**Figure quality**
- First version: the legend covered the red lines. I raised the upper y-limit (×4 rather than a fixed amount, because on a log scale multiplying gives a constant visual gap), added a title and horizontal axis labels (`las = 1`).
- Learned to use `pdf()` and `dev.off()`, and to check the saved PDF rather than the RStudio plot pane, because the size and layout differ.
- To do when combining with panel b: replace "Panel a)" in the title with a corner label, and possibly reduce the empty space above the lines.

**Note**
- In an earlier commit today I also corrected a typo (a full-width colon) in the heading of the 14:10 entry; no content was changed. From now on I will not edit earlier entries.

**AI usage**
- Claude provided the plotting skeleton; I filled in the blue lines and the second deterministic line. I fixed a missing-comma syntax error after Claude explained how to read R's "unexpected symbol" message.
- Claude explained the transient decline (stable stage distribution) after I had noticed the numbers going down.

**Next:** Part 1 panel b — write and test locally the simulation script for the HPC.

### 2026-11-24 20:16

**Plan for Part 1 panel b (before writing the code)**
- Script `code/part1_hpc.R`, written so it can run both locally and on the HPC:
  - clear the workspace, source `Demographic.R`, define the matrices and clutch distribution;
  - read `iter` from `PBS_ARRAY_INDEX`; if it is `NA` (running locally), set `iter <- 1`;
  - `set.seed(iter)` so that each of the 20 jobs uses a different seed. If every job used the same seed, the 20 jobs would produce identical results, so the 800 "runs" per initial size would really be only 40 distinct runs repeated 20 times;
  - for each initial size (3, 10, 30, 100 adults), run 40 stochastic simulations of 120 steps;
  - save the results to `part1_hpc_output_<iter>.rda`.
- What to save: the full time series of every run, not only the final size. This allows me to look at *when* extinctions happen as well as whether they happen. Size estimate: 160 runs × 121 values × 8 bytes ≈ 155 KB per job, about 3 MB for all 20 jobs, so well under the 10 MB limit.
- Local testing: first run with a small number of simulations to catch bugs quickly; then run one full job locally with `system.time()` to estimate how long each HPC job will take.
- Afterwards, a separate script will read the 20 RDA files and compute the proportion of runs that are extinct at step 120 for each initial size.

**Predictions (before running)**
- Extinction probability will decrease as initial size increases.
- With only 3 adults it should be substantial (perhaps tens of percent), smaller with 10, and close to zero with 30 and 100.
- Most extinctions should happen early: once the population has grown, λ > 1 makes it increasingly safe.

**AI usage**
- Discussed the design with Claude. My answers: extinction decreases with size and happens early; save full series vs final value as a trade-off; test locally on fewer runs first; different seeds because the same seed gives identical results. Claude corrected my first prediction (I had said all four would be near 0), pointed out that memory is not the real reason for a small local test (speed of debugging is), and estimated the RDA size.

### 2026-11-25 22:47

**Part 1 panel b — writing and testing the HPC script locally**
- Wrote `code/part1_hpc.R`. It detects whether it is running on the cluster (`PBS_ARRAY_INDEX` set) or locally (`NA`, so `iter` is set to 1), and chooses the path to `Demographic.R` and the output folder accordingly.
- First test with `n_sims <- 2` to find bugs quickly. Two bugs: in both, the code ran without errors but the results were wrong. Both were found by checking that step 0 of every run equals the initial size:
  1. I passed the whole vector `initial_sizes` as the initial state, so every run started at 143 (= 3 + 10 + 30 + 100).
  2. I then used `initial_sizes[j]`, but `j` counts the runs, not the initial sizes, so runs started at 3 and 10 whatever the intended size. It was also a single number instead of a 4-stage state vector. The fix was `c(0, 0, 0, size)`.
- Lesson: code that runs without errors can still be wrong, so I will keep checking simple facts about the output (such as the value at step 0).
- Then ran one full job locally (40 runs × 4 sizes × 120 steps): about 5 seconds with `system.time()`, so a 30-minute walltime on the HPC will be plenty.
- Proportion extinct at step 120 in this single local job: 0.400 (3 adults), 0.075 (10), 0 (30), 0 (100). This matches my revised prediction, but 40 runs per size is too few for a reliable estimate. The 800 runs from the HPC will give the real answer.
- Found a file-name clash: the local test (`iter = 1`) would have written the same file as HPC job 1. The local test now saves to `data/part1_local_test.rda`, which is git-ignored.
- Removed the temporary `n_sims <- 2` line rather than leaving commented-out code.

**AI usage**
- Claude provided the script skeleton; I wrote the simulation loop. Claude spotted from my `str()` output that runs started at 143 and hinted at the cause. I attempted a fix (`initial_sizes[j]`), which was still wrong, and Claude explained how to read `str()` output column by column and why `j` was the wrong index.
- Claude also pointed out the file-name clash and suggested the `.gitignore` entry.
- Learned that the HPC path uses my short username without "@".

**Next:** write the `.sh` job script, log in to the HPC, and run a first test there.

### 2026-11-26 22:34

**First run on the HPC**
- Logged in to `login.cx3.hpc.imperial.ac.uk` for the first time. `echo $HOME` gave `/rds/general/user/zq725/home`, which matches the path to `Demographic.R` in `part1_hpc.R`.
- `module spider R/4.4.1-gfbf-2023b` showed that `tools/prod` must be loaded before R. Neither the classmate's Canvas post nor the course handouts mention this. Tested `module load tools/prod` then `module load R/4.4.1-gfbf-2023b` on the login node (`R --version` gave 4.4.1) and added both lines to `code/part1_hpc.sh`. The HPC runs R 4.4.1, while I use 4.6.1 locally; my code only uses base R, so this should not matter.
- Adapted the shell script from the Practical 1 template: replaced `anaconda3/personal` with the two `module load` lines, set walltime to 30 minutes (one job takes ~5 s locally), and removed the `mv` line because jobs now run in `$HOME`.
- Uploaded `Demographic.R`, `part1_hpc.R` and `part1_hpc.sh` with `scp`, then submitted a small test of 2 jobs (`qsub -J 1-2`) before the full 20.
- Job status went Q (queued) → B (array begun) → X (sub-job finished). X only means "finished", not "succeeded", so I checked the output of sub-job 1: the `.o` file starts with "R is about to run" and ends with "R has finished running", the `.e` file is empty (0 bytes), and `part1_hpc_output_1.rda` (~40 KB) appeared in `$HOME`. Since the script saves with no folder prefix on the cluster, this shows the job's working directory is `$HOME`.

**Code for panel b (written while waiting)**
- Wrote `code/part1_panel_b.R`, which reads all HPC result files and estimates the extinction probability for each initial size.
- Files are found with `list.files(pattern = "^part1_hpc_output_.*\\.rda$")`. My first idea, `"\\.rda$"`, would also have matched the local test file and mixed it into the results.
- The script adds up the number of extinctions and the number of runs across all files, then divides. This gives the same answer as averaging per-job proportions only when every job has the same number of runs; adding counts is correct in all cases. It also prints how many files were found, so a missing job will be noticed.
- Plan for the figure: log-scaled x-axis (3, 10, 30, 100 are roughly evenly spaced on a log scale), y-axis from 0 to 1 on a linear scale (probabilities of 0 cannot be shown on a log axis), and points with 95% confidence intervals rather than a line, because there are no results between the four sizes and each value is an estimate from 800 runs.

**Problem: no access from home**
- The HPC can only be reached from the Imperial network. Off campus, students need VPN or Unified Access (Zscaler), which must be requested from the ICT Service Desk. I have applied for Zscaler. The test results stay on the HPC until I can download them.

**AI usage**
- Claude provided the shell script with an explanation of each line and spotted the `tools/prod` requirement in the `module spider` output. It explained the PBS status codes (B, X), how to check `.o` and `.e` files, and why the remote path in `scp` must be quoted in zsh.
- For panel b, Claude made my file pattern more specific, confirmed my answer about adding counts and explained when it matters, and suggested points with confidence intervals instead of my proposed line plot.

**Next:** download the 2 test results on campus, test `part1_panel_b.R` on them (expect 2 files and 80 runs per size), then submit the full 20 jobs.
