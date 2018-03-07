###################################
# Use djs-classify model on new tweets
###################################

glmnet_classifier <- readRDS("data/djs-classifier-glmnet.RDS")

brexit.tweets <- read.csv("data/brexit-tweets-and-users.csv")

brexit.tweets$text<-conv_fun(brexit.tweets$text)
brexit.tweets <- subset(brexit.tweets, lang=="en")

brexit.tweets$text = gsub("&amp", "", brexit.tweets$text)
brexit.tweets$text = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", brexit.tweets$text)
brexit.tweets$text = gsub("@\\w+", "", brexit.tweets$text)
brexit.tweets$text = gsub(":", "", brexit.tweets$text) #not all punctuation, just colons leftover from RTs
brexit.tweets$text <- str_replace_all(brexit.tweets$text, "http\\S+\\s*", "") #urls 

brexit.tweets <- subset(brexit.tweets, is_retweet==FALSE)

# preprocessing and tokenization
it_brexit.tweets <- itoken(as.character(brexit.tweets$text),
                    preprocessor = prep_fun,
                    tokenizer = tok_fun,
                    ids = brexit.tweets$status_id,
                    progressbar = TRUE)

# creating vocabulary and document-term matrix
dtm_brexit.tweets <- create_dtm(it_brexit.tweets, vectorizer)

# transforming data with tf-idf
dtm_brexit.tweets_tfidf <- fit_transform(dtm_brexit.tweets, tfidf)

# predict probabilities of positiveness
preds_brexit.tweets <- predict(glmnet_classifier, dtm_brexit.tweets_tfidf, type = 'response')[ ,1]

# adding rates to initial dataset
brexit.tweets$datacont <- preds_brexit.tweets
brexit.tweets$datadriven <- ifelse(brexit.tweets$datacont>.6, 1, 0)

examples<-subset(brexit.tweets, datacont>.75)
# head(examples[c("text")], 10)

brexit.tweets$media_type <- recode(as.character(brexit.tweets$media_type), photo = "Photo", .missing = "No Photo")
brexit.tweets$links <- ifelse(is.na(brexit.tweets$urls_url), 0, 1)
brexit.tweets$reply <- ifelse(is.na(brexit.tweets$reply_to_screen_name), 0, 1)

write.csv(brexit.tweets, "data/brexit-classified.csv")
