#Merge Datasets ---------------------------------------------------------------
library(tidyverse)

Articles <- read_csv("Data/Final_Articles.csv") #Swissdox API cleaned dataset
ArticlesClassified <- read_csv("Data/final_classified_articles.csv") #Classified Data

Joined_Data <- Articles |> 
  left_join(ArticlesClassified, by = "id")

#Data inspection ---------------------------------------------------------------
glimpse(Joined_Data)
summary(Joined_Data) #706 NA's 

colSums(is.na(Joined_Data))

Joined_Data |> 
  select(starts_with("code")) |> 
  map(table)

#Handling NA's ----------------------------------------------------------------
Joined_Data_filtered <- Joined_Data |> 
  filter(!if_any(starts_with("code"), is.na))

nrow(Joined_Data_filtered) #N = 1025, 706 NA's removed

write_csv(Joined_Data_filtered, "Data/analysis_data_merged.csv")

#Task 1 - Relevance: remove irrelevant articles
Joined_Data_filtered <- Joined_Data |> 
  filter(code_1 == 1) #772 obs left

write_csv(Joined_Data_filtered, "Data/analysis_data_relevant_only.csv")

#Distribution of media --------------------------------------------------------
Joined_Data_filtered |> 
  select(medium_name) |> 
  map(table)


#Distrbution of Task 3 - Frames------------------------------------------------
Joined_Data_filtered |> 
  count(code_3)

Joined_Data_filtered |> 
  group_by(medium_name, code_3) |> 
  summarise(n = n()) |> 
  ungroup()

library(ggplot2)

Frame_Distribution_Plot <- Joined_Data_filtered |> 
  ggplot(aes(x = factor(code_3), fill = medium_name)) +
  geom_bar(position = "dodge") +
  scale_fill_brewer(palette = "Pastel1") + 
  labs(x = "Frame", y = "Number of Articles", fill = "Medium") +
  theme_minimal()

ggsave("Outputs/Frame_Distribution.png", plot = Frame_Distribution_Plot) 


table(Joined_Data_filtered$medium_name, Joined_Data_filtered$code_3)

#Barely any classifications for 3 = security frame / 4 = humanitarian frame
#Low for 2 = Cultural / identity frame
#BUT: Only four classified artciles with no frame (0)
#Mostly 5 = political/legal frame --> classification issue? 


#Collapsing frames with not enough obs. into separate category "9 = others" 

Joined_Data_filtered <- Joined_Data_filtered |>
  mutate(code_3_numeric = as.numeric(as.character(code_3))) |>
  mutate(task3_collapsed = case_when(
    code_3_numeric %in% c(0, 3, 4) ~ 9,
    TRUE ~ code_3_numeric
  ))

Joined_Data_filtered <- Joined_Data_filtered |>
  mutate(task3_collapsed = as.factor(task3_collapsed))

library(multinom)
m_frames_medium <- multinom(task3_collapsed ~ medium_name, data = Joined_Data_filtered)
summary(m_frames_medium)

Joined_Data_filtered |> 
  group_by(medium_name, task3_collapsed) |>
  summarise(n = n()) |> 
  ungroup()

#Plot Frame x Medium
ggplot(Joined_Data_filtered, aes(x = medium_name, fill = task3_collapsed)) +
  geom_bar(position = "fill") +  
  scale_fill_brewer(palette = "Pastel1") + 
  labs(y = "Proportion of Frames", fill = "Frame Type") +
  theme_minimal()


