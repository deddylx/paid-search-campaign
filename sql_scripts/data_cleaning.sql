-- create table
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


-- finding duplicate rows
SELECT (mall_campaigns.*)::text, count(*)
FROM mall_campaigns
GROUP BY mall_campaigns.*
HAVING count(*) > 1
-- result: no duplicate rows

-- check missing values
SELECT
    attname AS column_name,
    null_frac AS null_fraction
FROM pg_stats
WHERE tablename = 'mall_campaigns';
-- result: no missing values

-- recalculate metrics
-- ctr
update mall_campaigns
set ctr = clicks / impressions::numeric;

-- conv_rate
update mall_campaigns
set conv_rate = conversions / clicks::numeric;

-- cpc
update mall_campaigns
set cpc = cost / clicks::numeric;

-- pnl
update mall_campaigns
set pnl = revenue - cost;


-- create new columns (roas)
alter table mall_campaigns
add column roas numeric;

update mall_campaigns
set roas = revenue / cost::numeric;


-- add new columns (for transformed data)
alter table mall_campaigns
add column match_type varchar(10),
add column device_type varchar(10),
add column ad_type varchar(50),
add column date date;

-- transform data
update mall_campaigns
set 
	match_type = split_part(ad_group, ' - ', 1),
	device_type = split_part(ad_group, ' - ', 2),
	ad_type = split_part(ad_group, ' - ', 3),
	date = to_date(month || '2021', 'Month YYYY');,

-- check the result
select * from mall_campaigns;
