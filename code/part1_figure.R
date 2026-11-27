# Part 1 figure: panels a and b side by side
# Run from the repository root: source("code/part1_figure.R")

pdf("results/part1_figure.pdf", width = 10, height = 4.5)
par(mfrow = c(1, 2))
source("code/part1_panel_a.R")
source("code/part1_panel_b.R")
dev.off()