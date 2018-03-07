library(tidyverse)
library(purrrlyr)
library(text2vec)
library(caret)
library(glmnet)
library(ggrepel)

### The following works closely from https://analyzecore.com/2017/02/08/twitter-sentiment-analysis-doc2vec/?utm_campaign=Submission&utm_medium=Community&utm_source=GrowthHackers.com

### Load and preprocess a set of tweets from data journalists

# Function for dealing with irregular symbols
conv_fun <- function(x) iconv(x, "latin1", "ASCII", "")

# Load while cleaning some irregular symbols
tweets_classified <- read_csv('data/djs-hand-coded.csv') %>%
  # converting some symbols
  dmap_at('text', conv_fun)

# Merge in user information scraped in djs-scrape.R
djs <-read.csv("data/djs-users.csv")
tweets_classified <- merge(tweets_classified, djs, by="user_id")

# Assign 1 to tweets coded 'y' and 0 to tweets not coded as 'y'
tweets_classified$data <- recode(tweets_classified$data, y = 1)
tweets_classified$data[is.na(tweets_classified$data)] <- 0

# Write combo of tweets and user info to a .csv for later
# write.csv(tweets_classified, file="data/djs-coded-with-users.csv")

# Othe processing: removes ampersands, RT and/or via, @, :, and URLs
tweets_classified$text = gsub("&amp", "", tweets_classified$text)
tweets_classified$text = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", tweets_classified$text)
tweets_classified$text = gsub("@\\w+", "", tweets_classified$text)
tweets_classified$text = gsub(":", "", tweets_classified$text) #not all punctuation, just colons leftover from RTs
tweets_classified$text <- str_replace_all(tweets_classified$text, "http\\S+\\s*", "") #urls 

tweets_classified <- subset(tweets_classified, lang=="en")

# Convert numeric status id to character
tweets_classified$status_id <- as.character(tweets_classified$status_id)

# there are some tweets with NA ids that we replace with dummies
# tweets_classified_na <- tweets_classified %>%
#   filter(is.na(status_id) == TRUE) %>%
#   mutate(id = c(1:n()))
# tweets_classified <- tweets_classified %>%
#   filter(!is.na(id)) %>%
#   rbind(., tweets_classified_na)

# Split data into train and test
set.seed(2340)
trainIndex <- createDataPartition(tweets_classified$data, p = 0.7, 
                                  list = FALSE, 
                                  times = 1)
tweets_train <- tweets_classified[trainIndex, ]
tweets_test <- tweets_classified[-trainIndex, ]

#### Vectorization
# define preprocessing function and tokenization function

prep_fun <- tolower
tok_fun <- word_tokenizer

it_train <- itoken(tweets_train$text, 
                   preprocessor = prep_fun, 
                   tokenizer = tok_fun,
                   ids = tweets_train$status_id,
                   progressbar = TRUE)
it_test <- itoken(tweets_test$text, 
                  preprocessor = prep_fun, 
                  tokenizer = tok_fun,
                  ids = tweets_test$status_id,
                  progressbar = TRUE)

# creating vocabulary and document-term matrix
vocab <- create_vocabulary(it_train)
vectorizer <- vocab_vectorizer(vocab)
dtm_train <- create_dtm(it_train, vectorizer)
dtm_test <- create_dtm(it_test, vectorizer)
# define tf-idf model
tfidf <- TfIdf$new()
# fit the model to the train data and transform it with the fitted model
dtm_train_tfidf <- fit_transform(dtm_train, tfidf)
dtm_test_tfidf <- fit_transform(dtm_test, tfidf)

# train the model
t1 <- Sys.time()
glmnet_classifier <- cv.glmnet(x = dtm_train_tfidf,
                               y = tweets_train[['data']], 
                               family = 'binomial', 
                               # L1 penalty
                               alpha = 1,
                               # interested in the area under ROC curve
                               type.measure = "auc",
                               # 5-fold cross-validation
                               nfolds = 7)
print(difftime(Sys.time(), t1, units = 'mins'))

plot(glmnet_classifier)
# print(paste("max AUC =", round(max(glmnet_classifier$cvm), 4)))

preds <- predict(glmnet_classifier, dtm_test_tfidf, type = 'response')[ ,1]
# auc(as.numeric(tweets_test$data), preds)

############### save the model for future using
saveRDS(glmnet_classifier, 'data/djs-classifier-glmnet.RDS')
#######################################################
