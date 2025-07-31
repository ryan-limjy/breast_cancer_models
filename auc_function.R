#AUC function used within main function below
get.auc <- function(MODEL, DATASET, VARY, DP = 3) {
  pred <- predict(MODEL, newdata = DATASET)
  roc_ci <- ci(roc(DATASET[[VARY]], pred))
  
  out <- data.frame(
    auc = roc_ci[2],
    lb = roc_ci[1],
    ub = roc_ci[3]
  )
  
  out$auc.ci <- paste0(
    round(out$auc, DP), " (",
    round(out$lb, DP), " to ",
    round(out$ub, DP), ")"
  )
  
  return(out)
}

# Function to fit logistic regression and return ORs, CIs, p-values, and optional AUC
#VARY = DCIS/invasive status
#VARX.LIST = list of covariates (can take in multiple covariates but only the risk score was used)
#formula for all OR other than interaction is glm(status ~ risk.score)
#interaction model: glm(status ~ risk.score * age.cat)

glm.out <- function(VARY, VARX.LIST, DATASET, GET.AUC = FALSE, DP.OR = 2, DP.AUC = 3) {
  formula_str <- paste0(VARY, " ~ ", paste0(VARX.LIST, collapse = " + "))
  fit <- glm(formula_str, family = "binomial", data = DATASET)
  
  out <- as.data.frame(summary(fit)$coefficients)
  out$or <- exp(out$Estimate)
  out$lb <- exp(out$Estimate - qnorm(0.975) * out$`Std. Error`)  
  out$ub <- exp(out$Estimate + qnorm(0.975) * out$`Std. Error`)
  
  out$orci <- paste0(
    round(out$or, DP.OR), " (",
    round(out$lb, DP.OR), " to ",
    round(out$ub, DP.OR), ")"
  )
  
  pvals <- out[, 4]
  out$p <- ifelse(pvals < 0.001, "<0.001", round(pvals, 3))
  
  if (GET.AUC) {
    auc_out <- get.auc(MODEL = fit, DATASET = DATASET, VARY = VARY, DP = DP.AUC)
    out$auc.ci <- ""
    out$auc.ci[2] <- auc_out$auc.ci
  }
  
  out <- cbind(variable = rownames(out), out)
  rownames(out) <- NULL
  return(out)
}

#Example usage
glm.out("status", "gail", data, GET.AUC = T)


