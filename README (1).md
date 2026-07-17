# FIFA Player Ratings: Age, Potential, and Experience Analysis (SAS)

Statistical analysis of FIFA player data exploring how age relates to
overall rating, and whether a player's engineered "experience level" is
associated with their long-term potential. Originally completed as
coursework for Statistics 390 (Rutgers University).

## Question

1. Is there a linear relationship between a player's age and their
   overall rating?
2. Is a player's experience level (derived from age) associated with
   their potential classification?

## Data

- `fifa_cleaned.csv` — 20 players, columns: `index`, `full_name`, `age`,
  `overall_rating`
- Run the script from the same folder as the CSV (the script uses a
  relative filename).

## Methods

- Descriptive statistics and distribution diagnostics (`PROC MEANS`,
  `PROC UNIVARIATE`)
- One-sample t-tests on mean-centered age (vs. 25) and overall rating
  (vs. 70)
- Feature engineering: a `potential` score (`overall_rating + (30 - age)`)
  and an `experience_rating` (`age - 18`), each bucketed into categories
  (Low / Mid / High / Elite)
- Chi-square test of independence between experience group and
  potential class
- One-way ANOVA comparing mean potential across experience groups
- Paired t-test comparing potential scores between two randomly split
  halves of the sample (a sanity check for random-split bias)
- Pearson correlation among age, overall rating, potential, and
  experience rating

## Key Results

| Test | Result |
|---|---|
| Chi-square (experience group × potential class) | Not significant (p > 0.05) |
| ANOVA (potential across experience groups) | Not significant |
| Paired t-test (random split) | Fail to reject null — no artificial split bias |
| Correlation (age vs. overall rating) | Not significant — no clear linear relationship |

## Conclusion

In this sample of 20 players, age alone was not a statistically
significant predictor of overall rating, and grouping players by
experience level did not correspond to a significant difference in
potential classification. One important caveat: `potential` and
`experience_rating` are partly derived arithmetically from `age` and
`overall_rating`, so correlations among those four variables reflect
that construction rather than an independent finding — this is noted
directly in the script.

## Files

- `fifa_analysis.sas` — full analysis script
- `fifa_cleaned.csv` — dataset (20 players)
