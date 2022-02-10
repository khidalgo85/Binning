## Construindo tabela com taxonomia e qualidade dos mags

## install.packages('dplyr')
library(dplyr)

## install.packages('tidyr')
library(tidyr)


## Lendo a tabela saída do CheckM com a qualidade dos MAGs
quality <- read.delim("output.txt", skip = 33) %>% 
  select(Bin.Id, Completeness, Contamination) %>% 
  na.omit() %>% 
  as_tibble() %>% 
  rename(Genome = Bin.Id)

## Lendo a tabela de anotação taxonômica de bactérias
bact.taxa <- read.delim("gtdbtk.bac120.summary.tsv",
                        sep = '\t') %>% 
  select(user_genome, classification, classification_method, note) %>% 
  rename(Bin.Id = user_genome) %>% 
  as_tibble() %>% 
  separate(col = classification, into = c("Domain", "Phyla", "Class", "Order",
                                          "Family", "Genus", "Species"), sep = ';')


## Lendo a tabela de anotação taxonômica de Arqueas
arc.taxa <- read.delim("gtdbtk.ar122.summary.tsv",
                       sep = '\t') %>% 
  select(user_genome, classification, classification_method, note) %>% 
  rename(Bin.Id = user_genome) %>% 
  as_tibble() %>% 
  separate(col = classification, into = c("Domain", "Phyla", "Class", "Order",
                                          "Family", "Genus", "Species"), sep = ';')


## Unindo as tabelas de taxonomia
taxa <- rbind(bact.taxa,  arc.taxa) %>%
  rename(Genome = Bin.Id) 

## Unindo a taxonomia com a qualidade
taxa <- merge(quality, taxa, by = "Genome") 


# Eliminando caracteres indesejados na taxonomia 
taxa$Domain<-gsub("d__","",as.character(taxa$Domain))
taxa$Phyla<-gsub("p__","",as.character(taxa$Phyla))
taxa$Class<-gsub("c__","",as.character(taxa$Class))
taxa$Order<-gsub("o__","",as.character(taxa$Order))
taxa$Family<-gsub("f__","",as.character(taxa$Family))
taxa$Genus<-gsub("g__","",as.character(taxa$Genus))
taxa$Species<-gsub("s__","",as.character(taxa$Species))



# Classificando os MAGs pela qualidade
taxa2 <- taxa %>% 
  mutate(Quality = if_else(Completeness > 90 & Contamination < 5, "HighQuality",
                           "MediumQuality"))
