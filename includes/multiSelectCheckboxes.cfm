

<!--- this requires that variables be set for:
	mscb_fieldNamedescription, mscb_fieldname, mscb_data query of values that has id, description, checked

<cfdump var="#mscbvar_data#">--->
<cfset Variables.summary = "">
<cfloop query="mscb_data">
	<cfif checked>
		<cfif len(Variables.summary) GT 0>
			<cfset Variables.summary =Variables.summary & ", <br>">
		</cfif>
		<cfset Variables.summary = Variables.summary & "#description#">
	</cfif>
</cfloop>

	<label for="#mscb_fieldName#"><cfoutput>#mscb_fieldNameDescription# <i>(click to expand)</i></cfoutput>
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
