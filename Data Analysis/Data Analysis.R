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