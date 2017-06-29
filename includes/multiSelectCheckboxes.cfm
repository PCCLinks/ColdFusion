<!--- expects to call a method that returns a query with two fields:
  id, description
  also expects that the table follows a naming convention where
  the primarykey is [tablename]+id, i.e. householdid --->

<cfparam name="contactid" default="url.contactid">
<cfparam name="mscb_componentname" default="url.mscb_componentname">
<cfparam name="mscb_methodname" default="url.mscb_methodname">
<cfparam name="mscb_fieldName" default="url.mscb_fieldName">
<cfparam name="mscb_Description" default="url.mscb_Description">

<cfinvoke component="#mscb_componentname#" method="#mscb_methodname#" contactID=#contactID#  returnVariable="mscb_data">

<cfset Variables.summary = "">
<cfloop query="mscb_data">
	<cfif checked>
		<cfif len(Variables.summary) GT 0>
			<cfset Variables.summary =Variables.summary & ", <br>">
		</cfif>
		<cfset Variables.summary = Variables.summary & "#description#">
	</cfif>
</cfloop>

<label for="#mscb_fieldName#"><cfoutput>#mscb_Description#<i>(click to expand)</i></cfoutput>
<ul class="accordion" data-accordion data-allow-all-closed="true">
	<li class="accordion-item" data-accordion-item>
  		<a href="#" class="accordion-title"><cfoutput>#Variables.summary#</cfoutput></a>
		<div class="accordion-content" data-tab-content>
		<cfoutput query="mscb_data">
			<cfset idname="#mscb_fieldName#" & #id#>
			<label for="#description#"><input id="#idname#" name="#idname#" type="checkbox" <cfif #checked#>checked</cfif>>#description#</label>
		</cfoutput>
  		</div>
	</li>
</ul>
</label>

<script>
$('.accordion-item').click(function() {
    if($(this).find('.accordion-title').attr('aria-expanded')=="false") {
    	title = '';
        $(this).find("input[type=checkbox]").each(function() {
			if(this.checked){
				if(title.length > 0){
					title = title + ', <br>';
				}
            	title = title + this.nextSibling.nodeValue;
			}
        });
        $(this).find('.accordion-title').html(title);
    }
});
</script>