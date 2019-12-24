# mbta_bus_ridership_trends
## Overview
This repo illustrates the work I have done in the MATH 345, "Probability and Statistics I", final group project from Fall 2019. The figures were created in R, specifically using the tidyverse package. The datasets used were from [MBTA Back on Track](https://mbtabackontrack.com/performance/#/download), gathered on December 2. 

## Research question
### What are the bus ridership trends?
Aside from subway and commuter rail usage, the bus is amongst one of the most popular modes of transit. We would like to observe information about bus ridership trends such as weekday/weekend activity, peak hours, and popular locations. Since the bus is the cheapest and most common form of transportation, we want to see the trends for boardings and alightings. The following sub-questions contribute to our observations. 

#### How does ridership vary on weekdays versus weekends? 
![Average boardings 2017-2018](https://github.com/jtquach1/mbta_bus_ridership_trends/blob/master/Outputs/average_boardings_2017_2018.jpg)
Here, we observe the average number of boardings given a particular Day Type and Direction for all bus routes. The independent variable was Type of Day and the dependent variable was average boardings. I used aggregate() to get the mean boardings. 
```R
## Get average Boardings for each unique Direction, Year, and Day Type
a_unique = aggregate(
  a$Boardings, 
  by=list(Direction=a$GTFS.direction_id, Year=a$Year, `Day Type`=a$Day.Type), 
  FUN=mean
)
```
It may seem obvious that the average Weekday boardings are higher than the average weekend boardings combined, since people do not typically work on weekends. Additionally, the moderate average boardings on Saturday and Sunday might indicate leisurely activities, given that people may go out during the weekend for shopping or holiday activities. However, this dataset does not include information on holiday travels. 
It is also likely that bus usage on weekends correlates with differing schedules for other modes of transit, such as the commuter rail. Judging by the following bar plots, it appears that the average boardings inbound and outbound are approximately equal, which makes sense since the bus is the most common form of MBTA transit. People may also take the same route in opposite directions when commuting back and forth. 

#### What are peak ridership times for boardings and alightings? 
![Peak times boardings](https://github.com/jtquach1/mbta_bus_ridership_trends/blob/master/Outputs/peak_times_boardings.jpg)
Here, we observe the total volume of boardings and alightings given a particular Direction and Time of Day for all bus routes. Time of Day is considered the independent variable, whereas boardings or alightings were considered the dependent variable. Below follows some interesting observations on the data. The by() function was used to get the sum of all ridership values at a given time. 
```R
## Get total number of boardings
avg = by(b$Boardings, 
         list(direction = b$GTFS.direction_id, 
              start.time = time_axis, 
              Year = b$Year), FUN = sum, na.rm = TRUE)
...
## Get total number of alightings
avg = by(b$Alightings, 
         list(direction = b$GTFS.direction_id, 
              start.time = time_axis, 
              Year = b$Year), FUN = sum, na.rm = TRUE)
```
It appears that the two sets of graphs for both 2017 and 2018 almost perfectly correspond to one another in terms of shape, except for a peak at 6:30 pm for Total Outbound Alightings in 2018. I would conclude that the 9-5 trend holds in 2017-2018 and for years to come, given that most people are active during the day when it comes to work and school. What is interesting is that activity is lowest from 3:30 am and after 4:00 am. Perhaps bus service is decreased around these two extremes, and hence there won’t be as many people boarding or alighting.  
![Peak times alightings](https://github.com/jtquach1/mbta_bus_ridership_trends/blob/master/Outputs/peak_times_alightings.jpg)
Here follows an analysis on inbound and outbound activity. For outbound activity, it appears that the four largest spikes are located around 6 am, 10 am,  3:30 am, and 7 pm. As for inbound activity, it appears that the four largest spikes are located around 7 am, 11, am, 3 pm, and 8:30 pm. I would suppose that people may initially go outbound to reach one stop around 6 am, then go inbound to a different stop around 7 am. Or, that person may depart in a particular direction around 6-7 am, depending on where the bus is relative to their home. Likewise, a person may depart home at around 6 to 9 pm by inbound or outbound. 3 pm is also a popular time, as it’s possible that early morning workers will leave work around then. 3 am may be a popular time for night shift workers or people who must commute from afar, as it’s likely that bus service may be reduced around this time. However, the ridership values are not very condensed around 3 am, so it’s likely that only a few stops service around 3 am. In contrast, the rest of the graph is relatively condensed in black, so it’s likely that there are a couple hundred passengers that board or alight consistently throughout the day. For the points in blue, which indicate peak hours, it’s likely that perhaps the most popular stops, such as those corresponding to Dudley or subway stations, are saturated with passengers. 
As for the similarity in time frames for inbound and outbound activity, I might deduce that the same stop may have different buses at a given time, so a person may get off a bus and get on a different one. However, whether a person goes inbound or outbound does not necessarily indicate whether they are going to work and going back home, as people may either live far from Boston or close to Boston. I might assume that those who live toward the south must go inbound to get to work, whereas those who live toward the north must go outbound to get to work; inbound and outbound depends on what direction a person is coming from. 

#### What streets and stations are the most popular for boardings and alightings?
Here, we observe the top 25 most popular streets and stations in terms of average boardings and alightings. The independent variable was the name of each location type and the dependent variable was average boardings or alightings. The purpose of this observation is to get a sense of the busiest locations for any given day, instead of just at rush hour (peak ridership times). This is because the data set used for this subquestion is for that of a composite day rather than for a given time interval and stop. The locations, which were internally represented as “streets” in R, were obtained by taking the first street name out of a stop name with the following format: “STREET 1” separated by an @, OPP, OPPOSITE, and -, next to STREET 2. For instance, “WASHINGTON ST” would be parsed from a string like “WASHINGTON ST OPP RUGGLES ST”. I used additional delimiters to help with merging “duplicate” locations, such as two busways found at the same station. 
```R
# Get vectors (street1, street2) separated by @,-,OPP,OPPOSITE
# e.g. "WASHINGTON ST OPP RUGGLES ST" => "WASHINGTON ST" "RUGGLES ST"
streets = str_split_fixed(string=stops, 
                          pattern="\\s+(@|-|OPP|OPPOSITE|UPPER|LOWER|STA|BA|WEST|EAST|AFTER|BEFORE)\\s+",
                          n=Inf)
```
Next, I distinguished streets, busways, and terminals by filtering out row entries whose stops contained STATION and TERMINAL, and names of station stops that sound like streets, like GREEN ST. 
```R
# get rid of anything not a street, such as a STATION
streets_only = C %>% filter(!str_detect(Stop.Name, 
"STATION|TERMINAL|GREEN|BUSWAY|Busway|HARVARD SQ|HARVARD|RUGGLES STA|RUGGLES|SILVER LINE|CTR|MALDEN|WONDERLAND|NOT A STOP|BROADWAY")
)

# get everything that is a STATION, TERMINAL
stations = C %>% filter(str_detect(Stop.Name, "STATION|SILVER LINE"))
terminals = C %>% filter(str_detect(Stop.Name, "TERMINAL"))
```
I also used distinct() before averaging to remove rows with 0’s in both boardings and alightings. This was for buses that had 0 passengers or were scheduled to operate at some time but did not. By getting rid of these rows, the ridership means won’t be dragged down by the “empty” entries. 
```R
# take distinct elements to get rid of common 0 elements
streets_only = distinct(streets_only)
stations = distinct(stations)
terminals = distinct(terminals)
```
![Popular 2017-2018 streets](https://github.com/jtquach1/mbta_bus_ridership_trends/blob/master/Outputs/popular_2017_2018_streets.jpg)
When comparing the top 25 streets, it appears that TEMPLE PL is the most popular street in all ridership scenarios, except for alightings in 2017. BURGIN PKWY, HAWTHORNE ST, and 1624 BLUE HILL AVE are amongst the top 3 for ridership in both years. I would assume that these streets are popular because they are adjacent to subway stations. For instance, BURGIN PKWY is a street adjacent to Quincy Center, which has connections to Wollaston and Mattapan. HAWTHORNE ST is adjacent to Chelsea, which is a commuter rail stop, and also has connections to Haymarket, Wellington, and Wonderland. TEMPLE PL is adjacent to the Boston Common, which is within walking distance to Park St and Boylston St, and has connections to the Silver Line, in which Dudley Station can be accessed. 1624 BLUE HILL AVE is adjacent to Mattapan Square, which has multiple connections to Forest Hills, Ashmont, and Quincy Center. 
![Popular 2017-2018 stations](https://github.com/jtquach1/mbta_bus_ridership_trends/blob/master/Outputs/popular_2017_2018_stations.jpg)
When comparing the top 25 stations, it appears that DUDLEY STATION is the most popular station in all ridership scenarios. This makes sense, as DUDLEY STATION connects 17 MBTA bus routes. HAYMARKET, ASHMONT, and FOREST HILLS Stations are also consistent in their positions as popular stations for boardings and alightings since they have multiple connections to other bus stops. I would have expected N QUINCY STATION and LECHMERE STATION to have increased in ridership from 2017 to 2018 due to construction on Wollaston Station and the Green Line Extension Project. However, the positions of those two subway stations have not noticeably changed. From 2017 to 2018, N QUINCY STATION rose from the top 25th to the 24th and LECHMERE STATION from the top 10th to the 9th, for stations with the most boardings. On a different note, overall average ridership seems to have increased between the years. The number of average boardings and alightings at DUDLEY STATION approaches 5000 as of 2018. It’s possible that when Wollaston Station was still under construction, people would take other buses located nearby Quincy Center and North Quincy Stations, since the bus is generally cheaper than subway. Buses might also be taken in the case of fully saturated subway cars, e.g. 8 AM at North Quincy Station. So, people can still take alternate routes, whether it be to JFK/UMASS or Braintree, etc. 
