#Merge Datasets ---------------------------------------------------------------
library(tidyverse)

Articles <- read_csv("Data/Final_Articles.csv") #Swissdox API cleaned dataset
ArticlesClassified <- read_csv("Data/final_classified_articles.csv") #Classified Data

Joined_Data <- Articles |> 
  left_join(ArticlesClassified, by = "id")

write_csv(Joined_Data, "Data/analysis_data_merged.csv")

#Data inspection ---------------------------------------------------------------
glimpse(Joined_Data)
summary(Joined_Data) #706 NA's 

colSums(is.na(Joined_Data))

Joined_Data |> 
  select(starts_with("code")) |> 
  map(table)
