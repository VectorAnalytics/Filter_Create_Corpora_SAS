/*This code .......................*/

/* Define library where patent data is stored. */
LIBNAME pats "C:\Users\Mprice79\Documents\MP_Patents\Patent_SAS";


*Append patents together;
data all_patents;
	set 
	  	pats.patent_data_2013
		pats.patent_data_2014
		pats.patent_data_2015 
		pats.patent_data_2016
		;
		*Create a yymonth variable from the grant_date;
		yrmonth=substrn(grant_date,1,6);
		cpc_search_field = (trim(left(cpc_m_section))||trim(left(cpc_m_class))||trim(left(cpc_m_subclass))||trim(left(cpc_m_main_group)));
run;
data selected_patents;
	set all_patents;
	
	if (cpc_search_field in ('B64D27', 'B64D29', 'B64D31', 'B64D33', 'B64D35', 'B64D37'));
	
	run;
*Need to sort dataset before first. and last. variables become available to use;
Proc sort data=selected_patents out=sorted_patents;	
	by yrmonth;
	run;

/*This data step groups the data by month and counts the number of patents with cpc code only, uspc code only,
	and both cpc and uspc codes.  Unfortunately detecting missing values did not work on this data, so I needed to
	use the "anyalnum" function to detect if the cpc or uspc was missing. Doing it 6 times as I have is processing
	time intensive.  If I created 2 variables to hold the results of the "anyalnum" function, 
	then did the if/then, it might be faster. */

data power_counts;
	set sorted_patents;
	by yrmonth; *yrmonth is my group by variable;
	*I must retain the values of the count variables while reading in a yrmonth (where yrmonth is the "by"/sort variable);
	retain cpc_only_count uspc_only_count have_both_count;
	*Reinitialize counts to 0 at the start of a new month.;
	if first.yrmonth then do;
		cpc_only_count=0;
		uspc_only_count=0;
		have_both_count=0; 
	end;
	
	if (anyalnum(main_uspc) > 0 )	and (anyalnum(cpc_m_section) = 0) then uspc_only_count+1;  
	if (anyalnum(cpc_m_section) > 0) and (anyalnum(main_uspc) = 0) then cpc_only_count+1;
	if (anyalnum(cpc_m_section) > 0) and (anyalnum(main_uspc) > 0)  then have_both_count+1;   
	
	*Output the counts when I'm done processing a yrmonth.;
	if last.yrmonth=1 then output;
	keep yrmonth cpc_only_count uspc_only_count have_both_count;
	
	run; 
