<cfsetting requesttimeout="180">
<cfinclude template="includes/header.cfm">


<cfparam name="selectedCRN" default="">
<cfif structKeyExists(Session, "selectedCRN") and url.type EQ 'Attendance'>
	<cfset Variables.selectedCRN = Session.selectedCRN>
</cfif>

<cfinvoke component="LookUp" method="getCurrentYearTerms" returnvariable="qryTerms"></cfinvoke>

<cfif url.type EQ 'Term'>
	<cfinvoke component="LookUp" method="getNextTermToBill" returnvariable="term"></cfinvoke>
	<cfset billingStartDate = ''>
<cfelse>
	<cfinvoke component="LookUp" method="getLastAttendanceDateClosed" returnvariable="attendanceData"></cfinvoke>
	<cfset term = attendanceData.Term>
	<cfset billingStartDate = attendanceData.billingStartDate>
</cfif>


<cfinvoke component="LookUp" method="getPrograms" returnvariable="qryPrograms"></cfinvoke>


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
<div id="errorMessage" class="callout alert" style="display:none"></div>
<div id="addStudent" style="display:none">
	<div class="callout primary">
		<div class="row">
			<div class="small-12 columns">
				Add Student: <input id="bannerGNumber" name="bannerGNumber" type="text" readonly style="max-width:25%;display:inline-block" >
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
						<option  value="#term#" <cfif qryTerms.term EQ term>selected</cfif> >#termDescription#</option>
						</cfoutput>
					</select>
				</label>
			</div>
			<div class="small-3 columns">
				<label>Term Begin Date:<br/>
					<input name="termBeginDate" id="termBeginDate" type="text"  readonly="true" />
				</label>
			</div>
			<div class="small-3 columns">
				<label>Term Drop Date:<br/>
					<input name="termDropDate" id="termDropDate" type="text" readonly="true" />
				</label>
			</div>
			<div class="small-3 columns"></div>
		</div>
		<div class="row">
			<div class="small-3 columns">
				<label>Billing Start Date:<br/>
					<input name="billingStartDate" id="billingStartDate" type="text" class="fdatepicker" />
				</label>
			</div>
			<div class="small-3 columns">
				<label>Billing End Date:<br/>
					<input name="billingEndDate" id="billingEndDate" type="text" class="fdatepicker" />
				</label>
			</div>
			<div class="small-6 columns"></div>
		</div>
		<div class="row">
			<div class="small-3 columns" id="crnselect"></div>
			<div class="small-9 columns">
				<br><input class="button" type="submit" name="submit" value="Add Student to Billing" onClick="javascript:addStudentToBilling();" id="addStudentToBilling"/>
				<input class="button" value="New Search" onClick="javascript:newSearch();" id="newSearch">
			</div>
		</div>
		<div id="result"></div>
	</div> <!-- end div callout primary -->
</div><!-- end div addStudent -->

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
</div> <!-- end div search -->

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
</div> <!-- end SIDNY data -->

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
</div> <!-- end person data -->

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
</div> <!-- end Banner course data -->

