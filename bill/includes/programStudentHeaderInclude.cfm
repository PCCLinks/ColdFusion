
<cfparam name="qryBillingStudentEntries" default="#attributes.qryBillingStudentEntries#">
<cfparam name="billingStudentId" default="#attributes.billingStudentId#">
<cfquery dbtype="query" name="qryStudent">
	select *
	from qryBillingStudentEntries
	where billingStudentId = #attributes.billingStudentId#
</cfquery>
<cfinvoke component="pcclinks.bill.LookUp" method="getPrograms" returnvariable="programs"></cfinvoke>
<cfset readonly=false>
<cfif #qryStudent.BillingStatus# EQ 'BILLED'>
	<cfset readonly=true>
</cfif>
<cfset local.sidnyExitDateAlert = false>
<cfif LEN(qryStudent.SIDNYExitDate) GT 0 AND qryStudent.SIDNYExitDate LT qryStudent.BillingStartDate>
	<cfset local.sidnyExitDateAlert = true>
</cfif>
<cfset noBannerAttr = false>
<cfif #qryStudent.BillingStatus# EQ "MISSING BANNER ATTRIBUTE">
	<cfset noBannerAttr = true>
</cfif>

<cfoutput query="qryStudent">
	<!-- begin header data for billingStudentId #attributes.billingStudentId# -->
	<div class="callout
				<cfif local.sidnyExitDateAlert OR includeFlag EQ 0> alert
				<cfelse><cfif billingStatus EQ 'BILLED'>secondary
						<cfelse> primary</cfif>
				</cfif>
		"> <!--- end callout div --->
		<div class="row">
			<div class="small-1 columns"><b>G</b></div>
			<div class="small-2 columns"><b>Name</b></div>
			<div class="small-2 columns"><b>Program</b></div>
			<div class="small-1 columns"><b>Billing Exit Date </b></div>
			<div class="small-1 columns"><b>Current Exit Date</b></div>
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
				<select name="programH#attributes.billingStudentId#" id="programH#attributes.billingStudentId#"
						onchange="javascript:updateStudentHeaderProgram('programH#attributes.billingStudentId#', #attributes.billingStudentId#);">
					<cfloop query="programs">
						<option value="#programName#" <cfif #qryStudent.program# EQ #programName#> selected </cfif> > #programName# </option>
					</cfloop>
				</select>
				</cfif>
			</div>
			<div class="small-1 columns">
				<cfif readonly>
					<cfif LEN(#EXITDATE#) EQ 0>None<cfelse>#DateFormat(EXITDATE,"m/d/yy")#</cfif>
				<cfelse><input id="exitDateH#attributes.billingStudentId#" name="exitDateH#attributes.billingStudentId#" value="#DateFormat(EXITDATE,"m/d/yy")#"
							style="width:75px;" type="text" class="fdatepicker" onChange="javascript:updateStudentHeaderExitDate('exitDateH#attributes.billingStudentId#', #attributes.billingStudentId#);">
				</cfif>
			</div>
			<div class="small-1 columns"><cfif LEN(#SIDNYExitDate#) EQ 0>None<cfelse>#DateFormat(SIDNYExitDate,"m/d/yy")#</cfif></div>
			<div class="small-1 columns">#term#<br/>#DateFormat(billingStartDate,'m/d/yy')#</div>
			<div class="small-1 columns">#schooldistrict#</div>
			<div class="small-1 columns" id="billingStatusH#attributes.billingStudentId#"><cfif noBannerAttr><span style="color:red"></cfif>#billingstatus#<cfif noBannerAttr></span></cfif></div>
			<div class="small-1 columns">
				<cfif NOT readonly>
					<input type="checkbox" id="reviewWithCoachFlagH#attributes.billingStudentId#" <cfif #reviewWithCoachFlag# EQ 1>checked</cfif>
							onclick="javascript:updateStudentHeaderReviewWithCoachFlag('reviewWithCoachFlagH#attributes.billingStudentId#', #attributes.billingStudentId#);" >
				</cfif>
			</div>
			<div class="small-1 columns">
				<cfif readonly>
					<cfif includeFlag EQ 1>TRUE<cfelse>FALSE</cfif>
				<cfelse>
					<input type="checkbox" id="includeFlagH#attributes.billingStudentId#" <cfif #includeFlag# EQ 1>checked</cfif>
							onclick="javascript:updateStudentHeaderIncludeFlag('includeFlagH#attributes.billingStudentId#', #attributes.billingStudentId#);" >
				</cfif>
			</div>
		</div>
		<div class="row">
			<div class="small-1 columns">Review Notes:</div>
			<div class="small-11 columns">
				<textarea rows="2"  wrap="true" maxlength="1000" id="reviewNotesH#attributes.billingStudentId#"
					onchange="javascript:updateStudentHeaderSaveReviewNotes('reviewNotesH#attributes.billingStudentId#', #attributes.billingStudentId#);"
					onkeyup="javascript:updateStudentHeaderSaveReviewNotes('reviewNotesH#attributes.billingStudentId#', #attributes.billingStudentId#);"
					onpaste="javascript:updateStudentHeaderSaveReviewNotes('reviewNotesH#attributes.billingStudentId#', #attributes.billingStudentId#);">#reviewNotes#</textarea>
			</div>
		</div>
		<div class="row">
			<div class="small-12 columns" style="color:red">
				<cfif noBannerAttr>Add Banner Attribute for this student and re-run Set Up Billing</cfif>
				<cfif local.sidnyExitDateAlert>SIDNY data indicates student has exited before term start. </cfif>
				<cfif includeFlag EQ 0>Student NOT included in billing for this period.</cfif>
			</div>
		</div>
	</div> <!-- end header data for #attributes.billingStudentId# -->
</cfoutput>



