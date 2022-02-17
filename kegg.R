
library(dplyr)
library(stringr)
library(tidyr)


### Lendo a tabela única de anotação funcional
func <- read.delim("funcannot.txt", header = F) %>% 
  select(V1,V2,V3,V5,V17) 

### Filtrando só as anotações de KEGG
func.annot.kegg <- func %>% 
  filter(str_detect(V5, "^K")) %>% # Filtra strings que começem com K (i.e. K00001)
  # Renomea as colunas
  rename(Genome = V1, ContigID = V2, length = V3, KO = V5, pident = V17) %>% 
  # converte para data.frame
  as.data.frame()


# Lê a tabela das informações completas do KEGG
kegg <- read.delim("kegg.tsv", header = F) %>% 
  rename(KO = V1, Level1 = V2, Level2 = V3, Level3 = V4, GenName = V5)

## Junta as tabelas da anotação do Kegg e as informações dos níveis do KEGG
func.annot.kegg.final <- left_join(func.annot.kegg %>% 
                                     group_by(KO) %>% 
                                     mutate(id = row_number()),
                                   kegg %>% 
                                     group_by(KO) %>% 
                                     mutate(id = row_number()), 
                                   by = c("KO", "id"))

head(func.annot.kegg.final)


