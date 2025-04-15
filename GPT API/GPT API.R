#Load libraries---------------------------------------------------------------
library(readr)
library(httr)
library(jsonlite)

#Load data, prompt, api key, url-----------------------------------------------
prompt <- read_file("GPT API/Prompts.txt")
articles <-read_csv("Data/Final_Articles.csv")
api_key <- readLines("Access Tokens/GPT API Key.txt")
openai_url <- "https://api.openai.com/v1/chat/completions"

#Function to classify single article--------------------------------------------
classify_article <- function(article_text, prompt_text, retries = 3) {
  messages <- list(
    list(
      role = "system", 
      content = paste(prompt_text, article_text, sep = "\nHere is the article for you to code: ")
    )
  )
  
  attempt <- 1
  repeat {
    response <- tryCatch({
      POST(
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
    }, error = function(e) {
      cat("Error:", conditionMessage(e), "\n")
      return(NULL)
    })
    
    if (!is.null(response)) {
      parsed <- content(response, as = "parsed", simplifyVector = TRUE)
      
      if (!is.null(parsed$error$message)) {
        cat("API Error:", parsed$error$message, "\n")
        return(NA)
      }
      
      # Correctly access message content from data frame
      if (!is.null(parsed$choices$message.content[1])) {
        return(parsed$choices$message.content[1])
      }
    }
    
    attempt <- attempt + 1
    if (attempt > retries) {
      cat("Max retries exceeded\n")
      return(NA)
    }
    Sys.sleep(5)
  }
}

#Storage vectors--------------------------------------------------------------

n_articles <- nrow(articles)
relevance <- rep(NA_character_, n_articles)
indirect <- rep(NA_character_, n_articles)
frame <- rep(NA_character_, n_articles)
sentiment <- rep(NA_character_, n_articles)
opposition <- rep(NA_character_, n_articles)

#Loop over all articles ------------------------------------------------------
for (i in 1:n_articles) {
  cat("Processing article", i, "of", n_articles, "\n")
  result <- classify_article(article_text = articles$content[i], prompt_text = prompt)
  Sys.sleep(2)
  
  if (!is.na(result)) {
    # Split result on ANY whitespace (space, tab, or newline)
    task_values <- unlist(strsplit(result, "\\s+"))
    
    if (length(task_values) == 5) {
      relevance[i]  <- task_values[1]
      indirect[i]   <- task_values[2]
      frame[i]      <- task_values[3]
      sentiment[i]  <- task_values[4]
      opposition[i] <- task_values[5]
    } else {
      cat("Unexpected format in article", i, "- got", length(task_values), "values\n")
    }
  } else {
    cat("Failed to classify article", i, "\n")
  }
  
}


#Save to original dataset------------------------------------------------------
df <- data.frame(
  relevance = relevance,
  indirect = indirect,
  frame = frame,
  sentiment = sentiment,
  opposition = opposition
)
articles <- cbind(articles, df)

write.csv(articles, "classified_articles_final.csv", row.names = FALSE)

atest1 <-read_csv("classified_articles_final.csv")


#Different code to try---------------------------------------------------------

#Libraries
library(tidyverse)
library(httr)
library(jsonlite)
library(readr)

#Api Key & Prompt
analysis_prompt <- read_file("GPT API/Prompts.txt") |>  paste(collapse = " ")
api_key <- api_key <- readLines("Access Tokens/GPT API Key.txt")

#Data
data <- read_csv("Data/Final_Articles.csv")
articles <- data |> 
  mutate(article_nr = 1:n(),
         content = as.character(content))



#Response vector
chatgpt_responses <- vector("character", length = nrow(articles))

exponential_backoff <- function(retries) {
  
  Sys.sleep(2^retries)
}

#Classify function & loop 
for (i in seq_len(nrow(articles))) {
  article_text <- articles$content[i]
  
  retries <- 0
  success <- FALSE
  
  while (!success && retries < 5) {  # maximum of 5 tries
    response <- tryCatch({
      httr::POST(
        url = "https://api.openai.com/v1/chat/completions",
        content_type("application/json"),
        add_headers(Authorization = paste("Bearer", api_key)),
        body = list(
          model = "gpt-4o",
          temperature = 0,
          messages = list(
            list(role = "system", 
                 content = paste(analysis_prompt, "\nHere is the article for you to code:", article_text))
          )
        ),
        encode = "json"
      )
    }, error = function(e) {
      message(paste("Error in case", i, "-", conditionMessage(e)))
      NULL
    })
    
    if (!is.null(response)) {
      # Überprüfe, ob die Antwort gültig ist
      response_content <- content(response, as = "parsed")
      if (!is.null(response_content$choices) && length(response_content$choices) > 0) {
        chatgpt_responses[i] <- response_content$choices[[1]]$message$content
        success <- TRUE
      } else {
        message("Empty response in case", i)
        success <- TRUE  
      }
    }
    
    if (!success) {
      retries <- retries + 1
      message(paste("Retrying case", i, "attempt", retries))
      exponential_backoff(retries)  
    }
  }
  
  cat("Finished case", i, "\n")
  Sys.sleep(2)  # to slower analysis
}

