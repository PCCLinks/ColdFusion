<cfset debug="true">
<cfif debug><cfdump var="#FORM#"></cfif>
<cfset formData = FORM.data>
<cfif RIGHT(formData,1) EQ '/'>
	<cfset formData  = LEFT(data, LEN(data)-1)>
</cfif>
<cfset data = DeserializeJSON(URLDecode(formData))>
<cfif debug><cfdump var="#data#"></cfif>
<cfif NOT StructISEmpty(data)>
	<cfscript>
	structAppend(SESSION, data);
	</cfscript>
</cfif>
<cfif debug><cfdump var="#SESSION#"></cfif>