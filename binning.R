### Comparação antes e depois do MagPurify2

### Ativar os pacotes
library(dplyr)
library(stringr)

# CheckM output antes do MagPurify2
af1 <- read.csv2("docs/checkm_output.csv")


head(af1)
### Eliminando colunas desnecessárias

af2 <- af1 %>% 
  select(-X..genomes, -X..markers, -X..marker.sets,
         -X0, -X1, -X2, -X3, -X4, -X5., -Strain.heterogeneity) %>% 
  rename(Completeness_before = Completeness, Contamination.before =
           Contamination) %>% 
  filter(Bin.Id != "binsanity_-kmean-bin_74_sub")

head(af2)

# CheckM output depois do MagPurify2 --fastmode
bef1 <- read.csv2("docs/checkm_filtered_output.csv")


head(bef1)
### Eliminando colunas desnecessárias

bef2 <- bef1 %>% 
  filter(Bin.Id != "binsanity_-kmean-bin_74_sub.filtered") %>% 
  select(-Bin.Id, -X..genomes, -Marker.lineage, -X..markers, -X..marker.sets,
         -X0, -X1, -X2, -X3, -X4, -X5., -Strain.heterogeneity) %>% 
  rename(Completeness_after = Completeness, Contamination.after =
           Contamination)
  

head(bef2)


# CheckM output depois do MagPurify complete mode
comp.bef1 <- read.csv2("docs/checkm_filtered_complete_output.csv")


head(comp.bef1)
### Eliminando colunas desnecessárias

comp.bef2 <- comp.bef1 %>% 
  select(-Bin.Id, -X..genomes,  -Marker.lineage, -X..markers, -X..marker.sets,
         -X0, -X1, -X2, -X3, -X4, -X5., -Strain.heterogeneity) %>% 
  rename(Completeness_after = Completeness, Contamination_after =
           Contamination)

head(comp.bef2)


### Juntando as tabelas

table.all <- bind_cols(af2, comp.bef2)

View(table.all)

### Reorganizando a tabela

table.all <- table.all %>% 
  relocate(Completeness_after, .after = Completeness_before)


### Calculando os Score

table.all <- table.all %>% 
  mutate(Completeness_before = 
           as.numeric(Completeness_before),
         Completeness_after = as.numeric(Completeness_after),
         Contamination.before = as.numeric(Contamination.before),
         Contamination_after = as.numeric(Contamination_after),
         score.before = Completeness_before -
           (5 *  Contamination.before), score.after = Completeness_after -
           (5 * Contamination_after), score.after =
           Completeness_after - (5 * Contamination_after))

## Quantos bins tem um score menor ou igual a 0
## (Compl < 50, Cont > 10)
table.all %>% 
  filter(score.before <= 0) %>% 
  summarise(conteo = n())
## 5 bins
table.all %>% 
  filter(score.after <= 0) %>% 
  summarise(conteo = n())

## Quantos bins tem um score maior ou igual a 65

table.all %>% 
  filter(score.before >= 65) %>% 
  summarise(conteo = n())

table.all %>% 
  filter(score.after >= 65) %>% 
  summarise(conteo = n())

## Quantos bins tem Compl > 90 e cont < 5 (AnTES)

table.all %>% 
  filter(Completeness_before >= 90 & 
           Contamination.before <= 5) %>% 
  summarise(conteo = n())

## Quantos bins tem Compl > 90 e cont < 5 (DESPUES)

table.all %>% 
  filter(Completeness_after >= 90 & 
           Contamination_after <= 5) %>% 
  summarise(conteo = n())

## Quantos bins tem Compl >= 50 e cont < 10

table.all %>% 
  filter(Completeness_before >= 50 & 
           Contamination.before <= 10) %>% 
  summarise(conteo = n())


## Quantos bins tem Compl < 50 e cont > 10

table.all %>% 
  filter(Completeness_before < 50 & 
           Contamination.before > 10) %>% 
  summarise(conteo = n())

### Add uma coluna com o nome da ferramenta

final.table <-table.all %>% 
  mutate(Bin.Tool = case_when(str_detect(Bin.Id, "maxbin") ~ "MaxBin",
                              str_detect(Bin.Id, "Metabat2") ~ "Meatabat2",
                              str_detect(Bin.Id, "binsanity") ~ "Binsanity",
                              str_detect(Bin.Id, "^60")~ "Vamb",
                              (str_detect(Bin.Id, "maxbin", negate = TRUE) & 
                                str_detect(Bin.Id, "Metabat2", negate = TRUE) & 
                                str_detect(Bin.Id, "binsanity", negate = TRUE) &
                                str_detect(Bin.Id, "^60", negate = TRUE) ~ "CONCOCT")))
  

## Add coluna com qualidade segundo MIMAG

final.table <- final.table %>% 
  mutate(Inicial.MiMAG.Quality = case_when(Contamination.before < 5 & Completeness_before > 90 ~ "High-Quality",
                                  Contamination.before < 10 & Completeness_before >= 50 ~ "Medium-Quality",
                                  Completeness_before < 50 ~ "Low-Quality",
                                Contamination.before > 10 ~ "Low-Quality"),
Final.MiMAG.Quality = case_when(Contamination_after < 5 & Completeness_after > 90 ~ "High-Quality",
                                Contamination_after < 10 & Completeness_after >= 50 ~ "Medium-Quality",
                                Completeness_after < 50 ~ "Low-Quality",
                                Contamination_after > 10 ~ "Low-Quality"))


