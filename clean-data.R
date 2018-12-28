# sort out data for all outlets
# Manhattan and Bronx only

setwd("G:/Dr.Brian Elbel's Projects/CURRENT PROJECTS/GEO R01/Data/Food Environment Data/data-requests/Sean-Lucan-request/v2_raw-data")
#### retail food stores 2016-2018 ----
retail1618 <- read.csv("Record 1.csv", stringsAsFactors = FALSE, strip.white = TRUE)
names(retail1618)
table(retail1618$CtyName)

# select Manhattan and Bronx only
retail1618 <- subset(retail1618, subset=(retail1618$CtyName=="Bronx"|retail1618$CtyName=="New York"))

# delete unecessary vars
retail1618 <- retail1618[, c(1:3, 6:7)]
names(retail1618)
colnames(retail1618) <- c("boro", "id", "inspection_Date", "name", "address")

# cleaning up
head(retail1618)
retail1618$date <- substr(retail1618$inspection_Date, 1, 2)
retail1618$month <- substr(retail1618$inspection_Date, 4, 6)
retail1618$year <- substr(retail1618$inspection_Date, 8, 9)

retail1618$month[retail1618$month=="Jan"] <- "01"
retail1618$month[retail1618$month=="Feb"] <- "02"
retail1618$month[retail1618$month=="Mar"] <- "03"
retail1618$month[retail1618$month=="Apr"] <- "04"
retail1618$month[retail1618$month=="May"] <- "05"
retail1618$month[retail1618$month=="Jun"] <- "06"
retail1618$month[retail1618$month=="Jul"] <- "07"
retail1618$month[retail1618$month=="Aug"] <- "08"
retail1618$month[retail1618$month=="Sep"] <- "09"
retail1618$month[retail1618$month=="Oct"] <- "10"
retail1618$month[retail1618$month=="Nov"] <- "11"
retail1618$month[retail1618$month=="Dec"] <- "12"
table(retail1618$month)
class(retail1618$month)

retail1618$inspection_date <- paste("20", retail1618$year, "-", retail1618$month, "-", retail1618$date, sep="")
class(retail1618$inspection_date)
retail1618$inspection_date <- as.Date(retail1618$inspection_date)
names(retail1618)
retail1618 <- retail1618[, c(1:2, 4:5, 9)]
retail1618 <- retail1618[order(retail1618$id, retail1618$inspection_date), ]

#### read retail food stores 2015 ----
retail2015 <- read.csv("RetailFoodStore_NYC_Inspections_2015.csv",
                       stringsAsFactors = FALSE, strip.white = TRUE)
names(retail2015)
retail2015 <- retail2015[, c(2, 4:6, 12)]
colnames(retail2015) <- c("id", "name", "address", "boro", "inspection_date")
retail2015 <- subset(retail2015,
                     subset=(retail2015$boro=="NEW YORK"|retail2015$boro=="4EW YORK"|retail2015$boro=="BRONX"))
retail2015 <- na.omit(retail2015)

for (i in 1:length(retail2015$id)) {
      retail2015$month[i] <- strsplit(retail2015$inspection_date[i], split = "/")[[1]][1]
      retail2015$date[i] <- strsplit(retail2015$inspection_date[i], split = "/")[[1]][2]
      retail2015$year[i] <- strsplit(retail2015$inspection_date[i], split = "/")[[1]][3]
}

retail2015$inspection_date <- paste(retail2015$year, "-", retail2015$month, "-",
                                    retail2015$date, sep="")
names(retail2015)
retail2015 <- retail2015[, c(1:5)]

#### read retail stores 2005-2014 ----
################################################################################
# run these codes in Stata first
# b/c NYS Ag & Mkts sent me data via FOIL
# but the data are formatted in a soul crushing way
# possibly a different encoding...
#foreach var in 06 07 08 09 10 11 12 13 14 {
#      import excel "G:\Dr.Brian Elbel's Projects\CURRENT PROJECTS\GEO R01\Data\Ag & Markets\Ag and Markets - Raw\RetailFoodStore_NYC_Inspections_20`var'.xlsx", sheet("qry_FOILno_14_43") firstrow clear
#      keep ESTABNO TRADENAME STREET CITY INSPDATE
#      rename ESTA id
#      rename TRADENAME name
#      rename STREET address
#      rename CITY boro
#      rename INSPDATE inspection_date
#      *keep if boro=="BRONX"|boro=="NEW YORK"
#      export delimited using "G:\Dr.Brian Elbel's Projects\CURRENT PROJECTS\GEO R01\Data\Food Environment Data\data-requests\Sean-Lucan-request\v2_raw-data\retailFoodStore_inspection_20`var'.csv", replace
#}
#.
################################################################################
retail <- read.csv("retailFoodStore_inspection_2006.csv",
                   stringsAsFactors = FALSE, strip.white = TRUE)
