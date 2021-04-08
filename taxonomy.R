
### anotação taxonômica


### Pacotes

library(dplyr)
library(tidyr)


### Lendo as tabelas

gtdb <- read.csv2("docs/gtdbtk.csv", sep = ";",
                  header = TRUE)
gtdb <- gtdb %>% 
  select(-X) %>% 
  rename(Genome = User.Genome)

#### JUNTANDO TABELAS

great_table <- merge(gtdb, final.table, by = "Genome")

great_table <- great_table %>% 
  select(-Marker.lineage)
  
  
write.table(great_table, "tabela_final_binning.csv", sep = ",")





