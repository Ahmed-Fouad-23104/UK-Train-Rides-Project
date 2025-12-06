-- 1) Total Rev
SELECT SUM(t.Price) AS Total_Revenue
FROM TicketInfo t
LEFT JOIN Delay d
    ON t.Transaction_ID = d.Transaction_ID
WHERE d.Refund_Request = 'No' 
   OR d.Refund_Request IS NULL;
-- Total Rev = 703,219
-- ----------------------------------------------------

-- 2) Number of Journeys
SELECT COUNT(*) AS Total_Journeys
FROM Journey;
-- Total Journeys = 31653
-- ----------------------------------------------------

-- 3) Number of Cancelled Journeys
SELECT COUNT(*) AS Cancelled_Journeys
FROM Journey
WHERE Journey_Status = 'Cancelled';
-- Cancelled Journeys = 1880 
-- -----------------------------------------------------

-- 4) Number of Delayed Journeys
SELECT COUNT(*) AS Delayed_Journeys
FROM Journey
WHERE Journey_Status = 'Delayed';
-- Delayed Journeys = 2292
-- -----------------------------------------------------

-- 5) Most Common Reason for Delay
SELECT Reason_for_Delay, COUNT(*) AS Times
FROM Delay
WHERE Journey_Status = 'Delayed'
GROUP BY Reason_for_Delay
ORDER BY Times DESC;
-- -----------------------------------------------------

-- 6) Avg Ticket Price
SELECT Round(AVG(Price), 2) AS Avg_Price
FROM TicketInfo;
-- Avg Price = 23.44
-- ------------------------------------------------------

-- 7) Purchase Type Revenue and Tickets Count
SELECT Purchase_Type, SUM(Price) AS Revenue, COUNT(*) AS Tickets_Count
FROM TicketInfo
GROUP BY Purchase_Type
ORDER BY Revenue DESC;
-- --------------------------------------------------------

-- 8) Ticket Type Revenue and Tickets Count
SELECT Ticket_Type, SUM(Price) AS Revenue, COUNT(*) AS Tickets_Count
FROM TicketInfo
GROUP BY Ticket_Type
ORDER BY Revenue DESC;
-- --------------------------------------------------------

-- 9) Ticket Class Revenue and Tickets Count
SELECT Ticket_Class, SUM(Price) AS Revenue, COUNT(*) AS Tickets_Count
FROM TicketInfo
GROUP BY Ticket_Class
ORDER BY Revenue DESC;
-- --------------------------------------------------------

-- 10) Avg Delayed Time
SELECT AVG(DATEDIFF(MINUTE, Arrival_Time, Actual_Arrival_Time)) AS Avg_Delay_Minutes
FROM Journey
WHERE Journey_Status = 'Delayed';
-- Avg Delayed Time = 42 mins
-- ----------------------------------------------------------

-- 11) Top 10 Stations With Highest Ticket Purchased Volume
SELECT Top 10 Departure_Station, COUNT(*) AS Total_Tickets
FROM Journey
GROUP BY Departure_Station
ORDER BY Total_Tickets DESC;
-- ----------------------------------------------------------

-- 12) Top 10 Stations With Most Delyayed + Canceled Journeys
SELECT Top 10 Departure_Station, COUNT(*) AS Disruptions
FROM Journey
WHERE Journey_Status IN ('Delayed', 'Cancelled')
GROUP BY Departure_Station
ORDER BY Disruptions DESC;

-- ----------------------------------------------------------

-- 13) Top 10 Routes with Most Delayed
SELECT Top 10 r.Departure_Station, r.Arrival_Destination, r.Route_ID, COUNT(*) as Delayed
from Delay d
join RouteInfo r 
on d.Route_ID  = r.Route_ID 
where Journey_Status = 'Delayed'
GROUP BY 
    r.Departure_Station,
    r.Arrival_Destination,
	r.Route_ID
ORDER BY Delayed DESC;

-- ----------------------------------------------------------

-- 14) Monthly Revenue
Select DATENAME(Month, t.Date_of_Purchase) as Month,
YEAR(t.Date_of_Purchase) as Year,
sum(t.Price) as Total_Revenue 
from TicketInfo t
left join Delay d
on t.Transaction_ID = d.Transaction_ID
where d.Refund_Request = 'No'
or d.Refund_Request is null
group by DATENAME(Month, t.Date_of_Purchase), YEAR(t.Date_of_Purchase), MONTH(t.Date_of_Purchase)
order by YEAR(t.Date_of_Purchase), MONTH(t.Date_of_Purchase);

-- ----------------------------------------------------------

-- 15) No of Refund Request and Lost Rev
Select COUNT(*) as Refunded_Tickets , SUM(t.price) as Lost_Rev 
from Delay d
join TicketInfo t
on d.Transaction_ID = t.Transaction_ID
where Refund_Request = 'Yes';

-- ----------------------------------------------------------

-- 16) Top 10 Routes with Highest Tickets
Select Top 10 r.Departure_Station, r.Arrival_Destination, r.Route_ID, COUNT(*) as Tickets_Booked
from RouteInfo r 
join Journey j 
on r.Departure_Station = j.Departure_Station
and r.Arrival_Destination = j.Arrival_Destination
group by r.Departure_Station, r.Arrival_Destination, r.Route_ID
order by Tickets_Booked Desc;

-- -----------------------------------------------------------

-- 17) Top Reasons with Refund Request
Select Reason_for_Delay, COUNT(*) as Refunded_Asked
from Delay 
where Refund_Request = 'Yes'
group by Reason_for_Delay
order by Refunded_Asked desc;
-- -----------------------------------------------------------

