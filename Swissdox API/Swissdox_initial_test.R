# Submitting a query -----------------------------------------------------------

library(httr)

api_key <- readLines("API/API-Key.txt")
api_secret <- readLines("API/API-Secret.txt") 

headers <- add_headers(
  "X-API-Key" = api_key,
  "X-API-Secret" = api_secret
)

API_URL_QUERY <- "https://swissdox.linguistik.uzh.ch/api/query"

yaml_query <- "
query:
  sources:
    - ZWA
    - ZWAS
  dates:
    - from: 2022-12-01
      to: 2022-12-31
  languages:
    - de
    - fr
  content:
    AND:
      - OR:
          - COVID
          - Corona
      - NOT: China
      - NOT: chin*
result:
  format: TSV
  maxResults: 100
  columns:
    - id
    - pubtime
    - medium_code
    - medium_name
    - rubric
    - regional
    - doctype
    - doctype_description
    - language
    - char_count
    - dateline
    - head
    - subhead
    - content_id
    - content
version: 1.2
"

response <- POST(
  url = API_URL_QUERY,
  headers,
  body = list(
    query = yaml_query,
    name = "Query name 2", ##change name next time!!
    comment = "Query comment",
    expirationDate = "2025-12-28"
  ),
  encode = "form"
)

print(content(response, "parsed"))



#Checking the status of submitted queries--------------------------------------
library(httr)
library(jsonlite)

API_URL_STATUS <- "https://swissdox.linguistik.uzh.ch/api/status"

status_response <- GET(
  url = API_URL_STATUS,
  headers
)

status_content <- content(status_response, "text", encoding = "UTF-8")
status_json <- fromJSON(status_content)
print(status_json)


#Download of the retrieved dataset----------------------------------------------


download_url <- "https://swissdox.linguistik.uzh.ch/api/download/06092e04-63b2-4ee0-8861-b1984691a77f__2025_03_26T09_47_42.tsv.xz"

download_response <- GET(download_url, headers)

if (status_code(download_response) == 200) {
  writeBin(content(download_response, "raw"), "dataset.tsv.xz")
  cat("Download complete. File saved as dataset.tsv.xz\n")
} else {
  cat("Download failed:\n")
  print(content(download_response, "text"))
}


#Unzip & load data -------------------------------------------------------------

install.packages("R.utils")
library(R.utils)

gunzip("dataset.tsv.xz", destname = "dataset.tsv", remove = FALSE)
data <- read.delim("dataset.tsv", sep = "\t", encoding = "UTF-8")
head(data)

