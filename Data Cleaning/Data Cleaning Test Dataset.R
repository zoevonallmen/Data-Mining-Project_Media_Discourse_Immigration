library(readr)
data <- read.delim("Data/Immigration_Data_Test.tsv", sep = "\t", encoding = "UTF-8")

View(data)

library(dplyr)
library(stringr)

articles_clean <- data |> 
  filter(!is.na(content)) |>                               
  mutate(content = str_remove_all(content, "<[^>]+>")) |>  
  mutate(content = str_squish(content)) |>                  
  filter(nchar(content) > 50) |>                            
  distinct(content, .keep_all = TRUE)

for (i in 40:50) {
  cat(paste0("---- ARTICLE ", i, " ----\n"))
  cat(articles_clean$content[i], "\n\n")
}

articles_clean <- articles_clean |> 
  mutate(content = str_remove(content, "\\(SDA\\).*")) |>   
  mutate(content = str_remove(content, "Publiziert.*")) |>   
  mutate(content = str_remove(content, "Aktualisiert.*")) |>   
  mutate(content = str_squish(content))  

articles_clean <- articles_clean |> 
  mutate(content = str_remove(content, "^Von [A-ZÄÖÜa-zäöüß\\s]+")) |> 
  mutate(content = str_squish(content))  

write_csv(articles_clean, "Data/test_articles.csv")
