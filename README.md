# Swiss Media Discourse on Immigration

LUMACSS Capstone Project

## Overview

This project analyzes how immigration is represented in Swiss print media, especially during periods of heightened political salience (national initiatives/referendums). Using large-scale newspaper data and GPT-based classification, the project identifies frames, emotional tone, and oppositional narratives in coverage across ideologically diverse outlets.

## Pipeline

**1. Data Collection via Swissdox API**

Filtered by:

-   Keywords (e.g. Einwanderung, Asyl, Zuwanderung, Flüchtlinge, etc.)

-   Newspapers: BAZ, Blick, Weltwoche, WOZ, NZZ, SRF, Tages-Anzeiger

-   Time frames: 3 weeks before + 1 week after major immigration-related initiatives (e.g., Masseneinwanderung, Begrenzungsinitiative, etc.)

Resulting in \~1731 articles, of which 1025 were successfully classified by GPT, and 772 were marked relevant. \
Extract and clean full article text

**2. Article Classification via GPT 4.0 API**

Prompt contained 5 classification tasks:

-   Relevance: Is the article about immigration in a Swiss context?

-   Indirect Mention: Is immigration just a minor part of the article?

-   Framing: How is immigration framed? (Economic, Cultural, Legal, etc.)

-   Sentiment: What emotional tone is used?

-   Oppositional Construction: Does the article construct a “Swiss vs. Migrants” narrative?

Prompt includes examples, definitions and instructions. \
Output saved as structured CSV and merged with article metadata.

**3. Data Cleaning & Recoding**

Rare frame and sentiment categories collapsed:

-   Frame 2, 3, and 0 → “Other”

-   Sentiment 1 & 2 → “Positive”; 5, 7, 0 → “Other”

## Analysis & Visualization

-   Descriptive Analysis: distribution of frames, sentiments, oppositions. Differences across newspapers.
-   Regression: multinom() for frame & sentiment by newspaper, glm() (logistic regression) for constructed oppositions by newspaper.

## Scripts Documentation

00_Testing: initial tests for the Swissdox API & GPT API \
01_Swissdox API: Script for the Swissdox API article extraction \
02_Data_Cleaning: Script for cleaning of articles \
03_GPT_API: Script for the GPT classification, promt for the classification \
04_Data_Analysis: Script for the analysis of frames, sentiments, oppositions \
05_Outputs: Plots of the analysis \
06_Report: Final report in .qmd and pfd form
