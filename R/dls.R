#--Function for updating lambda used in selection
#n = number of observation; p = number of independent variables; se = standard error of residual or dependent variable
updateLambda <- function(n, p, se) {se * (1.1 / sqrt(n)) * qnorm(1 - (.1 / log(n)) / (2 * p))}


#--Function for acquiring the indices of the selected variables in df_x
#df_x = matrix with only variables to be tested; y = dependent variable or treatment variables; lambda = the initial lambda computed in advance
acquireBetaIndices <- function(df_x, y, lambda, n, p) {
  #glmnet accept only matrix not df
  df_x <- as.matrix(df_x)

  #Update lambda k times, k is selected based on literature
  k <- 1
  while(k < 15) {
    model_las <- glmnet(x=df_x, y=y, alpha=1, lambda=lambda, standardize=TRUE)
    beta <- coef(model_las)
    residual.se <- sd(y - predict(model_las, df_x))
    lambda <- updateLambda(n=n, p=p, se=residual.se)
    k <- k + 1
  }

  #Return the variable indices with absolute value of beta > 0
  return(Matrix::which(abs(beta) > 0))
}


#--Function to perform double lasso selection
#output = a new df with variables selected
mainOperation <- function(df, outcome, treatment, test) {
  #--Setting up
  #Produce necessary data structures
  ytreatment <- union(outcome, treatment[treatment != ""])
  df_ytreatment <- df[, ..ytreatment]
  df_test <- df[, ..test]
  c_outcome <- df[[outcome]]

  #The number of observations
  n <- nrow(df_test)

  #The number of variables to be tested
  p <- ncol(df_test)


  #--Select vars that predict outcome
  #Lambda is initialized as the se of residuals of a simple linear using only treatments predicting dependent variable
  #If the treatment var is NULL, use the se pf dependent var to initiate
  residual.se <- if(ncol(df_ytreatment) == 1) {sd(c_outcome)} else {sd(residuals(lm(as.formula(sprintf("`%s` ~ .", outcome)), data=df_ytreatment)))}
  lambda <- updateLambda(n=n, p=p, se=residual.se)

  #by Lasso model: dependent variable ~ test variables
  betaIndices <- acquireBetaIndices(df_x=df_test, y=c_outcome, lambda=lambda, n=n, p=p)


  #--Select vars that predict treatments
  #Each column of the treatment variables as the y in the Lasso selection
  #Starting from 2 because 1 is the dependent variable
  if(ncol(df_ytreatment) != 1) { #Run only when treatment vars not NULL
    for(i in seq(2, ncol(df_ytreatment))) {
      #Acquire target treatment variable
      c_treatment <- df_ytreatment[[i]]

      #Lambda is initialized as the se of the target treatment variable
      c_treatment.se <- sd(c_treatment)
      lambda <- updateLambda(n=n, p=p, se=c_treatment.se)

      #Acquire the indices and union the result indices of each treatment variable
      betaIndices <- union(betaIndices, acquireBetaIndices(df_x=df_test, y=c_treatment, lambda=lambda, n=n, p=p))
    }
  }


  #Process the result indices to remove the first term (the intercept term)
  betaIndices <- setdiff((betaIndices - 1), 0)

  #Bind the selected variables with dependent and treatment variables
  df_selected <- if(nrow(df_test[, ..betaIndices]) == 0) df_ytreatment else cbind(df_ytreatment, df_test[, ..betaIndices])

  #Return a new df with variables selected
  return(df_selected)
}

#--Identify vars to be processed
#Function to make obj expression of a string vector
objstr <- function(ss) {
  ss_obj <- character()
  for(s in ss) ss_obj <- c(ss_obj, sub(":", "`:`", sprintf("`%s`", s)))
  return(ss_obj)
}

#Function to remove obj expression of a df
deobjdf <- function(df) {
  ss_deobj <- character()
  for(s in names(df)) ss_deobj <- c(ss_deobj, gsub("`", "", x=s))
  names(df) <- ss_deobj
  return(df)
}

#Function to produce expanded dts
expandDt <- function(outcome, treatment, test, DT) {
  output <- sprintf("~%s", paste(union(treatment[treatment != ""], test) %>% objstr, collapse="+")) %>%
    as.formula %>%
    model.matrix(data=DT) %>%
    as.data.table %>%
    deobjdf %>%
    cbind(DT[, outcome, with=FALSE])
  output[, -1] #-1 to remove the intersection term created by matrix
}




#' A Cat Function
#'
#' This function allows you to express your love of cats.
#' @param df Do you love cats? Defaults to TRUE.
#' @param outcome gg
#' @param treatment sss
#' @param test sss
#' @keywords cats
#' @return gggg
#' @export
#' @examples
#' data(mtcars)
#' outcome <- "mpg"
#' treatment <- ""
#' test <- ""
#' DT_select <- doubleLassoSelect(df=mtcars, outcome=outcome, treatment=treatment, test=test)
#'
#' #Result
#' model_lm <- lm(as.formula(sprintf("`%s` ~ .", outcome)), data=DT_select)
#' summary(model_lm)
doubleLassoSelect <- function(df, outcome, treatment, test) {
  #Deal with all var as test
  if(test == "") test <- names(df)[!(names(df) %in% union(outcome, treatment))]

  DT <- expandDt(outcome, treatment, test, as.data.table(df))
  DT_select <- mainOperation(df=DT, outcome=outcome, treatment=treatment, test=test)
}


