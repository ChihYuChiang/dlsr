% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dlsr.R
\docType{package}
\name{dlsr-package}
\alias{dlsr}
\alias{dlsr-package}
\title{dlsr: Double Lasso Selection}
\description{
The \code{doubleLassoSelect} function is an alternative implementation of Double Lasso Selection on OLS. This implementation is based primarily on package \code{glmet} and a paper of O. Urminsky, C. Hansen, and V. Chernozhukov (working draft), as listed in the reference.\cr\cr
For original implementation, please see \code{hdm} package by Chernozhukov, Hansen, and Spindler.
About the mathematical details of the method, please refer to the original papers listed in the reference section.
}
\details{
Compared to \code{rlassoEffects} function in the original \code{hdm}, \code{doubleLassoSelect} function in \code{dlsr} provides an alternative implementation of this specific method with the following benefits:
\enumerate{
  \item The \code{doubleLassoSelect} function accepts character vectors as variable input, instead of matrix indices or logical vectors. This improves code readability and facilitates batch implementation with external data source such as a csv.
  \item It Supports interaction terms as variable input. The \code{doubleLassoSelect} handles the matrix expansion for you.
  \item Instead of the result of a linear model, the \code{doubleLassoSelect} outputs a data frame (data.table) with the selected variables. This provides users more flexibility in subsequent operations, for example, applying the selected result further in a latent class model.
}
}
\references{
\itemize{
  \item A. Belloni, D. Chen, V. Chernozhukov, and C. Hansen (2012).Sparse models and methods for optimal instruments with an application to eminent domain. Econometrica 80 (6), 2369-2429.
  \item A. Belloni, V. Chernozhukov, and C. Hansen (2013). Inference for high-dimensional sparse econometricmodels. InAdvancesinEconomicsandEconometrics: 10thWorldCongress,Vol. 3: Econometrics, Cambirdge University Press: Cambridge, 245-295.
  \item A. Belloni, V. Chernozhukov, and C. Hansen (2014). Inference on treatment effects after selection among high-dimensional controls. The Review of Economic Studies 81(2), 608-650.
  \item O. Urminsky, C. Hansen, and V. Chernozhukov (working draft). Using Double-Lasso Regression for Principled Variable Selection.
}
}
\author{
\strong{Maintainer}: Chih-Yu Chiang \email{chihyuchiang@uchicago.edu}

}
\keyword{internal}
