-- Trasaction_ID Cleaning
Select Transaction_ID, COUNT(*) as 'Duplicated Rows'
from railways
group by Transaction_ID
having COUNT(*) > 1;

--Duplicated Rows = 0

Select COUNT(*) as 'Null ID'
from railways
where Transaction_ID is null;

--Nulls in Transaction_ID = 0

Alter table railways
Alter column Transaction_ID nvarchar(255) NOT NULL;

Alter table railways
add constraint PK_Transaction_Id primary key (Transaction_ID)

-- Transaction_ID is the primary key now

-- ------------------------------------------------------------------

-- Date_of_Purchase Cleaning

Select COUNT(*) as 'Nulls'
from railways
where Date_of_Purchase is null;
-- Nulls = 0

Alter table railways
alter column Date_of_Purchase date not null;
-- --------------------------------------------------------------------

-- Time of Purchase Cleaning

Select COUNT(*) as 'Nulls'
from railways
where Time_of_Purchase is null;
-- NUlls = 0

Alter table railways
alter column Time_of_Purchase time(0) not null;
-- --------------------------------------------------------------------

-- Date of Journey Cleaning

Select COUNT(*) as 'Nulls'
from railways
where Date_of_Journey is null;
-- Nulls = 0

Alter table railways
alter column Date_of_Journey date not null;
-- -------------------------------------------------------------

-- Departure Time Cleaning

Select COUNT(*) as 'Nulls'
from railways
where Departure_Time is null;
-- Nulls = 0 

Alter table railways 
alter column Departure_Time time(0) not null;
-- --------------------------------------------------------------

-- Arrival Time Cleaning 

Select COUNT(*) as 'Nulls'
from railways
where Arrival_Time is null;
-- Nulls = 0

Alter table railways
alter column Arrival_Time time(0) not null;
-- --------------------------------------------------------------

-- Actual Arrival Time Cleaning

Select COUNT(*) as 'Nulls'
from railways
where Actual_Arrival_Time is null;
-- Nulls = 1880, nulls will be kept to save the column structure as a time 

Alter table railways
Alter column Actual_Arrival_Time time(0) null;
-- ----------------------------------------------------------------

-- Purchase Type 

Select COUNT(*) as 'Nulls'
from railways
where Purchase_Type is null;
-- Nulls = 0

-- ----------------------------------------------------------------

--Payment Method

Select COUNT(*) as 'Nulls'
from railways
where Payment_Method is null;
-- Nulls = 0

-- ---------------------------------------------------------------

-- Railcard

Select COUNT(*) as 'Nulls'
from railways
where Railcard is null;
-- Nulls = 0
-- ---------------------------------------------------------------

-- Ticket Class 
Select COUNT(*) as 'Nulls'
from railways
where Ticket_Class is null;
-- Nulls = 0
-- ---------------------------------------------------------------

-- Ticket Type 

Select COUNT(*) as 'Nulls'
from railways
where Ticket_Type is null;
-- Nulls = 0 
-- ----------------------------------------------------------------

-- Price
Select COUNT(*) as 'Nulls'
from railways
where Price is null;
-- Nulls = 0

Select COUNT(*) as 'Invalid Price'
from railways
where Price < 0;
-- Invalid Price = 0
-- ---------------------------------------------------------------

-- Departure Station
Select COUNT(*) as 'Nulls'
from railways
where Departure_Station is null;
-- Nulls = 0
-- --------------------------------------------------------------

-- Arrival Destination
Select COUNT(*) as 'Nulls'
from railways
where Arrival_Destination is null;
-- Nulls = 0
-- ------------------------------------------------------------

-- Journey Status

Select COUNT(*) as 'Nulls'
from railways
where Journey_Status is null;
-- Nulls = 0
-----------------------------------------------------------------

-- Reason for Delay

Select COUNT(*) as 'Nulls'
from railways
where Reason_for_Delay is null;
-- Nulls = 27481

Update railways
set Reason_for_Delay = ISNULL(Reason_for_Delay, 'No Delay'); 
-- Nulls changed to 'No Delay'

select Reason_for_Delay from railways;
-- --------------------------------------------------------------
Alter table railways
alter column Purchase_Type nvarchar(255) not null;

Alter table railways
alter column Payment_Method nvarchar(255) not null;

Alter table railways
alter column Railcard nvarchar(255) not null;

Alter table railways
alter column Ticket_Class nvarchar(255) not null;

Alter table railways
alter column Ticket_Type nvarchar(255) not null;

Alter table railways
alter column Price float not null;

Alter table railways
alter column Departure_Station nvarchar(255) not null;

Alter table railways
alter column Arrival_Destination nvarchar(255) not null;

Alter table railways
alter column Journey_Status nvarchar(255) not null;

Alter table railways
alter column Reason_for_Delay nvarchar(255) not null;

Alter table railways
alter column Refund_Request nvarchar(255) not null;

-- All columns are not null except the Actual Arrival Time column

