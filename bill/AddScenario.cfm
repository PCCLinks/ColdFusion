<cfinclude template="includes/header.cfm">

<cfinvoke component="LookUp" method="getTerms" returnvariable="qryTerms"></cfinvoke>


<div class= "callout display">
	<div class="row">
		<div class="small-3 columns">
			<label>Term:<br/>
				<select name="term" id="term"/>
					<option disabled selected value="" >
						--Select Term--
					</option>
					<cfoutput query="qryTerms">
					<option  value="#term#" >#term#</option>
					</cfoutput>
				</select>
			</label>
		</div>
</div>

<div id="dataTable"></div>

<cfsavecontent variable="pcc_scripts">
<script>
	$(document).ready(function() {
		//intialize table
		$.fn.dataTable.ext.errMode = 'throw';
		$('#dt_table').DataTable();
	});

	function  insertItem(billingStudentID)
	{
		var crn = '99999';
		var subj = 'TUT';
		var crse = '99999';
		var title = 'Tutor Roll';
		var typecode = 'ATTENDANCE'
		$.ajax({
            type: 'post',
            url: 'programBilling.cfc?method=insertClass',
            data: {billingStudentId: billingStudentID, crn: crn, subj: subj, crse: crse, title: title, typecode: typecode, isAjax:'true'},
            datatype:'json',
            success: function(billingStudentItemID){
            	$('#' + billingStudentID).parent().html('<a href="javascript:removeItem(' + billingStudentItemID + ');" id=' + billingStudentID + '>Remove Entry</a>');
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
	            	$('#' + billingStudentID).parent().html('<input type="checkbox" id=' + billingStudentID + ' onclick="javascript:insertItem(' + billingStudentID + ');">');
	            },
	            error: function (jqXHR, exception) {
					handleAjaxError(jqXHR, exception);
				}
        });
		}
	}

</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm">