<cfinclude template="includes/header.cfm" />

<cfset Variables.CRN = "27513">
<cfset Variables.Term = "201702">
<cfset Variables.BillingDate = "2017-04-01 00:00:00">

<cfinvoke component="SetUpBilling" method="setUpBillingClassAttendanceForMonth"  returnvariable="data">
	<cfinvokeargument name="term" value="#Form.Term#">
	<cfinvokeargument name="crn" value="#Form.CRN#">
	<cfinvokeargument name="billingdate" value="#Form.BillingDate#">
</cfinvoke>



<!---
<cfinvoke component="SetUpBilling" method="getClassAttendanceGrid"  returnvariable="data">
	<cfinvokeargument name="crn" value="#Variables.CRN#">
	<cfinvokeargument name="term" value="#Variables.Term#">
	<cfinvokeargument name="billingdate" value="#Variables.BillingDate#">
</cfinvoke>
--->
<cfquery name="buckets" dbtype="query">
	select billingDate
	from data
	group by billingDate
</cfquery>

<cfquery name="heading" dbtype="query">
	select crn, crse, subj, title
	from data
	group by crn, crse, subj, title
</cfquery>


<div class="callout primary">
<cfoutput>Term: #Variables.Term#&nbsp;Class:#heading.subj#-#heading.crse#&nbsp;#heading.title#&nbsp;(#Variables.crn#)</cfoutput>
</div>
<table name="dt_table">
	<thead>
		<tr>
			<th>Name</th>
			<cfoutput query="buckets">
			<th><a href="javascript:goToDetail('#BillingDate#');">#BillingDate#</a></th>
			</cfoutput>
		</tr>
	</thead>
	<tbody>
		<cfset g = ''>
		<cfoutput query="data">
		<cfif g EQ #bannerGnumber#>
				<td>#courseValue#</td>
		<cfelse>
			<cfif g NEQ ''></tr></cfif>
			<tr>
				<td>#bannerGnumber#</td>
				<td>#courseValue#</td>
		</cfif>
		<cfset g = "#bannerGnumber#">
		</cfoutput>
			</tr>
	</tbody>
</table>
<cfsavecontent variable="pcc_scripts">
<script>
		function goToDetail(billingDate){
			<cfoutput>
			sessionStorage.setItem("billingDate", billingDate);
			sessionStorage.setItem('crn', '#Variables.crn#');
			sessionStorage.setItem('term', '#Variables.term#');
			</cfoutput>
			var data = $.param({data:encodeURIComponent(JSON.stringify(sessionStorage))});
  			$.post("SaveSession.cfm", data, function(){
  				window.location	='attendanceDetail.cfm';
  			});
		}
</script>
</cfsavecontent>
<cfinclude template="includes/footer.cfm" />
