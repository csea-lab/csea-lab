Myaps_matout4tats <- readxl::read_excel("/Users/csea/Dropbox (UFL)/LabFiles/Myaps/Myaps_matout4stats.xlsx")
library(tidyverse)
library(ggplot2)
library(ggdist)
library(ggridges)
library(ggbeeswarm)
library(patchwork)

# Reshape data to long format
data_long <- tidyr::gather(Myaps_matout4tats, key = "Variable", value = "Value", -Subject_ID)


#https://aubreyshuga.netlify.app/post/exploring-the-raincloudplots-package-2/
##connected rain cloud plot example


# # Plot raincloud plot
# ggplot(data_long, aes(x = Value, y = as.factor(Subject_ID), fill = Variable)) +
#   geom_density_ridges(
#     jittered_points = TRUE,
#     position = position_points_jitter(width = 0.2),
#     scale = 2,
#     rel_min_height = 0.01,
#     quantile_lines = TRUE,
#     quantiles = 2,
#     alpha = 0.7,
#     color = "white",
#     size = 0.5
#   ) +
#   theme_minimal() +
#   labs(
#     title = "Raincloud Plot of Variables by Subject_ID",
#     x = "Value",
#     y = "Subject_ID"
#   )


data_long %>% 
  mutate(Variable = factor(Variable,
                           levels = c("Real_Pleasant",   
                                      "Real_Neutral",    
                                      "Real_Unpleasant", 
                                      "AI_Pleasant",     
                                      "AI_Neutral",
                                      "AI_Unpleasant" ))) %>% 
  ggplot() +
  geom_point(aes(x = Variable, y = Value,
                 color = Variable)) +
  geom_line(aes(x = Variable, y = Value, group = Subject_ID)) +
  theme_classic() 

data_long %>% 
  mutate(
    emotional = case_when(
      Variable %in% c("Real_Pleasant",   
                      "Real_Unpleasant", 
                      "AI_Pleasant",   
                      "AI_Unpleasant") ~ "emotional",
      Variable %in% c("Real_Neutral",    
                      "AI_Neutral") ~ "neutral"),
    ai_or_real = case_when(
      Variable %in% c("Real_Pleasant",   
                      "Real_Unpleasant", 
                      "Real_Neutral") ~ "Real",
      Variable %in% c("AI_Pleasant",
                      "AI_Unpleasant",
                      
                      
                      "AI_Neutral") ~ "AI")) %>% 
  group_by(Subject_ID, emotional, ai_or_real) %>% 
  summarise(mean_pupil = mean(Value)) %>% 
  ggplot() +
  geom_point(aes(x = ai_or_real, y = mean_pupil,
                 color = emotional),size = 2, position = position_dodge(width = .2)) +
  geom_line(aes(x = ai_or_real, y = mean_pupil,
                group = interaction(Subject_ID, emotional)),
            position = position_dodge(width = .2)) +
  scale_color_manual(values = c("pink", "lightblue"),
                     name = "Emotional Category",labels = c("Emotional", "Neutral")) +
  scale_y_continuous(limits = c(),breaks = seq(0,1,.1), name = "Pupil Diameter") +
  ggtitle("this is a title") +
  theme(text = element_text(family = "Arial",size = 20)) +
  theme_classic() 

data_long$Variable %>% unique()
  
  
1 %>% sum(1)

sum(1,1)

ggplot(data_long, aes(x = Variable, y = Value)) +
  aes(color = Variable) +
  ggdist::stat_halfeye(
    adjust = .5,
    width = .5,
    justification = -.1,
    .width = 0,
    point_colour = "blue"
  ) + 
  geom_boxplot(
    width = .15,
    outlier.color = "white"
  ) + 
  ggdist::stat_dots(
    side = "left",
    justification = .12,
    binwidth = .005
  )# +
  #coord_cartesian(xlim = c(1.3,2.9))
