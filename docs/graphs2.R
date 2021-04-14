### Gráfico de dispersão dos bins baseado na completude e contaminação

# Lendo os dados 

tab <- read.delim("docs/checkm_output.tsv", sep = "\t")

class(tab)

library(stringr)
library(dplyr)

tab1 <- as_tibble(tab)



tab2 <-tab1 %>% 
  mutate(Bin.Tool = case_when(str_detect(Bin.Id, "maxbin") ~ "MaxBin",
                              str_detect(Bin.Id, "Metabat2") ~ "Meatabat2",
                              str_detect(Bin.Id, "binsanity") ~ "Binsanity",
                              str_detect(Bin.Id, "^60")~ "Vamb",
                              (str_detect(Bin.Id, "maxbin", negate = TRUE) & 
                                 str_detect(Bin.Id, "Metabat2", negate = TRUE) & 
                                 str_detect(Bin.Id, "binsanity", negate = TRUE) &
                                 str_detect(Bin.Id, "^60", negate = TRUE) ~ "CONCOCT")))

tab2 <- select(tab2, "Bin.Id", "Completeness", "Contamination", "Bin.Tool")



tab3 <- tab2 %>%
  mutate(Quality = ifelse(Contamination < 5 & Completeness > 90, "High-Quality", "Medium-Quality"))


tab4 <- tab3 %>%
  mutate(Quality = case_when(Contamination < 5 & Completeness > 90 ~ "High-Quality",
                             Contamination < 10 & Completeness >= 50 ~ "Medium-Quality",
                             Completeness < 50 ~ "Low-Quality",
                             Contamination > 10 ~ "Low-Quality"))


hq <- rowSums(tab4[,5 ] == "High-Quality")
hq <- sum(hq)

mq <- rowSums(tab4[,5 ] == "Medium-Quality")
mq <- sum(mq)

lq <- rowSums(tab4[,5 ] == "Low-Quality")
lq <- sum(lq)



library(ggplot2)


p <- ggplot(data = tab4, aes(x=Completeness, y=Contamination, colour= Bin.Tool, shape=Quality)) + 
  geom_point(size =1.3) +
  ggtitle("MAGs Dispersion by CheckM") +
  theme(plot.title = element_text(face = "bold", colour = "Dark blue")) +
  theme(axis.title = element_text(face = "bold", colour = "Gray")) +
  scale_colour_brewer(palette = "Dark2") +
  scale_shape_manual(values = c(17, 8, 1)) +
  ylim(50,0) + xlim(0,100) +
  annotate("text", x = 45, y = 50, label = "High-Quality draft 9 (Comp > 90 & Cont < 5)", size = 2.5, colour= "Dark green") +
  annotate("text", x = 45, y = 45, label = "Medium-Quality draft 16 (Comp > 50 & Cont < 10)", size = 2.5, colour= "Orange") +
  annotate("text", x = 45, y = 40, label = "Low-Quality draft 10 (Comp < 50 & Cont > 10)", size = 2.5, colour= "Red" ) + 
  geom_vline(xintercept=90, linetype="dashed", colour="Dark green") + geom_hline(yintercept=5, linetype="dashed", colour="Dark green") +
  geom_vline(xintercept=50, linetype="dashed", colour="orange") + geom_hline(yintercept=10, linetype="dashed", colour="Orange")



p
