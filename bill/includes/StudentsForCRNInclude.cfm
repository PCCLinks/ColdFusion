<cfinvoke component="pcclinks.bill.programBilling" method="getAttendanceStudentForCRNAndTerm" returnvariable="data">
	<cfinvokeargument name="term" value="#url.term#">
	<cfinvokeargument name="crn" value="#url.crn#">
</cfinvoke>


<cfoutput query="data">
	#firstname# #lastname#<br/>
</cfoutput>
