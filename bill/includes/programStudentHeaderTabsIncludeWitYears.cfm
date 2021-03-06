<cfinvoke component="pcclinks.bill.ProgramBilling" method="getAllStudentInfoByBillingStudentId"  returnvariable="qryBillingStudentEntries">
	<cfinvokeargument name="billingStudentId" value="#url.billingStudentId#">
</cfinvoke>
<cfset Session.qryBillingStudentEntries = qryBillingStudentEntries>

<!--- assuming sorted by billingDate desc --->
<cfquery dbtype="query" name="qryStudent">
	select *
	from qryBillingStudentEntries
	where billingStudentId = <cfqueryparam value=#qryBillingStudentEntries.billingStudentId#>
</cfquery>




<cfquery dbtype="query" name="qryCurrentProgramYear">
	select max(ProgramYear) currentProgramYear
	from qryBillingStudentEntries
</cfquery>

<cfquery dbtype="query" name="qryStudentCurrentYear">
	select *
	from qryBillingStudentEntries
	where programYear = '#qryCurrentProgramYear.currentProgramYear#'
	order by billingStartDate desc
</cfquery>

<cfset Session.mostRecentTermBillingStudentId = qryStudent.billingStudentId>
<cfset Session.qryStudent = qryStudent>
<cfset Session.qryStudentCurrentYear = qryStudentCurrentYear>

<cfquery dbtype="query" name="qryOtherProgramYears">
	select ProgramYear
	from qryBillingStudentEntries
	where ProgramYear != '#qryCurrentProgramYear.currentProgramYear#'
	group by ProgramYear
</cfquery>

<!--- Start of UI --->



<!-- Years Header  Tabs -->
<ul class="tabs" data-tabs id="programyear-tabs">
	<!-- Current Year -->
	<li class="tabs-title is-active">
		<cfoutput>
		<a href="###Replace(qryCurrentProgramYear.currentProgramYear,'/','')#" aria-selected="true">
			#qryCurrentProgramYear.currentProgramYear#
		</a>
		</cfoutput>
	</li>
	<!-- older years -->
	<cfloop query="qryOtherProgramYears">
	<li class="tabs-title">
		<cfoutput>
		<a href="###Replace(ProgramYear,'/','')#" aria-selected="true">
			#ProgramYear#
		</a>
		</cfoutput>
	</li>
	</cfloop>
</ul>


<cfoutput>
<!-- start year tab-content container -->
<div class="tabs-content" data-tabs-content="programyear-tabs" id="content-tabs" >

	<!-- current year/term panel -->
	<div class= "tabs-panel is-active" id="<cfoutput>#Replace(qryCurrentProgramYear.currentProgramYear,'/','')#</cfoutput>" style="padding-bottom:0px; margin-bottom: 2px">

		<!-- Term/Month Header Tabs -->
		<ul class="tabs" data-tabs id="term-header-tabs" >
		<cfset currentKey = qryStudent.billingStudentId & "H" >
		<!--- Active tab based on url billingStudentId date --->
			<li class="tabs-title is-active">
				<a href="###currentKey#" aria-selected="true">
					#DateFormat(qryStudent.billingStartDate,'m-d-yy')#<br><span style="color:gray">#qryStudent.Term#</span>
				</a>
			</li>

		<!--- Remaining tabs --->
		<cfquery dbtype="query" name="qryOtherBilling">
			select *
			from qryStudentCurrentYear
			where billingStudentId <> <cfqueryparam value=#qryStudent.billingStudentId# >
			order by billingStartDate desc
		</cfquery>

		<cfloop query="qryOtherBilling" >
			<li class="tabs-title">
				<a href="###billingStudentId#H">
					#DateFormat(billingStartDate,'m-d-yy')#<br><span style="color:gray">#Term#</span>
				</a>
			</li>
		</cfloop>
		</ul> <!-- end of Header Tabs -->

		<!-- start term tab-content container -->
		<div class="tabs-content" data-tabs-content="term-header-tabs" id="content-tabs" >
			<!-- current term container -->
			<div class= "tabs-panel is-active" id="<cfoutput>#currentKey#</cfoutput>" style="padding-bottom:0px; margin-bottom: 2px">
				<cfmodule template="programStudentHeaderInclude.cfm"
					qryBillingStudentEntries = #qryBillingStudentEntries#
					billingStudentId = #qryStudent.billingStudentId#>
			</div>

			<!-- Previous Term Content Container -->
			<cfloop query="qryOtherBilling">
			<div class= "tabs-panel" id="#billingStudentId#H">
				<cfmodule template="programStudentHeaderInclude.cfm"
					qryBillingStudentEntries = #qryBillingStudentEntries#
					billingStudentId = #qryOtherBilling.billingStudentId#>
			</div> <!-- end tab content -->
			</cfloop>

		</div> <!-- end term tab content -->
	</div> <!-- end  current year panel -->

	<!-- older  year panel -->
	<cfloop query="qryOtherProgramYears">
		<div class= "tabs-panel" id="<cfoutput>#Replace(ProgramYear,'/','')#</cfoutput>" style="padding-bottom:0px; margin-bottom: 2px">

			<!--- Term/Month tabs --->
			<cfquery dbtype="query" name="qryOtherBilling">
				select *
				from qryBillingStudentEntries
				where billingStudentId <> <cfqueryparam value=#qryStudent.billingStudentId# >
				and programYear = '#ProgramYear#'
				order by billingStartDate desc
			</cfquery>

			<!-- Term/Month older year Header Tabs -->
			<ul class="tabs" data-tabs id="term-header-tabs" >
			<cfloop query="qryOtherBilling" >
				<li class="tabs-title">
					<a href="###billingStudentId#H">
						#DateFormat(billingStartDate,'m-d-yy')#<br><span style="color:gray">#Term#</span>
					</a>
				</li>
			</cfloop>
			</ul><!-- end term/month older year header tabs -->

			<!-- start tab-content container -->
			<div class="tabs-content" data-tabs-content="term-header-tabs" id="content-tabs" >
				<!-- Previous Term Content Container -->
				<cfloop query="qryOtherBilling">
				<div class= "tabs-panel" id="#billingStudentId#H" style="padding-bottom:0px; margin-bottom: 2px">
					<cfmodule template="programStudentHeaderInclude.cfm"
						qryBillingStudentEntries = #qryBillingStudentEntries#
						billingStudentId = #qryOtherBilling.billingStudentId#>
				</div> <!-- end tab content -->
				</cfloop>
			</div> <!-- end total tab content -->
	</div> <!-- end older year panel -->
	</cfloop> <!--- looping older years --->
