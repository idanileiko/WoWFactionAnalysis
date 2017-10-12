
## RealmPop Scraper in R

### Synopsis

The site [RealmPop]("http://realmpop.com/") contains data on World of Warcraft characters, races, classes, etc. for all of the different realms of the game. I was interested in the faction distributions over the different types of realms, specifically the differences between PvP and PvE realms. For this I scraped the following data from the [US Realms page]("https://realmpop.com/us.html"):

* Realm: Name & Type (PvP, PvE, RP)
* Realm Stats: Alliance population, Horde population

This scraper may get updated as I analyze more pieces of statistics from the website, such as character race or class choice preferences, regions, EU servers, etc.

The data source for the webpage is in JSON format found [here]("http://realmpop.com/us.json"). To reformat this into a data frame, I'm going to use the `R` package `jsonlite`, which is a fast JSON parser.




```r
library(jsonlite)
```

***

### Scrape the US realm JSON page for the realm list

Read in the data.


```r
# Read the JSON on the main page
URL <- "http://realmpop.com/us.json"

# convert JSON data to an R object
data <- fromJSON(URL, flatten=TRUE)

# loop over all the realms and converts the data into a data frame (assuming 9 columns of variables)
RealmPop <- lapply(data, function(realm){data.frame(matrix(unlist(realm), ncol=9, byrow=T))})
RealmPop <- do.call(rbind, RealmPop)

dim(RealmPop)
```

```
## [1] 26255     9
```

```r
tail(RealmPop)
```

```
##                      X1   X2   X3   X4   X5   X6   X7   X8   X9
## demographics.26003 <NA> <NA> <NA> <NA> <NA> <NA> <NA> <NA> <NA>
## demographics.26004 <NA> <NA> <NA> <NA> <NA> <NA> <NA> <NA> <NA>
## demographics.26005 <NA> <NA> <NA> <NA>   32 <NA> <NA> <NA> <NA>
## demographics.26006 <NA> <NA> <NA> <NA>   16 <NA> <NA> <NA> <NA>
## demographics.26007 <NA> <NA> <NA> <NA>    2 <NA> <NA> <NA> <NA>
## demographics.26008 <NA> <NA> <NA>    2 <NA> <NA> <NA> <NA> <NA>
```

As you can see, the tail-end of our data frame `RealmPop` shows that the JSON file has a lot more information than we need for the faction analysis (there's currently 26255 rows!). All I really need is the information for all the realms, not necessarily the demographics (maybe for a different analysis!). So I'll get rid of the extra data to make a smaller data frame.

I know that the last realm alphabetically is Zuluhed, so I want that to be the last row in the data frame.


```r
# Find the Zuluhed row in the data frame
index <- which(RealmPop$X1 == "Zuluhed")
index
```

```
## [1] 246
```

```r
# Keep only the realms rows
RealmPop <- RealmPop[1:index, ] 

dim(RealmPop)
```

```
## [1] 246   9
```

Now that I have the data I need, I'm going to clean up the data frame by renaming the columns and making sure that the numbers I'll need are a numeric class.


```r
# Keep only the columns I'm interested in
RealmPop <- RealmPop[ -c(4:5)]
colnames(RealmPop) <- c("RealmName", "Alliance", "Horde", "Type", "Roleplay", "Region", "TimeZone")

# Convert from factors to other classes
RealmPop$RealmName <- as.character(RealmPop$RealmName)
RealmPop$Alliance <- as.numeric(levels(RealmPop$Alliance))[RealmPop$Alliance]
RealmPop$Horde <- as.numeric(levels(RealmPop$Horde))[RealmPop$Horde]

head(RealmPop)
```

```
##            RealmName Alliance  Horde Type Roleplay        Region           TimeZone
## realms.1     Aegwynn    71705  71877  PvP   Normal United States America/Los_Angeles
## realms.2  Aerie Peak   275469  90698  PvE   Normal United States America/Los_Angeles
## realms.3   Agamaggan    24256  28345  PvP   Normal United States America/Los_Angeles
## realms.4    Aggramar   180922 106804  PvE   Normal United States America/Los_Angeles
## realms.5       Akama    29495  55193  PvP   Normal United States America/Los_Angeles
## realms.6 Alexstrasza   111128  59291  PvE   Normal United States America/Los_Angeles
## 
```

```r
str(RealmPop)
```

```
## 'data.frame':	246 obs. of  7 variables:
##  $ RealmName: chr  "Aegwynn" "Aerie Peak" "Agamaggan" "Aggramar" ...
##  $ Alliance : num  71705 275469 24256 180922 29495 ...
##  $ Horde    : num  71877 90698 28345 106804 55193 ...
##  $ Type     : Factor w/ 2 levels "PvE","PvP": 2 1 2 1 2 1 1 2 2 1 ...
##  $ Roleplay : Factor w/ 2 levels "Normal","RP": 1 1 1 1 1 1 1 1 1 1 ...
##  $ Region   : Factor w/ 4 levels "Brazil","Latin America",..: 4 4 4 4 4 4 4 4 4 3 ...
##  $ TimeZone : Factor w/ 3 levels "America/Los_Angeles",..: 1 1 1 1 1 1 1 1 1 3 ...
```

Save the data so we can use it for the analysis.


```r
# Save and timestamp the data
save(RealmPop, file = paste0("RealmPop_", format(Sys.Date(), "%m-%d-%Y"), ".Rda"))
```

