#Load libraries----------------------------------------------------------------
library(tidyverse)
library(httr)
library(jsonlite)
library(readr)

#Load api Key & Prompt---------------------------------------------------------
analysis_prompt <- read_file("GPT API/Prompts.txt") |>  paste(collapse = " ")
api_key <- api_key <- readLines("Access Tokens/GPT API Key.txt")

#Load data---------------------------------------------------------------------
data <- read_csv("Data/Final_Articles.csv")
articles <- data |> 
  mutate(article_nr = 1:n(),
         content = as.character(content))



#Response vector--------------------------------------------------------------
chatgpt_responses <- vector("character", length = nrow(articles))

exponential_backoff <- function(retries) {
  
  Sys.sleep(2^retries)
}

#Classify function & loop ----------------------------------------------------
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


results_df <- articles %>%
  mutate(chatgpt_response = chatgpt_responses) %>%
  select(id, chatgpt_response)

#Dataset, assign dataframe-----------------------------------------------------
results_clean <- results_df %>%
  mutate(
    cleaned_response = chatgpt_response %>%
      str_remove_all("```.*?\\n?|```") %>%
      str_squish()
  )

results_split <- results_clean %>%
  separate(cleaned_response, into = paste0("code_", 1:5), sep = " ")

results_split %>% count(code_1)
results_split %>% count(code_2)
results_split %>% count(code_3)
results_split %>% count(code_4)
results_split %>% count(code_5)


#Write as CSV, safe dataset-------------------------------------------
write_csv(results_split, "Data/final_classified_articles.csv")