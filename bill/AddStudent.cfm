<cfsetting requesttimeout="180">
<cfinclude template="includes/header.cfm">

<cfinvoke component="LookUp" method="getTerms" returnvariable="qryTerms"></cfinvoke>
<cfinvoke component="LookUp" method="getLatestAttendanceDates" returnvariable="qryDates"></cfinvoke>

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

<div id="addStudent">

<div class="callout primary">
	<div class="row">
		<div class="small-12 columns">
			Add Student: <input id="bannerGNumber" name="bannerGNumber" type="text" readonly style="max-width:25%;display:inline-block">
		</div>
	</div>
	<div class="row">
		<div class="small-3 columns">
			<label>Term:<br/>
				<select name="term" id="term" >
					<option disabled selected value="" >
						--Select Term--
					</option>
					<cfoutput query="qryTerms">
					<option  value="#term#" <cfif qryDates.term EQ term>selected</cfif> >#termDescription#</option>
					</cfoutput>
				</select>
			</label>
		</div>
		<cfoutput>
		<div class="small-3 columns">
			<label>Term Begin Date:<br/>
				<input name="termBeginDate" id="termBeginDate" type="text"  readonly="true" value="#DateFormat(qryDates.termBeginDate,"mm/dd/yyyy")#"/>
			</label>
		</div>
		<div class="small-3 columns">
			<label>Term Drop Date:<br/>
				<input name="termDropDate" id="termDropDate" type="text" readonly="true" value="#DateFormat(qryDates.termDropDate,"mm/dd/yyyy")#"/>
			</label>
		</div>
		</cfoutput>
		<div class="small-3 columns"></div>
	</div>
	<div class="row">
		<cfoutput>
		<div class="small-3 columns">
			<label>Billing Start Date:<br/>
				<input name="billingStartDate" id="billingStartDate" type="text" class="fdatepicker" value="#DateFormat(qryDates.billingStartDate,"mm/dd/yyyy")#"/>
			</label>
		</div>
		<div class="small-3 columns">
			<label>Billing End Date:<br/>
				<input name="billingEndDate" id="billingEndDate" type="text" class="fdatepicker" value="#DateFormat(qryDates.billingEndDate,"mm/dd/yyyy")#"/>
			</label>
		</div>
		</cfoutput>
		<div class="small-6 columns">
			<br><input class="button" type="submit" name="submit" value="Add Student to Billing" onClick="javascript:addStudentToBilling();" id="addStudentToBilling"/>
			<input class="button" value="New Search" onClick="javascript:newSearch();" id="newSearch">
		</div>
	</div>
	<div id="result"></div>
</div>

</div>

<div id="search">
	<div class="callout primary" >
		<div class="row">
			<div class="small-4 columns">
				Banner G Number: <input name="bannerGNumberSearch" id="bannerGNumberSearch" >
			</div>
			<div class="small-8 columns">
				<input type="button" class="button" value="Search" onClick="javascript:refreshTable()">
			</div>
		</div>
	</div>
</div>
<div class="callout">
	<b>SIDNY Data</b><br><br>
	<table id="dt_table_sidny">
		<thead>
			<tr>
				<th>First Name</th>
				<th>Last Name</th>
				<th>G</th>
				<th>Program</th>
				<th>Enrolled</th>
				<th>Exit</th>
				<th>School District</th>
				<th></th>
			</tr>
		</thead>
		<tbody></tbody>
	</table>
</div>
<div class="callout">
	<b>Banner Person Data</b><br><br>
	<table id="dt_table_banner_person">
		<thead>
			<tr>
				<th>Banner Attribute</th>
				<th>Name</th>
				<th>G</th>
			</tr>
		</thead>
		<tbody></tbody>
	</table>
</div>
<div class="callout">
	<b>Banner Course Data</b><br><br>
	<table id="dt_table_banner_course">
		<thead>
			<tr>
				<th>Term</th>
				<th>CRN</th>
				<th>LEVL</th>
				<th>SUBJ</th>
				<th>CRSE</th>
				<th>Title</th>
			</tr>
		</thead>
		<tbody></tbody>
	</table>
</div>

