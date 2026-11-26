# Part 1 panel b: read HPC output and estimate extinction probabilities
# Run from the repository root: source("code/part1_panel_b.R")

rm(list = ls())

files <- list.files("data", pattern = "^part1_hpc_output_.*\\.rda$", full.names = TRUE)
cat("Found", length(files), "result files\n")

sizes <- c(3, 10, 30, 100)
n_extinct <- c(0, 0, 0, 0)   # running totals, one per initial size
n_total   <- c(0, 0, 0, 0)

for (f in files) {
  load(f)   # creates 'results' (a list of 4 matrices)
  for (k in 1:4) {
    final_sizes <- results[[as.character(sizes[k])]][, 121]   # population at step 120
    n_extinct[k] <- n_extinct[k] + sum(final_sizes == 0)
    n_total[k] <- n_total[k] + length(final_sizes)
  }
}

p_extinct <- n_extinct / n_total
print(data.frame(initial_size = sizes, n_extinct, n_total, p_extinct))