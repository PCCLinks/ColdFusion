<cfinvoke component="fc" method="getNotes"  id = #studentvar_id# returnvariable="notes"></cfinvoke>

<div class="card" style="overflow-y: scroll;height:150px">
<cfoutput query="notes">
<b>-- #DateFormat(noteDateAdded,'m/d/y')# #noteAddedBy# --</b><br>
#noteText#<br>
</cfoutput>
</div>
