#!/usr/bin/env Rscript

.libPaths("/scratch/midway3/mdhernandez/renv_topics/rlibs")
cat("Loaded packages:", .packages(), "\n")

# load libraries
library(topicmodels)
library(dplyr)
library(ggplot2)
library(cluster)
library(doParallel)

cat("Loaded packages:", .packages(), "\n")
print("hello world")

#pass an argument
args <- commandArgs(trailingOnly = TRUE)

# Assign the input to a variable
size_fraction <- args[1]   #FL, PA, SSF, LSF

#dirs
asv_FL_dir='../output/tables/runFL/'
asv_PA_dir='../output/tables/runPA/'
asv_SSF_dir='../output/tables/runSSF/'
asv_LSF_dir='../output/tables/runLSF/'

if (size_fraction == "FL"){
	X_counts=read.csv(paste(asv_FL_dir,"FL_counts.csv",sep=""),header=TRUE,row.names=1)
	#transpose so that the rows are samples and cols are ASVs
	X_counts=t(X_counts)
} else if (size_fraction == "PA"){
	X_counts=read.csv(paste(asv_PA_dir,"PA_counts.csv",sep=""),header=TRUE,row.names=1)
	#transpose so that the rows are samples and cols are ASVs
	X_counts=t(X_counts)
} else if (size_fraction == "SSF"){
	X_counts=read.csv(paste(asv_SSF_dir,"SSF_counts.csv",sep=""),header=TRUE,row.names=1)
	#transpose so that the rows are samples and cols are ASVs
	X_counts <- t(X_counts)
	# drop samples with zero total counts
	X_counts <- X_counts[rowSums(X_counts) > 0, ]
	cat("Samples after filtering:", nrow(X_counts), "\n")
} else if (size_fraction == "LSF"){
	X_counts=read.csv(paste(asv_LSF_dir,"LSF_counts.csv",sep=""),header=TRUE,row.names=1)
	#transpose so that the rows are samples and cols are ASVs
	X_counts <- t(X_counts)
	# drop samples with zero total counts
	X_counts <- X_counts[rowSums(X_counts) > 0, ]
	cat("Samples after filtering:", nrow(X_counts), "\n")
} else {
	print("check inputs")
}



 
# perplexity
# to make paralell
cluster <- makeCluster(as.integer(Sys.getenv("SLURM_CPUS_PER_TASK"))) 
registerDoParallel(cluster)
 
#load up the needed R package on all the parallel sessions
clusterEvalQ(cluster, {
.libPaths("/scratch/midway3/mdhernandez/renv_topics/rlibs")
library(topicmodels)})

## for data selected
full_data  <- X_counts
n <- nrow(full_data)
burnin = 500
iter = 500
keep = 5
 
folds <- 3
set.seed(42)
splitfolds <- sample(1:folds, n, replace = TRUE)
candidate_k <- c(2,4,6,8,10,12,14,16,18,20) # candidates for how many topics
 
# export all the needed R objects to the parallel sessions
clusterExport(cluster, c("full_data", "burnin", "iter", "keep", "splitfolds", "folds", "candidate_k"))
 
system.time({
  results <- foreach(j = 1:length(candidate_k), .combine = rbind) %dopar%{
    k <- candidate_k[j]
    results_1k <- matrix(0, nrow = folds, ncol = 2)
    colnames(results_1k) <- c("k", "perplexity")
    for(i in 1:folds){
      print(i)
      train_set <- full_data[splitfolds != i , ]
      valid_set <- full_data[splitfolds == i, ]
      fitted <- LDA(train_set, k = k, method = "Gibbs",control = list(burnin = burnin, iter = iter, keep = keep))
      results_1k[i,] <- c(k, perplexity(fitted, newdata = valid_set))
    }
    return(results_1k)
  }
})
stopCluster(cluster)

## table with results
results_df <- as.data.frame(results) 
write.csv(results_df, paste(size_fraction,"_perplexity.csv",sep=""), row.names=FALSE)

p<-ggplot(results_df, aes(x = k, y = perplexity)) +
  geom_point() +
  geom_smooth(se = FALSE) +
  labs(x = "Candidate number of topics", y = "Perplexity when fitting the trained model to the hold-out set")

ggsave(p, filename = paste(size_fraction,"_perplexity.png",sep=""), height = 14, width = 21, units = "cm", scale = 1.5)


