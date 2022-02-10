
library(tidyr)
library(ggplot2)

## Lendo a tabela de cobertura

cov <- read.delim("output_coverm.tsv") %>% 
  rename(Sample1 = Sample1_.sorted.Relative.Abundance....,
         Sample2 = Sample2_.sorted.Relative.Abundance....,
         Sample3 = Sample3_.sorted.Relative.Abundance....,
         Sample4 = Sample4_.sorted.Relative.Abundance....,
         Sample5 = Sample5_.sorted.Relative.Abundance....,
         Sample6 = Sample6_.sorted.Relative.Abundance....
  ) %>% 
  filter(Genome != "unmapped") %>% 
  mutate_if(is.numeric, round, digits = 2)


## Unindo com a tabela de taxonomia e qualidade

final.table <- merge(taxa2, cov, by = "Genome")

## Transpondo

df <- final.table %>%
  gather(Sample, RelativeAbundance, Sample1:Sample6) %>% 
  as_tibble()


mypalette <- c("#a65538","#7282e2","#6fbe48","#ad5ed3","#bbb237",
               "#6256ba","#e29a39","#6086c3")


### Phylum
df %>% 
  ggplot(aes(y=Sample, x=RelativeAbundance, fill=Family)) + 
  geom_bar(stat='identity') + scale_fill_manual(values=c(mypalette)) +
  scale_y_discrete(labels=c("Sample1", "Sample2", "Sample3", "Sample4", 
                            "Sample5", "Sample6")) +
  theme(axis.text.x = element_text(size = 14)) +
  theme(axis.text.y = element_text(size = 14)) +
theme(legend.position = "bottom") +
  theme(axis.text.x = element_text(size = 14)) +
  theme(axis.text.y = element_text(size = 14)) +
  theme(legend.text = element_text(size = 12))


