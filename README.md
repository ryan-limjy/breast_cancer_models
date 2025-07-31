# PRS and Gail model evaluation by ethnicity and age

This repository contains code for evaluating the predictive performance of **Polygenic Risk Scores (PRS)** and the **Gail Model** in a large case-control cohort of women. The primary focus is to assess model discrimination and calibration across different ethnic and age groups.

## Summary

We examine how well PRS and Gail risk scores predict breast cancer status among women of varying backgrounds. We:

- Calculated the Gail risk score for the sample using the R package `BRCA`
- Computed polygenic risk scores (PRS) from imputed genotype using PLINK2
- Calculated **AUC** (Area Under the Curve) for different subgroups using logistic regression.
- Plotted AUC curves based on different threshold for both risk scores
- Assessed **calibration** using the `predtools` package, comparing observed versus predicted risk in other groups relative to a reference group (European women aged ≥50).


## File Overview

### 1. Gail risk score

The gail risk score was computed using the function `BRCA::absolute.risk`. An example dataset is given within the same package with the function `exampledata`. For Figure 3 where we look at risk factors included, factors that were not considered were set to 99 (unknown).

### 2. Polygenic risk score

The polygenic risk score (PRS) was derived using the `.txt` pipeline contained within the PRS folder. Within, it has:
- A `.score` file contatining variant weights derived from GWAS summary statistics
- A `.txt` bash script that runs PRS computation using PLINK2's `--score` across ancestries
- Scoring for overall, ER-positive and ER-negative risk models
- Removal of duplicated samples across arrays
- Aggregation of ancestry-specific results into unified PRS profiles for downstream analysis

### 3. `auc_function.R`

This script contains functions used in calculating the 95% confidence intervals of the odds ratio and AUC reported. It includes:

- `glm.out()`: Fits the logistic regression model `glm(status ~ risk.score)` and returns odds ratios (OR), 95% confidence intervals, and p-values.
- `get.auc()`: Optionally computes the Area Under the Curve (AUC) and its 95% CI using the `pROC` package, for model discrimination.

### 2. `calibration.R`

This script contains the function used to generate calibration plots and p-values using the R package `predtools`.

- Fit a **reference model** with the group of European women aged above 50y.

- Apply that model to:
  - The reference model (for empirical ROC)
  - Other subgroups (for ROC and model-based ROC [mROC] using `predtools::mROC`).

Outputs include: 
- ROC and mROC curves.
- p-values from `mROC_inference()`
- Calibration plots using `calibration_plot()`, stratified by deciles


### Additional Notes

- The interaction models used in Figure 2 uses the formula
```{r}
glm(status ~ risk score * age_group)
```
where age_group is a binary indicator for <50 or ≥50 years of age.