<cfsavecontent variable="pcc_scripts">
<script>
	var returnPage = null;
	<cfif IsDefined("Session.addStudentReturnPage") and url.type EQ 'Attendance'>returnPage = '<cfoutput>#Session.addStudentReturnPage#</cfoutput>';</cfif>
	var table;
	var selectedCRN = '<cfoutput>#selectedCRN#</cfoutput>';
	var billingType = '<cfoutput>#url.type#</cfoutput>';

	$(document).ready(function() {
		$.fn.dataTable.ext.errMode = 'throw';

		setUpTables();

		<cfoutput>
		billingType = '#url.type#';
		if(billingType == 'Term'){
			setTermDates('#term#');
		}else{
			setAttendanceDates('#term#','#billingStartDate#');
		}
		</cfoutput>

		 $('#term').on('change', function(e) {
			 if(billingType == 'Term'){
			 	setTermDates($('#term').val());
			 }else{
			 	setAttendanceDates($('#term').val(),'');
			 }
		  });
	})
	//end document ready


	function setUpTables(){
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
                    	var d = moment(data, "MMM Do YYYY hA");
                        return  moment(d).isValid() ? moment(d).format('M/D/YY') : '';
                    }
                 },
			 	{targets : 5 ,
                    render: function ( data, type, row ) {
                    	var d = moment(data, "MMM Do YYYY hA");
                        return  moment(d).isValid() ? moment(data).format('M/D/YY') : '';
                    }
                 },
                {targets: 7,
			 	render: function ( data, type, row ) {
			 				if(row[8] != 0){
                 				return '<a href="javascript:addStudent(\''+data+'\')">Select</a>';
			 				}else{
			 					return '<span style="color:red">Cannot Add without Banner Attribute</span>';
			 				}
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
	}

	function addStudentToBilling(){
		$('#addStudentToBilling').attr('disabled',true);
		$('#addStudentToBilling').val("Please wait ...");
		$('#newSearch').hide();
		var crn = "";
		if($("#crn").length !== 0) {
			crn = $('#crn').val();
		}

        $.ajax({
            url: "setUpBilling.cfc?method=addBillingStudent",
            type:'post',
            data:{bannerGNumber:$('#bannerGNumber').val(), term:$('#term').val(),
            		billingStartDate:$('#billingStartDate').val(), billingEndDate:$('#billingEndDate').val(),
            		crn: crn, billingType: billingType},
            dataType: 'json',
            async:false,
            success: function(billingStudentId){
            	if(Array.isArray(billingStudentId)){
            		$("#errorMessage").html("An error occurred adding this student.<br>"+billingStudentId[1]);
            		$("#errorMessage").css("display", "block");
            	}else{
            		window.location = 'javascript:getBillingStudent('+billingStudentId+');';
            	}
            },
            error: function (jqXHR, exception) {
			    handleAjaxError(jqXHR, exception);
            }
        });
        if(returnPage){
        	window.location = returnPage;
        }
    }
	function setTermDates(term){
        var url = 'LookUp.cfc?method=getBannerCalendarEntry&term=' + term;
        $.ajax({
            url: url,
            dataType: 'json',
            success: function(termData){
            	$.each(termData.COLUMNS, function(index, col){
            		v = termData.DATA[0][index];
            		switch(col){
            			case "TERMBEGINDATE":
            				$("#termBeginDate").val(v);
            				$("#billingStartDate").val(v);
            				break;
            			case "TERMENDDATE":
            				$("#termEndDate").val(v);
            				$("#billingEndDate").val(v);
            				break;
            			case "TERMDROPDATE":
            				$("#termDropDate").val(v);
            				break;
            		}
            	});
            },
            error: function (jqXHR, exception) {
					handleAjaxError(jqXHR, exception);
			}
        })
   	}
   	function setAttendanceDates(term, billingStartDate){
		selectedTerm = term;
        var url = 'LookUp.cfc?method=getAttendanceDatesToBill&term=' + term;
        if(billingStartDate.length > 0){
        	url = url  + '&billingStartDate=' + billingStartDate;
        }
        $.ajax({
            url: url,
            dataType: 'json',
            success: function(termData){
            	$.each(termData.COLUMNS, function(index, col){
            		v = termData.DATA[0][index];
            		switch(col){
            			case "TERMBEGINDATE":
            				$("#termBeginDate").val(v);
            				break;
            			case "TERMENDDATE":
            				$("#termEndDate").val(v);
            				break;
            			case "TERMDROPDATE":
            				$("#termDropDate").val(v);
            				break;
            			case "NEXTBEGINDATE":
            				$("#billingStartDate").val(v);
            				break;
            			case "NEXTENDDATE":
            				$("#billingEndDate").val(v);
            				break;
            			case "MAXBILLABLEDAYSPERBILLINGPERIOD":
            				$("#MaxBillableDaysPerBillingPeriod").val(v);
            				break;
            		}
            	});
            },
            error: function (jqXHR, exception) {
					handleAjaxError(jqXHR, exception);
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
		$('#search').css("display", "none");
		if(billingType == 'Attendance'){
			getCRN();
		}
		$('#addStudent').css("display", "block");
	}
	function newSearch(){
		$('#search').css("display", "block");
		$('#addStudent').css("display", "none");
	}

	function getCRN(){
		var url = "includes/crnForTermInclude.cfm?billingStartDate=" + $('#billingStartDate').val() + '&crn='+ selectedCRN;
		$.ajax({
        	url: url,
       		cache: false
    	}).done(function(data) {
        	$("#crnselect").html(data);
    	});
	}


</script>
</cfsavecontent>


<cfinclude template="includes/footer.cfm">