<cfinclude template="includes/header.cfm">
<cfparam name="selectedBillingStartDate" default="" >
<cfif structKeyExists(url, "billingStartDate")>
	<cfset Variables.selectedBillingStartDate = url.billingStartDate>
<cfelse>
	<cfinvoke component="LookUp" method="getCurrentProgramYear"  returnvariable="programYear"></cfinvoke>
</cfif>
<!---><cfinvoke component="LookUp" method="getBillingStudentWithMaxBillingStartDate" returnvariable="billingDates"></cfinvoke>--->
<cfinvoke component="ProgramBilling" method="getExitDateList" returnvariable="data">
	<cfinvokeargument name="programYear" value="#Variables.programYear#">
</cfinvoke>

<cfinvoke component="LookUp" method="getExitReasons" returnvariable="exitReasons"></cfinvoke>
<style>

	.dataTables_info{
		margin-right:10px !important;
	}
	.dataTables_wrapper .dataTables_filter{
		float:left;
		text-align:left;
	}
	.dataTables_filter input{
		width:75%;
		display: inline-block;
	}
	select {
		width:auto;
	}
	input{
		display:inline-block;
		width:auto;
	}

</style>
<!--->
<div class= "callout display" id="addExistingClassDisplay">
	<div class="row">
		<div class="medium-12 columns" >
				<label for="billingStartDate">Month Start Date:
				<select name="billingStartDate" id="billingStartDate" onChange="javascript:refreshPage()">
					<option disabled selected value="" > --Select Month Start Date-- </option>
				<cfoutput query="billingDates">
					<option value="#billingStartDate#" <cfif billingStartDate EQ Variables.selectedBillingStartDate> selected </cfif>  > #DateFormat(billingStartDate,'mm-dd-yy')# </option>
				</cfoutput>
				</select>
			</label>
		</div>
	</div>
</div>--->

<div class="row">
	<div class="small-6 columns">
		<table id="dt_table">
			<thead>
				<tr>
					<th>Name</th>
					<th>G</th>
					<th>Program</th>
					<th>Billing Period</th>
					<th>Exit Date</th>
					<th>Exit Reason</th>
				</tr>
			</thead>
			<tbody>
			<cfoutput query="data">
				<tr>
					<cfset heading = firstname & ' ' & lastname & ' (' & bannerGNumber & ')' >
					<td>#firstname# #lastname#</td>
					<td><a href='javascript:getStudent(#billingStudentId#)'>#bannerGNumber#</a></td>
					<td>#program#</td>
					<td>#billingPeriod#</td>
					<td>#exitdate#</td>
					<td>#billingstudentexitreasondescription#</td>
				</tr>
			</cfoutput>
			</tbody>
		</table>
	</div>
	<div class="small-1 columns"></div>
	<br><br>
	<div class="small-5 columns">
		<div class="callout primary" id="selectedGNumber">Select a Student from the left</div>
		<div id="target"></div>
	</div>
</div>


<cfsavecontent variable="pcc_scripts">
<script>
	var currentRow;
	var currentBillingStudentId;
	var table;
	$(document).ready(function() {
		$('#dt_table').DataTable({
			order:[[4, 'desc'],[1],[0]],
			dom: 'ftlp',
			saveState: true
		});
		table = $('#dt_table').DataTable();
		$('#dt_table tbody').on( 'click', 'tr', function () {
    		currentRow =this;
		} );
	});
	function refreshPage(){
		window.location = window.location.pathname + '?billingStartDate=' + $('#billingStartDate').val();
	}
	function getStudent(billingStudentId){
		currentBillingStudentId = billingStudentId;
		var heading = '<b>' + table.cell(currentRow, 0).data() + '</b>'
							+ ' (' + table.cell(currentRow,1).data().replace('getStudent','goToDetail') + ') '
							+ '<br><b>Program:</b> ' + table.cell(currentRow,2).data() + ', <b>Billing Period:</b> ' + table.cell(currentRow,3).data();

		$.ajax({
        	url: "includes/billingstudentRecordInclude.cfm?billingStudentId=" + billingStudentId,
       		cache: false
    	}).done(function(data) {
        	$("#selectedGNumber").html(heading);
        	$("#target").html(data);
    	});
	}
	function goToDetail(billingStudentId){
		window.open('programStudentDetail.cfm?billingStudentId='+billingStudentId+'&showNext=false');
	}
	function saveValues(frmId){
	 	var $form = $('#'+frmId);
	 	var id = frmId.substring(3,10);
	    $.ajax({
	       	url: 'report.cfc?method=updateBillingStudentRecord',
	       	type: 'POST',
	       	data: $form.serialize(),
	       	success: function (data, textStatus, jqXHR) {
	        	var d = new Date();
				$('#savemessage').html('Saved ' + addZero(d.getHours()) + ':' + addZero(d.getMinutes()) + ':' + addZero(d.getSeconds()));
				$.ajax({
		        	url: "programBilling.cfc?method=getExitDateList&billingStudentId=" + currentBillingStudentId,
		       		cache: false,
		       		dataType:'json'
		    	}).done(function(data) {
					table.cell(currentRow,4).data($('#exitDate'+id).val()).draw('page');
					table.cell(currentRow,5).data($('#billingStudentExitReasonCode' + id + ' option:selected').text()).draw('page');
		    	});
	    	},
			error: function (jqXHR, exception) {
	      		handleAjaxError(jqXHR, exception);
			}
		});
	}

	function addZero($time) {
	  if ($time < 10) {
	    $time = "0" + $time;
	  }
	  return $time;
	}

</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm">