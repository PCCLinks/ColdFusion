<cfquery name="list_coach">
	SELECT distinct displayName as coach
	FROM applicationUser
	WHERE position = 'coach'
	ORDER BY 1 ASC
</cfquery>


<!--->
<style>
input.gridfilter{
	margin-bottom: 0px !important;
	padding: 4px;
}
.dataTables_length select {
	width:auto !important;
}
</style>
--->

<div id="errorDialog" ></div>
<!-- STEP 1 DO PASTE -->
<div id="step1">
	<div class="callout primary">
		Step 1: Paste Applicant Caseload Entries Here
	</div>
	<div class="callout">
		Paste rows from "awarded" spreadsheet in the box below. Include the header row. <br>
		- You copy additional columns than those you will want to import.<br>
		- Once you paste the rows, you will be able to map the columns for importing.  Make sure you include a column that has the student GNumber and Fund Source.<br>
		- Student name is not needed. Columns to import are: Preferred Name, Gender, Living Situation, Cell Phone, Alternate Phone and personal email.<br>
		- Coach can be set either by an input column, or separately.<br>
		<b>- Do NOT include the essay columns. They are too long and not needed.</b>
	</div>
	<textarea id="import_paste" onPaste="javascript:doPaste()" rows="15" cols="10" ></textarea>
</div>
<!-- END STEP 1 -->

<!--STEP 2 DO MAPPING -->
<div id="step2" style="display:none">
	<div class="callout primary">
		Columns to Import
	</div>
	<div class="callout">
		Select the matching import column to the spreadsheet columns below.  A match for the Banner GNumber is required.  Also select coach
		if it is not in the pasted information, and the cohort, if it is not correct.
	</div>
	<div class="row">
		<div class="columns small-4">
			<label for="coachImportSelect" id="lblcoachImportSelect">Coach for all entries:</label>
			<select id="coachImportSelect" name="coachImportSelect" style="width: 200px">
				<option value="" selected>--- Select ---</option>');
				<cfoutput query="list_coach">
				<option value="#coach#">#coach#</option>
				</cfoutput>
			</select>
		</div>
		<div class="columns small-8">
			<label for="cohortImport">Cohort:</label>
			<input  id="cohortImport" name="cohortImport" value="<cfoutput>#DatePart("yyyy", Now())#</cfoutput>" style="width:200px">
		</div>
	</div>
	<div id="importMapping"></div>
</div>
<!-- END STEP 2 -->

<!-- STEP 3 CONFIRM -->
<div id="step3" style="display:none">
	<div class="callout primary">Confirm Import</div>
	<div id="confirm"></div>
</div>
<!-- END STEP 3 -->

<!-- STEP 4 IMPORT RESULTS -->
<div id="step4" style="display:none">
	<div class="callout primary" >Import Results<br>
	You will need to log out and log back in to see these results in the caseload.</div>
	<div id="results"></div>
</div>
<!-- END STEP 4 -->

<input class="button" id="btnNext" value="Next" onClick="javascript:doNext();">
<input class="button" id="btnBack" value="Back" onClick="javascript:goBack();">

