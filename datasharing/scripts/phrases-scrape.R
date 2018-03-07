library(rtweet)
library(dplyr)

# Run auth.R


#####################################
# Collected data-driven and non-data-driven messages about Trump/Russia
#####################################

###### Search for tweets mentioning Trump and Russia
trump<-search_tweets(q = 'Russia Trump', include_rts=F, n = 10000, retryonratelimit = T)

##### Extract user information from tweets
trumpusers<-users_data(trump)
trumpusers <- trumpusers %>% distinct(user_id, .keep_all = TRUE)

##### Assign 0 for these tweets not necessarily mentioning data
trump$data <- 0

##### Conduct multiple searches mentioning Trump-Russia and different phrases indicating data references
trumpdata<-Map("search_tweets",
                  c('Trump Russia AND "graph shows" OR "graph reveals" OR "graph indicates" OR "graph suggests" OR "graph proves"',
                    'Trump Russia AND "chart shows" OR "chart reveals" OR "chart indicates" OR "chart suggests" OR "chart proves"',
                    'Trump Russia AND "map shows" OR "map reveals" OR "map indicates" OR "map suggests" OR "map proves"',
                    'Trump Russia AND "poll shows" OR "poll reveals" OR "poll indicates" OR "poll suggests" OR "poll proves"',
                    'Trump Russia AND "polling shows" OR "polling reveals" OR "polling indicates" OR "polling suggests" OR "polling proves"',
                    'Trump Russia AND "studies show" OR "studies reveal" OR "studies indicate" OR "studies suggest" OR "studies prove"',
                    'Trump Russia AND "study shows" OR "study reveals" OR "study indicates" OR "study suggests" OR "study proves"',
                    'Trump Russia AND "data shows" OR "data reveals" OR "data indicates" OR "data suggests" OR "data proves"',
                    'Trump Russia AND "data show" OR "data reveal" OR "data indicate" OR "data suggest" OR "data prove"',
                    'Trump Russia AND "figure shows" OR "figure reveals" OR "figure indicates" OR "figure suggests" OR "figure proves"'),
                  include_rts=F, n = 100000, retryonratelimit = T)

# Unlist into dataframe preserving rtweet's attributes
trumpdata<-do_call_rbind(trumpdata)

# Remove duplicates
trumpdata<-trumpdata %>% distinct(status_id, .keep_all = TRUE)

# Extract user information for each user
trumpdatausers<-users_data(trumpdata)

# Assign 1 for these tweets mentioning data
trumpdata$data <- 1

# Remove from non-data set any tweets found in set mentioning data
trump <- trump[!(trump$status_id %in% trumpdata$status_id),]

# Bind both groups of users into one dataframe
trumpusers<-rbind(trumpusers, trumpdatausers)

# Bind both sets of tweets into one dataframe
trump<-rbind(trump, trumpdata)

# Merge user info with tweet info
trump.df<-merge(unique(trump), unique(trumpusers), by="user_id")

trump.df <- trump.df %>% distinct(status_id, .keep_all = TRUE)


trump.df$media_type <- recode(as.character(trump.df$media_type), photo = "Photo", .missing = "No Photo")
trump.df$links <- ifelse(is.na(trump.df$urls_url), 0, 1)
trump.df$reply <- ifelse(is.na(trump.df$reply_to_screen_name), 0, 1)

trump.df[14:64] <- sapply(trump.df[14:64], function(x) unlist(x))

write.csv(trump.df, "data/trump-tweets-and-users.csv")


###########################################################

climate<-Map("search_tweets",
               c("climate change",
                 "global warming"),
                      include_rts=F, n = 10000, retryonratelimit = T)
climate<-do_call_rbind(climate)
climateusers<-users_data(climate)
climateusers <- climateusers %>% distinct(user_id, .keep_all = TRUE)
climate$data <- 0

