/*This code selects patents based on CPC codes for a specific technology area. This code works on 2014+ data,
being mindful of which month CPC started to be assigned with thought for that particular technology area. 
Two datasets are created, one that captures patents during a training period (of when both CPC and USPC was assigned
with thought, and a second data set of post May 2015 (the date that USPCs was no longer assigned)*/

/* Define library where patent data is stored. */
LIBNAME pats "C:\Users\Mprice79\Documents\MP_Patents\Patent_SAS";


*Append patents together;

data all_patents;
	set 
	  /*	pats.patent_data_2013  */
		pats.patent_data_2014
		pats.patent_data_2015 
		pats.patent_data_2016
		;
		*Create a yymonth variable from the grant_date;
		yrmonth_n= input(substrn(grant_date,1,6), 6.);
		cpc_search_field = (trim(left(cpc_m_section))||trim(left(cpc_m_class))||trim(left(cpc_m_subclass))||trim(left(cpc_m_main_group)));
run; 
data selected_patents;
	set all_patents;
	if (cpc_search_field in ('B64D27', 'B64D29', 'B64D31', 'B64D33', 'B64D35', 'B64D37'));
	run;


data pats.power_post201505 pats.power_201406to201505;
	set selected_patents;
	if yrmonth_n >201505 then output pats.power_post201505;
	if (yrmonth_n >=201406 and yrmonth_n<=201505) then output pats.power_201406to201505;
run;