-- 18) Top Causes for Cancelled Trips
SELECT Reason_for_Delay, COUNT(*) AS Times
FROM Delay
WHERE Journey_Status = 'Cancelled'
GROUP BY Reason_for_Delay
ORDER BY Times DESC;

-- ------------------------------------------------------------

-- 19) Months with Most Delayed and Cancelled Journeys
SELECT
    DATENAME(MONTH, Date_of_Journey) AS Month_Name,
    MONTH(Date_of_Journey) AS Month_Number,
    YEAR(Date_of_Journey) AS Year_Number,
    COUNT(*) AS Total_Disruptions
FROM Journey
WHERE Journey_Status IN ('Delayed', 'Cancelled')
GROUP BY 
    DATENAME(MONTH, Date_of_Journey),
    MONTH(Date_of_Journey),
    YEAR(Date_of_Journey)
ORDER BY 
	Total_Disruptions DESC;

-- ----------------------------------------------------

-- 20) Top Stations with Cancelled Journeys
SELECT Top 10 Departure_Station, COUNT(*) AS Disruptions
FROM Journey
WHERE Journey_Status = 'Cancelled'
GROUP BY Departure_Station
ORDER BY Disruptions DESC;

-- -----------------------------------------------------

-- 21) Top Stations with Delayed Journeys
SELECT Top 10 Departure_Station, COUNT(*) AS Disruptions
FROM Journey
WHERE Journey_Status = 'Delayed'
GROUP BY Departure_Station
ORDER BY Disruptions DESC;

-- ----------------------------------------------------

-- 22) Best Route Perfomrance
SELECT Top 10 r.Departure_Station, r.Arrival_Destination, r.Route_ID, COUNT(*) as Delayed
from Delay d
join RouteInfo r 
on d.Route_ID  = r.Route_ID 
where Journey_Status IN ('Delayed', 'Cancelled')
GROUP BY 
    r.Departure_Station,
    r.Arrival_Destination,
	r.Route_ID
ORDER BY Delayed ASC;

-- ---------------------------------------------------------

-- 23) Top 10 Routes with Most Cancelled
SELECT Top 10 r.Departure_Station, r.Arrival_Destination, r.Route_ID, COUNT(*) as Delayed
from Delay d
join RouteInfo r 
on d.Route_ID  = r.Route_ID 
where Journey_Status = 'Cancelled'
GROUP BY 
    r.Departure_Station,
    r.Arrival_Destination,
	r.Route_ID
ORDER BY Delayed DESC;
-- ----------------------------------------------------

-- 24) Top 10 Routes with Revenue
SELECT TOP 10
    r.Route_ID,
    r.Departure_Station,
    r.Arrival_Destination,

    -- Total revenue from all tickets on this route
    SUM(t.Price) AS Total_Revenue,

    -- Total refunded ticket value
    SUM(
        CASE 
            WHEN d.Refund_Request = 'Yes' THEN t.Price 
            ELSE 0 
        END
    ) AS Total_Refunds,

    -- Net revenue after subtracting refunds
    SUM(t.Price) 
    - SUM(
        CASE 
            WHEN d.Refund_Request = 'Yes' THEN t.Price 
            ELSE 0 
        END
    ) AS Net_Revenue

FROM TicketInfo t
JOIN RouteInfo r
    ON t.Route_ID = r.Route_ID
LEFT JOIN Delay d
    ON t.Transaction_ID = d.Transaction_ID
GROUP BY 
    r.Route_ID,
    r.Departure_Station,
    r.Arrival_Destination
ORDER BY Net_Revenue DESC;

-- ----------------------------------------------------

-- 25) Top 10 Routes Rev 2024
SELECT TOP 10
    r.Departure_Station,
    SUM(t.Price) AS Total_Revenue
FROM TicketInfo t
JOIN RouteInfo r
    ON t.Route_ID = r.Route_ID
LEFT JOIN Delay d
    ON t.Transaction_ID = d.Transaction_ID
WHERE d.Refund_Request != 'Yes' OR d.Refund_Request IS NULL
GROUP BY r.Departure_Station
ORDER BY Total_Revenue DESC;

-- -----------------------------------------------------------

-- 26) April Avg Price

SELECT ROUND(AVG(t.Price), 2) AS Avg_Ticket_Price_April_2024
FROM TicketInfo t
JOIN Journey j
    ON t.Journey_ID = j.Journey_ID
WHERE MONTH(j.Date_of_Journey) = 4
  AND YEAR(j.Date_of_Journey) = 2024;
-- -----------------------------------------------------------

-- 27) April Total Journeys
SELECT COUNT(*) AS Total_Journeys_April_2024
FROM Journey
WHERE MONTH(Date_of_Journey) = 4
  AND YEAR(Date_of_Journey) = 2024;

-- -----------------------------------------------------------

-- 28) April Delayed Journeys
SELECT COUNT(*) AS Delayed_Cancelled_April_2024
FROM Journey
WHERE MONTH(Date_of_Journey) = 4
  AND YEAR(Date_of_Journey) = 2024
  AND Journey_Status IN ('Delayed', 'Cancelled');

-- -------------------------------------------------------

-- 29) April Total Revenue
  SELECT Sum(t.Price) AS April_2024_Total_Revenue
FROM TicketInfo t
JOIN Journey j
    ON t.Journey_ID = j.Journey_ID
WHERE MONTH(j.Date_of_Journey) = 4
  AND YEAR(j.Date_of_Journey) = 2024;


