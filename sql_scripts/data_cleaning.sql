-- 1. CREATE TABLE
create table mall_campaigns (
	ad_group varchar(50),
	month varchar(10),
	impressions int,
	clicks int,
	ctr numeric,
	conversions int,
	conv_rate numeric,
	cost int,
	cpc numeric,
	revenue int,
	sale_amount numeric,
	pnl numeric
);

-- check the table after importing csv file
select * from mall_campaigns;


-- 2. FIND DUPLICATE ROWS
select
    (mall_campaigns.*)::text, 
    count(*)
from mall_campaigns
group by mall_campaigns.*
having count(*) > 1
-- result: no duplicate rows

	
-- 3. CHECK MISSING VALUES
select
    attname as column_name,
    null_frac as null_fraction
from pg_stats
where tablename = 'mall_campaigns';
-- result: no missing values


-- 4. RECALCULATE METRICS
--- ctr
update mall_campaigns
set ctr = clicks / impressions::numeric;

--- conv_rate
update mall_campaigns
set conv_rate = conversions / clicks::numeric;

--- cpc
update mall_campaigns
set cpc = cost / clicks::numeric;

--- pnl
update mall_campaigns
set pnl = revenue - cost;


--- 5. CREATE NEW COLUMNS
--- roas
alter table mall_campaigns
add column roas numeric;

update mall_campaigns
set roas = revenue / cost::numeric;


-- 6. ADD NEW COLUMNS
alter table mall_campaigns
add column match_type varchar(10),
add column device_type varchar(10),
add column ad_type varchar(50),
add column date date;

--- transform data
update mall_campaigns
set 
	match_type = split_part(ad_group, ' - ', 1),
	device_type = split_part(ad_group, ' - ', 2),
	ad_type = split_part(ad_group, ' - ', 3),
	date = to_date(month || '2021', 'Month YYYY');,

-- 7. CHECK THE RESULTS
select * from mall_campaigns;
