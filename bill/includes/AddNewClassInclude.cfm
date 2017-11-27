<cfinvoke component="pcclinks.bill.ProgramBilling" method="getAttendanceStudentsForBillingStartDate"  returnvariable="data">
	<cfinvokeargument name="billingStartDate" value="#url.billingStartDate#">
</cfinvoke>

<div class= "callout display" id="addNewClassDisplay">
	<div class="row">
		<div class="small-12 columns"><b>Enter a CRN or Short Name to Identify the Class, if No CRN</b></div>
	</div>
	<div class="row">
		<div class="small-2 columns"><label>CRN: <input id="crn_anc"></label></div>
		<div class="small-2 columns"><label>SUBJ: <input id="subj_anc"></label></div>
		<div class="small-2 columns"><label>CRSE: <input id="crse_anc"></label></div>
		<div class="small-2 columns"><label>TITLE: <input id="title_anc"></label></div>
		<div class="small-4 columns">
			<input type="button" class="button" value="Save Class" onClick="javascript:saveClass();"/>
			<input type="button" class="button" value="Enter Attendance" onClick="javascript:showAttendance($('#crn_anc').val());"/>
		</div>
	</div>
</div>

<div id="addStudents">
	<h3>Select Students to Add To Class</h3>
	<table id="dt_table_anc">
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
</div>


<script>
	$(document).ready(function() {
		//intialize table
		$.fn.dataTable.ext.errMode = 'throw';
		$('#dt_table_anc').DataTable( {
			order:[[2, 'desc'],[1, 'asc']]
		});
		$('#addStudents').hide();
	});
	function saveClass(){
		$('#addStudents').show();
	}
	function  insertItem(billingStudentID, billingStudentItemId)
	{
		if($('#crn_anc').val() == ''){
			alert('Enter a CRN before adding students');
			$('#'+billingStudentID).attr('checked', false);
			return;
		}
		var crn = $('#crn_anc').val();
		if($('#subj_anc').val() == ''){
				$('#subj_anc').val(crn);
		}
		if($('#crse_anc').val() == ''){
				$('#crse_anc').val(crn);
		}
		if($('#title_anc').val() == ''){
				$('#title_anc').val(crn);
		}
		$.ajax({
            type: 'post',
            url: 'programBilling.cfc?method=insertClass',
            data: {billingStudentId: billingStudentID, crn: crn, subj: $('#subj_anc').val(), crse: $('#crse_anc').val(), title:$('#title_anc').val(),
            			billingStudentItemId:billingStudentItemId, isAjax:'true'},
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