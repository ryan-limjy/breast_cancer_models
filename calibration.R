##Example calculation/plots of calibration and mROC diganostics

#Reference model
ref_model = glm(status ~ gail, family = binomial, data = eu_50plus)
eu_50plus$gail_pred <- predict.glm(ref_model_gail, type = 'response')
ref_gail_roc = roc(response=eu_50plus[,'status'], predictor=eu_50plus$gail_pred)

#External dataset
eu_50below$gail_pred <- predict.glm(ref_model_gail, newdata = eu_50below, type = 'response')

#function to plot mROC + ROC plots and calculate p-values
plot_mROC_with_pvals_gg <- function(varname, title, ref_roc = ref_gail_roc, show.legend = FALSE, predictor = "gail_pred") {
  # Compute ROC and mROC
  var_roc <- roc(response = varname$status, predictor = varname[,predictor])
  var_mroc <- mROC(p = varname[,predictor])
  var_p <- mROC_inference(varname$status, varname[,predictor])
  
  A <- var_p$pvals[["A"]]
  B <- var_p$pvals[["B"]]
  U <- var_p$pval
  
  # Extract ROC coords
  roc_df <- data.frame(
    FPR = 1 - var_roc$specificities,
    TPR = var_roc$sensitivities,
    Curve = "ROC"
  )
  
  # Extract mROC coords
  mroc_df <- data.frame(
    FPR = var_mroc$FPs,
    TPR = var_mroc$TPs,
    Curve = "mROC"
  )
  
  # Extract ref ROC
  ref_df <- data.frame(
    FPR = 1 - ref_roc$specificities,
    TPR = ref_roc$sensitivities,
    Curve = "Reference (European, ≥50y)"
  )
  
  # Combine
  plot_df <- bind_rows(roc_df, mroc_df, ref_df)
  
  # Base plot
  p <- ggplot(plot_df, aes(x = FPR, y = TPR, color = Curve)) +
    geom_line(linewidth = 1) +
    scale_x_continuous(
      trans = "identity",
      breaks = seq(0, 1, 0.2),
      labels = rev(seq(0, 1, 0.2))
    ) +
    scale_color_manual(values = c("Reference (EU 50+)" = "black", "ROC" = "blue", "mROC" = "red")) +
    theme_minimal(base_size = 14) +
    ggtitle(title) +
    xlab("Specificity") +
    ylab("Sensitivity") +
    coord_equal()
  
  return(list(plot = p, pvals = c(A = A,B = B,U = U)))
}

#calibration plot (CI per decile)
cplot = function(varname, title, predictor = "gail_pred"){
  tmp = bind_rows(eu_50below, eu_50plus, asian_50below, asian_50plus)
  tmp = tmp %>% filter(Group %in% c("Ref", varname))
  plot = calibration_plot(data = tmp, obs = "status", pred = predictor, y_lim = c(0.25, 0.8), x_lim=c(0.25, 0.8),
                          title = title, group = "Group")
  return(plot)
}

#example usage
plot_mROC_with_pvals_gg(eu_50below, title = "European, <50y")$plot
plot_mROC_with_pvals_gg(asian_50below, title = "Asian, <50y", predictor = "prs_pred")$pvals
cplot("European, <50y", "")[[1]] #calibration_plot object stores the plot in a list
