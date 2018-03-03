<cfinvoke component="pcclinks.bill.ProgramBilling" method="getAttendanceStudentsForCRN"  returnvariable="data">
	<cfinvokeargument name="billingStartDate" value="#url.billingStartDate#">
	<cfinvokeargument name="crn" value="#url.crn#">
</cfinvoke>

<cfmodule template="addBillingStudentsAttendanceInclude.cfm"
	billingStartDate="#url.billingStartDate#"
	crn = "#url.crn#"
	dataType = "studentsForCRN"
>


<script>
		$(document).ready(function() {
		//createTable();
		});

	function  insertItem(billingStudentID, billingStudentItemId)
	{
		$.ajax({
            type: 'post',
            url: 'programBilling.cfc?method=addStudentToClass',
            data: {billingStudentId: billingStudentID, crn: '<cfoutput>#url.crn#</cfoutput>', billingStudentItemId:billingStudentItemId, isAjax:'true'},
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
		var response = window.confirm('Are you sure you want to remove this student from this class?');
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