<script>
	var step = 1;
	var rows;
	var headerCols;
	var mapping = [];
	var fieldSetId = 'fieldsToImport';
	var coachValueFromSelect = '';
	var cohortValue;

	$(document).ready(function() {
		$('#btnBack').hide();

	});

	function doNext(){
		switch(step){
			case 2:
				confirmImport();
				break;
			case 3:
				doImport();
				break;
			case 4:
				newImport();
				break;
		}
	}
	function goBack(){
		switch(step){
			case 2:
				$('#btnBack').hide();
				step = 1;
				$('#step2').css("display", "none");
				$('#step1').css("display", "block");
				break;
			case 3:
				$('#btnNext').val("Next");
				step = 2;
				$('#step3').css("display", "none");
				$('#step2').css("display", "block");
				break;
			case 4:
				step = 3;
				$('#step4').css("display", "none");
				$('#step3').css("display", "block");
				break;
		}
	}

	function doPaste(){
		//do this within a short timeout, or else does not capture full paste
		setTimeout(function () {
			var data = $('#import_paste').val();
			var pastedRows = data.split("\n");
			rows = [];
			var pasteHeader = pastedRows[0];
			headerCols = pasteHeader.split("\t");
			var parts = [];

			//clean up rows
			$.each(pastedRows, function(index, value){
				var cols = value.split("\t");

				//multirow columsn are breaking before end of line
				//need to piece the columns back together
				//can tell because there are not enough columns to the line
				if(cols.length < headerCols.length){
					if(parts.length == 0){
						parts = cols;
					}else{
						$.each(cols, function(i, v){
							if(i == 0){
								//append the two colums together
								parts[parts.length-1] = parts[parts.length-1]+ " " + v;
							}else{
								//just add the remaining columns to piece together the full row
								parts.push(v);
							}
						});
					}
					if(parts.length == headerCols.length){
						rows.push(parts);
						parts = [];
					}
				}else{
					rows.push(cols);
				}
			})

			var fieldList =$('<fieldset/>');
			fieldList.attr("id", fieldSetId);

			fields = [];
			fields.push({displayName:"Banner GNumber", id:"BannerGNumber"})
			fields.push({displayName:"Fund Source", id:"FundedBy"})
			fields.push({displayName:"Preferred Name", id:"PreferredName"})
			fields.push({displayName:"Gender", id:"Gender"})
			fields.push({displayName:"Living Situation", id:"livingSituationDescription"})
			fields.push({displayName:"Cell Phone", id:"CellPhone"})
			fields.push({displayName:"Alternate Phone", id:"Phone2"})
			fields.push({displayName:"Personal Email", id:"EmailPesonal"})
			fields.push({displayName:"Coach (can also be set in the first section)", id:"Coach"})

			$.each(fields, function(index, value){
				fieldList.append(getLabel(value.displayName, value.id));
				fieldList.append(getChoice(value.id));
			})

			$('#importMapping').html(fieldList);
			$('#step1').css('display', 'none');
			$('#step2').css('display', 'block');
			$('#btnBack').show();
			step = 2;
			$("html, body").animate({ scrollTop: 0 }, "slow");

		}, 1); //end timeout - to capture paste when completed
	}


	function confirmImport(){
		//build mapping
		mapping = [];
		var missingGNumberMapping = true;
		var missingCoach = true;
		var missingCohort = true;

		//set overall values
		var coachSelect = $('#coachImportSelect');
		if(coachSelect.val() != ""){
			missingCoach = false;
			coachValueFromSelect = coachSelect.val();
		}
		var cohortInput = $('#cohortImport');
		if(cohortInput.val() != ""){
			missingCohort = false;
			cohortValue = cohortInput.val();
		}

		//iterate through remaining columns
		$('#' + fieldSetId + ' select').each(function() {
			//overall coach select takes precedence, so skip if previously set
			if(this.id == "Coach" && !missingCoach){
				return true;
			}else{
				var item = {field:this.id, fieldDisplayName:$('#lbl' + this.id).text(), skip: $(this).val() == "", matchedColName:$(this).val()};
			}
			mapping.push(item);

			if(this.id == "BannerGNumber" && $(this).val() != ""){
				missingGNumberMapping = false;
			}
			if(this.id == "Coach" && $(this).val() != ""){
				missingCoach = false;
			}
			if(this.id == "Cohort" && $(this).val() != ""){
				missingCohort = false;
			}
		});


		//validate mapping
		if(missingGNumberMapping || missingCoach || missingCohort){
			$( "#errorDialog" ).css("display","none");
			$( "#errorDialog" ).html("One column must map to the GNumber. Coach must be selected in first drop down or pasted information and cohort must be populated.");
			var d = $( "#errorDialog" ).dialog({
			  title: "Missing Information",
			  modal: true,
			  autoOpen: false,
			  width: 350,
			  height:250,
			  position:{my:'center center', at:'center center', of: window, collision: "none"},
			  buttons: {
			      "OK": function() {
			        	$( this ).dialog( "close" );
			      }
			   }
			});
			d.dialog("open");

		//if validated, display results
		}else{
			var confirmTable = $('<table />');
			if(coachValueFromSelect != ''){
				confirmTable.append('<tr><td>Coach</td><td>' + coachValueFromSelect + '</td></tr>');
			}
			confirmTable.append('<tr><td>Cohort</td><td>' + cohortValue + '</td></tr>');
			$.each(mapping, function(index, value){
				var rowSkip =  $('<tr />');
				var rowAppend =  $('<tr />');
				if(value.skip){
					rowSkip.append('<td>'+value.fieldDisplayName + '</td><td>SKIP</td>');
				}else{
					rowAppend.append('<td>'+value.fieldDisplayName + '</td><td>' + value.matchedColName + '</td>');
				}
				confirmTable.append(rowSkip);
				confirmTable.append(rowAppend);
			});
			$('#confirm').html(confirmTable);
			$('#step2').css("display", "none");
			$('#step3').css("display", "block");
			$('#btnNext').val("Do Import");
			step = 3;
		}
	}

	function doImport(){
		var result = [];
		var requests = [];
		var columns;
		$("body").css("cursor", "progress");

		$.each(rows, function(rowIndex, row){
			//first row is header
			if(rowIndex == 0){
				return true;
			}

			var applicant = {};
			applicant["method"] = "importApplicant";
			if(coachValueFromSelect != ''){
				applicant["coach"] = coachValueFromSelect;
			}
			applicant["cohort"] = cohortValue;

			$.each(mapping, function(mapIndex, mapValue){
				//skip coach if getting it from global select box
				if(coachValueFromSelect != '' && mapValue.id == "Coach"){
					return true;
				}
				if(!mapValue.skip){
					applicant[mapValue.field] = row[getColumnIndex(mapValue.matchedColName)];
				}

			})


			var r = $.ajax({
				method:"post",
				url:"fc.cfc",
				data:applicant,
				dataType: "json",
				success:function(data){
					columns = data.COLUMNS;
					result.push(data.DATA);
				},
	            error: function (xhr, textStatus, thrownError) {
					 handleAjaxError(xhr, textStatus, thrownError);
				}
			});
			requests.push(r);
		})

		//call when all the above requests have completed
		//apply turns the requests array into the list format required by $.when
		$.when.apply($, requests).done(function(resp) {
			var t = $("<table/>")
			var th = $("<thead/>");
			var r = $("<tr/>");
			$.each(columns, function(index, value){
				r.append('<th>' + value + '</th>')
			})
			th.append(r);
			t.append(th);

			var tb = $("<tbody/>");
			$.each(result, function(resultIndex, resultValue){
				r = $("<tr/>");
				var data = resultValue[0];
				$.each(data, function(colIndex, colValue){
					r.append('<td>' + (colValue == null ? "" : colValue) + '</td>')
				})
				tb.append(r);
			})
			t.append(tb);
			t.attr("id", "resultTable");
			$('#results').html(t);
			$('#resultTable').DataTable();
			$('#step3').css("display", "none");
			$('#step4').css("display", "block");
			$('#btnNext').val("New Import");
			$('#btnBack').hide();
			step = 4;
			$("body").css("cursor", "default");
		});
	}

	function newImport(){
		step = 1;
		$('#step4').css("display", "none");
		$('#import_paste').val('');
		$('#step1').css("display", "block");
		$('#btnBack').hide();
		$('#btnNext').val('Next');
	}

	function getLabel(displayName, id){
		var lbl = $('<label />');
		lbl.attr("for", displayName)
		lbl.append(displayName);
		lbl.attr("id", "lbl" + id);
		return lbl;
	}
	function getChoice(id){
		//need to maintain the original order to peruse the row indexes properly
		var matchedCol = getMappingSelected(id);
		var sortedCols = headerCols.concat().sort();
		var ddChoice = $('<select />');
		var opt = $('<option value="" selected>--- Skip ---</option>');
		ddChoice.append(opt);
		for(var i in sortedCols){
			opt = $('<option value="' + sortedCols[i] + '">' + sortedCols[i] + '</option>');
			ddChoice.append(opt);
		}
		ddChoice.attr("id", id);
		if(matchedCol != ""){
			ddChoice.val(matchedCol);
		}
		return ddChoice;
	}
	function getMappingSelected(id){
		var rtn = '';
		$.each(mapping, function(index, value){
			if(value.field == id){
				rtn = value.matchedColName;
				return false;
			}
		})
		return rtn;
	}
	function getColumnIndex(columnName){
		var rtnIndex;
		$.each(headerCols, function(index, value){
			if(value == columnName){
				rtnIndex = index;
				return false;
			}
		})
		return rtnIndex;
	}




</script>

