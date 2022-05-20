SELECT fips, area_name, state_abbreviation, pst045214, pst040210, pst120214, pop010210, age135214, age295214, age775214, sex255214, rhi125214, rhi225214, rhi325214, rhi425214, rhi525214, rhi625214, rhi725214, rhi825214, pop715213, pop645213, pop815213, edu635213, edu685213, vet605213, lfe305213, hsg010214, hsg445213, hsg096213, hsg495213, hsd410213, hsd310213, inc910213, inc110213, pvy020213, bza010213, bza110213, bza115213, nes010213, sbo001207, sbo315207, sbo115207, sbo215207, sbo515207, sbo415207, sbo015207, man450207, wtn220207, rtn130207, rtn131207, afn120207, bps030214, lnd110210, pop060210
FROM public.county_facts_csv;


select distinct a.fips
into county_id
from county_facts_csv_poprawna a 
join primary_results_csv b on a.fips = b.fips;

select
--		fips,
--		area_name,
--		state_abbreviation,
--		population_2014,
		percentile_disc(array[0.25, 0.5, 0.75]) within group (order by median_value_of_owner_occupied_housing_units_2009_2013)
from county_facts_csv_poprawna a 
join county_id b on a.fips = b.fips;



select
		a.fips,
		a.area_name,
		a.state_abbreviation,
		a.population_2014,
		case when per_capita_money_income_in_past_12_months_2009_2013  < 20000.0 then '<20000.0'
			 when per_capita_money_income_in_past_12_months_2009_2013 between 20000.0 and 22500.0 then '20000.0 - 22500.0'
			 when per_capita_money_income_in_past_12_months_2009_2013 between 22500.0 and 25000.0 then '22500.0 - 25000.0'
			 else '> 25000.0'
			 end as grupa_per_capita_money_income_in_past_12_months_2009_2013
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
into Results
from cte a
where votes_pct > 0.5
order by state, county, party;

drop table table_per_capita_money_income_in_past_12_months_2009_2013;

select
		a.fips,
		a.area_name,
		a.state_abbreviation,
		a.population_2014,
		case when per_capita_money_income_in_past_12_months_2009_2013 < 20000.0 then '<20000.0 '
			 when per_capita_money_income_in_past_12_months_2009_2013 between 20000.0 and 22500.0 then '20000.0 - 22500.0'
			 when per_capita_money_income_in_past_12_months_2009_2013 between 22500.0 and 25000.0 then '22500.0 - 25000.0'
			 else '> 25000.0'
			 end Var,--grupa_per_capita_money_income_in_past_12_months_2009_2013,
			 b.party,
			 b.sum_total,
			 b.sum_party,
			 b.votes_pct,
		case when party = 'Republican' then 1 else 0 end Party_Republican,
		case when party = 'Democrat' then 1 else 0 end Party_Democrat
into temporary table table_per_capita_money_income_in_past_12_months_2009_2013
		from county_facts_csv_poprawna a
join Results b on a.fips = b.fips;

drop table table_per_capita_money_income_in_past_12_months_2009_2013;


with cte as(
select Var,
		count(*) Liczba,
		sum(Party_Republican) Party_Republican,
		 sum(Party_Democrat) Party_Democrat
from table_per_capita_money_income_in_past_12_months_2009_2013
group by Var
)
, cte2 as (
select a.*,
		Party_Republican::float/sum(Party_Republican::float) over () as Distribution_Rep,
		Party_Democrat::float/sum(Party_Democrat::float) over () as Distribution_Dem
from cte a
),
cte3 as (
select *,
		ln(Distribution_Dem::float/ Distribution_Rep) as WOE,
		Distribution_Dem::float - Distribution_Rep as  "D_Dem - D_Rep",
		(Distribution_Dem::float - Distribution_Rep) * ln(Distribution_Dem::float/ Distribution_Rep)  as inf_val_czastkowe
from cte2
)
select sum(inf_val_czastkowe) inf_val from cte3
;
select * from Information_Value_temp;


select 
		a.fips,
		a.area_name,
		a.state_abbreviation,
		--a.population_2014,
		case when per_capita_money_income_in_past_12_months_2009_2013 < 20000.0 then '<20000.0 '
			 when per_capita_money_income_in_past_12_months_2009_2013 between 20000.0 and 22500.0 then '20000.0 - 22500.0'
			 when per_capita_money_income_in_past_12_months_2009_2013 between 22500.0 and 25000.0 then '22500.0 - 25000.0'
			 else '> 25000.0'
			 end group_per_capita_money_income_in_past_12_months_2009_2013
from county_facts_csv_poprawna a
join county_id b on a.fips = b.fips



with cte as (
select a.group_per_capita_money_income_in_past_12_months_2009_2013,
		b.party,
		 count(*) Liczba_hrabstw
from Dane_do_tabel_krzyzowych13 a
join resultatas b on a.fips = b.fips
group by a.group_per_capita_money_income_in_past_12_months_2009_2013,
		b.party
order by 1,2
)
select a.*,
		sum(Liczba_hrabstw) over (partition by group_per_capita_money_income_in_past_12_months_2009_2013) Liczba_hrabstw_w_grupie,
		Liczba_hrabstw / sum(Liczba_hrabstw) over (partition by group_per_capita_money_income_in_past_12_months_2009_2013) * 100 Pct
from cte a
