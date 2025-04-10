library(readr)

prompt <- read_file("GPT API/Prompts.txt")
articles <-read_csv("Data/Final_Articles.csv")

library(httr)
library(jsonlite)

api_key <- readLines("Access Tokens/GPT API Key.txt")
openai_url <- "https://api.openai.com/v1/chat/completions"

#original code-----------------------------------------------------------------
classify_article <- function(article_text, prompt_text) {
  messages <- list(
    list(
      role = "system", 
      content = paste(prompt_text, article_text, 
                      sep = "\nHere is the article for you to code: ")))
  
  response <- POST(
    url = openai_url,
    add_headers(
      Authorization = paste("Bearer", api_key),
      `Content-Type` = "application/json"
    ),
    body = toJSON(list(
      model = "gpt-4o",
      messages = messages,
      temperature = 0
    ), auto_unbox = TRUE)
  )
  
  result <- content(response, as = "parsed", simplifyVector = TRUE)
  return(result$choices$message$content)
}

test <- classify_article(article_text = articles$content[159], prompt_text = prompt)

test$choices$message$content


#Test for 10 articles ----------------------------------------------------------
classified_results <- vector("list", length = 10)

for (i in 151:152) {
  article_text <- articles$content[i]  
  
  classified_results[[i]] <- classify_article(article_text = article_text, prompt_text = prompt)
}



classified_results <- unlist(classified_results)


write.csv(classified_results, "classified_articles_150_to_160.csv", row.names = FALSE)

test <- read_csv("classified_articles_150_to_160.csv")


#testing fro two articles, separating tasks -----------------------------------------

relevance <- vector("character", length = 2)
indirect <- vector("character", length = 2)
frame <- vector("character", length = 2)
sentiment <- vector("character", length = 2)
opposition <- vector("character", length = 2)

# Loop through just the first 2 articles
for (i in 1:2) {
  article_text <- articles$content[i] 
  

  task_results <- classify_article(article_text = article_text, prompt_text = prompt)
  

  task_values <- strsplit(task_results, "\n")[[1]]  
  

  task_values <- trimws(task_values)
  

  if (length(task_values) == 5) {

    relevance[i] <- task_values[1]  # First task (relevance)
    indirect[i] <- task_values[2]   # Second task (indirect)
    frame[i] <- task_values[3]      # Third task (frame)
    sentiment[i] <- task_values[4]  # Fourth task (sentiment)
    opposition[i] <- task_values[5] # Fifth task (opposition)
  } else {

    cat("Error: Unexpected number of tasks in article", i, "\n")
  }
  
}

articles$relevance[1:2] <- relevance
articles$indirect[1:2] <- indirect
articles$frame[1:2] <- frame
articles$sentiment[1:2] <- sentiment
articles$opposition[1:2] <- opposition


write.csv(articles[1:2, ], "classified_articles_with_tasks_2_articles.csv", row.names = FALSE)
help <- read.csv("classified_articles_with_tasks_2_articles.csv")