</div> <!-- end  year content container -->
</cfoutput>


<script>
function programStudentHeaderInit(){
	$('body').on("saveAction", function(e){
		programStudentHeaderSaveEventHandler(e);
	})
}
function programStudentHeaderSaveEventHandler(e){
	if(e.caller != "programStudentHeaderTabsInclude"){
		var billingStudentId = e.billingStudentId;
		switch(e.field){
			case 'exitDate':
				$('#exitDateH'+billingStudentId).val(e.value);
				break;
			case 'Program':
				$('#programH'+billingStudentId).val(e.value);
				break;
			case 'billingStatus':
				$('#billingStatusH'+billingStudentId).html(e.value);
				break;
			case "includeFlag":
				var v = e.value;
				if(e.value === "on")
					v = true;
				if(e.value === "off")
					v = false;

				$('#includeFlagH'+billingStudentId).prop("checked", v);
				break;
		}
	}
}



// save program dropdown changes
function updateStudentHeaderProgram(id, billingStudentId){
	var program = $('#'+id).val();
	$.ajax({
		url: "programbilling.cfc?method=updatestudentbillingprogram",
		type: "POST",
		async: false,
		data: { billingstudentid: billingStudentId, program: program },
		error: function (jqXHR, exception) {
	        handleAjaxError(jqXHR, exception);
		},
		success:function(){
			callSaveActionEvent(billingStudentId, "program", program, "programStudentHeaderTabsInclude");
		}
	});
} //end save checkbox changes

// save exit date changes
 function updateStudentHeaderExitDate(id, billingStudentId){
	var exitDate = $('#'+id).val();
	$.ajax({
		url: "programbilling.cfc?method=updatestudentbillingexitdate",
		type: "POST",
		async: false,
		data: { billingstudentid: billingStudentId, exitDate: exitDate },
		error: function (jqXHR, exception) {
	        handleAjaxError(jqXHR, exception);
		},
		success: function(){
			callSaveActionEvent(billingStudentId, "exitDate", exitDate, "programStudentHeaderTabsInclude");
		}
	});
} //end save checkbox changes

function updateStudentHeaderReviewWithCoachFlag(id, billingStudentId){
	var reviewWithCoachFlag = $('#'+id)[0].checked ? 1 : 0;
	$.ajax({
		url: "programbilling.cfc?method=updateStudentReviewWithCoachFlag",
		type: "POST",
		async: false,
		data: { billingStudentId: billingStudentId, reviewWithCoachFlag:reviewWithCoachFlag },
		error: function (jqXHR, exception) {
	        handleAjaxError(jqXHR, exception);
		},
		success: function(){
			callSaveActionEvent(billingStudentId, "reviewWithCoachFlag", reviewWithCoachFlag, "programStudentHeaderTabsInclude");
		}
	});
} //end save checkbox changes


// save include in billing checkbox changes
function updateStudentHeaderIncludeFlag(id, billingStudentId){
	var includeFlag = $('#'+id)[0].checked ? 1 : 0;
	$.ajax({
		url: "programbilling.cfc?method=updateStudentIncludeFlag",
		type: "POST",
		async: false,
		data: { billingStudentId: billingStudentId, includeFlag:includeFlag },
		error: function (jqXHR, exception) {
	        handleAjaxError(jqXHR, exception);
		},
		success: function(){
			callSaveActionEvent(billingStudentId, "includeFlag", includeFlag, "programStudentHeaderTabsInclude");
		}
	});
} //end save checkbox changes



// save include in billing checkbox changes
 function updateStudentHeaderSaveReviewNotes(id, billingStudentId){
	var notes = $('#' + id).val();
	$.ajax({
		url: "programbilling.cfc?method=updateStudentReviewNotes",
		type: "POST",
		async: false,
		data: { billingStudentId: billingStudentId, reviewNotes:notes },
		error: function (jqXHR, exception) {
	        handleAjaxError(jqXHR, exception);
		}
	});
}





</script>
