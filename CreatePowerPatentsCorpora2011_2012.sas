/*This code selects patents based on CPC codes for a specific technology area. This code works on 2011 and 2012 data
as in those years all cpcs are mapped, none were assigned with thought.*/

/* Define library where patent data is stored. */
LIBNAME pats "C:\Users\Public\Documents\Patent_SAS";


*Append patents together;

data all_patents;
	set 
		pats.patent_data_2011_mapped
		pats.patent_data_2012_mapped 
		;
		*Create a yymonth variable from the grant_date;
		yrmonth_n= input(substrn(grant_date,1,6), 6.);
		*create a cpc search field based on the cpc code that I have mapped to the patent;
		cpc_search_field = scan(cpc_mapped,1,'/');
run; 

data selected_patents;
	set all_patents;
	if (cpc_search_field in ('B64D27', 'B64D29', 'B64D31', 'B64D33', 'B64D35', 'B64D37'));
	run;

data pats.power_2011 pats.power_2012;
	set selected_patents;
	if yrmonth_n <201201 then output pats.power_2011;
	if yrmonth_n >=201201 then output pats.power_2012;
run;
