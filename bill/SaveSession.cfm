<cfset debug="true">
<cfif debug><cfdump var="#FORM#"></cfif>
<cfif structKeyExists(FORM, "data")>
	<cfset formData = FORM.data>
	<cfif RIGHT(formData,1) EQ '/'>
		<cfset formData  = LEFT(data, LEN(data)-1)>
	</cfif>
	<cfset data = DeserializeJSON(URLDecode(formData))>
<cfelse>
	<cfset data = FORM>
</cfif>
<cfif debug><cfdump var="#data#"></cfif>
<cfif NOT StructISEmpty(data)>
	<cfscript>
	structAppend(SESSION, data);
	</cfscript>
</cfif>
<cfif debug><cfdump var="#SESSION#"></cfif>
<cfif structKeyExists(FORM, "location")>
	<cflocation url="#FORM.location#">
</cfif>