-- Ticket Info Table (Fact)
CREATE TABLE TicketInfo (
    Transaction_ID nvarchar(255) PRIMARY KEY, 
    Date_of_Purchase DATE not null,
    Time_of_Purchase TIME not null,
    Purchase_Type nvarchar(255) not null,
    Payment_Method nvarchar(255) not null,
    Railcard nvarchar(255) not null,
    Ticket_Class nvarchar(255) not null,
    Ticket_Type nvarchar(255) not null,
    Price float not null
);

INSERT INTO TicketInfo (Transaction_ID, Date_of_Purchase, Time_of_Purchase, 
                        Purchase_Type, Payment_Method, Railcard, 
                        Ticket_Class, Ticket_Type, Price)
SELECT 
    Transaction_ID,
    Date_of_Purchase,
    Time_of_Purchase,
    Purchase_Type,
    Payment_Method,
    Railcard,
    Ticket_Class,
    Ticket_Type,
    Price
FROM Railways;

Alter table TicketInfo
Alter column Time_of_Purchase time(0) not null;
----------------------------------------------------------------------------------------
-- Route Info Table (Dimension)
CREATE TABLE RouteInfo (
    Route_ID INT IDENTITY(1,1) PRIMARY KEY,
    Departure_Station nvarchar(255) not null,
    Arrival_Destination nvarchar(255) not null,
    UNIQUE (Departure_Station, Arrival_Destination) 
);


INSERT INTO RouteInfo (Departure_Station, Arrival_Destination)
SELECT DISTINCT Departure_Station, Arrival_Destination
FROM Railways;

Select COUNT(*) from RouteInfo;
-- ----------------------------------------------------------------------------

-- Journey Table (Dimension)
CREATE TABLE Journey (
    Journey_ID INT IDENTITY(1,1) PRIMARY KEY,
	Transaction_ID nvarchar(255) UNIQUE not null,
    Departure_Station nvarchar(255) not null,
    Arrival_Destination nvarchar(255) not null,
    Date_of_Journey DATE not null,
    Departure_Time TIME(0) not null,
    Arrival_Time TIME(0) not null,
    Actual_Arrival_Time TIME(0) NULL,
    Journey_Status nvarchar(255) not null
);
INSERT INTO Journey (Transaction_ID, Departure_Station, Arrival_Destination, 
                     Date_of_Journey, Departure_Time, Arrival_Time, Actual_Arrival_Time, Journey_Status)
SELECT 
    Transaction_ID,
    Departure_Station,
    Arrival_Destination,
    Date_of_Journey,
	Departure_Time,
    Arrival_Time,
    Actual_Arrival_Time,
    Journey_Status
FROM Railways;

--------------------------------------------------------------------------------

-- Delay Table (Dimension)

CREATE TABLE Delay (
    Delay_ID INT IDENTITY(1,1) PRIMARY KEY,
    Transaction_ID nvarchar(255) not null,
    Journey_ID INT not null,
    Route_ID INT not null,
    Journey_Status nvarchar(255) not null,
    Reason_for_Delay nvarchar(255) not null,
    Refund_Request nvarchar(255),
    FOREIGN KEY (Transaction_ID) REFERENCES TicketInfo(Transaction_ID),
    FOREIGN KEY (Journey_ID) REFERENCES Journey(Journey_ID),
    FOREIGN KEY (Route_ID) REFERENCES RouteInfo(Route_ID)
);

INSERT INTO Delay (Transaction_ID, Journey_ID, Route_ID, Journey_Status, Reason_for_Delay, Refund_Request)
SELECT 
    rw.Transaction_ID,
    j.Journey_ID,
    r.Route_ID,
    j.Journey_Status,
    rw.Reason_for_Delay,
    rw.Refund_Request
FROM Railways rw
JOIN Journey j 
    ON rw.Transaction_ID = j.Transaction_ID  
JOIN RouteInfo r
    ON rw.Departure_Station = r.Departure_Station 
   AND rw.Arrival_Destination = r.Arrival_Destination
where j.Journey_Status in ('Cancelled' , 'Delayed');
----------------------------------------------------------------------------------------

-- Date (Dimension)

CREATE TABLE Date (
    DateKey INT Identity(1,1) PRIMARY KEY,
    FullDate DATE,
    Day INT,
    Month INT,
    Year INT
);

INSERT INTO Date (FullDate, Day, Month, Year)
SELECT DISTINCT 
    Date_of_Journey,
    DAY(Date_of_Journey),
    MONTH(Date_of_Journey),
    YEAR(Date_of_Journey)
FROM railways;

-------------------------------------------------------------------------------------------------------------


SELECT COUNT(*) AS RailwaysCount FROM Railways;
SELECT COUNT(*) AS JourneyCount FROM Journey;
SELECT COUNT(*) AS TicketInfoCount FROM TicketInfo;
SELECT COUNT(*) AS DelayCount FROM Delay;
SELECT COUNT(*) AS DelayCount FROM Date;

select * from RouteInfo
order by Route_ID;
select * from Delay;
select * from Journey;
select * from TicketInfo;
select * from railways;
select * from RouteInfo;
select * from Date;



   






