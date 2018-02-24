# dlsr: Double Lasso Selection

## Description
The `doubleLassoSelect` function is an alternative implementation of Double Lasso Selection on OLS. This implementation is based primarily on package `glmet` and a paper of O. Urminsky, C. Hansen, and V. Chernozhukov (working draft), as listed in the reference.

For original implementation, please see `hdm` package by Chernozhukov, Hansen, and Spindler. About the mathematical details of the method, please refer to the original papers listed in the reference section. 

## Details
Compared to `rlassoEffects` function in the original hdm, `doubleLassoSelect` function in `dlsr` provides an alternative implementation of this specific method with the following benefits:  
1. The `doubleLassoSelect` function accepts character vectors as variable input, instead of matrix indices or logical vectors. This improves code readability and facilitates batch implementation with external data source such as a csv.
1. It Supports interaction terms as variable input. The `doubleLassoSelect` handles the matrix expansion for you. 
1. Instead of the result of a linear model, the `doubleLassoSelect` outputs a data frame (`data.table`) with the selected variables. This provides users more flexibility in subsequent operations, for example, applying the selected result further in a latent class model.

## Author(s)
Maintainer: Chih-Yu Chiang chihyuchiang@uchicago.edu 

## References
- A. Belloni, D. Chen, V. Chernozhukov, and C. Hansen (2012).Sparse models and methods for optimal instruments with an application to eminent domain. Econometrica 80 (6), 2369-2429. 
- A. Belloni, V. Chernozhukov, and C. Hansen (2013). Inference for high-dimensional sparse econometricmodels. InAdvancesinEconomicsandEconometrics: 10thWorldCongress,Vol. 3: Econometrics, Cambirdge University Press: Cambridge, 245-295. 
- A. Belloni, V. Chernozhukov, and C. Hansen (2014). Inference on treatment effects after selection among high-dimensional controls. The Review of Economic Studies 81(2), 608-650. 
- O. Urminsky, C. Hansen, and V. Chernozhukov (working draft). Using Double-Lasso Regression for Principled Variable Selection.

## Installation
```
install.packages("devtools")  
devtools::install_github("ChihYuChiang/dlsr")
```

## Functions
```
doubleLassoSelect(df, outcome, treatment, test, k=15)
```

### Description
This function implements Double Lasso Selection on a specified data frame, with specified treatment variables to be included in the final model and covariates to be tested via the selection process.

### Arguments
Argument | Description
------- | ------
df | Accepts `data.frame` and `data.table`. The data frame must contain all the variables specified in outcome, treatment, and test.
outcome | Accepts single `character` value. It cannot be an empty `character`. The character specifies the outcome variable's name, which will be searched in the column names of provided data frame.
treatment | Accepts single `character` value or a `character vector`. It specifies the treatment variable's name(s), which will be searched in the column names of provided data frame. The treatment variables are those variables will NOT go through the selection and will be included in the final output data set. This parameter accepts empty `character`, which implies no treatment variable to be included in the process.
test | Accepts single empty `character` or a `character vector` with a length >= 2 (restricted by the `glmet` package). It specifies the test variable's name(s), which will be searched in the column names of provided data frame. The test variables are those covariates will go through the selection and may or may not be included in the final data set. This parameter accepts empty character, which implies performing selection on all variables except for the outcome and treatment variables.
k | Accepts a `numeric` value. This is the number of times `lambda` being updated. The `lambda` here is a parameter used in lasso regression to represent the degree of regularization. You do not have to adjust this value in most situations. The default value is suggested by the paper specified in the package reference.
-------

### Value
This function returns a data frame (`data.table`) with selected variables.

### Examples
```
#Fetch data for demonstration
data(mtcars)

#Input example 1:
#Character vectors as `treatment` and `test` input with an interaction term
outcome <- "mpg"
treatment <- c("cyl", "hp")
test <- c("drat", "disp", "vs", "cyl:hp")

#Input example 2:
#Empty character as `treatment` and `test` input
outcome <- "mpg"
treatment <- ""
test <- ""

#Acquire the selected data frame
DT_select <- doubleLassoSelect(df=mtcars, outcome=outcome, treatment=treatment, test=test)

#Implement a linear model after the selection
model_lm <- lm(as.formula(sprintf("`%s` ~ .", outcome)), data=DT_select)
summary(model_lm)
```