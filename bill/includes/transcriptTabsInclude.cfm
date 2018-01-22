<cfinvoke component="pcclinks.bill.ProgramBilling" method="getTranscriptTerms" returnvariable="data">
	<cfinvokeargument name="bannerGNumber" value="#url.bannerGNumber#">
</cfinvoke>
<style>
 .tabs-panel{
	padding:0;
}
</style>
<!-- Tabs -->
<ul class="tabs" data-tabs id="transcript-tabs">
	<cfoutput query="data">
		<cfset key = #term# >
		<cfset liClass = "tabs-title">
		<cfif term EQ url.lasttermbilled><cfset liClass = liClass & " is-active"></cfif>
  		<li class="#liClass#"><a href="###term#" aria-selected="<cfif term EQ url.lasttermbilled>true<cfelse>false</cfif>">#term#</a></li>
	</cfoutput>
</ul>

<!-- tab content -->
<div class="tabs-content" data-tabs-content="transcript-tabs">
<cfoutput query="data">
  	<div class= "tabs-panel<cfif term EQ url.lasttermbilled> is-active</cfif>" id="#term#">
    	<cfmodule template="termTranscriptInclude.cfm"
			pidm = #pidm#
			term = #term#
			contactId = #contactId#>
  	</div>
</cfoutput>
</div>

<script>
$(document).foundation();
</script>