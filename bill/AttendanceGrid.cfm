<cfinclude template="includes/header.cfm" />

<cfinvoke component="ProgramBilling" method="getLatestDateAttendanceMonth"  returnvariable="attendanceMonth"></cfinvoke>
<cfparam name="billingStartDate" default = #attendanceMonth# >
<cfif structKeyExists(Session, "billingStartDate")>
	<cfset Variables.billingStartDate = Session.billingStartDate>
</cfif>
<cfinvoke component="ProgramBilling" method="getClassAttendanceGrid"  returnvariable="data">
	<cfinvokeargument name="billingStartDate" value="#Variables.billingStartDate#">
	<cfinvokeargument name="crn" value="#Session.CRN#">
</cfinvoke>


<!---
<cfinvoke component="SetUpBilling" method="getClassAttendanceGrid"  returnvariable="data">
	<cfinvokeargument name="crn" value="#Variables.CRN#">
	<cfinvokeargument name="term" value="#Variables.Term#">
	<cfinvokeargument name="billingdate" value="#Variables.BillingDate#">
</cfinvoke>
--->
<cfquery name="buckets" dbtype="query">
	select billingStartDate
	from data
	group by billingStartDate
</cfquery>

<cfquery name="heading" dbtype="query">
	select crn, crse, subj, title
	from data
	group by crn, crse, subj, title
</cfquery>


<div class="callout primary">
<cfoutput>Term: #Session.Term#&nbsp;Class:#heading.subj#-#heading.crse#&nbsp;#heading.title#&nbsp;(#Session.crn#)</cfoutput>
</div>
<table name="dt_table">
	<thead>
		<tr>
			<th>Name</th>
			<cfoutput query="buckets">
			<th><a href="javascript:goToDetail('#Variables.billingStartDate#');">#Variables.billingStartDate#</a></th>
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
		function goToDetail(billingStartDate){
			<cfoutput>
			sessionStorage.setItem("billingStartDate", billingStartDate);
			sessionStorage.setItem('crn', '#Session.crn#');
			sessionStorage.setItem('term', '#Session.term#');
			</cfoutput>
			var data = $.param({data:encodeURIComponent(JSON.stringify(sessionStorage))});
  			$.post("SaveSession.cfm", data, function(){
  				window.location	='attendanceDetail.cfm';
  			});
		}
</script>
</cfsavecontent>
<cfinclude template="includes/footer.cfm" />
