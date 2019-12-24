##########################################
## Joyce Quach                          ##
## MATH 345                             ##
## Prof. David Degras                   ##
## MBTA Project - Bus Ridership Trends  ##
##########################################

require(tidyverse)
require(grid)
require(gridExtra)

# -------------------------------------------------------------------------- #
# ------ Importing Data - Feel free to comment out for replication --------- #
# -------------------------------------------------------------------------- #

## $ is used to extract elements by name from a named list
## %>% is used to redirect left side as input to the right side
## substring(x, first, last) 

## Bus Route Direction Composite Day
#setwd("~/GitHub/mbta_bus_ridership_trends/Data/Ridership/Bus Route Direction Composite Day/2017-2018")
#brdcd <- list.files(pattern=".csv")
#brdcd <- brdcd %>% map_dfr(read.csv)

## Bus Route Trip Stop Composite Day
#setwd("~/GitHub/mbta_bus_ridership_trends/Data/Ridership/Bus Route Trip Stop Composite Day/2017-2018")
#brtscd <- list.files(pattern=".csv")
#brtscd1 <- read.csv(brtscd[1], header=T, fill=T)
#brtscd2 <- read.csv(brtscd[2], header=T, fill=T)

## Bus Stop Composite Day
#setwd("~/GitHub/mbta_bus_ridership_trends/Data/Ridership/Bus Stop Composite Day/2017-2018")
#bscd <- list.files(pattern=".csv")
#bscd <- bscd %>% map_dfr(read.csv)

## Write into CSVs for backups
#setwd("~/GitHub/mbta_bus_ridership_trends/Outputs")
#write_csv(brdcd, "brdcd.csv")
#write_csv(brtscd1, "brtscd.csv", append=FALSE)
#write_csv(brtscd2, "brtscd.csv", append=TRUE)
## merge 2 years content together
#brtscd <- read.csv("brtscd.csv", na.strings = c("", "NULL"))
#write_csv(bscd, "bscd.csv")
#rm(brtscd1, brtscd2)

# -------------------------------------------------------------------------- #
# -------------------------- Required data sets ---------------------------- #
# -------------------------------------------------------------------------- #

setwd("~/GitHub/mbta_bus_ridership_trends/Outputs")
brdcd = read.csv("brdcd.csv", na.strings = c("", "NULL"))
brtscd = read.csv("brtscd.csv", na.strings = c("", "NULL"))
bscd = read.csv("bscd.csv", na.strings = c("", "NULL"))

# -------------------------------------------------------------------------- #
# ------ How does ridership vary on weekdays versus weekends? -------------- #
# -------------------------------------------------------------------------- #

## Inbound/Outbound Weekday vs. Weekend boardings in 2017-2018. Bar chart.
a = select(brdcd,2,3,4,5)

## Merge Saturday and Sunday into Weekend
a$Day.Type = gsub('Sunday', 'Weekend', a$Day.Type)
a$Day.Type = gsub('Saturday', 'Weekend', a$Day.Type)

## Get average Boardings for each unique Direction, Year, and Day Type
a_unique = aggregate(
  a$Boardings, 
  by=list(Direction=a$GTFS.direction_id, Year=a$Year, `Day Type`=a$Day.Type), 
  FUN=mean
)

## Split data by 2017 and 2018
a_unique = split(a_unique, a_unique$Year)
a1 = a_unique$FY2017
a2 = a_unique$FY2018

## Produce bar plots with Day Types, Direction, and Boardings
column1 <- c(rep("Weekday", 2), c(rep("Weekend", 2)))        # Weekday comes first
column2 <- gl(2, 1, 4, labels=c("Outbound", "Inbound"))   # Outbound=0 comes first
column3 <- a1$x
p1 = data.frame(`Day Type`=column1, Direction=column2, Boardings=column3)
p1 = ggplot(p1, aes(x=column1, y=column3, fill=column2)) + 
  geom_bar(position=position_dodge(), stat="identity") + 
  labs(
    title="Average boardings in 2017", 
    fill = "Direction", 
    x = "Day Types", 
    y = "Boardings")

column3 <- a2$x
p2 = data.frame(`Day Type`=column1, Direction=column2, Boardings=column3)
p2 = ggplot(p2, aes(x=column1, y=column3, fill=column2)) + 
  geom_bar(position=position_dodge(), stat="identity") + 
  labs(
    title="Average boardings in 2018", 
    fill = "Direction", 
    x = "Day Types", 
    y = "Boardings")

## plot 2 graphs side by side
g = grid.arrange(p1, p2, nrow=1)
ggsave("average_boardings_2017_2018.jpg", g)

## clear workspace of variables
rm(brdcd, a, a_unique, a1, a2, column1, column2, column3, p1, p2, g)

