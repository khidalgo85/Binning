setwd("~/04.MinHash/")

# install.packages('dplyr')
library(dplyr)
# install.packages('stringr')
library(stringr)
# install.packages('tidyverse')
library(tidyverse)

data <- read.table("distancesOutputFinal.tsv", comment.char = '', 
                   header = TRUE ) %>% 
  rename(X = X.query) 


data$X <- str_remove_all(data$X, "04.MinHash/")
data$X <- str_remove_all(data$X, ".fq")

names <- c("X", data[,1])

colnames(data) <- names

data <- column_to_rownames(data, var="X")

library(pheatmap)


pheatmap(data)