<cfinclude template="includes/header.cfm">

<cfinvoke component="LookUp" method="getMaxTerm"  returnvariable="maxTerm"></cfinvoke>
<cfinvoke component="LookUp" method="getLatestDateAttendanceMonth"  returnvariable="maxBillDate"></cfinvoke>
<cfinvoke component="ProgramBilling" method="getAttendanceCRNForTerm"  returnvariable="crnData">
	<cfinvokeargument name="term" value="#maxTerm#">
	<cfinvokeargument name="billingStartDate" value="#maxBillDate#">
</cfinvoke>

<div class= "callout display" id="addExistingClassDisplay">
	<div class="row">
		<div class="medium-2 columns"><label>Select Existing CRN:
			<select id="crnSelect">
				<option value="" selected>--- None Selected ---</option>
				<cfoutput query="crnData"><option value="#crn#">#crn#</option></cfoutput>
			</select>
		</div>
		<div class="medium-10 columns">
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
			<input type="button" class="button" value="Get Student List" onClick="javascript:showStudents();"/>
			<input type="button" class="button" value="Add Existing Class" id="addClass" onClick="javascript:showExistingClass();">
		</div>
	</div>
</div>

<div id="addStudentsToClass">
</div>


<cfsavecontent variable="pcc_scripts">
<script>
	var addingClass = false;
	<cfoutput>
	var term=#maxTerm#;
	var billingDate = '#maxBillDate#';
	var crn = '';
	var subj = '';
	var title = '';
	var crse = '';
	</cfoutput>
	$(document).ready(function() {
		showExistingClass();

	});
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
	function showStudents(){
		setClassInfo();
		$.ajax({
            type: 'get',
            url: 'AddStudentsToClass.cfm?term=' + term + '&billingStartDate=' + billingDate + '&crn='+crn,
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