<cfsavecontent variable="pcc_scripts">
<script>
	<cfif IsDefined("Session.addStudentReturnPage")>var returnPage = '<cfoutput>#Session.addStudentReturnPage#</cfoutput>';</cfif>
	var table;
	$(document).ready(function() {
		//intialize table
		$.fn.dataTable.ext.errMode = 'throw';

		sidnyTable = $('#dt_table_sidny').DataTable( {
			processing:true,
			serverSide: true,
			deferLoading: 0,
			searching: false,
			paging: false,
			info: false,
			language: {zeroRecords: '<span style="color:red">No entry in SIDNY for this G Number for programs GtC or YtC</span>',
				emptyTable: 'Enter a G Number and Click Search'},
			ajax:{
				url:"setUpBilling.cfc?method=getSIDNYData",
				type:'POST',
				data: function(d){
						d.bannerGNumber = $('#bannerGNumberSearch').val();
						},
				dataSrc:'DATA',
				error: function (xhr, textStatus, thrownError) {
				        handleAjaxError(xhr, textStatus, thrownError);
					}
			},
			columnDefs:[
			 	{targets : 4 ,
                    render: function ( data, type, row ) {
                         return  moment(data).isValid() ? moment(data).format('M/D/YY') : '';
                    }
                 },
			 	{targets : 5 ,
                    render: function ( data, type, row ) {
                         return  moment(data).isValid() ? moment(data).format('M/D/YY') : '';
                    }
                 },
                {targets: 7,
			 	render: function ( data, type, row ) {
                 			return '<a href="javascript:addStudent(\''+data+'\')">Select</a>';
            			}
			 	},
               ]
		});

		bannerPersonTable = $('#dt_table_banner_person').DataTable( {
			processing:true,
			serverSide: true,
			deferLoading: 0,
			searching: false,
			paging: false,
			info: false,
			language: {zeroRecords: '<span style="color:red">No PCC Links Attribute set in Banner for this G Number</span>',
				emptyTable: 'Enter a G Number and Click Search'},
			ajax:{
				url:"setUpBilling.cfc?method=getBannerPerson",
				type:'POST',
				data: function(d){
						d.bannerGNumber = $('#bannerGNumberSearch').val();
						},
				dataSrc:'DATA',
				error: function (xhr, textStatus, thrownError) {
				        handleAjaxError(xhr, textStatus, thrownError);
					}
			}
		});

		bannerCourseTable = $('#dt_table_banner_course').DataTable( {
			processing:true,
			serverSide: true,
			deferLoading: 0,
			searching: false,
			paging: false,
			info: false,
			ajax:{
				url:"setUpBilling.cfc?method=getBannerCourse",
				type:'POST',
				data: function(d){
						d.bannerGNumber = $('#bannerGNumberSearch').val();
						},
				dataSrc:'DATA',
				error: function (xhr, textStatus, thrownError) {
				        handleAjaxError(xhr, textStatus, thrownError);
					}
			}
		});



		$('#addStudent').hide();

		 $('body').on('change', '#term', function(e) {
		 	termValue = $('#term').val();
		 	setDate(termValue, 'TermBeginDate', 'termBeginDate');
		 	setDate(termValue, 'TermDropDate', 'termDropDate');
		 });
	})
	function addStudentToBilling(){
		$('#addStudentToBilling').attr('disabled',true);
		$('#addStudentToBilling').val("Please wait ...");
		$('#newSearch').hide();
        $.ajax({
            url: "setUpBilling.cfc?method=addBillingStudent",
            type:'post',
            data:{bannerGNumber:$('#bannerGNumber').val(), term:$('#term').val(),
            		billingStartDate:$('#billingStartDate').val(), billingEndDate:$('#billingEndDate').val()},
            dataType: 'json',
            async:false,
            success: function(billingStudentId){
            	window.location = 'programStudentDetail.cfm?billingStudentId='+billingStudentId+'&showNext=false';
            },
            error: function (jqXHR, exception) {
			    handleAjaxError(jqXHR, exception);
            }
        });
        if(returnPage){
        	window.location(returnPage);
        }
    }
	function setDate(term, displayField, idName){
		selectedTerm = term;
        var url = 'LookUp.cfc?method=getFilteredTerm&term=' + term + '&displayField='+ displayField + '&ReturnFormat=json';
        $.ajax({
            url: url,
            dataType: 'json',
            success: function(response){
            	$('#' + idName).val(response);
            },
            error: function(ErrorMsg){
                console.log('Error');
            }
        })
    }
	function refreshTable(){
		sidnyTable.ajax.reload();
		bannerPersonTable.ajax.reload();
		bannerCourseTable.ajax.reload();
	}
	function addStudent(gNumber){
		$('#bannerGNumber').val(gNumber);
		$('#search').hide();
		$('#addStudent').show();
	}
	function newSearch(){
		$('#search').show();
		$('#addStudent').hide();
	}


</script>
</cfsavecontent>


<cfinclude template="includes/footer.cfm">