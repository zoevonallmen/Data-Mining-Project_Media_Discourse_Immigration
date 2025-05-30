# Submitting a query -----------------------------------------------------------

library(httr)

api_key <- readLines("Access Tokens/API-Key.txt")
api_secret <- readLines("Access Tokens/API-Secret.txt") 


headers <- add_headers(
  "X-API-Key" = api_key,
  "X-API-Secret" = api_secret
)

API_URL_QUERY <- "https://swissdox.linguistik.uzh.ch/api/query"

yaml_query <- "
query:
  sources:
    - BAZ 
    - BLI
    - WOZ
    - WEW
    - SRF
    - NZZ
    - TA
  dates:
    - from: 2000-06-24
      to: 2000-10-24
    - from: 2013-11-09
      to: 2014-03-09
    - from: 2014-08-30
      to: 2014-12-30
    - from: 2020-06-27
      to: 2020-10-27  
  languages:
    - de
  content:
    AND:
      - OR:
              - einwander*
              - zuwander*
              - asyl*
              - flüchtling*
              - Personenfreizügigkeit
              - überfremdung
              - migrationspolitik
              - migrationsabkommen
              - abschiebung
              - integrationspolitik
result:
  format: TSV
  maxResults: 500000
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
    name = "Immigration Unlimited", ##change name next time!!
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


query_id <- "83a0d4e9-1570-408d-85a2-a5eb57cacca1"
download_url <- "https://swissdox.linguistik.uzh.ch/api/download/83a0d4e9-1570-408d-85a2-a5eb57cacca1__2025_04_01T13_26_45.tsv.xz"


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

gunzip("dataset.tsv.xz", destname = "Immigration_Articles_Unlimited.tsv", remove = FALSE)

# Load the data into R
data <- read.delim("Data/Immigration_Articles_Unlimited.tsv", sep = "\t", encoding = "UTF-8")

# Preview the first few rows
head(data)


