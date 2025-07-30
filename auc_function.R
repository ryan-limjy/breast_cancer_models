#function to compute AUC using PRS/Gail risk score on logistic regression model
#uses risk score both as a continuou variable and a binary variable (based on THRESHOLD )

auc.fun <- function(VAR,STATUS="status",DATASET,THRESHOLD=1.66){
  status=DATASET[,STATUS]
  var.con=DATASET[,VAR]
  summary(var.con)
  high=ifelse(var.con>=THRESHOLD,1,0)
  high <- factor(high,c(0,1))
  print(table(high))
  tab.out <- table(status,high)
  
  fit.con <- glm(status ~ var.con,family="binomial")
  summary(fit.con)
  pred <- predict(fit.con,type="response")
  ci.con <- ci(roc(status,pred))
  auc.con.out <- cbind("auc.con" =ci.con[2],
                       "lb.con" =ci.con[1],
                       "ub.con" =ci.con[3]) 
  
  auc.high.out <- cbind("auc.high" ="",
                        "lb.high" ="",
                        "ub.high" ="") 
  
  if(length(which(var.con>=THRESHOLD))>5){
    fit.high <- glm(status ~ high,family="binomial")
    summary(fit.high)
    summary(fit.high)
    pred <- predict(fit.high,type="response")
    ci.high <- ci(roc(status,pred))
    auc.high.out[,paste0(c("auc","lb","ub"),".high")] <- ci.high[c(2,1,3)]
  }
  
  out=list("auc.con"=auc.con.out,
           "auc.high"= auc.high.out,
           "tab.high"=tab.out)
  
  return(out)
}