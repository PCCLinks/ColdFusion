<cfparam name="so_values" type="array" default="#attributes.so_values#">
<cfparam name="so_selectedvalue" type="string" default="#attributes.so_selectedvalue#">
<cfparam name="so_label" type="string" default="#attributes.so_label#">
<cfparam name="so_selectname" type="string" default="#attributes.so_selectname#">

<cfoutput>
<cfif so_selectedvalue EQ "">
	<cfset selectedFound = true>
<cfelse>
	<cfset selectedFound = false>
	<cfloop array="#so_values#" item="value">
		<cfif so_selectedvalue EQ value>
			<cfset selectedFound = true>
		</cfif>
	</cfloop>
</cfif>
<label>#so_label#
	<select name="#so_selectname#">
		<option value=""
			<cfif #so_selectedvalue# EQ "">selected</cfif>
		>
			--- None Selected ---
		</option>
	<cfloop array="#so_values#" item="value">
		<option value="#value#"
			<cfif "#so_selectedvalue#" eq "#value#">selected</cfif>
		>
			#value#
		</option>
	</cfloop>
	<cfif selectedFound EQ false>
	<option value="#so_selectedvalue#" selected>#so_selectedvalue# (legacy)</option>
	</cfif>
	</select>
</label>
</cfoutput>