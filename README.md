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