Bus Route Trip Stop Composite Day

Composite day (e.g. typical weekday) number of boardings, alightings, and load for each bus route, direction, trip, and stop by fiscal year.

Notes about stop sequences:
Every trip on each route has been exported with the same stop sequence. However, not every trip serves every stop in that sequence due to the different variants. 
The trips will often have more stops listed than they really serve due to short turns and other operational considerations. 
Stops that were not served by a trip or were missed by APC readers consistently for that trip will have 'NULL' values in the on/off/load columns.
Stop sequences are not guaranteed to match the stop sequence in the GTFS stop times file for the trips starting at that time due to changes in operations throughout the fiscal year.

The # of trips samples is the count of total trips that met our criteria. 
However, it does not always equal the number of samples for each stop. 
Some trips are not able to match all stops for various reason. 
The ons/offs/load are calculated (and rounded) independently, so adding the average ons and subtracting the average offs, won’t always equal the average load.


Adding up boardings/alightings/load for all trips for a route will give typical boardings/alightings/load on the route per day type and fiscal year. 
Dividing total boardings/alightings/load on the route by the total number of trips for the route gives average load per trip per route.

Adding up boardings/alightings/load for all trips for a stop will give typical boardings/alightings/load at the stop per day type and fiscal year. 
Dividing total boardings/alightings/load at the stop by the total number of trips for the stop gives average load per trip per stop.

Files are separated by fiscal year (July 1 – June 30).
