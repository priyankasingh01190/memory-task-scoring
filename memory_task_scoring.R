# =====================================================================
# Recognition-memory task scoring in R
# Self-directed mini-project - Priyanka Singh
#
# What this does:
#   1. Loads trial-level data from a recognition ("old/new") memory task
#   2. For each participant, tabulates hits, misses, false alarms and
#      correct rejections
#   3. Computes signal detection theory (SDT) metrics: hit rate, false
#      alarm rate, d-prime (sensitivity) and criterion (response bias),
#      plus accuracy and mean reaction time
#   4. Saves a per-participant summary table and two plots
#
# Data: simulated recognition-memory dataset (for demonstration).
# Methods follow standard SDT scoring, with a log-linear correction for
# extreme rates (Hautus, 1995).
# =====================================================================

# ---- 0. Settings ----------------------------------------------------
infile <- "memory_task_sample.csv"
outdir <- "output"
if (!dir.exists(outdir)) dir.create(outdir)

# ---- 1. Load data ---------------------------------------------------
d <- read.csv(infile, stringsAsFactors = FALSE)
cat("Loaded", nrow(d), "trials from", length(unique(d$participant)), "participants\n")
# columns: participant, item_type ('old'/'new'), response ('old'/'new'),
#          correct (1/0), rt_ms

# ---- 2. Label each trial's SDT outcome ------------------------------
d$outcome <- with(d, ifelse(item_type == "old" & response == "old", "Hit",
                     ifelse(item_type == "old" & response == "new", "Miss",
                     ifelse(item_type == "new" & response == "old", "FA",
                                                                    "CR"))))

# ---- 3. Per-participant SDT scoring ---------------------------------
score_participant <- function(sub) {
  n_old <- sum(sub$item_type == "old")
  n_new <- sum(sub$item_type == "new")
  hits  <- sum(sub$outcome == "Hit")
  fa    <- sum(sub$outcome == "FA")

  # log-linear correction (avoids d' = infinity at 0/100% rates)
  HR  <- (hits + 0.5) / (n_old + 1)
  FAR <- (fa   + 0.5) / (n_new + 1)

  dprime    <- qnorm(HR) - qnorm(FAR)
  criterion <- -0.5 * (qnorm(HR) + qnorm(FAR))
  accuracy  <- mean(sub$correct)
  mean_rt   <- mean(sub$rt_ms[sub$correct == 1])   # RT on correct trials

  data.frame(
    participant = sub$participant[1],
    hit_rate    = round(HR, 3),
    fa_rate     = round(FAR, 3),
    dprime      = round(dprime, 3),
    criterion   = round(criterion, 3),
    accuracy    = round(accuracy, 3),
    mean_rt_ms  = round(mean_rt, 0)
  )
}

parts <- split(d, d$participant)
summary_tab <- do.call(rbind, lapply(parts, score_participant))
rownames(summary_tab) <- NULL

cat("\n=========== PER-PARTICIPANT SUMMARY (first 8) ===========\n")
print(head(summary_tab, 8), row.names = FALSE)

cat("\n---------------- GROUP AVERAGES ----------------\n")
cat(sprintf("Mean d-prime    : %.2f  (sensitivity; higher = better memory)\n",
            mean(summary_tab$dprime)))
cat(sprintf("Mean criterion  : %.2f  (bias; + = conservative, - = liberal)\n",
            mean(summary_tab$criterion)))
cat(sprintf("Mean accuracy   : %.1f %%\n", 100 * mean(summary_tab$accuracy)))
cat(sprintf("Mean RT (correct): %.0f ms\n", mean(summary_tab$mean_rt_ms)))

write.csv(summary_tab, file.path(outdir, "memory_task_summary.csv"), row.names = FALSE)

# ---- 4. Plot 1: distribution of d-prime across participants ---------
png(file.path(outdir, "dprime_distribution.png"), width = 950, height = 550, res = 110)
par(mar = c(5, 5, 3, 2))
hist(summary_tab$dprime, breaks = 8, col = rgb(0.15, 0.35, 0.7, 0.7),
     border = "white", xlab = "d-prime (sensitivity)",
     main = "Distribution of memory sensitivity (d-prime) across participants")
abline(v = mean(summary_tab$dprime), col = "darkorange", lwd = 3)
text(mean(summary_tab$dprime), par("usr")[4] * 0.9,
     labels = sprintf(" mean = %.2f", mean(summary_tab$dprime)),
     col = "darkorange", pos = 4, font = 2)
dev.off()

# ---- 5. Plot 2: mean RT by trial outcome ----------------------------
rt_by_outcome <- tapply(d$rt_ms, d$outcome, mean)
rt_by_outcome <- rt_by_outcome[c("Hit", "Miss", "FA", "CR")]
se_by_outcome <- tapply(d$rt_ms, d$outcome, function(x) sd(x)/sqrt(length(x)))
se_by_outcome <- se_by_outcome[c("Hit", "Miss", "FA", "CR")]

png(file.path(outdir, "rt_by_outcome.png"), width = 950, height = 550, res = 110)
par(mar = c(5, 5, 3, 2))
bp <- barplot(rt_by_outcome, col = rgb(0.15, 0.35, 0.7, 0.7), border = "white",
              ylim = c(0, max(rt_by_outcome + se_by_outcome) * 1.15),
              ylab = "Mean reaction time (ms)",
              names.arg = c("Hit", "Miss", "False alarm", "Correct rej."),
              main = "Reaction time by trial outcome")
arrows(bp, rt_by_outcome - se_by_outcome, bp, rt_by_outcome + se_by_outcome,
       angle = 90, code = 3, length = 0.05, col = "grey30")
dev.off()

cat("\nSaved: output/memory_task_summary.csv, output/dprime_distribution.png, output/rt_by_outcome.png\n")
cat("Done.\n")
