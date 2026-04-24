create database smartcity;

use smartcity;

drop table energy;

create table energy (
	MeterID varchar(20),
    Zone varchar(20),
    ConsumerType varchar(30),
    Date date,
    EnergyConsumed_kWh decimal(10,2),
    PeakUsage_kwh decimal(10,2),
    OutageMinutes int,
    MeterStatus varchar	(20),
    TariffRate decimal(10,2)
);

SET GLOBAL local_infile = 1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';

LOAD DATA INFILE 'C:/SmartCityEnergy.csv'
INTO TABLE energy
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(MeterID, Zone, ConsumerType, @DateVar, EnergyConsumed_kWh, PeakUsage_kWh, OutageMinutes, MeterStatus, TariffRate)
SET Date = STR_TO_DATE(@DateVar, '%d-%m-%Y');


Select * from energy;

Select count(*)  from energy;

-- Total and Average Energy by Zone

select 
	Zone,
    sum(EnergyConsumed_kwh) as TotalEnergy,
    avg(EnergyConsumed_kwh) as AvgDailyEnergy
from energy
group by Zone;

-- Top 5 Highest Energy Consumers by Type

select 
	ConsumerType,
    MeterID,
    EnergyConsumed_kwh
from 
(
	select
		consumerType,
        MeterID,
        EnergyConsumed_kwh,
        dense_rank() over(
			partition by ConsumerType
            order by EnergyConsumed_kwh desc
		) as rn
	from energy
)x
where rn <=5;


 -- Monthly Trend of Consumption Across Zones
 
 select 
	month(date) as month,
    Zone,
	sum(EnergyConsumed_kwh) as TotalEnergy
from energy
group by month(date),Zone
order by month;

-- Calculate Average Cost per Zone 

select 
	Zone,
	avg(EnergyConsumed_kwh * TariffRate) as AvgCost
from energy
group by Zone;

-- Zone with Highest Number of Faults / Outages

select
	Zone,
    sum(OutageMinutes) as TotalOutage
from energy
group by Zone
order by TotalOutage;

-- Lowest Energy Efficiency Zone

select
	Zone,
    avg(EnergyConsumed_kwh) as Avgusage,
    avg(OutageMinutes) as Avgoutage
from energy
group by Zone
order by AvgUsage Desc,Avgoutage desc;

-- Weekday vs Weekend Peak Usage

select
	case
		when dayofweek(date) in (1,7) then 'Weekend'
		else 'Weekday'
	end as DayType,
	Avg(Peakusage_kwh) as AvgPeakUsage
from energy
group by DayType;