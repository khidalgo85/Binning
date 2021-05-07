
library(plotly)
library(hrbrthemes)
library(ggplot2)
library(readxl)

df.heatmap <- read_excel("modules_mags.xlsx", sheet = "Hoja1")

p <- ggplot(df.heatmap, aes(x = Module, y = Genome, fill = Percentage_Complete)) +
  geom_tile(colour = "gray", size = 0.2) + 
  scale_fill_viridis_c(name = "% Complete",
                       direction = -1) +
  theme(axis.text.x = element_text(angle = 270, hjust = 0.0)) +
  facet_wrap(~ Metabolism, scales = "free_x", nrow = 1, labeller = 
               label_wrap_gen(10))+
  theme(strip.placement = "outside") +
  ggtitle("Pathways percentages") +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(strip.background = element_rect(fill = "black")) +
  theme(strip.text = element_text(colour = "white", face = 'bold', size = 16))+
  theme(axis.text.y = element_text(size = 12)) +
  theme(axis.text.x = element_text(size = 15, vjust = 0.5)) +
  theme(axis.title.x = element_blank()) +
  theme(axis.title.y = element_blank());p

ggplotly(p, tooltip = "all")

library(RColorBrewer)


