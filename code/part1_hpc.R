# Part 1 panel b: stochastic simulations for the HPC
# Runs locally (from the repository root) or as a cluster array job.

rm(list = ls())
graphics.off()

## ---- where are we running? ----
iter <- as.numeric(Sys.getenv("PBS_ARRAY_INDEX"))
on_cluster <- !is.na(iter)
if (!on_cluster) iter <- 1   # local test: pretend to be job 1

if (on_cluster) {
  source("/rds/general/user/zq725/home/Demographic.R")
  output_dir <- ""
} else {
  source("code/Demographic.R")
  output_dir <- "data/"
}

set.seed(iter)   # a different seed for every job

## ---- parameters ----
growth_matrix <- matrix(c(0.1, 0.0, 0.0, 0.0,
0.5, 0.4, 0.0, 0.0,
0.0, 0.4, 0.7, 0.0,
0.0, 0.0, 0.25, 0.4),
nrow=4, ncol=4, byrow=T)
reproduction_matrix <- matrix(c(0.0, 0.0, 0.0, 2.6,
0.0, 0.0, 0.0, 0.0,
0.0, 0.0, 0.0, 0.0,
0.0, 0.0, 0.0, 0.0),
nrow=4, ncol=4, byrow=T)
projection_matrix = reproduction_matrix + growth_matrix
clutch_distribution <- c(0.06,0.08,0.13,0.15,0.16,0.18,0.15,0.06,0.03)

initial_sizes <- c(3, 10, 30, 100)
simulation_length <- 120
n_sims <- 40 # simulations per initial size in each job (as specified in the worksheet)

## ---- simulations ----
results <- list()
for (size in initial_sizes) {
  runs <- matrix(NA, nrow = n_sims, ncol = simulation_length + 1)
  for (j in 1:n_sims) {
    runs[j, ] <- stochastic_simulation(c(0, 0, 0, size), growth_matrix,
                                         reproduction_matrix, clutch_distribution,
                                         simulation_length)
  }
  results[[as.character(size)]] <- runs
}

## ---- save ----
if (on_cluster) {
  filename <- paste0(output_dir, "part1_hpc_output_", iter, ".rda")
} else {
  filename <- paste0(output_dir, "part1_local_test.rda")
}
save(results, initial_sizes, n_sims, simulation_length, iter, file = filename)