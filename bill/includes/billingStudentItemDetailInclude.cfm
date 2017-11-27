<cfif IsDefined("url.BillingStudentItemId")>
	<cfset Variables.billingStudentItemId = url.billingStudentItemId>
<cfelse>
	<cfif IsDefined("attributes.BillingStudentItemId")>
		<cfset Variables.billingStudentItemId = attributes.billingStudentItemId>
	<cfelse>
		<cfthrow message="billingStudentItemDetail.cfm missing url or attribute value for billingStudentItemId">
	</cfif>
</cfif>
<cfinvoke component="pcclinks.bill.ProgramBilling" method="getBillingStudentItemDetail" returnvariable="data">
	<cfinvokeargument name="billingStudentItemId" value="#Variables.billingStudentItemId#">
</cfinvoke>

<style>
	.pasteCell{
		padding-left:5px;
		padding-right:5px;
		padding-top:2px;
		padding-bottom:2px;
		border-color:rgb(221,221,221);
		border-style:solid;
		border-width:1px;
</style>

<table style="width:auto">
<tr>
<cfoutput query="data">
	<td class="pasteCell">#billingStudentItemDetailValue#</td>
</cfoutput>
</tr>
</table>