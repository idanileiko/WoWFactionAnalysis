# Analyze RealmPop.com data

# Load in the data frame; change the timestamp date to match the file that is saved
timestamp <- "10-12-2017"
filename <- paste0("RealmPop_", timestamp, ".Rda")
load(filename)

# Load packages
library(ggplot2)
library(reshape2)

# Separate into PvP and PvE realms
PvPrealms <- subset(RealmPop, Type == "PvP")
PvErealms <- subset(RealmPop, Type == "PvE")

# Calculate total characters in a realm
totalPvP <- PvPrealms$Alliance + PvPrealms$Horde
totalPvE <- PvErealms$Alliance + PvErealms$Horde

# Convert Alliance and Horde columns into proportions of total characters
PvPrealms$Alliance <- PvPrealms$Alliance / totalPvP
PvPrealms$Horde <- PvPrealms$Horde / totalPvP

PvErealms$Alliance <- PvErealms$Alliance / totalPvE
PvErealms$Horde <- PvErealms$Horde / totalPvE

# Order the data frame by proportion of Alliance characters
PvPrealms <- PvPrealms[order(PvPrealms$Alliance), ]
PvErealms <- PvErealms[order(PvErealms$Alliance), ]

# Reformat PvP data
PvPdata <- melt(PvPrealms)
names(PvPdata)[6] <- "Faction"
names(PvPdata)[7] <- "Proportion"
PvPdata$RealmName <- factor(PvPdata$RealmName, levels = PvPdata$RealmName)

# Reformat PvE data
PvEdata <- melt(PvErealms)
names(PvEdata)[6] <- "Faction"
names(PvEdata)[7] <- "Proportion"
PvEdata$RealmName <- factor(PvEdata$RealmName, levels = PvEdata$RealmName)

# Plot of faction proportions for PvP data
ggplot(PvPdata, aes(x = RealmName, y = Proportion, fill = Faction)) + 
  geom_bar(stat="identity", position = "stack") +
  coord_flip() + scale_fill_manual(values=c("#033069", "#9e0e03")) +
  labs(title= "PvP Realm Distribution", y = "Proportion of Population", x = "Realm") +
  scale_x_discrete(breaks = NULL)

# Plot of faction proportions for PvE data
ggplot(PvEdata, aes(x = RealmName, y = Proportion, fill = Faction)) + 
  geom_bar(stat="identity", position = "fill") +
  coord_flip() + scale_fill_manual(values=c("#033069", "#9e0e03")) +
  labs(title= "PvE Realm Distribution", y = "Proportion of Population", x = "Realm") +
  scale_x_discrete(breaks = NULL)

# How many realms in PvP and PvE have a Alliance/Horde ratio between 0.40 and 0.60?
sum(PvPrealms$Alliance >= 0.40 & PvPrealms$Alliance <= 0.60)
sum(PvErealms$Alliance >= 0.40 & PvErealms$Alliance <= 0.60)

# How many realms in PvP and PvE have a Alliance/Horde ratio under 0.30 or over 0.70?
sum(PvPrealms$Alliance <= 0.30 | PvPrealms$Alliance >= 0.70)
sum(PvErealms$Alliance <= 0.30 | PvErealms$Alliance >= 0.70)


# Stats on populations of PvP and PvE realms
stats <- matrix(c(min(totalPvP), max(totalPvP), mean(totalPvP), median(totalPvP), sd(totalPvP),
                  min(totalPvE), max(totalPvE), mean(totalPvE), median(totalPvE), sd(totalPvE)),
                ncol=2,byrow=FALSE)
colnames(stats) <- c("PvP","PvE")
rownames(stats) <- c("minimum", "maximum", "mean", "median", "sd")
stats <- as.table(stats)

# Add a total population column to the original data frame
RealmPop$Total <- RealmPop$Alliance + RealmPop$Horde

# Subset by PvP and PvE again
PvPpop <- subset(RealmPop, Type == "PvP")
PvEpop <- subset(RealmPop, Type == "PvE")

# Get the 10 most populated PvP realms
PvPpop <- PvPpop[order(PvPpop$Total), ]
PvPpopTop <- tail(PvPpop, 10)
# Subset PvP data for graphing by the top populated realms
PvPdataTop <- PvPdata[PvPdata$RealmName %in% PvPpopTop$RealmName, ]

# Get the 10 most populated PvE realms
PvEpop <- PvEpop[order(PvEpop$Total), ]
PvEpopTop <- tail(PvEpop, 10)
# Subset PvE data for graphing by the top populated realms
PvEdataTop <- PvEdata[PvEdata$RealmName %in% PvEpopTop$RealmName, ]

# Plot of faction proportions for PvP top population data
ggplot(PvPdataTop, aes(x = RealmName, y = Proportion, fill = Faction)) + 
  geom_bar(stat="identity", position = "stack") +
  coord_flip() + scale_fill_manual(values=c("#033069", "#9e0e03")) +
  labs(title= "PvP Realm Distribution", y = "Proportion of Population", x = "Realm")

# Plot of faction proportions for PvE top population data
ggplot(PvEdataTop, aes(x = RealmName, y = Proportion, fill = Faction)) + 
  geom_bar(stat="identity", position = "fill") +
  coord_flip() + scale_fill_manual(values=c("#033069", "#9e0e03")) +
  labs(title= "PvE Realm Distribution", y = "Proportion of Population", x = "Realm")

# Subset PvP data for calculating ratios
PvPrealmsTop <- PvPrealms[PvPrealms$RealmName %in% PvPpopTop$RealmName, ]

# Subset PvE data for calculating ratios
PvErealmsTop <- PvErealms[PvErealms$RealmName %in% PvEpopTop$RealmName, ]

# How many top populated realms in PvP and PvE have a Alliance/Horde ratio between 0.40 and 0.60?
sum(PvPrealmsTop$Alliance >= 0.40 & PvPrealmsTop$Alliance <= 0.60)
sum(PvErealmsTop$Alliance >= 0.40 & PvErealmsTop$Alliance <= 0.60)

# How many top populated realms in PvP and PvE have a Alliance/Horde ratio under 0.30 or over 0.70?
sum(PvPrealmsTop$Alliance <= 0.30 | PvPrealmsTop$Alliance >= 0.70)
sum(PvErealmsTop$Alliance <= 0.30 | PvErealmsTop$Alliance >= 0.70)

# Are there more Horde characters in PvP realms?

# Number of Horde & Alliance Numbers on the realms
factionNum <- matrix(c(sum(PvPpop$Alliance), sum(PvPpop$Horde), sum(PvEpop$Alliance), sum(PvEpop$Horde)),
                     ncol=2,byrow=FALSE)
colnames(factionNum) <- c("PvP","PvE")
rownames(factionNum) <- c("Alliance", "Horde")
factionNum <- as.table(factionNum)
factionNum

# Proportion of Horde & Alliance Numbers on the realms
factionPop <- matrix(c(sum(PvPpop$Alliance)/sum(PvPpop$Total), sum(PvPpop$Horde)/sum(PvPpop$Total),
                  sum(PvEpop$Alliance)/sum(PvEpop$Total), sum(PvEpop$Horde)/sum(PvEpop$Total)),
                ncol=2,byrow=FALSE)
factionPop <- round(factionPop,3)
colnames(factionPop) <- c("PvP","PvE")
rownames(factionPop) <- c("Alliance", "Horde")
factionPop <- as.table(factionPop)
factionPop
