	<!-- current term content container -->
	<div class= "tabs-panel is-active" id="<cfoutput>#Session.mostRecentTermBillingStudentId#H</cfoutput>">
		<cfmodule template="programStudentHeaderInclude.cfm"
			qryBillingStudentEntries = #Session.qryBillingStudentEntries#
			billingStudentId = #Session.mostRecentTermBillingStudentId#>
	</div> <!-- end current term content container -->


	<!-- Previous Term Content Container -->
	<cfoutput query="Session.qryOtherBilling">
	<div class= "tabs-panel" id="#billingStudentId#H">
		<cfmodule template="programStudentHeaderInclude.cfm"
			qryBillingStudentEntries = #Session.qryBillingStudentEntries#
			billingStudentId = #billingStudentId#>
	</div> <!-- end Previous term content container -->
	</cfoutput>