final.table <- final.table %>% 
  rename(Genome = Bin.Id)

## Graficando a comparação antes vs depois do refinamento
library(ggplot2)

##################################################
## Organizando tabela para graficar LOW QUALITY
##################################################


comparision.table.lowquality <- final.table %>% 
  filter(Inicial.MiMAG.Quality == "Low-Quality") %>% 
  select(Bin.Id, score.before, score.after,
         Inicial.MiMAG.Quality, Final.MiMAG.Quality)


t1 <- comparision.table.lowquality %>%
  select(Bin.Id, score.before) %>% 
  mutate(Ref = "Sem") %>% 
  rename(score = score.before)

t2 <- comparision.table.lowquality %>%
  select(Bin.Id, score.after) %>% 
  mutate(Ref = "MP_CM") %>% 
  rename(score = score.after)

t123 <- bind_rows(t1,t2)

# Basic stripchart
ggplot(t123, aes(x=Ref, y=score)) + 
  geom_jitter()
# Change the position
# 0.2 : degree of jitter in x direction
p <- ggplot(t123, aes(x=Ref, y=score, color=Ref)) + 
  geom_jitter(position=position_jitter(0.07), cex=0.8)
p
# stripchart with mean points
p + stat_summary(fun=mean, geom="crossbar",
                 size=0.1, color="red") +
  scale_color_brewer(palette = "Dark2") +
  theme(legend.position = "none") +
  scale_x_discrete(limits=c("Sem", "MP_CM")) +
  geom_hline(yintercept=0, linetype="dashed", colour="gray") +
    theme(axis.title.x = element_blank()) +
  ggtitle("Antes vs Depois do MagPurify2 (Low-Quality)") +
  theme(title = element_text(size = 8))


##################################################
## Organizando tabela para graficar MEDIUM QUALITY
##################################################


comparision.table.medquality <- final.table %>% 
  filter(Inicial.MiMAG.Quality == "Medium-Quality") %>% 
  select(Bin.Id, score.before, score.after,
         Inicial.MiMAG.Quality, Final.MiMAG.Quality)


t1 <- comparision.table.medquality %>%
  select(Bin.Id, score.before) %>% 
  mutate(Ref = "Sem") %>% 
  rename(score = score.before)

t2 <- comparision.table.medquality %>%
  select(Bin.Id, score.after) %>% 
  mutate(Ref = "MP_CM") %>% 
  rename(score = score.after)

t123 <- bind_rows(t1,t2)

# Basic stripchart
ggplot(t123, aes(x=Ref, y=score)) + 
  geom_jitter()
# Change the position
# 0.2 : degree of jitter in x direction
p <- ggplot(t123, aes(x=Ref, y=score, color=Ref)) + 
  geom_jitter(position=position_jitter(0.07), cex=0.8)
p
# stripchart with mean points
p + stat_summary(fun=mean, geom="crossbar",
                 size=0.1, color="red") +
  scale_color_brewer(palette = "Dark2") +
  theme(legend.position = "none") +
  scale_x_discrete(limits=c("Sem", "MP_CM")) +
  geom_hline(yintercept=0, linetype="dashed", colour="gray") +
  theme(axis.title.x = element_blank()) +
  ggtitle("Antes vs Depois do MagPurify2 (Medium-Quality)") +
  theme(title = element_text(size = 8))


##################################################
## Organizando tabela para graficar HIGH QUALITY
##################################################


comparision.table.highquality <- final.table %>% 
  filter(Inicial.MiMAG.Quality == "High-Quality") %>% 
  select(Bin.Id, score.before, score.after,
         Inicial.MiMAG.Quality, Final.MiMAG.Quality)


t1 <- comparision.table.highquality %>%
  select(Bin.Id, score.before) %>% 
  mutate(Ref = "Sem") %>% 
  rename(score = score.before)

t2 <- comparision.table.highquality %>%
  select(Bin.Id, score.after) %>% 
  mutate(Ref = "MP_CM") %>% 
  rename(score = score.after)


t123 <- bind_rows(t1,t2)

# Basic stripchart
ggplot(t123, aes(x=Ref, y=score)) + 
  geom_jitter()
# Change the position
# 0.2 : degree of jitter in x direction
p <- ggplot(t123, aes(x=Ref, y=score, color=Ref)) + 
  geom_jitter(position=position_jitter(0.07), cex=0.8)
p
# stripchart with mean points
p + stat_summary(fun=mean, geom="crossbar",
                 size=0.1, color="red") +
  scale_color_brewer(palette = "Dark2") +
  theme(legend.position = "none") +
  scale_x_discrete(limits=c("Sem","MP_CM")) +
  geom_hline(yintercept=0, linetype="dashed", colour="gray") +
  theme(axis.title.x = element_blank()) +
  ggtitle("Antes vs Depois do MagPurify2 (High-Qualit)") +
  theme(title = element_text(size = 8)) 


