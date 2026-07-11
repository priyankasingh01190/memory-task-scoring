# memory-task-scoring
# Recognition-memory task scoring in R - mini-project pack

Run a genuine learning-and-memory scoring analysis in R yourself, and
produce clean outputs (a per-participant SDT summary and two plots) for
your website and CV.

## Files
- `memory_task_sample.csv`    - simulated recognition ("old/new") task data
- `memory_task_scoring.R`     - the scoring script (base R, no extra packages)
- `output/` (example)         - what you'll produce
  - `memory_task_summary.csv`, `dprime_distribution.png`, `rt_by_outcome.png`

## What the analysis does (so you can explain it)
1. Loads trial-level data from a recognition memory task (each trial: was the
   item old or new, did the person respond old or new, correct?, reaction time).
2. Labels each trial as a Hit, Miss, False alarm, or Correct rejection.
3. Per participant, computes signal detection theory metrics:
   - Hit rate and false-alarm rate
   - d-prime (sensitivity - how well old is told from new)
   - criterion (response bias - liberal vs conservative)
   - accuracy and mean reaction time (correct trials)
   Uses the standard log-linear correction (Hautus, 1995) for extreme rates.
4. Saves a per-participant summary table and two plots.

## How to run it (step by step)
1. Put `memory_task_sample.csv` and `memory_task_scoring.R` in ONE folder.
2. Open `memory_task_scoring.R` in RStudio.
3. Session > Set Working Directory > To Source File Location.
4. Click Source (or run: source("memory_task_scoring.R") ).
5. Open the new `output/` folder for your summary CSV and two PNG plots.

