library(rtweet)
library(dplyr)

# This script should not be run again, as it precedes the hand-coding for data-driven messages
# Its outputted data, djs-tweets.csv, becomes djs-hand-coded.csv
# If you re-run it, it will not replicate because it will be different tweets

# Must run Twitter app authorization

# First round, data journalists from followerwonk
dj1 <- get_timeline("jordstyles", n = 200)
dj2 <- get_timeline("Rukmini", n = 200)
dj3 <- get_timeline("guidoromeo", n = 200)
dj4 <- get_timeline("mccandelish", n = 200)
dj5 <- get_timeline("martinstabe", n = 200)
dj6 <- get_timeline("stiles", n = 200)
dj7 <- get_timeline("Phanyxx", n = 200)
dj8 <- get_timeline("TWallack", n = 200)
dj9 <- get_timeline("MawuliTsikata", n = 200)
dj10 <- get_timeline("ryanmartin", n = 200)

# Second round. January 22, 2018
dj11 <- get_timeline("maartenzam", n = 200)
dj12 <- get_timeline("Sherrell_Dorsey", n = 200)
dj13 <- get_timeline("chadskelton", n = 200)
dj14 <- get_timeline("michelleminkoff", n = 200)
dj15 <- get_timeline("KathyPennacchio", n = 200)
dj16 <- get_timeline("SophieWarnes", n = 200)
dj17 <- get_timeline("jgro_the", n = 200)
dj18 <- get_timeline("DataMinerUK", n = 200)
dj19 <- get_timeline("miketaylorsport", n = 200)
dj20 <- get_timeline("ian_a_jones", n = 200)

dj<-rbind(dj1, dj2, dj3, dj4, dj5, dj6, dj7, dj8, dj9, dj10,
          dj11, dj12, dj13, dj14, dj15, dj16, dj17, dj18, dj19, dj20)


dj[14:42] <- sapply(dj[14:42], function(x) unlist(x))

# Due to large time costs and low percentage of data-driven messages,
# here I experimented with different ways of narrowing down tweets
# from dj10-dj20 to more data-oriented tweets.
# In short, the sample used for training is arbitrary.

write.csv(dj, file="djs-tweets.csv")

users <- c("jordstyles", "Rukmini", "guidoromeo", "mccandelish", "martinstabe", "stiles",
            "Phanyxx", "TWallack", "MawuliTsikata", "ryanmartin", "maartenzam",
           "Sherrell_Dorsey", "chadskelton", "michelleminkoff", "KathyPennacchio",
           "SophieWarnes", "jgro_the", "DataMinerUK", "miketaylorsport", "ian_a_jones")

djs <- lookup_users(users)

write.csv(djs, file="djs_users.csv")
