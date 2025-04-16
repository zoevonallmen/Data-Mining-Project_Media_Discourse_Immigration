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

Joined_Data_filtered |> 
  ggplot(aes(x = factor(code_3), fill = medium_name)) +
  geom_bar(position = "dodge") +
  scale_fill_brewer(palette = "Pastel1") + # Try Set1, Set2, Dark2, Pastel1
  labs(x = "Frame", y = "Number of Articles", fill = "Medium") +
  theme_minimal()

