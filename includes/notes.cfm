<cfparam name="tableName" default="url.tableName">
<cfparam name="contactID" default="url.contactID">

<cfquery name="comments">
	select *
	from notes
	where tableName = <cfqueryparam value="#tableName#">
		and contactID = <cfqueryparam value="#contactID#">
	order by noteDateAdded desc
</cfquery>

<label>Notes
	<textarea name="notes" rows="10"></textarea>
	<div class="card" style="overflow-y: scroll;height:150px">
		<cfoutput query="comments">
		<b>-- #DateFormat(noteDateAdded,'m/d/y')# #noteAddedBy# --</b><br>
		#noteText#<br>
		</cfoutput>
	</div><!-- end div card -->
</label>
