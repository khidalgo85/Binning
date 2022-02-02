install.packages("Nonpareil") #para instalar o pacote
library(Nonpareil) # ativa o pacote
setwd("~/03.NonPareil") # determina seu diretório de trabalho (coloque o seu, onde colocou os arquivos .npo e o arquivo samples.txt)

samples <- read.table('samples.txt', sep='\t', header=TRUE, as.is=TRUE); #lê o arquivo samples.txt com a informação das amostras

attach(samples);
nps <- Nonpareil.set(File, col=Col, labels=Name, 
                     plot.opts=list(plot.observed=FALSE, 
                                    ylim = c(0, 1.05),
                                    legend.opts = FALSE)) #grafica as curvas

Nonpareil.legend(nps, x.intersp=0.5, y.intersp=0.7, pt.cex=0.5, cex=0.5) #coloca e personaliza a legenda

detach(samples);
summary(nps) #mostra o resumo em forma de tabela

results <- as.data.frame(summary(nps))

library(dplyr)

df <- results %>%
  select(-kappa, -modelR) %>% 
  rename(Coverage = C,
         `Required Effort (Gbp)` = LR,
         `Actual effort (Gbp)` = LRstar)

df$`Required Effort (Gbp)` <- round(df$`Required Effort (Gbp)` / 1E9, 
                                    digits = 2)
df$`Actual effort (Gbp)` <- round(df$`Actual effort (Gbp)` / 1E9, 
                                  digits = 2)
df$diversity <- round(df$diversity, digits = 2)
df$Coverage <- round(df$Coverage, digits = 2)
df  


write.csv(df, "nonpareil_summary.csv",
          row.names = TRUE)
