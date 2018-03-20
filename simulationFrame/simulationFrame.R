library("plyr")
library("dplyr")
library("ggplot2")


# assume two cluters with different size and probability being captured
# these two are major parameters to vary 


#cluster.props <- list(a=c(0.2,0.8),b=c(0.2,0.8),c=c(0.5,0.5),d=c(0.8,0.2),e=c(0.8,0.2),f=c(0.0,1.0))

#freq <- list(a=c(81,1),b=c(11,1),c=c(51,1),d=c(81,1),e=c(11,1),f=c(11,1))

freqs <- seq(0, 1, 0.05)
cluster.props <- seq(0, 1, 0.05)

# assume total population of size 1000, captures of 250 
# using 1000 bootstrap resamples to build confidence interval 
# point and interval estimate data will be saved 
# plots of CI and point estimate will be outputed


for(freq in freqs){
	for(cluter.prop in cluster.props){
		result <- data.frame()
  		clu <- cluster.prop
  		fre <- freq
  		output.name <- paste('~/downloads/ztnb_clu_', clu, '_fre_', fre, '_250_Of_1000.csv', sep="")
  		for(j in 1:100){
  
    		# estimate 
    		result.temp <- ztnb_boot(1000, 250, clu, fre, B=1000)
    		result <- rbind(result, result.temp)
   			write.csv(result, file = output.name)
    
    		# plot     
    		result_order <- result[order(result$N_hat), ]
    
    		pdf(paste("~/downloads/ztnb_clu_", clu, '_fre_', fre, "_250_Of_1000_plot.pdf", sep=""))
    		plt <- ggplot(result_order, aes(x = 1:dim(result_order)[1], y = N_hat, ymin = N_hat_low, ymax = N_hat_up)) +
    		geom_pointrange(fatten = 0.5) +
   			geom_hline(yintercept = 1000, linetype = 2) +
    		coord_flip() +
    		ggtitle('CI width') +
    		xlab('Index') +
    		ylab('Estimated N_hat') +
    		theme(plot.title = element_text(size = 18, colour = 'darkblue', hjust = 0.5),
          		axis.text = element_text(size = 12), axis.title = element_text(size = 16))
			print(plt)
			dev.off()
	}
}




