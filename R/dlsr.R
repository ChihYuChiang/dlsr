#' @details
#' Compared to \code{rlassoEffects} function in the original \code{hdm}, \code{doubleLassoSelect} function in \code{dlsr} provides an alternative implementation of this specific method with the following benefits:
#' \enumerate{
#'   \item The \code{doubleLassoSelect} function accepts character vectors as variable input, instead of matrix indice or logical vectors. This improves code readability and facilitates batch implementation with external data source such as a csv.
#'   \item It Supports interaction terms as variable input. The \code{doubleLassoSelect} handles the matrix expansion for you.
#'   \item Instead of the result of a linear model, the \code{doubleLassoSelect} outputs a data frame (data.table) with the selected variables. This provides users more flexibility in subsequent operations, for example, applying the selected result further in a latent class model.
#' }
#'
#' @references
#' \itemize{
#'   \item A. Belloni, D. Chen, V. Chernozhukov, and C. Hansen (2012).Sparse models and methods for optimal instruments with an application to eminent domain. Econometrica 80 (6), 2369-2429.
#'   \item A. Belloni, V. Chernozhukov, and C. Hansen (2013). Inference for high-dimensional sparse econometricmodels. InAdvancesinEconomicsandEconometrics: 10thWorldCongress,Vol. 3: Econometrics, Cambirdge University Press: Cambridge, 245-295.
#'   \item A. Belloni, V. Chernozhukov, and C. Hansen (2014). Inference on treatment effects after selection among high-dimensional controls. The Review of Economic Studies 81(2), 608-650.
#'   \item O. Urminsky, C. Hansen, and V. Chernozhukov (working draft). Using Double-Lasso Regression for Principled Variable Selection.
#' }
#'
#' @keywords internal

"_PACKAGE"
