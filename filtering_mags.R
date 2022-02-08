# Lendo os dados 

tab <- read.delim("output.txt", skip = 33)

library(dplyr)

## Formatando a tabela
tab1 <- as_tibble(tab) %>% 
  na.omit() %>% 
  select(1,12,13) %>% 
  mutate(Quality = case_when(Contamination < 5 & Completeness > 90 ~ "High-Quality",
                             Contamination < 10 & Completeness >= 50 ~ "Medium-Quality",
                             Completeness < 50 ~ "Low-Quality",
                             Contamination > 10 ~ "Low-Quality"))

## Contando os MAGs por qualidade

tab1 %>% 
  group_by(Quality) %>% 
  summarise(
    n=n()
  )

### Criando tabela só com os MAGs de alta e média qualidade
mags.filtered <- tab1 %>% 
  group_by(Quality) %>% 
  filter(Quality == "High-Quality" | Quality == "Medium-Quality") %>% 
  ungroup() %>% 
  select(Bin.Id) %>% 
  as.data.frame()

fa <- c(rep(".fa", nrow(mags.filtered)))


mags <- mags.filtered[,1] %>% 
  paste0(., fa) %>% 
  write(., file="filt.mags.txt")

mags.filtered
