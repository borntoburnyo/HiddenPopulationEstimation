library("plyr")
library("dplyr")

### The function "estimate_N" computes N_hat for simple Poisson process

estimate_N <- function(x, is.counts = TRUE) {
    # the input sample x could be in the form of original data ('a', 'b', 'c', 'b', 'a', 'b') 
    # or Poisson counts (4, 2, 3, 2, 1)
    # is.counts indicates what kind of input it is (TRUE for Poisson counts)
    
    if (!is.counts) # if the input is in the form of original data, then convert to counts
        x <- as.data.frame(table(x))$Freq
    
    S <- sum(x) 
    n <- length(x)
    
    N_hat <- n # initialize N_hat
    temp <- 0
    
    while (abs(N_hat - temp) >= 10e-5) { # iterate until the convergence of N_hat
        temp <- N_hat    
        lambda_hat <- S / N_hat # compute lambda
        p0_hat <- exp(-lambda_hat) # compute p0
        N_hat <- n / (1 - p0_hat) # compute new N_hat
    }
    
    ceiling(N_hat)
}
