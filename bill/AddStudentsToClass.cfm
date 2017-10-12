<cfinvoke component="ProgramBilling" method="getAttendanceStudentsForTerm"  returnvariable="data">
	<cfinvokeargument name="term" value="#url.term#">
	<cfinvokeargument name="billingStartDate" value="#url.billingStartDate#">
	<cfinvokeargument name="crn" value="#url.crn#">
</cfinvoke>



	<table id="dt_table">
		<thead>
			<th>Name</th>
			<th>Banner G Number</th>
			<th>Add</th>
		</thead>
		<tbody>
			<cfoutput query="data">
			<tr>
				<td>#firstname#&nbsp;#lastname#</td>
				<td>#bannerGNumber#</td>
				<td><cfif #includeFlag# EQ 1><a href="javascript:removeItem(#billingStudentItemID#, #billingStudentID#);" id=#billingStudentID#>Remove Entry</a>
					<cfelse><input type="checkbox" id=#billingStudentID# onclick="javascript:insertItem(#billingStudentID#, #billingStudentItemID#);">
					</cfif>
				</td>
			</tr>
			</cfoutput>
		</tbody>
	</table>


<script>
	$(document).ready(function() {
		//intialize table
		$.fn.dataTable.ext.errMode = 'throw';
		$('#dt_table').DataTable( );
	});

	function  insertItem(billingStudentID, billingStudentItemId)
	{
		setClassInfo();
		$.ajax({
            type: 'post',
            url: 'programBilling.cfc?method=insertClass',
            data: {billingStudentId: billingStudentID, crn: crn, subj: subj, crse: crse, title: title, typecode: 'ATTENDANCE', billingStudentItemId:billingStudentItemId, isAjax:'true'},
            datatype:'json',
            success: function(billingStudentItemID){
            	$('#' + billingStudentID).parent().html('<a href="javascript:removeItem(' + billingStudentItemID + ', billingStudentId=' + billingStudentID + ');" id=' + billingStudentID + '>Remove Entry</a>');
            },
            error: function (jqXHR, exception) {
				handleAjaxError(jqXHR, exception);
			}
        });
	}

	function  removeItem(billingStudentItemID, billingStudentID)
	{
		var response = window.confirm('Are you sure you want to remove this item?');
		if(response)
		{
			$.ajax({
	            type: 'post',
	            url: 'programBilling.cfc?method=removeItem',
	            data: {billingStudentItemID: billingStudentItemID, isAjax:'true'},
	            datatype:'json',
	            success: function(){
	            	$('#' + billingStudentID).parent().html('<input type="checkbox" id=' + billingStudentID + ' onclick="javascript:insertItem(' + billingStudentID + ', ' + billingStudentItemID + ');">');
	            },
	            error: function (jqXHR, exception) {
					handleAjaxError(jqXHR, exception);
				}
        });
		}
	}

</script>


