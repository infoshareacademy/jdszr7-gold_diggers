

--Wspólne id
select distinct a.fips
into "SQL_project".county_id
from "SQL_project".county_facts_csv_counties a
join "SQL_project". primary_results_csv b on a.fips = b.fips


--Wybieram moje kolumny do analizy
drop table "SQL_project".county_facts_csv_counties_my_columns;
select a.fips,
		a.area_name,
		a.state_abbreviation,
		a.population_2014,
		language_other_than_english_at_home_age_min_5_pct_2009_2013,
		min_highschool_graduate_age_min_25_pct_2009_2013,
		min_bachelor_age_min_25_pct_2009_2013,
		veterans_2009_2013,
		veterans_2009_2013/population_2014 * 100 veterans_pct_2009_2013,
		mean_travel_time_to_work_minutes_age_min_16_2009_2013,
		manufacturers_shipments_2007,	--wysy³ki producentów w tysi¹cach USD
		merchant_wholesaler_sales_2007,		--sprzeda¿ hurtowa w tysi¹cach USD 
		retail_sales_2007,	--sprzeda¿ detaliczna w tysi¹cach USD
		retail_sales_per_capita_2007,
		accommodation_and_food_services_sales_2007,	--sprzeda¿ us³ug noclegowych i gastronomicznych w tysi¹cach USD
		building_permits_2014
into "SQL_project".county_facts_csv_counties_my_columns
from "SQL_project".county_facts_csv_counties a
join "SQL_project".county_id b on a.fips = b.fips;


--Przerobienie tabeli z wynikami wyborów, aby dla ka¿dego hrabstwa mieæ 1 rekord z nazw¹ zwyciêskiej partii
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
from "SQL_project".primary_results_csv a
join "SQL_project".county_id b on a.fips = b.fips
)
select distinct a.*
into "SQL_project".Results
from cte a
where votes_pct > 0.5
order by state, county, party;



select * from "SQL_project".Results
where state = 'Kansas'
;

select * from "SQL_project".Results
where state = 'Washington'
;
select * from "SQL_project".Results
where state = 'Pennsylvania'
and county = 'Philadelphia'
;

with cte as (
select *,
		sum(votes) over (order by state) suma_stan,
		sum(votes) over (partition by candidate order by state) suma_kandydat,
		sum(votes) over (partition by party order by state) suma_partia
from "SQL_project".primary_results_csv a
where state = 'Washington'
order by county, party
)
select distinct party, candidate, suma_stan, suma_kandydat, suma_partia,
 suma_kandydat::float/suma_stan::float * 100 pct_stan,
 suma_kandydat::float/suma_partia::float * 100 pct_kandydat_w_partii
from cte
;
------------------------------------------------------------------------------------------------------------------------------------


