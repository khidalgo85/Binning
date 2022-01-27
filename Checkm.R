### Gráfico de dispersão dos bins baseado na completude e contaminação

# Lendo os dados 

tab <- read.delim("14.CheckM/output.txt", skip = 33)

library(dplyr)

## Formatando a tabela
tab1 <- as_tibble(tab) %>% 
  na.omit() %>% 
  select(1,12,13) %>% 
  mutate(Quality = case_when(Contamination < 5 & Completeness > 90 ~ "High-Quality",
                             Contamination < 10 & Completeness >= 50 ~ "Medium-Quality",
                             Completeness < 50 ~ "Low-Quality",
                             Contamination > 10 ~ "Low-Quality"))


library(ggplot2)

tab1 %>% 
  ggplot(aes(x=Completeness, y=Contamination, shape=Quality)) + 
  geom_point(size =1.3) +
  ggtitle("MAGs Dispersion by CheckM") +
  theme(plot.title = element_text(face = "bold", colour = "Dark blue")) +
  theme(axis.title = element_text(face = "bold", colour = "Black")) +
  scale_shape_manual(values = c(17, 8, 1)) +
  ylim(50,0) + xlim(0,100) +
  annotate("text", x = 45, y = 50, label = "High-Quality draft 9 (Comp > 90 & Cont < 5)", size = 2.5, colour= "Dark green") +
  annotate("text", x = 45, y = 45, label = "Medium-Quality draft 16 (Comp > 50 & Cont < 10)", size = 2.5, colour= "Orange") +
  annotate("text", x = 45, y = 40, label = "Low-Quality draft 10 (Comp < 50 & Cont > 10)", size = 2.5, colour= "Red" ) + 
  geom_vline(xintercept=90, linetype="dashed", colour="Dark green") + geom_hline(yintercept=5, linetype="dashed", colour="Dark green") +
  geom_vline(xintercept=50, linetype="dashed", colour="orange") + geom_hline(yintercept=10, linetype="dashed", colour="Orange")

p