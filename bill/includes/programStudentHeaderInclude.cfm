<cfparam name="qryBillingStudentEntries" default="#attributes.qryBillingStudentEntries#">
<cfparam name="billingStudentId" default="#attributes.billingStudentId#">
<cfquery dbtype="query" name="qryStudent">
	select *
	from qryBillingStudentEntries
	where billingStudentId = #attributes.billingStudentId#
</cfquery>
<cfinvoke component="LookUp" method="getPrograms" returnvariable="programs"></cfinvoke>
<cfset readonly=false>
<cfif #qryStudent.BillingStatus# EQ 'BILLED'>
	<cfset readonly=true>
</cfif>

<cfoutput query="qryStudent">
	<div class=<cfif readonly EQ 'BILLED'>"callout alert"<cfelse>"callout primary"</cfif> >
		<div class="row">
			<div class="small-1 columns"><b>G</b></div>
			<div class="small-2 columns"><b>Name</b></div>
			<div class="small-2 columns"><b>Program</b></div>
			<div class="small-1 columns"><b>Enrolled Date</b></div>
			<div class="small-1 columns"><b>Exit Date </b></div>
			<div class="small-1 columns"><b>Term</b></div>
			<div class="small-1 columns"><b>School</b></div>
			<div class="small-1 columns"><b>Status</b></div>
			<div class="small-1 columns"><b>Review with Coach</b></div>
			<div class="small-1 columns"><b>Include in Billing</b></div>
		</div>
		<div class="row">
			<div class="small-1 columns">#bannerGNumber#</div>
			<div class="small-2 columns">#FIRSTNAME# #LASTNAME#</div>
			<div class="small-2 columns">
				<cfif readonly>
					#program#
				<cfelse>
				<select name="program#attributes.billingStudentId#" id="program#attributes.billingStudentId#">
					<cfloop query="programs">
						<option value="#programName#" <cfif #qryStudent.program# EQ #programName#> selected </cfif> > #programName# </option>
					</cfloop>
				</select>
				</cfif>
			</div>
			<div class="small-1 columns">#DateFormat(ENROLLEDDATE,"m/d/yy")#</div>
			<div class="small-1 columns">
				<cfif readonly>
					<cfif LEN(#EXITDATE#) EQ 0>None<cfelse>#DateFormat(EXITDATE,"m/d/yy")#</cfif>
				<cfelse><input id="exitDate#attributes.billingStudentId#" name="exitDate#attributes.billingStudentId#" value="#DateFormat(EXITDATE,"m/d/yy")#" style="width:75px;" type="text" class="fdatepicker">
				</cfif>
			</div>
			<div class="small-1 columns">#term#<br/>#DateFormat(billingStartDate,'m/d/yy')#</div>
			<div class="small-1 columns">#schooldistrict#</div>
			<div class="small-1 columns">#billingstatus#</div>
			<div class="small-1 columns">
				<cfif NOT readonly>
					<input type="checkbox" id="reviewWithCoachFlag#attributes.billingStudentId#" <cfif #reviewWithCoachFlag# EQ 1>checked</cfif>>
				</cfif>
			</div>
			<div class="small-1 columns">
				<cfif readonly>
					<cfif includeFlag EQ 1>TRUE<cfelse>FALSE</cfif>
				<cfelse>
					<input type="checkbox" id="includeFlag#attributes.billingStudentId#" <cfif #includeFlag# EQ 1>checked</cfif>>
				</cfif>
			</div>
		</div>
		<div class="row">
			<div class="small-1 columns">Review Notes:</div>
			<div class="small-11 columns">
				<textarea rows="2"  wrap="true" maxlength="1000" id="reviewNotes#attributes.billingStudentId#" >#reviewNotes#</textarea>
			</div>
		</div>
		<div class="row">
			<div class="small-12 columns" style="color:red">
				#ErrorMessage#
			</div>
		</div>
	</div> <!-- end header data -->
</cfoutput>


<script type="text/javascript">
	var saveInterval<cfoutput>#attributes.billingStudentId#</cfoutput> = 1000*60*5;
   	var doSave = setInterval(saveReviewNotes<cfoutput>#attributes.billingStudentId#</cfoutput>, saveInterval<cfoutput>#attributes.billingStudentId#</cfoutput>);
	//save before leaving
   	$(window).bind('beforeunload', function(){
  		saveReviewNotes<cfoutput>#attributes.billingStudentId#</cfoutput>();
	});
//source page: programStudentHeaderInclude.cfm
$(document).ready(function() {
// save program dropdown changes
	   $('#program<cfoutput>#attributes.billingStudentId#</cfoutput>').change(function(){
			var program = $(this).val();
			$.ajax({
				url: "programbilling.cfc?method=updatestudentbillingprogram",
				type: "POST",
				async: false,
				data: { billingstudentid: <cfoutput>#attributes.billingStudentId#</cfoutput>, program: program },
				error: function (jqXHR, exception) {
			        handleAjaxError(jqXHR, exception);
				}
			});
		}); //end save checkbox changes

		// save exit date changes
	   $('#exitDate<cfoutput>#attributes.billingStudentId#</cfoutput>').change(function(){
			var exitDate = $(this).val();
			$.ajax({
				url: "programbilling.cfc?method=updatestudentbillingexitdate",
				type: "POST",
				async: false,
				data: { billingstudentid: <cfoutput>#attributes.billingStudentId#</cfoutput>, exitDate: exitDate },
				error: function (jqXHR, exception) {
			        handleAjaxError(jqXHR, exception);
				}
			});
		}); //end save checkbox changes

 		$('#reviewWithCoachFlag<cfoutput>#attributes.billingStudentId#</cfoutput>').click(function(){
			var reviewWithCoachFlag = $(this)[0].checked ? 1 : 0;
			$.ajax({
				url: "programbilling.cfc?method=updateStudentReviewWithCoachFlag",
				type: "POST",
				async: false,
				data: { billingStudentId: <cfoutput>#attributes.billingStudentId#</cfoutput>, reviewWithCoachFlag:reviewWithCoachFlag },
				error: function (jqXHR, exception) {
			        handleAjaxError(jqXHR, exception);
				}
			});
		}); //end save checkbox changes


		// save include in billing checkbox changes
	   	 $('#includeFlag<cfoutput>#attributes.billingStudentId#</cfoutput>').click(function(){
			var includeFlag = $(this)[0].checked ? 1 : 0;
			$.ajax({
				url: "programbilling.cfc?method=updateStudentIncludeFlag",
				type: "POST",
				async: false,
				data: { billingStudentId: <cfoutput>#attributes.billingStudentId#</cfoutput>, includeFlag:includeFlag },
				error: function (jqXHR, exception) {
			        handleAjaxError(jqXHR, exception);
				}
			});
		}); //end save checkbox changes

	});

	// save include in billing checkbox changes
   	function saveReviewNotes<cfoutput>#attributes.billingStudentId#</cfoutput>(){
		var notes = $('#reviewNotes<cfoutput>#attributes.billingStudentId#</cfoutput>').val();
		$.ajax({
			url: "programbilling.cfc?method=updateStudentReviewNotes",
			type: "POST",
			async: false,
			data: { billingStudentId: <cfoutput>#attributes.billingStudentId#</cfoutput>, reviewNotes:notes },
			error: function (jqXHR, exception) {
		        handleAjaxError(jqXHR, exception);
			}
		});
	}
</script>