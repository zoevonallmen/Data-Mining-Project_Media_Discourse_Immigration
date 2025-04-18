#Load data ---------------------------------------------------------------------
library(readr)
data <- read.delim("Data/Immigration_Articles_Unlimited.tsv", sep = "\t", encoding = "UTF-8")

nrow(data)
head(data)

#data cleaning-----------------------------------------------------------------
library(dplyr)
library(stringr)

for (i in 40:50) {
  cat(paste0("---- ARTICLE ", i, " ----\n"))
  cat(articles_clean$content[i], "\n\n")
}

articles_clean <- data |> 
  mutate(content = str_remove_all(content, "<[^>]+>")) |>  
  mutate(content = str_remove(content, "\\(SDA\\).*")) |>   
  mutate(content = str_remove(content, "Publiziert.*")) |>   
  mutate(content = str_remove(content, "Aktualisiert.*")) |>   
  mutate(content = str_remove(content, "^Von [A-ZÄÖÜa-zäöüß\\s]+")) |> 
  mutate(content = str_squish(content)) 
 
write_csv(articles_clean, "Data/Final_Articles.csv")