table(retail$boro)
retail <- subset(retail, 
                 subset=(retail$boro=="NEW YORK"|retail$boro=="4EW YORK"|retail$boro=="BRONX"))

head(retail)
retail$date <- substr(retail$inspection_date, 1, 2)
retail$month <- substr(retail$inspection_date, 3, 5)
retail$year <- substr(retail$inspection_date, 6, 9)

retail$month[retail$month=="jan"] <- "01"
retail$month[retail$month=="feb"] <- "02"
retail$month[retail$month=="mar"] <- "03"
retail$month[retail$month=="apr"] <- "04"
retail$month[retail$month=="may"] <- "05"
retail$month[retail$month=="jun"] <- "06"
retail$month[retail$month=="jul"] <- "07"
retail$month[retail$month=="aug"] <- "08"
retail$month[retail$month=="sep"] <- "09"
retail$month[retail$month=="oct"] <- "10"
retail$month[retail$month=="nov"] <- "11"
retail$month[retail$month=="dec"] <- "12"
table(retail$month)
class(retail$month)

retail$inspection_date <- paste(retail$year, "-", retail$month, "-", retail$date, sep="")
retail <- retail[, c(1:5)]

years <- c("07", "08", "09", "10", "11", "12", "13", "14") 
for (i in years) {
      retail1 <- read.csv(paste("retailFoodStore_inspection_20", i, ".csv", sep=""),
                         stringsAsFactors = FALSE, strip.white = TRUE)
      table(retail1$boro)
      retail1 <- subset(retail1, 
                       subset=(retail1$boro=="NEW YORK"|retail1$boro=="4EW YORK"|retail1$boro=="BRONX"))
      #head(retail1)
      retail1$date <- substr(retail1$inspection_date, 1, 2)
      retail1$month <- substr(retail1$inspection_date, 3, 5)
      retail1$year <- substr(retail1$inspection_date, 6, 9)
      retail1$month[retail1$month=="jan"] <- "01"
      retail1$month[retail1$month=="feb"] <- "02"
      retail1$month[retail1$month=="mar"] <- "03"
      retail1$month[retail1$month=="apr"] <- "04"
      retail1$month[retail1$month=="may"] <- "05"
      retail1$month[retail1$month=="jun"] <- "06"
      retail1$month[retail1$month=="jul"] <- "07"
      retail1$month[retail1$month=="aug"] <- "08"
      retail1$month[retail1$month=="sep"] <- "09"
      retail1$month[retail1$month=="oct"] <- "10"
      retail1$month[retail1$month=="nov"] <- "11"
      retail1$month[retail1$month=="dec"] <- "12"
      table(retail1$month)
      class(retail1$month)
      retail1$inspection_date <- paste(retail1$year, "-", retail1$month, "-", retail1$date, sep="")
      retail1 <- retail1[, c(1:5)]
      retail <- rbind(retail, retail1)
}

retail$year <- substr(retail$inspection_date, 1, 4)
table(retail$year) #sanity check
retail$year <- NULL

retail <- rbind(retail, retail2015, retail1618)
retail$data_source <- "Ag & Mkts"

#### read restaurants ----
inspection <- read.csv("inspection_data_1207_0418.csv", stringsAsFactors = FALSE, 
                       sep="\t")
names(inspection) #keep entity id and inspection date
inspection <- inspection[, c(5:6)]
inspection$inspection_date <- substr(inspection$inspection_date, 1, 10)

# read .dta file in current food env data
# merge on entity_id var
restaurants <- read.csv("entity_list_1207_0418.csv", header = FALSE, 
                          sep="\t", skip = 1, stringsAsFactors = FALSE)
head(restaurants)
restaurants <- restaurants[, c(1:4)]
colnames(restaurants) <- c("entity_id", "name", "address", "boro")

restaurants.all <- merge(restaurants, inspection, by="entity_id")
restaurants.all <- subset(restaurants.all,
                          subset=(restaurants.all$boro=="Bronx"|restaurants.all$boro=="Manhattan"))
names(restaurants.all)
colnames(restaurants.all)[1] <- "id"
restaurants.all$data_source <- "restaurant grading"

#### combine and export ----
food <- rbind(retail, restaurants.all)
names(food)
head(food)

food <- food[order(food$data_source, food$id, food$inspection_date), ]
table(food$boro)
food$boro[food$boro=="4EW YORK"|food$boro=="NEW YORK"|food$boro=="New York"] <- "Manhattan"
food$boro[food$boro=="BRONX"] <- "Bronx"
table(food$data_source)

write.csv(food, "food_outlets_inspection_2006-2015.csv")

rm(retail1, i, years, retail2015, inspection, restaurants, retail1618, restaurants.all, retail)


