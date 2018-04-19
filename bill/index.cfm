<!--- header template --->
<cfinclude template="includes/header.cfm" />

<cfinvoke component="ProgramBilling" method="getCurrentTermSummary"  returnvariable="qryData">
</cfinvoke>
<cfset Session.Term = qryData.Term>
<cflock timeout=20 scope="Session" type="Exclusive">
	<cfset StructDelete(Session, "Program")>
	<cfset StructDelete(Session, "SchoolDistrict")>
</cflock>

<cfparam name="type" default="attendance">
<cfif isDefined("url.type")>
	<cfset type = url.type>
</cfif>


<!-- Tabs -->
<ul class="tabs" data-tabs id="index-tabs">
	<li class="tabs-title
		<cfoutput><cfif type EQ "attendance">is-active</cfif></cfoutput>" onClick="javascript:setType('attendance')";>
		<a href="#attendanceTab" <cfoutput><cfif type EQ "attendance">aria-selected="true"</cfif></cfoutput>>Attendance Steps</a>
	</li>
	<li class="tabs-title
		<cfoutput><cfif type EQ "term">is-active</cfif></cfoutput>" onClick="javascript:setType('term')";>
		<a href="#termTab" <cfoutput><cfif type EQ "term">aria-selected="true"</cfif></cfoutput>>Term</a>
	</li>
</ul>


<!-- billing tab content -->
<div class="tabs-content" data-tabs-content="index-tabs">
	<!-- attendance content -->
  	<div class = "tabs-panel is-active" id="attendanceTab">
    	<cfmodule template="includes/indexAttendanceInclude.cfm" >
  	</div>
	<!-- term content -->
	<div class = "tabs-panel" id="termTab">
    	<cfmodule template="includes/indexTermInclude.cfm" >
  	</div>
</div>

<!--- scripts referenced in footer --->
<cfsavecontent variable="pcc_scripts">
<script>
	var type = <cfoutput>'#type#';</cfoutput>

	$(document).ready(function() {
		$('#dt_table').dataTable({
			paging:false,
			searching:false
		});
	});

	function setType(typeToSet){
		type = typeToSet
	}

	function saveValues(formName){
	 	var $form = $('#'+formName);
	    $.ajax({
	       	url:$form.attr('action'),
	       	type: 'POST',
	       	async: false,
	       	data: $form.serialize(),
	       	success: function (data, textStatus, jqXHR) {
	       		if(formName.substring(1,10) == 'frmCalculateBilling'){
					rePopulateBillingInfo();
					closeForm();
	       		}else{
	       			location = "index.cfm?type=" + type;
	       		}
	    	},
			error: function (jqXHR, exception) {
	      		handleAjaxError(jqXHR, exception);
			}
	    });
	}
	function showForm(idName){
		$('#'+idName).show();
	}
	function closeForm(idName){
		$('#'+idName).hide();
	}



</script>
</cfsavecontent>

<!--- footer template --->
<cfinclude template="includes/footer.cfm">