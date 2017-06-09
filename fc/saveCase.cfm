<!---<cfdump var="#FORM#">--->
<cfset Session.bannerGNumber = FORM.bannerGNumber>
<cfinvoke component="fc" method="updateCase">
<cfinvokeargument name="data" value="#FORM#">
</cfinvoke>
<br><br>
<cflocation url = "student.cfm">
