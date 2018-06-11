<!--- pulled into a div in caseload.cfm, so no need for headers or footers --->

<!--- main content --->
<ul class="tabs" data-tabs id="student-tabs">
  <li class="tabs-title is-active"><a href="#panelEdit" aria-selected="true">Edit</a></li>
  <li class="tabs-title"><a href="#panelDashboard">Student Dashboard</a></li>
</ul>

<div class="callout primary">

	<div class = "row">
		<div class = "large-4 columns">
			<h3 id='heading_studentname'></h3>
		</div>
		<div class = "large-4 columns" style="text-align:left">
			<h3 id="heading_studentdata"></h3>
		</div>
		<div class = "large-4 columns" style="text-align:left">
			<h3 id="heading_registration"></h3>
		</div>
	</div>

</div>

<div class="tabs-content" data-tabs-content="student-tabs">
  <div class="tabs-panel is-active" id="panelEdit">
  </div>
  <div class="tabs-panel" id="panelDashboard">
  </div>
</div>

<script>
function loadStudent(pidm, maxTerm, doSave){
	var cohort;
	var bannerGNumber;

	//get main edit data fc.getEditCase
	$.ajax({
		  type: "POST",
		  url: 'fc.cfc',
		  data: {'method':'getEditCase', 'pidm':pidm},
		  success: function(data){
			editData = jQuery.parseJSON(data);

			//create a mapping of columns for use
			var colMap = new Object();
			for(var i = 0; i < editData.COLUMNS.length; i++) {
				colMap[editData.COLUMNS[i]] = i;
			}
			var rowData = editData.DATA[0];

			cohort = rowData[colMap["COHORT"]];
			bannerGNumber = rowData[colMap["BANNERGNUMBER"]];

			$('#heading_studentname').html(rowData[colMap["STU_NAME"]] + "<br>" + rowData[colMap["STU_ID"]]);
			$('#heading_studentdata').html('Overall GPA: ' + rowData[colMap["O_GPA"]] + '<br>Total Credits Earned: ' + rowData[colMap["O_EARNED"]]);

			loadStudent_panelEdit(pidm, cohort);
			loadStudent_panelDashboard(pidm, cohort, bannerGNumber);
		  },
		  error:function(jqXHR, exception, thrownError){
			handleAjaxError(jqXHR, exception, thrownError);
		  }
	});

	//get data for registration heading
	$.ajax({
		type:"POST",
		url: 'fc.cfc',
		data: {'method':'getMaxRegistration','pidm': pidm, 'maxterm': maxTerm},
		success: function(data){
			termData = jQuery.parseJSON(data);

			//create a mapping of columns for use
			var colMap = new Object();
			for(var i = 0; i < termData.COLUMNS.length; i++) {
				colMap[termData.COLUMNS[i]] = i;
			}
			var rowData = termData.DATA[0];

			var heading = 'Last Registration: <br> ' + rowData[colMap["MAXREGISTRATIONTERM"]]
					+ ' for ' + rowData[colMap["MAXREGISTRATIONCREDITS"]] + ' credits'
			$('#heading_registration').html(heading);
		},
		error:function(jqXHR, exception, thrownError){
			handleAjaxError(jqXHR, exception, thrownError);
		}
	});

	//autosave every 5 minutes
	saveInterval = 1000*60*5;
	doSave = setInterval(saveStudentContent, saveInterval);
}

function loadStudent_panelEdit(pidm, cohort){
	$.ajax({
		type: "POST",
		url: 'editCase.cfm',
		data: {'pidm':pidm, 'cohort':cohort},
	 	success: function(data){
	  		$('#panelEdit').html(data).foundation();
	 	}
	});
}

function loadStudent_panelDashboard(pidm, cohort, bannerGNumber, doSave){
	$.ajax({
		type: "POST",
		url: 'studentDashboard.cfm',
		data: {'pidm':pidm, 'cohort':cohort, 'bannerGNumber': bannerGNumber},
		success: function(data){
			$('#panelDashboard').html(data);
	  		loadStudent_panelDashboard_studentCharts(pidm, cohort, bannerGNumber);
	  		loadStudent_panelDashboard_classesTable(pidm, cohort);
		}
  	});
}

function unloadStudent(doSave, functionToCall){
	saveStudentContent(functionToCall);
	clearInterval(doSave);
}

function loadStudent_panelDashboard_classesTable(pidm, cohort){
	var dt_student_dashboard = $('#dt_table_studentdashboard').DataTable({
		processing:true,
		ajax:{
			url:"fc.cfc?method=getCoursesByStudentDashboardList",
			data:{'pidm':pidm, 'cohort':cohort},
			dataSrc:'DATA',
			columns:'COLUMN',
			error: function (xhr, textStatus, thrownError) {
			        handleAjaxError(xhr, textStatus, thrownError);
				}
		},
		searching: false,
		paging: false,
		info: false,
		createdRow: function( row, data, dataIndex ) {
			if ( data[5] == "N" &&row[4].length() > 0 ) {
		      	$(row).addClass( 'highlight' );
		    }
		},
    	orderFixed: [0, "desc" ],
    	rowGroup: {
    		dataSrc: 0
    	}
    }); //end datatable
    dt_student_dashboard.rowGroup().enable().draw();
}
function loadStudent_panelDashboard_studentCharts(pidm, cohort, bannerGNumber){
	$.ajax({
           type: 'post',
           datatype:'json',
		url:'fc.cfc?method=getStudentTermArray',
		data:{'bannerGNumber':bannerGNumber},
		error: function (xhr, textStatus, thrownError) {
		        handleAjaxError(xhr, textStatus, thrownError);
		},
		success:function(data){
			data = data.substring(1,data.length-1);
			termArray = data.split(",");
			loadStudentCharts_GPA(bannerGNumber, termArray);
			loadStudentCharts_Credits(bannerGNumber, termArray);
		}
	});
}

