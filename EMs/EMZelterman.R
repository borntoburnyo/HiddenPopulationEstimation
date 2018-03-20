# Zelterman estimate with confidence interval 

Zelter <- function(dat){
  # dat is in count format##
  # for further bootstrap usage###
  Q <- 0 # initialize the zero-class frequency
  N_hat <- 0 # initialize population size

  dat = unname(dat)
  data <- as.data.frame(table(dat))
    
  # update Zelterman estimate for zero-class frequency 
  # Q_j = exp[-(j+1) * f_{j+1} / f_j]
  # choose j = 1
  Q <- exp(-2 * data$Freq[2] / data$Freq[1])
  N_hat <- sum(data$Freq) / (1 - Q)
  N_hat <- ceiling(N_hat)  
  N_hat
  
  # calculate variance of Q
  # var(Q) = Q_hat * (1-Q_hat) * log(1/Q_hat) / n
  Var_Q <- Q*(1-Q)*log(1/Q)/sum(dat)
  N_hat_low <- sum(data$Freq) / (1 - Q + 1.96*sqrt(Var_Q))
  N_hat_up <- sum(data$Freq) / (1 - Q - 1.96*sqrt(Var_Q))
  
  data.frame(N_hat = N_hat, 
             N_hat_low = N_hat_low, 
             N_hat_up = N_hat_up)
}
