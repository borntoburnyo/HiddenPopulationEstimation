
PMM_EM <- function(samples, K, lambda, pi, isdebug = FALSE) {
    # samples: (x1, x2, x3, x4, ..., xn) where xi is the count for ith person
    # K is the number of clusters
    # lambda (vector of length K) is the initial value of Poisson parameter
    # pi (vector of length K) is the initial probability for the ith person belonging to cluster j
    
    n <- length(samples) # number of people who have been surveyed at least once
    prob <- matrix(rep(0, n * K), nrow = n) # initialize latent variable
    epsilo <- 1e-3 # specify the accuracy
    
    step <- 0 # for counting
    iter <- TRUE # for iteration
    
    while (iter) { # iterate until converge
        # E step
        for (j in 1:K) {
            prob[, j] <- sapply(samples, dpois, lambda[j])
        }
        sumprob <- rowSums(prob)
        prob <- prob/sumprob
        
        # store old parameters
        old.lambda <- lambda 
        old.pi <- pi
        
        # M step
        for (j in 1:K) {
            lambda[j] <- sum(prob[ ,j] * samples) / sum(prob[ ,j]) # update lambda
            pi[j] <- sum(prob[ ,j])/n # update pi
        }
        
        step <- step + 1
        iter <-  (sum(abs(lambda - old.lambda)) > epsilo |
                      sum(abs(pi - old.pi)) > epsilo)
        
        if (isdebug)
            cat('step',step,'lambda', lambda,'pi',pi,'\n', sep = ' ')
    }
    data.frame(lambda = lambda, pi = pi)
}


### estimateN_PMM function estimate the population by using Poisson Mixture Model

estimateN_PMM <- function(samples, N_init, K, lambda_init, pi_init, isdebug = FALSE) {
    # samples: (x1, x2, x3, x4, ..., xn) where xi is the count for ith person
    # N_init: initial value of populuation N
    # K: the number of clusters
    # lambda_init (vector of length K): the initial value of Poisson parameter
    # pi_init (vector of length K): the initial probability for the ith person belonging to cluster j
    
    n <- length(samples)
    N_temp <- c(N_init, 0)
    
    step <- 0 # for counting
    iter <- TRUE # for iteration
    
    while (iter) { # iterate until converge
        N <- N_temp[1] 
        n0 <- N - n # find the number of people who have zero count
        p0_temp <- 0
        
        samples_temp <- c(rep(0, n0), samples) # create new samples with zeros
        
        # update Lambda and Pi by using EM algorithm
        LamPi_updates <- PMM_EM(samples_temp, K, lambda_init, pi_init) 
        p0_temp <- p0_temp + sum(LamPi_updates$pi * exp(-LamPi_updates$lambda))
        
        # update population N
        N_temp[2] <- N_temp[1]
        N_temp[1] <- n / (1 - p0_temp)
        
        iter <- (abs(N_temp[2] - N_temp[1]) > 0.1)
        
        step <- step + 1
        if (isdebug) print (c(step, ceiling(N_temp[1])))
    }
    ceiling(N_temp[1])
}
