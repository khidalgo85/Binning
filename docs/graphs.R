

## Gráfico da abundancia relativa dos MAGs nas amostras

t <- read.delim("docs/coverm.tsv", sep = "\t") %>%
  filter(Genome != "binsanity_-kmean-bin_74_sub")

y <- read.csv2("tabela_final_binning.csv", sep = ",") %>%
  rbind(c("unmapped"))

x <- merge(y, t, by = "Genome")

x1 <- rename(x, Sample.1 = B52, Sample.2 = B63, Sample.3 = B65, Sample.4 = PM62, Sample.5 = PM63, Sample.6 = PM65)

library(tidyr)

x2 <- x1 %>%
  gather(Sample, RelativeAbundance, Sample.1:Sample.6)
x2 <- as_tibble(x2)
x2

mypalette <- c("#50a4d3",
               "#45c3c6",
               "#5567a8",
               "#af9b54",
               "#4fb187",
               "#8798e2",
               "#4e7330",
               "#e48c72",
               "#af4f5f",
               "#a05185",
               "#98602a",
               "#db8bc7",
               "#81b263",
               "#8a53a7",
               "#d99833",
               "#db457a",
               "#5b6dd9",
               "#a0b434",
               "#d04c34",
               "#51b74c",
               "#ce4eb4",
               "#a360d8")
### Phylum
p <- ggplot(x2, aes(y=Sample, x=RelativeAbundance, fill=Phylum)) + 
  geom_bar(stat='identity') + scale_fill_manual(values=c(mypalette)) +
  scale_y_discrete(labels=c("B52", "B63", "B65", "PM62", "PM63", "PM65"))

### Family

p1 <- ggplot(x2, aes(y=Sample, x=RelativeAbundance, fill=Family)) + 
  geom_bar(stat='identity') + scale_fill_manual(values=c(mypalette)) +
  scale_y_discrete(labels=c("B52", "B63", "B65", "PM62", "PM63", "PM65"))


### Both
library(ggpubr)
pf <- ggarrange(p, p1, labels = c("A", "B"),
                ncol = 1, nrow = 2)
pf
