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
<table id="dt_banner"><thead>
		<tr>
			<td>First Name</td>
			<td>Last Name</td>
			<td>G</td>
		</tr>
	</thead>
</table>

<script>
	var table;
	$(document).ready(function() {
		//intialize table
		$.fn.dataTable.ext.errMode = 'throw';

		table = $('#dt_table').DataTable( {
			processing:true,
			ajax:{
				url:"setUpBilling.cfc?method=getSIDNYData",
				type:'POST',
				data: function(d){
						d.firstname = $('#firstNameSearch').val();
						d.lastname = $('#lastNameSearch').val();
						d.bannerGNumber = $('#bannerGNumberSearch').val();
						},
				dataSrc:'DATA',
				error: function (xhr, textStatus, thrownError) {
				        handleAjaxError(xhr, textStatus, thrownError);
					}
			},
			columnDefs:[{targets:2,
			 	render: function ( data, type, row ) {
                 			return '<a href="javascript:addStudent(\''+data+'\')">' + data + '</a>';
            			}
			 	}]
		});
		$('#addStudent').hide();

		 $('body').on('change', '#term', function(e) {
		 	termValue = $('#term').val();
		 	setDate(termValue, 'TermBeginDate', 'termBeginDate');
		 	setDate(termValue, 'TermDropDate', 'termDropDate');
		 });
	})

</script>


<cfinclude template="includes/footer.cfm" />