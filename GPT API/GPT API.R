library(readr)

prompt_text <- read_file("GPT API/Prompts.txt")

articles <-read_csv("")

library(httr)
library(jsonlite)

api_key <- readLines("Access Tokens/GPT API Key.txt")
openai_url <- "https://api.openai.com/v1/chat/completions"




classify_article <- function(article_text, prompt_text) {
  messages <- list(
    list(role = "system", content = prompt_text),
    list(role = "user", content = article_text)
  )
  
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
  return(result$choices[[1]]$message$content)
}


#Testing
test_articles <- head(articles, 10)
test_articles$classification <- sapply(test_articles$text, classify_article, prompt_text = prompt_text)
View(test_articles)
write_csv(test_articles, "classified_articles_TEST.csv")

#Full analysis
articles$classification <- sapply(articles$text, classify_article, prompt_text = prompt_text)
write_csv(articles, "classified_articles_FULL.csv")
