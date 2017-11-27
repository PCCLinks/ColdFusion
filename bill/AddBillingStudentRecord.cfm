<cfinclude template="includes/header.cfm" />

<form>
<label>firstname:<input name="firstname" id="firstname"></label>
<label>lastname:<input name="lastname" id="firstname"></label>
<label>Banner G Number:<input name="bannerGNumber" id="bannerGNumber"></label>
<input type="button" class="button" onClick="javascript:doSearch()">
</form>

<table id="dt_sidny">
	<thead>
		<tr>
			<td>First Name</td>
			<td>Last Name</td>
			<td>G</td>
			<td>Program</td>
			<td>Enrolled Date</td>
			<td>School District</td>
		</tr>
	</thead>
</table>
<table id="dt_banner"></table>
<table id="dt_billing"></table>

<script>


</script>


<cfinclude template="includes/footer.cfm" />