<!---><cfinvoke component="pcclinks.bill.ProgramBilling" method="getTranscriptTerms" returnvariable="data">
	<cfinvokeargument name="bannerGNumber" value="#url.bannerGNumber#">
</cfinvoke>--->

<cfinvoke component="pcclinks.bill.ProgramBilling" method="getBannerClassesForStudent"  returnvariable="data">
	<cfinvokeargument name="pidm" value="#url.pidm#">
</cfinvoke>
<cfset Session.getBannerClassesForTerm = data>
<cfquery dbtype="query" name="years">
	select ProgramYear
	from data
	group by ProgramYear
	order by ProgramYear desc
</cfquery>

<style>
 .tabs-panel{
	padding:0;
}
</style>

<!-- Year Tabs -->
<ul class="tabs" data-tabs id="year-tabs">
	<cfoutput query="years">
		<cfset key = #ProgramYear# >
		<cfset liClass = "tabs-title">
		<cfif ProgramYear EQ url.ProgramYear><cfset liClass = liClass & " is-active"></cfif>
  		<li class="#liClass#"><a href="###Replace(ProgramYear,'/','')#" aria-selected="<cfif ProgramYear EQ '2017/2018'>true<cfelse>false</cfif>">#ProgramYear#</a></li>
	</cfoutput>
</ul>

<!-- year tab content -->
<div class="tabs-content" data-tabs-content="year-tabs">
	<cfoutput query="years">
		<cfquery dbtype="query" name="terms">
			select term, termDescription
			from data
			where ProgramYear = <cfqueryparam value="#years.ProgramYear#">
			group by term, termDescription
			order by term desc
		</cfquery>
		<!-- Year tab panel -->
		<div class= "tabs-panel<cfif ProgramYear EQ url.ProgramYear> is-active</cfif>" id="#Replace(ProgramYear,'/','')#">
			<!-- Term Tabs -->
			<ul class="tabs" data-tabs id="transcript-tabs">
				<cfloop query="terms">
					<cfset key = #term# >
					<cfset liClass = "tabs-title">
					<cfif term EQ url.selectedTerm><cfset liClass = liClass & " is-active"></cfif>
			  		<li class="#liClass#"><a href="###term#" aria-selected="<cfif term EQ url.selectedTerm>true<cfelse>false</cfif>">#termDescription#<br>#term#</a></li>
				</cfloop>

				<!-- term tab content -->
				<div class="tabs-content" data-tabs-content="transcript-tabs">
				<cfloop query="terms">
					<!-- term tab panel -->
				  	<div class= "tabs-panel<cfif term EQ url.selectedTerm> is-active</cfif>" id="#term#">
				    	<cfmodule template="termTranscriptInclude.cfm" term = #term# >
				  	</div> <!-- end term tab panel -->
				</cfloop> <!--- end loop term --->
				</div> <!-- end term content tab -->
			</ul> <!-- end term tab -->
	</div> <!-- end year tab panel -->
</cfoutput>
</div> <!-- end year tab content -->

<script>
$(document).foundation();
</script>




