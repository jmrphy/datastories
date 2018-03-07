library(rtweet)
library(dplyr)

# Run auth.R

tweets<-search_tweets('Brexit', n = 17500,
                      include_rts = F,
                      retryonratelimit = T)

brexit_users <- users_data(tweets)

tweets_and_users <- merge(tweets, brexit_users, all.x = T, "user_id")
tweets_and_users <- distinct(tweets_and_users, status_id, .keep_all = TRUE)

tweets_and_users[14:61] <- sapply(tweets_and_users[14:61], function(x) unlist(x))

write.csv(tweets_and_users, file="data/brexit-tweets-and-users.csv")
