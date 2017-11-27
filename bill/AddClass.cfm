<cfinclude template="includes/header.cfm">
<cfinvoke component="LookUp" method="getLatestDateAttendanceMonth"  returnvariable="attendanceMonth"></cfinvoke>
<cfparam name="selectedBillingStartDate" default = #attendanceMonth# >
<cfif structKeyExists(url, "billingStartDate")>
	<cfset Variables.billingStartDate = url.billingStartDate>
</cfif>
<cfinvoke component="LookUp" method="getAttendanceBillingStartDates" returnvariable="billingDates"></cfinvoke>

<cfinvoke component="LookUp" method="getAttendanceCRN"  returnvariable="crnData">
	<cfinvokeargument name="billingStartDate" value="#attendanceMonth#">
</cfinvoke>
<style>

	.dataTables_info{
		margin-right:10px !important;
	}
	select {
		width:auto !important;
	}
	input{
		display:inline-block !important;
		width:auto !important;
	}

</style>

<div class= "callout display" id="addExistingClassDisplay">
	<div class="row">
		<div class="large-4 columns" >
				<label for="billingStartDate">Month Start Date:
				<select name="billingStartDate" id="billingStartDate" onChange="javascript:getCRN()">
					<option disabled selected value="" > --Select Month Start Date-- </option>
				<cfoutput query="billingDates">
					<option value="#billingStartDate#" <cfif billingStartDate EQ attendanceMonth> selected </cfif>  > #DateFormat(billingStartDate,'mm-dd-yy')# </option>
				</cfoutput>
				</select>
			</label>
		</div>
		<div class="large-4 columns" id="crnselect"></div>
		<div class="large-4 columns">
			<br><input type="button" class="button" value="Add New Class" id="addClass" onClick="javascript:showNewClass();">
			<input type="button" class="button" value="Get Student List" id="addStudents" onClick="javascript:showStudents();">
		</div>
	</div>
</div>

<div class= "callout display" id="addNewClassDisplay">
	<div class="row">
		<div class="small-2 columns"><label>CRN: <input id="crn"></label></div>
		<div class="small-2 columns"><label>SUBJ: <input id="subj"></label></div>
		<div class="small-2 columns"><label>CRSE: <input id="crse"></label></div>
		<div class="small-2 columns"><label>TITLE: <input id="title"></label></div>
		<div class="small-4 columns">
			<input type="button" class="button" value="Get Student List" onClick="javascript:getCRNChanged();"/>
			<input type="button" class="button" value="Add Existing Class" id="addClass" onClick="javascript:showExistingClass();">
		</div>
	</div>
</div>

<div id="addStudentsToClass">
</div>


<cfsavecontent variable="pcc_scripts">
<script>
	var addingClass = false;
	$(document).ready(function() {
		getCRN();
		showExistingClass();

	});

	function getCRN(){
		$.ajax({
        	url: "includes/crnForTermInclude.cfm?billingStartDate="+$('#billingStartDate').val(),
       		cache: false
    	}).done(function(data) {
        	$("#crnselect").html(data);
    	});
	}
	function showNewClass(){
		addingClass = true;
		$('#addNewClassDisplay').show();
		$('#addExistingClassDisplay').hide();
	}
	function showExistingClass(){
		addingClass = false;
		$('#addNewClassDisplay').hide();
		$('#addExistingClassDisplay').show();
	}
	function setClassInfo(){
		if(addingClass){
			crn = $('#crn').val();
			subj = $('#subj').val();
			crse = $('#crse').val();
			title = $('#title').val();
		}else{
			crn = $('#crnSelect').val();
		}
	}
	/*
	function setClassInfo(){
		if(addingClass){
			sessionStorage.setItem('crn', $('#crn').val());
			sessionStorage.setItem('subj', $('#subj').val());
			sessionStorage.setItem('crse', $('#crse').val());
			sessionStorage.setItem('title', $('#title').val());
		}else{
			sessionStorage.setItem('crn', $('#crnSelect').val());
		}
		var data = $.param({data:encodeURIComponent(JSON.stringify(sessionStorage))});
  		$.post("SaveSession.cfm", data);
	}*/
	function getCRNChanged(){
		setClassInfo();
		$.ajax({
            type: 'get',
            url: 'AddStudentsToClass.cfm?billingStartDate=' + $('#billingStartDate').val() + '&crn='+$('#crn').val(),
            success: function (data, textStatus, jqXHR) {
            	if(addingClass){
            		addingClass=false;
            		$('#crnSelect').append($('<option>', {
						    value: crn,
						    text: crn,
						    selected:true
						}));
					showExistingClass();
            	}
				$('#addStudentsToClass').html(data);
			},
            error: function (xhr, textStatus, thrownError) {
				 handleAjaxError(xhr, textStatus, thrownError);
			}
          });
	}

</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm">