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