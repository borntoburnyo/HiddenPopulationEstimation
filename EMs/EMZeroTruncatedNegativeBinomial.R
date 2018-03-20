### set default initial parameters 
SIZE.INIT <- 1
MU.INIT <- 0.5

### termination conditions for EM algorithm
TOLERANCE <- 1e-5
ITER.TOLERANCE <- 5000

### density function of a truncated zero negative binomial distribution
### size and mu are two parameters for the negative binomial
zerotruncated.dnbinom <- function(x, size, mu, log = FALSE)
{
  ## the density of x in negative binomial
  p <- dnbinom(x, size = size, mu = mu, log = log)

  ## set zeros in x with zero probability
  if (log == FALSE) {
    p[ which(x == 0) ] <- 0
  } else {
    p[ which(x == 0) ] <- -Inf
  }

  ## the density of non-zero in negative binomial
  q <- 1 - dnbinom(0, size = size, mu = mu)

  ## normalize all non-zero values in negrative binomial to generate ZTNB
  if (log == FALSE) {
    return( p/q )
  } else {
    return( p - log(q) )
  }
}


### zerotruncated negative loglikelihood
zerotruncated.minus.log.likelihood <- function(n, size, mu)
{
  prob <- zerotruncated.dnbinom(n[, 1], size, mu, log = TRUE)

  ## negative loglikelihood
  prob <- -prob
  return( prob %*% n[, 2] )
}


### calculate the negative binomial loglikelihood
### zero.items is number of items unobserved
### size and mu are parameters in a negative binomial distribution
nb.loglikelihood <- function(n, zero.items, size, mu)
{
  ## likelihood of nonzero terms
  log.prob <- dnbinom(n[, 1], size = size, mu = mu, log = TRUE)
  loglikelihood <- log.prob %*% n[, 2]

  ## add items with zero count
  log.zero.prob <- dnbinom(0, size = size, mu = mu, log = TRUE)
  loglikelihood <- loglikelihood + zero.items * log.zero.prob

  return(loglikelihood)
}


### EM algorithm to fit the histogram with a negative binomial distribution
### hist only includes information for observation
### the number of unobserved items is missing data
ztnb.em <- function(n, size=SIZE.INIT, mu=MU.INIT)
{
  #checking.hist(n)

  n[, 2] <- as.numeric(n[, 2])
  ## setting the number of unobserved items as 0
  zero.prob <- exp(dnbinom(0, size = size, mu = mu, log = TRUE))

  ## estimate the total number of distinct items
  observed.items <- sum(n[, 2])
  L <- observed.items/( 1 - zero.prob )

  ## expected the number of unobservations
  zero.items <- L*zero.prob

  ## estimated mean and variance
  m <- (n[, 1] %*% n[, 2]) / L
  v <- ( (n[, 1] - m)^2 %*% n[, 2] + m^2 * zero.items )/(L - 1)

  ## target function f
  f <- function(x) {
        return( -nb.loglikelihood(n, zero.items, size = x, mu = m)/L )
  }

  ## derivative of f
  gr <- function(x)
  {
    first.term <- ( digamma(x) * zero.items +
                    digamma(n[, 1] + x) %*% n[, 2] )/L
    second.term <- digamma(x)
    third.term <- log(x) - log(x + m)
    result <- first.term - second.term + third.term
    # f is negative loglikelihood
    return(-result)
  }

  ## estimate size and mu based on first and second moments
  if (v > m) {
    res <- optim(m^2 / (v - m), f, gr, method = "L-BFGS-B",
           lower = 0.0001, upper = 10000)
  } else {
    res <- optim(size, f, gr, method = "L-BFGS-B",
           lower = 0.0001, upper = 10000)
  }

  ## count the times of iteration
  iter <- as.double(1)

  ## initialize the negative loglikelihood
  loglikelihood.pre <- Inf

  ## zerotruncated loglikelihood
  loglikelihood <- zerotruncated.minus.log.likelihood(n, res$par, m)

  ## EM algorithm
  while (( loglikelihood.pre - loglikelihood )/observed.items > TOLERANCE &&
           iter < ITER.TOLERANCE)
  {
    ## update negative loglikelihood
    loglikelihood.pre <- loglikelihood

    ## update parameters
    size <- res$par
    mu <- m

### E-step: estimate the number of unobserved items

    ## update the probility an item unobserved
    zero.prob <- exp(dnbinom(0, size = size, mu = mu, log = TRUE))

    ## estimate the total number of distinct items
    L <- observed.items/( 1 - zero.prob )

    ## update expected number of unobserved items
    zero.items <- L*zero.prob

    ## estimated mean and variance
    m <- (n[, 1] %*% n[, 2])/L
    v <- ( (n[, 1] - m)^2 %*% n[, 2] + m^2 * zero.items )/(L - 1)

### M step: estimate the parameters size and mu
    if (v > m) {
      res <- optim(m^2 / (v - m), f, gr, method = "L-BFGS-B",
             lower = 0.0001, upper = 10000)
    } else {
      res <- optim(size, f, gr, method = "L-BFGS-B",
             lower = 0.0001, upper = 10000)
    }
    iter <- iter + 1
    ## zerotruncated loglikelihood
    loglikelihood <- zerotruncated.minus.log.likelihood(n, res$par, m)
  }
  return(list(size = size, mu = mu, loglik = -loglikelihood.pre))
}

################################################################################

get_ztnb <- function(dat){
  # dat in count format
  dat = unname(dat)
  dat <- as.data.frame(table(dat))
  data <- matrix(c(dat$dat, dat$Freq), ncol = 2)
    
  # fit zero-truncated negative binomial model 
  # using E-M algorithm 
  fit <- ztnb.em(data)
  
  # calculate N_hat 
  N_hat <- sum(dat$Freq) / (1 - (fit$size / (fit$size + fit$mu))^fit$size)
  ceiling(N_hat)
}

# functions to get point estimate and confidence interval 

ztnb_boot <- function(N, n, clu, fre, B){
  dat <- sim_LabeledData(N, n, clu, fre)$sample %>% table()
  dat = unname(dat)
  dat <- as.data.frame(table(dat))
  data <- matrix(c(dat$dat, dat$Freq), ncol = 2)
  n_d <- sum(dat$Freq)
  
  # fit zero-truncated negative binomial model 
  # using E-M algorithm 
  fit <- ztnb.em(data)
  
  # calculate N_hat 
  N_hat <- sum(dat$Freq) / (1 - (fit$size / (fit$size + fit$mu))^fit$size)
  N_hat <- ceiling(N_hat)
  
  N_hat_boot <- numeric()
  n_d_boot <- numeric()
  
  for(i in 1:B){
    n_d_boot[i] <- rbinom(1, N_hat, n_d/N_hat)
    dat_B <- sim_LabeledData(N,n_d_boot[i],clu,fre) %>% sample() %>% table()
    N_hat_boot[i] <- get_ztnb(dat_B)
  }
  
  N_hat_low <- N_hat - 1.96*sd(N_hat_boot)
  N_hat_up <- N_hat + 1.96*sd(N_hat_boot)
  
  data.frame(N_hat = N_hat, 
             N_hat_low = N_hat_low, 
             N_hat_up = N_hat_up)
  
}