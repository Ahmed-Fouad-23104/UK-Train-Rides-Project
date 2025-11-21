-- 1) Total Rev
SELECT SUM(Price) AS Total_Revenue
FROM TicketInfo;
-- Total Rev = 741,921
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
