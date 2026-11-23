# Part 1 panel a: deterministic vs stochastic time series
# Run from the repository root: source("code/part1_panel_a.R")

rm(list = ls())
source("code/Demographic.R")

## ---- parameters (from "matrix info for part 1.pdf") ----
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
projection_matrix <- growth_matrix + reproduction_matrix
clutch_distribution <- c(0.06,0.08,0.13,0.15,0.16,0.18,0.15,0.06,0.03)

simulation_length <- 24
initial_large <- c(0, 0, 0, 100)   # 100 adults
initial_small <- c(0, 0, 0, 10)    # 10 adults

## ---- deterministic runs ----
det_large <- deterministic_simulation(initial_large, projection_matrix, simulation_length)
det_small <- deterministic_simulation(initial_small, projection_matrix, simulation_length)

## ---- stochastic runs ----
n_runs <- 5
set.seed(1)   # fixed seed so the figure is reproducible

# empty matrices: one row per run, one column per time step (0..24)
stoch_large <- matrix(NA, nrow = n_runs, ncol = simulation_length + 1)
stoch_small <- matrix(NA, nrow = n_runs, ncol = simulation_length + 1)

for (i in 1:n_runs) {
  stoch_large[i, ] <- stochastic_simulation(initial_large, growth_matrix,
                                            reproduction_matrix, clutch_distribution,
                                            simulation_length)
  stoch_small[i, ] <- stochastic_simulation(initial_small, growth_matrix,
                                            reproduction_matrix, clutch_distribution,
                                            simulation_length)
}

## ---- plot ----
# zeros cannot be shown on a log axis: replace with NA so the line stops
stoch_large[stoch_large == 0] <- NA
stoch_small[stoch_small == 0] <- NA

time <- 0:simulation_length
all_values <- c(det_large, det_small, stoch_large, stoch_small)
y_limits <- c(min(all_values, na.rm = TRUE), max(all_values, na.rm = TRUE) * 4)

# semi-transparent colours for the stochastic runs
red_light  <- adjustcolor("red",  alpha.f = 0.5)
blue_light <- adjustcolor("blue", alpha.f = 0.5)

pdf("results/part1_panel_a.pdf", width = 7, height = 5)
# empty plot with log y-axis
plot(NA, xlim = range(time), ylim = y_limits, log = "y", las = 1,
     xlab = "Time step", ylab = "Total population size (log scale)",
     main = "Panel a) Deterministic vs stochastic dynamics")

# stochastic runs: dashed
for (i in 1:n_runs) {
  lines(time, stoch_large[i, ], col = red_light, lty = 2)
  lines(time, stoch_small[i, ], col = blue_light, lty = 2)
}

# deterministic runs: solid and thicker, drawn last so they sit on top
lines(time, det_large, col = "red", lwd = 2)
lines(time, det_small, col = "blue", lwd = 2)

legend("topleft",
       legend = c("100 adults, deterministic", "100 adults, stochastic",
                  "10 adults, deterministic",  "10 adults, stochastic"),
       col = c("red", red_light, "blue", blue_light),
       lty = c(1, 2, 1, 2), lwd = c(2, 1, 2, 1), bty = "n")
dev.off()