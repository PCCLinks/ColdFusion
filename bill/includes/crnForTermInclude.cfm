<cfinvoke component="pcclinks.bill.LookUp" method="getAttendanceCRN" returnvariable="crnData">
	<cfinvokeargument name="billingStartDate" value="#url.billingstartdate#">
</cfinvoke>
<cfparam name="crnselected" default="None">
<cfif structKeyExists(url, "crn")>
	<cfset crnselected = url.crn>
</cfif>
<label>Select Existing CRN:
	<select id="crn" name="crn" onChange="javascript:getCRNChanged()">
		<option value="" <cfoutput><cfif crnselected EQ "None">selected</cfif></cfoutput> >--- None Selected ---</option>
		<cfoutput query="crnData"><option value="#crn#" <cfif crn EQ crnselected>selected</cfif> >#crn#</option></cfoutput>
	</select>
</label>