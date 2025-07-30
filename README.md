# PRS and Gail model evaluation by ethnicity and age

This repository contains code for evaluating the predictive performance of **Polygenic Risk Scores (PRS)** and the **Gail Model** in a large case-control cohort of women. The primary focus is to assess model discrimination and calibration across different ethnic and age groups.

## Summary

We examine how well PRS and Gail risk scores predict breast cancer status among women of varying backgrounds. We:

- Calculate **AUC** (Area Under the Curve) for different subgroups using logistic regression.
- Assess **calibration** using the `predtools` package, comparing observed versus predicted risk in other groups relative to a reference group (European women aged ≥50).


## File Overview

### 1. `auc_function.R`

This script contains the function used to calculate AUC and its 95% CI reported:

- Fit a logistic regression model:
  ```r
  glm(status ~ risk_score, family = binomial)
  ```
- Use `predict()` on the fitted model to obtain the predicted probability of event.
- Compute the AUC and 95% CI using the pROC package (`pROC::roc()`).
- The argument THRESHOLD creates an alternative binary risk score variable, where individuals grouped 1 if their risk score exceed THRESHOLD and 0 otherwise. This binary risk score variable's AUC and corresponding CIs are also reported by the function.
- While not in the script, the odds ratio presented in Figure 2 are derived from the same logistic model.

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
- Gail risk scores were calculated using the `BRCA::absolute.risk` function from the R package `BRCA`. Example data for testing is provided within the package (`BRCA::exampledata`).

- The interaction models used in Figure 2 uses the formula
```{r}
glm(status ~ risk score * age_group)
```
where age_group is a binary indicator for <50 or ≥50 years of age.



