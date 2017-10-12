# Scrape RealmPop.com Data

# Load packages
library(jsonlite)

# Read the JSON on the main page
URL <- "http://realmpop.com/us.json"

# convert JSON data to an R object
data <- fromJSON(URL, flatten=TRUE)

# loop over all the realms and converts the data into a data frame (assuming 9 columns of variables)
RealmPop <- lapply(data, function(realm){data.frame(matrix(unlist(realm), ncol=9, byrow=T))})
RealmPop <- do.call(rbind, RealmPop)

# Find the Zuluhed row in the data frame
index <- which(RealmPop$X1 == "Zuluhed")

# Keep only the realms rows
RealmPop <- RealmPop[1:index, ]

# Keep only the columns I'm interested in
RealmPop <- RealmPop[ -c(4:5)]
colnames(RealmPop) <- c("RealmName", "Alliance", "Horde", "Type", "Roleplay", "Region", "TimeZone")

# Convert from factors to other classes
RealmPop$RealmName <- as.character(RealmPop$RealmName)
RealmPop$Alliance <- as.numeric(levels(RealmPop$Alliance))[RealmPop$Alliance]
RealmPop$Horde <- as.numeric(levels(RealmPop$Horde))[RealmPop$Horde]

str(RealmPop)

# Save and timestamp the data
save(RealmPop, file = paste0("RealmPop_", format(Sys.Date(), "%m-%d-%Y"), ".Rda"))