# -------------------------------------------------------------------------- #
# ------ What are peak ridership times for boardings and alightings? ------- #
# -------------------------------------------------------------------------- #

## Total volume vs. average number of boardings, alightings
## Peak hours (timeframe of 1 hour) in 2017-2018. Time series plot, line graph. 
b = select(brtscd,2,3,7,9,10)

# Example time data as character vectors
time_axis <- as.character(b$Trip.Start.Time)
# Split on ":"
time_axis <- strsplit(time_axis, ":", fixed=TRUE)
# Convert to numeric format
# first row = hours, 2nd row = minutes
time_axis <- sapply(time_axis, as.numeric)
# Add first row and (2nd row / 60) to get time in hours
## function(x) is an anonymous function
time_axis = sapply(time_axis, function(x) x[1]+x[2]/60)
## 0 is midnight, 24.5 is half past midnight of next day

##-------------------------------##
## Get total number of boardings ##
##-------------------------------##
avg = by(b$Boardings, 
         list(direction = b$GTFS.direction_id, 
              start.time = time_axis, 
              Year = b$Year), FUN = sum, na.rm = TRUE)

# Permute dimension in array so that dim1 = time, dim2=direction, dim3=year 
avg = aperm(avg, c(2,1,3))

# Collapse last 2 dimensions
dim(avg) = c(dim(avg)[1], prod(dim(avg)[2:3]))
colnames(avg) = c("out.2017", "in.2017", "out.2018", "in.2018")

# Plot title
gtitle_1 = c("Total Outbound Boardings in 2017", "Total Inbound Boardings in 2017", 
           "Total Outbound Boardings in 2018", "Total Inbound Boardings in 2018")

# so x and y lengths do not differ; plot unique times for boardings/averages
t = unique(time_axis)

# separate data frames
boardings = data.frame(t=c(t), out.2017=c(avg[,1]), in.2017=c(avg[,2]), out.2018=c(avg[,3]), in.2018=c(avg[,4]))
boardings[is.na(boardings)] = 0

##--------------------------------##
## Get total number of alightings ##
##--------------------------------##
avg = by(b$Alightings, 
         list(direction = b$GTFS.direction_id, 
              start.time = time_axis, 
              Year = b$Year), FUN = sum, na.rm = TRUE)

# Permute dimension in array so that dim1 = time, dim2=direction, dim3=year 
avg = aperm(avg, c(2,1,3))

# Collapse last 2 dimensions
dim(avg) = c(dim(avg)[1], prod(dim(avg)[2:3]))
colnames(avg) = c("out.2017", "in.2017", "out.2018", "in.2018")

# Plot title
gtitle_2 = c("Total Outbound Alightings in 2017", "Total Inbound Alightings in 2017", 
           "Total Outbound Alightings in 2018", "Total Inbound Alightings in 2018")

# separate data frames
alightings = data.frame(t=c(t), out.2017=c(avg[,1]), in.2017=c(avg[,2]), out.2018=c(avg[,3]), in.2018=c(avg[,4]))
alightings[is.na(alightings)] = 0

## clear workspace of variables
rm(avg, b, brtscd, t, time_axis)

##----------------##
## Plot boardings ##
##----------------##

## get boardings from cols 2-5
items = boardings[, 2:5]

## get column names, e.g. out.2017
c = colnames(items)
b = list()
times = c("3 am", "5 am", "7 am", "9 am", "11 am", "1 pm", "3 pm", "5 pm", "7 pm", "9 pm", "11 pm", "1 am")
## make plot for each boardings entry
for (i in 1:4) {
  # get literal string items$out.2017, items$in.2018, ...
  y_string = paste("items$", sep = "", c[i])
  
  # make a data frame with x as times and 
  # y evaluated as the string based on the current colname
  df = data.frame(x=boardings$t, y=eval(parse(text=y_string)))

  # add the ith plot to each entry in the empty list b
  b[[i]] = ggplot(df, aes(x, y)) + 
    geom_line(aes(color=y)) +
    ggtitle(gtitle_1[i]) +
    scale_x_continuous (
      name = "Time of Day",
      breaks = seq(3, 26, 2),
      limits = c(3, 26),
      labels = times) +
    scale_y_continuous (
      name = "Boardings",
      breaks = seq(0, 2500, 250),
      limits = c(0, 2500)) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1))
  #b[[i]] = b[[i]] + scale_colour_gradient(low="royalblue4",high="deepskyblue")
}

## clear workspace of variables
rm(items, c, y_string, df, i)

## plot 4 graphs together in 1 picture
g1 = grid.arrange(b[[1]], 
                  b[[2]],
                  b[[3]], 
                  b[[4]],
                  nrow=2,
                  top=t)