climatedata<-Map("search_tweets",
                  c('global warming AND "graph shows" OR "graph reveals" OR "graph indicates" OR "graph suggests" OR "graph proves"',
                    'global warming AND "chart shows" OR "chart reveals" OR "chart indicates" OR "chart suggests" OR "chart proves"',
                    'global warming AND "map shows" OR "map reveals" OR "map indicates" OR "map suggests" OR "map proves"',
                    'global warming AND "poll shows" OR "poll reveals" OR "poll indicates" OR "poll suggests" OR "poll proves"',
                    'global warming AND "polling shows" OR "polling reveals" OR "polling indicates" OR "polling suggests" OR "polling proves"',
                    'global warming AND "studies show" OR "studies reveal" OR "studies indicate" OR "studies suggest" OR "studies prove"',
                    'global warming AND "study shows" OR "study reveals" OR "study indicates" OR "study suggests" OR "study proves"',
                    'global warming AND "data shows" OR "data reveals" OR "data indicates" OR "data suggests" OR "data proves"',
                    'global warming AND "data show" OR "data reveal" OR "data indicate" OR "data suggest" OR "data prove"',
                    'global warming AND "figure shows" OR "figure reveals" OR "figure indicates" OR "figure suggests" OR "figure proves"',
                    'climate change AND "graph shows" OR "graph reveals" OR "graph indicates" OR "graph suggests" OR "graph proves"',
                    'climate change AND "chart shows" OR "chart reveals" OR "chart indicates" OR "chart suggests" OR "chart proves"',
                    'climate change AND "map shows" OR "map reveals" OR "map indicates" OR "map suggests" OR "map proves"',
                    'climate change AND "poll shows" OR "poll reveals" OR "poll indicates" OR "poll suggests" OR "poll proves"',
                    'climate change AND "polling shows" OR "polling reveals" OR "polling indicates" OR "polling suggests" OR "polling proves"',
                    'climate change AND "studies show" OR "studies reveal" OR "studies indicate" OR "studies suggest" OR "studies prove"',
                    'climate change AND "study shows" OR "study reveals" OR "study indicates" OR "study suggests" OR "study proves"',
                    'climate change AND "data shows" OR "data reveals" OR "data indicates" OR "data suggests" OR "data proves"',
                    'climate change AND "data show" OR "data reveal" OR "data indicate" OR "data suggest" OR "data prove"',
                    'climate change AND "figure shows" OR "figure reveals" OR "figure indicates" OR "figure suggests" OR "figure proves"'),
                      include_rts=F, n = 100000, retryonratelimit = T)
climatedata <- do_call_rbind(climatedata)
climatedatausers <- users_data(climatedata)

climatedata$data <- 1

climate <- climate[!(climate$status_id %in% climatedata$status_id),]

climateusers<-rbind(climateusers, climatedatausers)
climate<-rbind(climate, climatedata)

climate.df<-merge(unique(climate), unique(climateusers), by="user_id")

climate.df<- climate.df %>% distinct(status_id, .keep_all = TRUE)

climate.df$media_type <- recode(as.character(climate.df$media_type), photo = "Photo", .missing = "No Photo")
climate.df$links <- ifelse(is.na(climate.df$urls_url), 0, 1)
climate.df$reply <- ifelse(is.na(climate.df$reply_to_screen_name), 0, 1)

climate.df[14:61] <- sapply(climate.df[14:61], function(x) unlist(x))
write.csv(climate.df, "data/climate-tweets-and-users.csv")

mod<-zelig(log(retweet_count+1) ~ followers_count + as.factor(data), data=subset(climate.df, is_retweet==FALSE & reply==0), model='ls', cite=F)
summary(mod)
qplot(climate.df$data, climate.df$retweet_count)

write.csv(rbind(trump.df, climate.df), "data-mentions.csv")



terror<-search_tweets(q = 'terrorism', include_rts=F, n = 20000)
terrorusers<-users_data(terror)
terrordata<-search_tweets(q = 'terrorism AND "graph" OR "chart" OR "map" OR "data" OR "poll" OR "study"', include_rts=F, n = 100000, retryonratelimit = T)
terrordatausers<-users_data(terrordata)

terror<-search_tweets(q = 'terrorism', include_rts=F, n = 20000)
terrorusers<-users_data(terror)
terrordata<-search_tweets(q = 'terrorism AND "graph" OR "chart" OR "map" OR "data" OR "poll" OR "study"', include_rts=F, n = 100000, retryonratelimit = T)
terrordatausers<-users_data(terrordata)

                              "graph shows" OR "graph reveals" OR "graph indicates" OR "graph suggests" OR "graph proves" OR
                              "chart shows" OR "chart reveals" OR "chart indicates" OR "chart suggests" OR "chart proves" OR
                              "map shows" OR "map reveals" OR "map indicates" OR "map suggests" OR "map proves" OR
                              "poll shows" OR "poll reveals" OR "poll indicates" OR "poll suggests" OR "poll proves" OR
                              "polling shows" OR "polling reveals" OR "polling indicates" OR "polling suggests" OR "polling proves" OR
                              "figure shows" OR "figure reveals" OR "figure indicates" OR "figure suggests" OR "figure proves" OR
                              "data show" OR "data reveal" OR "data indicate" OR "data suggest" OR "data prove" OR
                              "data shows" OR "data reveals" OR "data indicates" OR "data suggests" OR "data proves" OR
                              "study shows" OR "study reveals" OR "study indicates" OR "study suggests" OR "study proves" OR
                              "studies show" OR "studies reveal" OR "studies indicate" OR "studies suggest" OR "studies prove"', include_rts=F, n = 100000)

                          
data_tweets<-search_tweets(q = '"graph shows" OR "chart shows" OR "map shows" OR "figure shows" OR "data shows" OR "data shows"', include_rts=F, n = 1000)
data_tweets<-search_tweets(q = '"this poll" OR "polling data" OR "polling shows" OR "new poll"', include_rts=F, n = 1000)
data_tweets<-search_tweets(q = '"scien" OR "polling data" OR "polling shows" OR "new poll"', include_rts=F, n = 1000)





