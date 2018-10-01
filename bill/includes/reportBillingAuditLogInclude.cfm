<style>
.ui-widget-content a {
    color:#1779ba;
}
</style>

<b>Program or School District Changes</b><br/>
<table id="dt_billingStudentAudit" class="compact">
	<thead>
		<th>G Number</th>
		<th>First name</th>
		<th>Last Name</th>
		<th>Info</th>
		<th>Old Value</th>
		<th>New Value</th>
		<th>Action</th>
		<th>Changed Date</th>
		<th>Changed By</th>
		<th>BillingStudentId</th>
	</thead>
	<tbody>
</table>
<hr>
<b>Attendance Changes</b><br/>
<table id="dt_billingStudentItemAudit" class="compact">
	<thead>
		<th>G Number</th>
		<th>Subj</th>
		<th>Crse</th>
		<th>CRN</th>
		<th>Attendance</th>
		<th>Info</th>
		<th>Old Value</th>
		<th>New Value</th>
		<th>Action</th>
		<th>Changed Date</th>
		<th>Changed By</th>
	</thead>
	<tbody>
</table>

<script>
var dtBS;
var dtBSI;
var indexOfBillingStudentId = 9;
var indexOfBannerGNumber = 0;

function reportBillingAuditLogInclude_getAuditData(bannerGNumber, monthNumber){
	if(dtBS){
		dtBS.destroy(false);
	}
	dtBS = $('#dt_billingStudentAudit').DataTable({
		processing:true,
		searching:false,
		info:false,
		paging:false,
		language: {zeroRecords: 'No changes'},
		ajax:{
	       	url: 'report.cfc?method=getBillingStudentAudit',
	       	type: 'POST',
	       	data: {'bannerGNumber':bannerGNumber, 'monthNumber':monthNumber},
			dataSrc:function(json){
				return json.DATA;
				},
			error: function (xhr, textStatus, thrownError) {
			        handleAjaxError(xhr, textStatus, thrownError)
				},
	     },
		columnDefs:[
			{targets: indexOfBillingStudentId, visible: false, searchable: true},
			{targets:indexOfBannerGNumber,
				render: function ( data, type, row ) {
           				return '<a href="javascript:getBillingStudent(' + row[indexOfBillingStudentId] + ', true)">' + data + '</a>';
     				}
			}
  		],
    });

	if(dtBSI){
		dtBSI.destroy(false);
	}
	dtBSI = $('#dt_billingStudentItemAudit').DataTable({
		processing:true,
		searching:false,
		info:false,
		paging:false,
		language: {zeroRecords: 'No changes'},
		ajax:{
	       	url: 'report.cfc?method=getBillingStudentItemAudit',
	       	type: 'POST',
	       	data: {'bannerGNumber':bannerGNumber, 'monthNumber':monthNumber},
			dataSrc:function(json){
				return json.DATA;
				},
			error: function (xhr, textStatus, thrownError) {
			        handleAjaxError(xhr, textStatus, thrownError)
				},
	     }
    });

}
</script>