ggsave(filename=paste("peak_times_boardings.jpg", sep=""),
       g1,
       units="in",
       width=11,
       height=8.5)

## clear workspace of variables
rm(b, boardings, g1, gtitle_1)

##-----------------##
## Plot alightings ##
##-----------------##

## get boardings from cols 2-5
items = alightings[, 2:5]

## get column names, e.g. out.2017
c = colnames(items)
b = list()

## make plot for each boardings entry
for (i in 1:4) {
  # get literal string items$out.2017, items$in.2018, ...
  y_string = paste("items$", sep = "", c[i])
  
  # make a data frame with x as times and 
  # y evaluated as the string based on the current colname
  df = data.frame(x=alightings$t, y=eval(parse(text=y_string)))
  
  # add the ith plot to each entry in the empty list b
  b[[i]] = ggplot(df, aes(x, y)) + 
    geom_line(aes(color=y)) +
    ggtitle(gtitle_2[i]) +
    scale_x_continuous (
      name = "Time of Day",
      breaks = seq(3, 26, 2),
      limits = c(3, 26),
      labels = times) +
    scale_y_continuous (
      name = "Alightings",
      breaks = seq(0, 2500, 250),
      limits = c(0, 2500)) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1))
    #b[[i]] = b[[i]] + scale_colour_gradient(low="royalblue4",high="deepskyblue")
}

## clear workspace of variables
rm(items, c, y_string, df, i)

## plot 4 graphs together in 1 picture
g1 = grid.arrange(b[[1]], 
                  b[[2]],
                  b[[3]], 
                  b[[4]],
                  nrow=2,
                  top=t)

ggsave(filename=paste("peak_times_alightings.jpg", sep=""),
       g1,
       units="in",
       width=11,
       height=8.5)

## clear workspace of variables
rm(b, alightings, g1, gtitle_2, times)

# -------------------------------------------------------------------------- #
# ------ What streets, stations, and terminals are the most popular? ------- #
# -------------------------------------------------------------------------- #
## Popular streets, stations, and terminals regardless of direction, separated by 
## "OPP", "@", "-" in 2017-2018. Counts average alightings/boardings. Bar chart. 
C = select(bscd,2,3,5,6)
C$Boardings = as.numeric(gsub(",", "", C$Boardings))
C$Alightings = as.numeric(gsub(",", "", C$Alightings))

## change NAs to 0s so arithmetic functions work properly
C$Boardings[is.na(C$Boardings)] = 0
C$Alightings[is.na(C$Alightings)] = 0

# get Stop Names from a given year
stops = as.character(C$Stop.Name)

# Get vectors (street1, street2) separated by @,-,OPP,OPPOSITE
# e.g. "WASHINGTON ST OPP RUGGLES ST" => "WASHINGTON ST" "RUGGLES ST"
streets = str_split_fixed(string=stops, 
                          pattern="\\s+(@|-|OPP|OPPOSITE|UPPER|LOWER|STA|BA|WEST|EAST|AFTER|BEFORE)\\s+",
                          n=Inf)

# get first street that intersects the other street
streets = streets[,1]
C$Stop.Name = streets

# get rid of anything not a street, such as a STATION
streets_only = C %>% filter(!str_detect(Stop.Name, 
"STATION|TERMINAL|GREEN|BUSWAY|Busway|HARVARD SQ|HARVARD|RUGGLES STA|RUGGLES|SILVER LINE|CTR|MALDEN|WONDERLAND|NOT A STOP|BROADWAY")
)

# get everything that is a STATION, TERMINAL
stations = C %>% filter(str_detect(Stop.Name, "STATION|SILVER LINE"))
terminals = C %>% filter(str_detect(Stop.Name, "TERMINAL"))

# take distinct elements to get rid of common 0 elements
streets_only = distinct(streets_only)
stations = distinct(stations)
terminals = distinct(terminals)

# take mean number of boardings for each street
items = c(list(streets_only), list(stations), list(terminals))

## clear workspace of variables
rm(bscd, C, stops, streets, streets_only, stations, terminals)

