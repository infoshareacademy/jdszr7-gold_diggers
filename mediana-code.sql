SELECT state, state_abbreviation, county, fips, party, candidate, votes, fraction_votes
FROM public.primary_results_csv;

select
		a.fips,
		a.area_name,
		a.state_abbreviation,
		a.population_2014,
		case when median_value_of_owner_occupied_housing_units_2009_2013  < 80000 then '<80000'
			 when median_value_of_owner_occupied_housing_units_2009_2013 between 80000 and 100000 then '80000- 100000'
			 when median_value_of_owner_occupied_housing_units_2009_2013 between 100000 and 150000 then '100000 - 150000'
			 else '> 150000'
			 end as grupa_median_value_of_owner_occupied_housing_units_2009_201
from county_facts_csv_poprawna a
join county_id b on a.fips = b.fips;
with cte as (
select a.state,
		a.state_abbreviation,
		a.county,
		a.fips,
		a.party,
		sum(votes) over (partition by a.state, a.state_abbreviation, a.county, a.fips) sum_total,
		sum(votes) over (partition by a.state, a.state_abbreviation, a.county, a.fips, party) sum_party,
		case when sum(votes::float) over (partition by a.state, a.state_abbreviation, a.county, a.fips) = 0
		then 0
		else sum(votes::float) over (partition by a.state, a.state_abbreviation, a.county, a.fips, party)/
		sum(votes::float) over (partition by a.state, a.state_abbreviation, a.county, a.fips)
		end votes_pct
from primary_results_csv a
join county_id b on a.fips = b.fips
)
select distinct a.*
from cte a
where votes_pct > 0.5
order by state, county, party;

select 
		a.fips,
		a.area_name,
		a.state_abbreviation,
		--a.population_2014,
		case when median_value_of_owner_occupied_housing_units_2009_2013  < 80000 then '<80000'
			 when median_value_of_owner_occupied_housing_units_2009_2013 between 80000 and 100000 then '80000- 100000'
			 when median_value_of_owner_occupied_housing_units_2009_2013 between 100000 and 150000 then '100000 - 150000'
			 else '> 150000'
			 end group_median_value_of_owner_occupied_housing_units_2009_2013
from county_facts_csv_poprawna a
join county_id b on a.fips = b.fips



with cte as (
select a.group_median_value_of_owner_occupied_housing_units_2009_2013,
		b.party,
		 count(*) Liczba_hrabstw
from Dane_do_tabel_krzyzowych13 a
join resultatas b on a.fips = b.fips
group by a.group_median_value_of_owner_occupied_housing_units_2009_2013,
		b.party
order by 1,2
)
select a.*,
		sum(Liczba_hrabstw) over (partition by group_median_value_of_owner_occupied_housing_units_2009_2013) Liczba_hrabstw_w_grupie,
		Liczba_hrabstw / sum(Liczba_hrabstw) over (partition by group_median_value_of_owner_occupied_housing_units_2009_2013) * 100 Pct
from cte a
