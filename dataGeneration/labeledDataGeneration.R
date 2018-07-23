#Assume population falls in two cluters:
#one being using forest frequently, another being rarely use forest 
#two clusters have different size and different probabilities to be sampled 

sim_LabeledData <- function(N, n, cluster.props, freq) {
    #N: total population size
    #n: population to be captured
    #cluster.props: list of fractions that sum to 1, describes proportion of people in each cluster
    #freq: list of fractions sum to 1, describes probabilities of people being in forest for each cluster
    n_clusters <- length(cluster.props) # number of clusters
    N_cluster <- round(N * cluster.props) # number of people in each cluster (population)
    N_cluster[1] <- N_cluster[1] + (N - sum(N_cluster)) # make sure that all people sum to N
    
    # generate label for all the people in the population
    labels <- rep(seq(1, n_clusters), times = N_cluster)
    # people in different clusters have different probability to be drawn
    prob <- rep(freq, times = N_cluster)/100
    
    # generate samples with class labels
    samples <- sample.int(N, n, prob = prob, replace = TRUE)
    data.frame(sample = samples, label = labels[samples])
}