# keep count of how many graphs were made
j = 0
for (i in items) {
  boardings = aggregate(
    i$Boardings, 
    by=list(Stop.Name=i$Stop.Name, Year=i$Year), 
    FUN=mean
  )
  alightings = aggregate(
    i$Alightings, 
    by=list(Stop.Name=i$Stop.Name, Year=i$Year), 
    FUN=mean
  )
  names(boardings)[3] = "Boardings"
  names(alightings)[3] = "Alightings"
  ba = full_join(boardings, alightings)
  ba = split(ba, ba$Year)
  ba_2017 = ba$FY2017
  ba_2018 = ba$FY2018

  ## -------------------------------- ##
  ## Graph the data for 2017 and 2018 ##
  ## -------------------------------- ##

  ## get top 25 most popular stops and remove the other column
  # top 25 streets and stations
  n = 25
  
  # top 9 terminals, not enough for top 25
  if (j == 2) {n = 9}
  
  a = top_n(ba_2017, n, Boardings)
  a = a[order(-a$Boardings),]
  a = subset(a, select = -c(Alightings))
  
  b = top_n(ba_2017, n, Alightings)
  b = b[order(-b$Alightings),]
  b = subset(b, select = -c(Boardings))
  
  c = top_n(ba_2018, n, Boardings)
  c = c[order(-c$Boardings),]
  c = subset(c, select = -c(Alightings))
  
  d = top_n(ba_2018, n, Alightings)
  d = d[order(-d$Alightings),]
  d = subset(d, select = -c(Boardings))

  ## order x-axis by frequency of y-axis 
  boardings_2017 = ggplot(a, aes(x=reorder(Stop.Name, -Boardings), y=Boardings, fill=Boardings)) + 
    geom_bar(stat="identity") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    coord_flip()
  alightings_2017 = ggplot(b, aes(x=reorder(Stop.Name, -Alightings), y=Alightings, fill=Alightings)) + 
    geom_bar(stat="identity") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    coord_flip()
  boardings_2018 = ggplot(c, aes(x=reorder(Stop.Name, -Boardings), y=Boardings, fill=Boardings)) + 
    geom_bar(stat="identity") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    coord_flip()
  alightings_2018 = ggplot(d, aes(x=reorder(Stop.Name, -Alightings), y=Alightings, fill=Alightings)) + 
    geom_bar(stat="identity") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    coord_flip()
  
  ## plot 2 graphs side by side per year
  ## placeholder values for if statements below
  t = textGrob("")
  name = ""
  
  # streets_only
  if (j == 0) {
    t = textGrob("Top 25 streets in average boardings and alightings, 2017-2018")
    name = "streets"
    boardings_2017 = boardings_2017 + labs(x = "Street Name (2017)") + 
      scale_fill_gradient(low="tomato4",high="tomato")
    alightings_2017 = alightings_2017 + labs(x = "") + 
      scale_fill_gradient(low="tomato4",high="tomato")
    boardings_2018 = boardings_2018 + labs(x = "Street Name (2018)") + 
      scale_fill_gradient(low="tomato4",high="tomato")
    alightings_2018 = alightings_2018 + labs(x = "") + 
      scale_fill_gradient(low="tomato4",high="tomato")
  }
  # stations
  if (j == 1) {
    t = textGrob("Top 25 stations in average boardings and alightings, 2017-2018")
    name = "stations"
    boardings_2017 = boardings_2017 + labs(x = "Station Name (2017)") + 
      scale_fill_gradient(low="royalblue4",high="deepskyblue")
    alightings_2017 = alightings_2017 + labs(x = "") + 
      scale_fill_gradient(low="royalblue4",high="deepskyblue")
    boardings_2018 = boardings_2018 + labs(x = "Station Name (2018)") + 
      scale_fill_gradient(low="royalblue4",high="deepskyblue")
    alightings_2018 = alightings_2018 + labs(x = "") + 
      scale_fill_gradient(low="royalblue4",high="deepskyblue")
  }
  # terminals
  if (j == 2) {
    t = textGrob("Top 9 terminals in average boardings and alightings, 2017-2018")
    name = "terminals"
    boardings_2017 = boardings_2017 + labs(x = "Terminal Name (2017)") + 
      scale_fill_gradient(low="darkgreen",high="seagreen2")
    alightings_2017 = alightings_2017 + labs(x = "") + 
      scale_fill_gradient(low="darkgreen",high="seagreen2")
    boardings_2018 = boardings_2018 + labs(x = "Terminal Name (2018)") + 
      scale_fill_gradient(low="darkgreen",high="seagreen2")
    alightings_2018 = alightings_2018 + labs(x = "") + 
      scale_fill_gradient(low="darkgreen",high="seagreen2")
  }
  g1 = grid.arrange(boardings_2017, 
                    alightings_2017, 
                    boardings_2018, 
                    alightings_2018,
                    nrow=2,
                    top=t)

  ggsave(filename=paste("popular_2017_2018_", name, ".jpg", sep=""),
         g1,
         units="in",
         width=11,
         height=8.5)
  j = j + 1

}

## clear workspace of variables
rm(a, alightings_2017, alightings_2018, alightings, 
   b, ba, ba_2017, ba_2018, boardings, boardings_2017, boardings_2018, 
   c, d, i, j, g1, n, name, t)
rm(items)
