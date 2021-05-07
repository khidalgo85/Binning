

## Gráfico da abundancia relativa dos MAGs nas amostras
library(dplyr)
t <- read.delim("docs/output_coverm_hqmq.tsv", sep = "\t") %>%
  filter(Genome != "binsanity_-kmean-bin_74_sub")

y <- read.csv2("tabela_final_binning.csv", sep = ";") %>%
  rbind(c("unmapped"))

x <- merge(y, t, by = "Genome") %>%
  select(-X)

x1 <- rename(x, Sample.1 = B52.sorted.Relative.Abundance...., Sample.2 = B63.sorted.Relative.Abundance...., Sample.3 = B65.sorted.Relative.Abundance...., Sample.4 = PM62.sorted.Relative.Abundance...., Sample.5 = PM63.sorted.Relative.Abundance...., Sample.6 = PM65.sorted.Relative.Abundance....)

library(tidyr)

x2 <- x1 %>%
  gather(Sample, RelativeAbundance, Sample.1:Sample.6)
x2 <- as_tibble(x2)

x3 <- x2 %>% 
  filter(Inicial.MiMAG.Quality != "Low-Quality")


mypalette <- c("#a65538",
               "#7282e2",
               "#6fbe48",
               "#ad5ed3",
               "#bbb237",
               "#6256ba",
               "#e29a39",
               "#6086c3",
               "#d6542d",
               "#47bcd2",
               "#d64056",
               "#5fc490",
               "#cd4dad",
               "#50923d",
               "#d64889",
               "#36845f",
               "#d18ed0",
               "#80882d",
               "#944f89",
               "#afb16c",
               "#a14458",
               "#5b6c2b",
               "#e17f8c",
               "#8e7032",
               "#e2986d",
               "#af6c21")

library(ggplot2)
### Phylum
p <- ggplot(x3, aes(y=Sample, x=RelativeAbundance, fill=ID)) + 
  geom_bar(stat='identity') + scale_fill_manual(values=c(mypalette)) +
  scale_y_discrete(labels=c("B52", "B63", "B65", "PM62", "PM63", "PM65")) +
  theme(legend.position = "bottom") +
  theme(axis.text.x = element_text(size = 14)) +
  theme(axis.text.y = element_text(size = 14)) +
  theme(legend.text = element_text(size = 12))

