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
  separate(col = classification, into = c("Kingdom", "Phylum", "Class", "Order",
                                          "Family", "Genus", "Species"), sep = ';')



## Lendo a tabela de anotação taxonômica de Arqueas
arc.taxa <- read.delim("gtdbtk.ar122.summary.tsv",
                       sep = '\t') %>% 
  select(user_genome, classification, classification_method, note) %>% 
  rename(Bin.Id = user_genome) %>% 
  as_tibble() %>% 
  separate(col = classification, into = c("Kingdom", "Phylum", "Class", "Order",
                                          "Family", "Genus", "Species"), sep = ';')


## Unindo as tabelas de taxonomia
taxa <- rbind(bact.taxa,  arc.taxa) %>%
  rename(Genome = Bin.Id) 

### Limpando a taxonomia
temp <- select(taxa, 2:8)

# Eliminando caracteres indesejados na taxonomia 
temp$Kingdom<-gsub("d__","",as.character(temp$Kingdom))
temp$Phylum<-gsub("p__","",as.character(temp$Phylum))
temp$Class<-gsub("c__","",as.character(temp$Class))
temp$Order<-gsub("o__","",as.character(temp$Order))
temp$Family<-gsub("f__","",as.character(temp$Family))
temp$Genus<-gsub("g__","",as.character(temp$Genus))
temp$Species<-gsub("s__","",as.character(temp$Species))


### Completando os campos sem taxonomia com o último nível assignado
temp[is.na(temp)] <- ""

for (i in 1:nrow(temp)){
  if (temp[i,2] == ""){
    Kingdom <- paste("Kingdom_", temp[i,1], sep = "")
    temp[i, 2:7] <- Kingdom
  } else if (temp[i,3] == ""){
    phylum <- paste("Phylum_", temp[i,2], sep = "")
    temp[i, 3:7] <- phylum
  } else if (temp[i,4] == ""){
    Class <- paste("Class_", temp[i,3], sep = "")
    temp[i, 4:7] <- Class
  } else if (temp[i,5] == ""){
    Order <- paste("Order_", temp[i,4], sep = "")
    temp[i, 5:7] <- Order
  } else if (temp[i,6] == ""){
    Family <- paste("Family_", temp[i,5], sep = "")
    temp[i, 6:7] <- Family
  } else if (temp[i,7] == ""){
    temp$Species[i] <- paste("Genus",temp$Genus[i], sep = "_")
  }
}

taxa$Kingdom <- temp$Kingdom
taxa$Phylum <- temp$Phylum
taxa$Class <- temp$Class
taxa$Order <- temp$Order
taxa$Family <- temp$Family
taxa$Genus <- temp$Genus
taxa$Species <- temp$Species



## Unindo a taxonomia com a qualidade
taxa <- merge(quality, taxa, by = "Genome") 



# Classificando os MAGs pela qualidade
taxa2 <- taxa %>% 
  mutate(Quality = if_else(Completeness > 90 & Contamination < 5, "HighQuality",
                           "MediumQuality"))
