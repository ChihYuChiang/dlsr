#--Function for updating lambda used in selection
#n = number of observation; p = number of independent variables; se = standard error of residual or dependent variable
updateLambda <- function(n, p, se) {se * (1.1 / sqrt(n)) * qnorm(1 - (.1 / log(n)) / (2 * p))}


#--Function for acquiring the indices of the selected variables in df_x
#df_x = matrix with only variables to be tested; y = dependent variable or treatment variables; lambda = the initial lambda computed in advance
acquireBetaIndices <- function(df_x, y, lambda, n, p, tk) {
  #glmnet accept only matrix not df
  df_x <- as.matrix(df_x)

  #Update lambda k times, k is selected based on literature
  k <- 1
  while(k <= tk) {
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
mainOperation <- function(df, outcome, treatment, test, k) {
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
  betaIndices <- acquireBetaIndices(df_x=df_test, y=c_outcome, lambda=lambda, n=n, p=p, tk=k)


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
      betaIndices <- union(betaIndices, acquireBetaIndices(df_x=df_test, y=c_treatment, lambda=lambda, n=n, p=p, tk=k))
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




#' A function implements the Double Lasso Selection
#'
#' This function implements Double Lasso Selection on a specified data frame, with specified treatment variables to be included in the final model and covariates to be tested via the selection process.
#' @param df Accepts \code{data.frame} and \code{data.table}. The data frame must contain all the variables specified in \code{outcome}, \code{treatment}, and \code{test}.
#' @param outcome Accepts single \code{character} value. It cannot be an empty character. The character specifies the outcome variable's name, which will be searched in the column names of provided data frame.
#' @param treatment
#'   Accepts single \code{character} value or a \code{character vector}. It specifies the treatment variable's name(s), which will be searched in the column names of provided data frame.
#'   The treatment variables are those variables will NOT go through the selection and will be included in the final output data set.
#'   This parameter accepts empty \code{character}, which implies no treatment variable to be included in the process.
#' @param test
#'   Accepts single empty \code{character} or a \code{character vector} with a length >= 2 (restricted by the \code{glmet} package). It specifies the test variable's name(s), which will be searched in the column names of provided data frame.
#'   The test variables are those covariates will go through the selection and may or may not be included in the final data set.
#'   This parameter accepts empty \code{character}, which implies performing selection on all variables except for the outcome and treatment variables.
#' @param k
#'   Accepts a \code{numeric} value. This is the number of times \code{lambda} being updated. The \code{lambda} here is a parameter used in lasso regression to represent the degree of regularization.
#'   You do not have to adjust this value in most situations. The default value is suggested by the paper specified in the package reference.
#' @return This function returns a data frame (\code{data.table}) with selected variables.
#' @keywords double lasso variable selection
#' @export
#' @examples
#' #Fetch data for demonstration
#' data(mtcars)
#'
#' #Input example 1:
#' #Character vectors as `treatment` and `test` input with an interaction term
#' outcome <- "mpg"
#' treatment <- c("cyl", "hp")
#' test <- c("drat", "disp", "vs", "cyl:hp")
#'
#' #Input example 2:
#' #Empty character as `treatment` and `test` input
#' outcome <- "mpg"
#' treatment <- ""
#' test <- ""
#'
#' #Acquire the selected data frame
#' DT_select <- doubleLassoSelect(df=mtcars, outcome=outcome, treatment=treatment, test=test)
#'
#' #Implement a linear model after the selection
#' model_lm <- lm(as.formula(sprintf("`%s` ~ .", outcome)), data=DT_select)
#' summary(model_lm)
#'
doubleLassoSelect <- function(df, outcome, treatment, test = NULL, k=15) {
  #Deal with all var as test
  if(is.null(test)) test <- names(df)[!(names(df) %in% union(outcome, treatment))]

  #Expand the data frame for interaction terms and processes variable names
  DT <- expandDt(outcome, treatment, test, as.data.table(df))

  #Perform selection and return
  DT_select <- mainOperation(df=DT, outcome=outcome, treatment=treatment, test=test, k=k)
  return(DT_select)
}
