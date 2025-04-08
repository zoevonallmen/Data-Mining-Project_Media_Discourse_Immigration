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

test <- classify_article(article_text = articles$content[1], prompt_text = prompt)

test$choices$message$content


#Test for 10 articles ----------------------------------------------------------
classified_results <- vector("list", length = 10)

for (i in 151:160) {
  article_text <- articles$content[i]  
  
  classified_results[[i]] <- classify_article(article_text = article_text, prompt_text = prompt)
}

classified_results <- unlist(classified_results)


