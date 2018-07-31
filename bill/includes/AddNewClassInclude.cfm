


<div class="callout" id="addNewClassDisplay">
	<div class="row">
		<div class="small-12 columns">Enter a CRN or, if there is no CRN, a Short Name to Identify the Class.
			<ul>
				<li>Subject, Course and Title are optional.</li>
				<li>Select below the students to add to the new class.</li>
				<li>Once all the students have been added, click &#60;Enter Attendance&#62.</li>
			</ul>
		</div>
	</div>
	<div class="row">
		<div class="small-2 columns"><label>CRN:* <input id="crn_anc"></label></div>
		<div class="small-2 columns"><label>SUBJ: <input id="subj_anc"></label></div>
		<div class="small-2 columns"><label>CRSE: <input id="crse_anc"></label></div>
		<div class="small-2 columns"><label>TITLE: <input id="title_anc"></label></div>
		<div class="small-4 columns">
			<input id="btnEnterAttendance_anc" type="button" class="button" value="Cancel" onClick="javascript:showAttendanceParent();"/>
		</div>
	</div>
</div>


<cfmodule template="addBillingStudentsAttendanceInclude.cfm"
	billingStartDate="#url.billingStartDate#"
	dataType = "allStudentsForBillingStartDate"
>


<script>


	function  insertItem(billingStudentID, billingStudentItemId)
	{
		var crn = $('#crn_anc').val();
		if($('#crn_anc').val() == ''){
			alert('Enter a CRN before adding students');
			$('#'+billingStudentID).attr('checked', false);
			return;
		}
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
            			billingStudentItemId:billingStudentItemId},
            datatype:'json',
            success: function(billingStudentItemID){
            	$('#' + billingStudentID).parent().html('<a href="javascript:removeItem(' + billingStudentItemID + ', billingStudentId=' + billingStudentID + ');" id=' + billingStudentID + '>Remove Entry</a>');
            	$('#btnEnterAttendance_anc').val('Enter Attendance');
				//selectedCRN declared in parent
				selectedCRN = $('#crn_anc').val();
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
	            data: {billingStudentItemID: billingStudentItemID},
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
	function showAttendanceParent(){
		//selectedCRN declared in parent
		if(selectedCRN != ''){
	    	getCRN();
		}
	    showAttendance();
	}

</script>