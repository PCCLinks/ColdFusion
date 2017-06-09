
<div class="card" style="overflow-y: scroll;height:150px">
<cfoutput query="notesvar_data">
<b>-- #DateFormat(noteDateAdded,'m/d/y')# #noteAddedBy# --</b><br>
#noteText#<br>
</cfoutput>
</div>