--kwartyle (tu podmienia³am nazwy moich kolumn i budowa³am na tej podstawie case'y w dalszej czêœci)
select 
		percentile_disc(array[0.25, 0.5, 0.75]) within group (order by building_permits_2014 )
from "SQL_project".county_facts_csv_counties_my_columns a
join "SQL_project".county_id b on a.fips = b.fips;



drop table "SQL_project".Dane_do_tabel_krzyzowych;
select 
		a.fips,
		a.area_name,
		a.state_abbreviation,
		--a.population_2014,
		case when language_other_than_english_at_home_age_min_5_pct_2009_2013 < 3 then '< 3'
			 when language_other_than_english_at_home_age_min_5_pct_2009_2013 between 3 and 5 then '3 - 5'
			 when language_other_than_english_at_home_age_min_5_pct_2009_2013 between 5 and 11 then '5 - 11'
			 else '> 11'
			 end group_language_other_than_english_at_home_age_min_5_pct_2009_2013,
		case when min_highschool_graduate_age_min_25_pct_2009_2013 < 80 then '< 80'
			 when min_highschool_graduate_age_min_25_pct_2009_2013 between 80 and 85 then '80 - 85'
			 when min_highschool_graduate_age_min_25_pct_2009_2013 between 85 and 90 then '85 - 90'
			 else '> 90'
			 end group_min_highschool_graduate_age_min_25_pct_2009_2013,
		case when min_bachelor_age_min_25_pct_2009_2013 < 10 then '< 10'
			 when min_bachelor_age_min_25_pct_2009_2013 between 10 and 15 then '10 - 15'
			 when min_bachelor_age_min_25_pct_2009_2013 between 15 and 20 then '15 - 20'
			 else '> 20'
			 end group_min_bachelor_age_min_25_pct_2009_2013,
		case when veterans_pct_2009_2013 < 6 then '< 6'
			 when veterans_pct_2009_2013 between 6 and 8 then '6 - 8'
			 when veterans_pct_2009_2013 between 8 and 10 then '8 - 10'
			 else '> 10'
			 end group_veterans_pct_2009_2013,
		case when mean_travel_time_to_work_minutes_age_min_16_2009_2013 < 20 then '< 20'
			 when mean_travel_time_to_work_minutes_age_min_16_2009_2013 between 20 and 23 then '20 - 23'
			 when mean_travel_time_to_work_minutes_age_min_16_2009_2013 between 23 and 27 then '23 - 27'
			 else '> 27'
			 end group_mean_travel_time_to_work_minutes_age_min_16_2009_2013,
		case when manufacturers_shipments_2007 = 0 then '0'
			 when manufacturers_shipments_2007 between 0 and 50000 then '0 - 50k'
			 when manufacturers_shipments_2007 between 50000 and 100000 then '50k - 100k'
			 else '> 100k'
			 end group_manufacturers_shipments_2007,
		case when merchant_wholesaler_sales_2007 = 0 then '0'
			 when merchant_wholesaler_sales_2007 between 0 and 50000 then '0 - 50k'
			 when merchant_wholesaler_sales_2007 between 50000 and 250000 then '50k - 250k'
			 else '> 250k'
			 end group_merchant_wholesaler_sales_2007,
		case when retail_sales_2007 < 100000 then '< 100k'
			 when retail_sales_2007 between 100000 and 300000 then '100k - 300k'
			 when retail_sales_2007 between 300000 and 800000 then '300k - 800k'
			 else '> 800k'
			 end group_retail_sales_2007,
		case when retail_sales_per_capita_2007 < 6000 then '< 6k'
			 when retail_sales_per_capita_2007 between 6000 and 10000 then '6k - 10k'
			 when retail_sales_per_capita_2007 between 10000 and 13000 then '10k - 13k'
			 else '> 13k'
			 end group_retail_sales_per_capita_2007,
		case when accommodation_and_food_services_sales_2007 < 6000 then '< 6 000'
			 when accommodation_and_food_services_sales_2007 between 6000 and 25000 then '6 000 - 25 000'
			 when accommodation_and_food_services_sales_2007 between 25000 and 100000 then '25 000 - 100 000'
			 else '> 100 000'
			 end group_accommodation_and_food_services_sales_2007,
		case when building_permits_2014 < 5 then '< 5'
			 when building_permits_2014 between 5 and 30 then '5 - 30'
			 when building_permits_2014 between 30 and 150 then '30 - 150'
			 else '> 150'
			 end group_building_permits_2014
into "SQL_project".Dane_do_tabel_krzyzowych
from "SQL_project".county_facts_csv_counties_my_columns a
join "SQL_project".county_id b on a.fips = b.fips
;


select * from "SQL_project".Dane_do_tabel_krzyzowych r;

----------INFORMATION VALUE-----------

--tu podmienia³am case'y. Ni¿ej spisywa³am wartoœci IV
drop table Table1;
select 
		a.fips,
		a.area_name,
		a.state_abbreviation,
		a.population_2014,
		case when building_permits_2014 < 5 then '< 5'
			 when building_permits_2014 between 5 and 30 then '5 - 30'
			 when building_permits_2014 between 30 and 150 then '30 - 150'
			 else '> 150'
			 end
			 Var,
			 b.party,
			 b.sum_total,
			 b.sum_party,
			 b.votes_pct,
		case when party = 'Republican' then 1 else 0 end Party_Republican,
		case when party = 'Democrat' then 1 else 0 end Party_Democrat
into temporary table Table1
from "SQL_project".county_facts_csv_counties_my_columns a
join "SQL_project".Results b on a.fips = b.fips;


with cte as(
select Var,
		count(*) Liczba,
		sum(Party_Republican) Party_Republican,
		 sum(Party_Democrat) Party_Democrat
from Table1
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



-------------------------------------------------------------------------------------------------------------------------------
--0.09318573145715522		language_other_than_english_at_home_age_min_5_pct_2009_2013,
--0.036962469467006195		min_highschool_graduate_age_min_25_pct_2009_2013,
0.11538105238938737		min_bachelor_age_min_25_pct_2009_2013,
0.20113020165360568		veterans_2009_2013/population_2014 * 100 veterans_pct_2009_2013,
----0.008408121984440103		mean_travel_time_to_work_minutes_age_min_16_2009_2013,
----0.01854844130647324		manufacturers_shipments_2007,	--wysy³ki producentów w tysi¹cach USD
--0.04803159282455956		merchant_wholesaler_sales_2007,		--sprzeda¿ hurtowa w tysi¹cach USD 
--0.08258814451315032		retail_sales_2007,	--sprzeda¿ detaliczna w tysi¹cach USD
--0.0647786572226739		retail_sales_per_capita_2007,
0.12137448417600086		accommodation_and_food_services_sales_2007,	--sprzeda¿ us³ug noclegowych i gastronomicznych w tysi¹cach USD
--0.07330280076355754		building_permits_2014


< 0.02	nieu¿yteczne - 2
0.02 - 0.1 s³aby predyktor - 6
0.1 - 0.3 œredni predyktor
0.3 - 0.5 mocny predyktor
> 0.5 podejrzanie dobry predyktor

-------------------------------------------------------------------------------------------------------------------------------

--Wybieram œrednie predyktory (w moim przypadku nie ma ¿adnego mocnego)

drop table decent_predictors;
select 
		a.fips,
		a.area_name,
		a.state_abbreviation,
		case when min_bachelor_age_min_25_pct_2009_2013 < 10 then '< 10'
			 when min_bachelor_age_min_25_pct_2009_2013 between 10 and 15 then '10 - 15'
			 when min_bachelor_age_min_25_pct_2009_2013 between 15 and 20 then '15 - 20'
			 else '> 20'
			 end group_min_bachelor_age_min_25_pct_2009_2013,
		case when veterans_pct_2009_2013 < 6 then '< 6'
			 when veterans_pct_2009_2013 between 6 and 8 then '6 - 8'
			 when veterans_pct_2009_2013 between 8 and 10 then '8 - 10'
			 else '> 10'
			 end group_veterans_pct_2009_2013,
		case when accommodation_and_food_services_sales_2007 < 6000 then '< 6 000'
			 when accommodation_and_food_services_sales_2007 between 6000 and 25000 then '6 000 - 25 000'
			 when accommodation_and_food_services_sales_2007 between 25000 and 100000 then '25 000 - 100 000'
			 else '> 100 000'
			 end group_accommodation_and_food_services_sales_2007
into temporary table decent_predictors
from "SQL_project".county_facts_csv_counties_my_columns a
join "SQL_project".county_id b on a.fips = b.fips
;

select * from decent_predictors;


select * from decent_predictors a
join "SQL_project".Results b on a.fips = b.fips;




----------TABELE KRZY¯OWE-------------
--Dane do wykresów

with cte as (
select a.group_min_bachelor_age_min_25_pct_2009_2013,
		b.party,
		 count(*) Liczba_hrabstw
from "SQL_project".Dane_do_tabel_krzyzowych a
join "SQL_project".results b on a.fips = b.fips
group by a.group_min_bachelor_age_min_25_pct_2009_2013,
		b.party
order by 1,2
)
select a.*,
		sum(Liczba_hrabstw) over (partition by group_min_bachelor_age_min_25_pct_2009_2013) Liczba_hrabstw_w_grupie,
		Liczba_hrabstw / sum(Liczba_hrabstw) over (partition by group_min_bachelor_age_min_25_pct_2009_2013) * 100 Pct
from cte a
;


with cte as (
select a.group_veterans_pct_2009_2013,
		b.party,
		 count(*) Liczba_hrabstw
from "SQL_project".Dane_do_tabel_krzyzowych a
join "SQL_project".results b on a.fips = b.fips
group by a.group_veterans_pct_2009_2013,
		b.party
order by 1,2
)
select a.*,
		sum(Liczba_hrabstw) over (partition by group_veterans_pct_2009_2013) Liczba_hrabstw_w_grupie,
		Liczba_hrabstw / sum(Liczba_hrabstw) over (partition by group_veterans_pct_2009_2013) * 100 Pct
from cte a
;


with cte as (
select a.group_accommodation_and_food_services_sales_2007,
		b.party,
		 count(*) Liczba_hrabstw
from "SQL_project".Dane_do_tabel_krzyzowych a
join "SQL_project".results b on a.fips = b.fips
group by a.group_accommodation_and_food_services_sales_2007,
		b.party
order by 1,2
)
select a.*,
		sum(Liczba_hrabstw) over (partition by group_accommodation_and_food_services_sales_2007),
		Liczba_hrabstw / sum(Liczba_hrabstw) over (partition by group_accommodation_and_food_services_sales_2007) * 100
from cte a
;




--------------------------------------------------------------------------------
--Rozk³ad zwyciêskich partii W skali stanów

drop table "SQL_project".Results_States_temp;
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
from "SQL_project".primary_results_csv a
join "SQL_project".county_id b on a.fips = b.fips
)
select distinct a.*
into "SQL_project".Results_States_temp
from cte a
--where votes_pct > 0.5
order by state, county, party;


select * from "SQL_project".Results_States_temp;


;with states as (
select distinct a.state,
		county,
		sum_total
from "SQL_project".Results_States_temp a
order by 1
)
, sum_total_states as (
select a.state,
		sum(sum_total) sum_total_states
from states a
group by a.state
)
, sum_party_states as(
select a.state,
		a.party,
		sum(sum_party) sum_party_states
from "SQL_project".Results_States_temp a
group by a.state,
		a.party
order by 1,2
)
select a.*,
		b.party,
		coalesce(b.sum_party_states, 0) sum_party_states,
		coalesce(b.sum_party_states, 0) / a.sum_total_states as pct_votes_states
from sum_total_states a
left join sum_party_states b on a.state = b.state
where coalesce(b.sum_party_states, 0) / a.sum_total_states > 0.5
order by 1,2,3
;


-------------------------------------------------------------------------------------------------------

--Wykres kandydatów

select a.*
into temporary table Candidates_Results
from "SQL_project".primary_results_csv a
join "SQL_project".county_id b on a.fips = b.fips
;



drop table Candidates_Winners;
with winners as (
select a.fips,
		a.state,
		a.county,
		a.party,
		a.candidate,
		fraction_votes,
		row_number() over (partition by a.state, a.county, a.party order by fraction_votes desc) rn
from Candidates_Results a
)
select a.*
into temporary table Candidates_Winners
from winners a
where a.rn = 1
;


with cte as (
select a.*,
		case when white_pct_2014 < 78 then '< 78'
			 when white_pct_2014 between 78 and 91 then '78 - 91'
			 when white_pct_2014 between 91 and 96 then '91 - 96'
			 else '> 96'
			 end Var
from Candidates_Winners a
join "SQL_project".county_facts_csv_counties b on a.fips = b.fips
)
, cte2 as (
select a.party,
		a.candidate,
		a.Var,
		count(*) Liczba_hrabstw
from cte a
group by a.party,
		a.candidate,
		a.Var
)
select a.*,
		sum(liczba_hrabstw) over (partition by party, var) liczba_hrabstw_w_grupie
from cte2 a
order by party, var, candidate
;