function loadStudentCharts_GPA(bannerGNumber, termArray){
	$.ajax({
           type: 'post',
           datatype:'json',
		url:'fc.cfc?method=getStudentGPAArray',
		data:{'bannerGNumber':bannerGNumber},
		error: function (xhr, textStatus, thrownError) {
		        handleAjaxError(xhr, textStatus, thrownError);
		},
		success:function(data){
			data = data.substring(1,data.length-1);
			gPAArray = data.split(",");
			buildStudentChart('line', termArray, gPAArray, 'graphGPA', 'rgba(144, 103, 167, 1.0)', 'rgba(144, 103, 167, 1.0)', 4, 0.5);
		}
	});
}

function loadStudentCharts_Credits(bannerGNumber, termArray){
	$.ajax({
           type: 'post',
           datatype:'json',
		url:'fc.cfc?method=getStudentCreditsEarnedArray',
		data:{'bannerGNumber':bannerGNumber},
		error: function (xhr, textStatus, thrownError) {
		        handleAjaxError(xhr, textStatus, thrownError);
		},
		success:function(data){
			data = data.substring(1,data.length-1);
			creditsEarnedArray = data.split(",");
			buildStudentChart('bar', termArray, creditsEarnedArray, 'graphCreditsEarned', 'rgba(144, 103, 167, 1.0)', 'rgba(144, 103, 167, 1.0)', 30, 5);
		}
	});
}

function buildStudentChart(type, labels, data, ctx, bgcolors, bcolors, yAxesMax, yAxesStep){
	var myChart = new Chart(ctx, {
		type: type,
		data: {
			labels: labels,
				lineThickness: 3,
				datasets: [{
				data: data,
				backgroundColor: bgcolors,
	            borderColor: bcolors,
			    borderWidth: 1,
				fill: false,
			}]
		},
		options: {
			responsive: true,
			legend:{
	           display:false
		    },
		    scales: {
			   xAxes: [{
			        gridLines: {
			            display: false,
			        }
			    }], //end xAxis
			    yAxes: [{
				  gridLines: {
				  	display:false
				  },
			      ticks: {
			        fontSize: 14,
					beginAtZero: true,
			        max: yAxesMax,
			        stepSize: yAxesStep,
			      },
			    }] //end yAxis
			  } //end scales
			} //end options
	}); //end chart
} //end build chart


function saveStudentContent(functionToCall){
	form = {};
	flagCheckBoxFound = false;
	flagFieldName = 'flagged';
	var contactId;
	//build a form object of all items on page
	//used to send a generic collection to the cfc update method
	$.each($('#editForm').serializeArray(), function(index, field) {
		if(field.name == flagFieldName){
			flagCheckBoxFound = true;
			//we know it is a checked value - field won't have that value in it
			form[field.name] = 1;
		}else{
   			form[field.name] = field.value;
		}
		if(field.name == "contactID"){
			contactId = field.value;
		}
   	});
   	//checkboxes only show up as posted values when checked
   	//if it was not found, add the unchecked value now
   	if(flagCheckBoxFound == false){
   		form[flagFieldName] = 0;
   	}


	$.ajax({
		type: 'post',
	    url: 'fc.cfc?method=updateCase',
		data: {data : JSON.stringify(form), isAjax:'yes'},
		datatype:'json',
		async:false,
		success: function (data, textStatus, jqXHR) {
			studentUpdateContent(contactId);
			var d = new Date();
			$('#savemessage').html('Last saved ' + addZero(d.getHours()) + ':' + addZero(d.getMinutes()) + ':' + addZero(d.getSeconds()));
			if(functionToCall){
				functionToCall();
			}
	   	},
	   	error: function (xhr, textStatus, thrownError) {
			handleAjaxError(xhr, textStatus, thrownError);
		}
	 });
}
function studentUpdateContent(contactId){
	//notes
	url = "includes/notes.cfm?contactid=" + contactId + "&tablename=futureConnect";
	$('#notes').load(url);
	//household
	url = "includes/multiselectcheckboxes.cfm?contactid=" + contactId + "&mscb_componentname=pcclinks.fc.fc&mscb_methodname=getHouseholdWithAssignments&mscb_fieldName=householdID&mscb_description=Household%20Information";
	$('#householdInfo').load(url, function(){$(this).foundation();});
	//living
	url = "includes/multiselectcheckboxes.cfm?contactid=" + contactId + "&mscb_componentname=pcclinks.fc.fc&mscb_methodname=getLivingSituationWithAssignments&mscb_fieldName=livingSituationID&mscb_description=Living%20Situation";
	$('#livingsituation').load(url, function(){$(this).foundation();});
	//enrichment
	url = "includes/multiselectcheckboxes.cfm?contactid=" + contactId + "&mscb_componentname=pcclinks.fc.fc&mscb_methodname=getEnrichmentProgramsWithAssignments&mscb_fieldName=enrichmentProgramId&mscb_description=Enrichment%20Program";
	$('#enrichmentprograms').load(url, function(){$(this).foundation();});
}
function addZero($time) {
  if ($time < 10) {
    $time = "0" + $time;
  }
  return $time;
}

</script>



