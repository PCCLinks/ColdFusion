<cfcomponent displayname="programStudentGetDetail">

	<cfobject name="appObj" component="application">


	<cffunction name="getUI" returnType="string" access="remote" returnformat="plain">
		<cfargument name="billingStudentIdInput" required="true">
		<cfinvoke component="ProgramBilling" method="getBillingStudentForYear"  returnvariable="qryBillingStudentEntries">
			<cfinvokeargument name="billingStudentId" value="#arguments.billingStudentIdInput#">
		</cfinvoke>

		<!--- assuming sorted by billingDate desc --->
		<cfquery dbtype="query" name="qryStudent">
			select *
			from qryBillingStudentEntries
			where billingStudentId = <cfqueryparam value=#qryBillingStudentEntries.billingStudentId#>
		</cfquery>

		<cfsavecontent variable="html">
			<!--- Next and Previous Buttons --->
			<div class="row">
				<div class="large-4 columns">
					<input id="prevStudent" name="prevStudent" type="button" class="button small" value="<< Prev Student in List <<">
				</div>
				<div class="large-2 columns">
					<input id="nextStudent" name="nextStudent" type="button" class="button small" value=">> Next Student in List >>" onclick="javascript:nextStudent();">
				</div>
			</div>

			<!-- Header Tabs -->
			<ul class="tabs" data-tabs id="header-tabs" >
				<cfset selectedBillingStudentId = qryStudent.billingStudentId >
				<cfset currentKey = selectedBillingStudentId & "H" >

				<!--- Active tab based on url billingStudentId date --->
				<cfoutput>
					<li class="tabs-title is-active">
						<a href="###currentKey#" aria-selected="true">
							#DateFormat(qryStudent.billingStartDate,'m-d-yy')#<br><span style="color:gray">#qryStudent.Term#</span>
						</a>
					</li>
				</cfoutput>

				<!--- Remaining tabs --->
				<cfquery dbtype="query" name="qryOtherBilling">
					select *
					from qryBillingStudentEntries
					where billingStudentId <> <cfqueryparam value=#qryStudent.billingStudentId# >
					order by billingStartDate desc
				</cfquery>

				<cfoutput query="qryOtherBilling" >
					<li class="tabs-title">
						<a href="###billingStudentId#H">
							#DateFormat(billingStartDate,'m-d-yy')#<br><span style="color:gray">#Term#</span>
						</a>
					</li>
				</cfoutput>
			</ul>

			<!-- start tab-content container -->
			<div class="tabs-content" data-tabs-content="header-tabs" style="margin-bottom:25px">
				<!-- current term container -->
				<div class= "tabs-panel is-active" id="<cfoutput>#currentKey#</cfoutput>">
					<cfmodule template="includes/programStudentHeaderInclude.cfm"
						qryBillingStudentEntries = #qryBillingStudentEntries#
						billingStudentId = #qryStudent.billingStudentId#>
				</div>


				<!-- Previous Term Content Container -->
				<cfoutput query="qryOtherBilling">
				<div class= "tabs-panel" id="#billingStudentId#H">
					<cfmodule template="includes/programStudentHeaderInclude.cfm"
						qryBillingStudentEntries = #qryBillingStudentEntries#
						billingStudentId = #qryOtherBilling.billingStudentId#>
				</div> <!-- end tab content -->
				</cfoutput>

			</div> <!-- end total tab content -->


			<!-- Class vs Billing Header Tabs -->
			<ul class="tabs" data-tabs id="billingclassheader-tabs" data-deep-link="true">
				<li class="tabs-title is-active">
					<a href="#Classes" aria-selected="true">CLASSES</a>
				</li>
				<li class="tabs-title">
					<a href="#Billing">BILLING</a>
				</li>
			</ul>

			<!-- Class vs Billing Header Content Container -->
			<div class="tabs-content" data-tabs-content="billingclassheader-tabs" >
				<!-- class content container -->
				<div class= "tabs-panel is-active" id="Classes">
					<!-- begin class information -->
					<div class="row">
						<!-- lefthand column -->
						<div class="small-6 columns">
							<!-- Billed Classes  -->
							<div class="row" style="margin-bottom:50px">
								<cfmodule template="includes/billedClassesInclude.cfm" billingStudentId="#arguments.billingStudentIdInput#">
							</div> <!-- end billed classes -->
						</div> <!-- end column -->

						<!-- blank column -->
						<div class="small-1 columns"></div>

						<!-- righthand column -->
						<div class="small-5 columns">
						<!-- past classes -->
						<div class="row">
							<cfmodule template="includes/pastClassesInclude.cfm" pidm="#qryStudent.pidm#" term="#qryStudent.Term#" contactId="#qryStudent.contactId#">
						</div>
						</div> <!-- end past classes -->

					</div> <!-- end class information -->
				</div> <!-- end class content container -->

				<!-- billing content container -->
				<div class= "tabs-panel" id="Billing">
					<!-- Billing Adjustments -->
					<cfmodule template="includes/billingStudentTabInclude.cfm"
						data = "#qryBillingStudentEntries#"
						selectedBillingStudentId = "#selectedBillingStudentId#">
				</div> <!-- end billing content container -->
			</div> <!-- End Class vs Billing Header Content Container -->
		</cfsavecontent>
		<cfreturn html>
	</cffunction>
	
	
	<cffunction name="getProgramStudentHeader">
		<cfargument name="qryBillingStudentEntries" >
		<cfargument name="billingStudentId" >
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
		<cfset local.sidnyExitDateAlert = false>
		<cfif LEN(qryStudent.SIDNYExitDate) GT 0 AND qryStudent.SIDNYExitDate LT qryStudent.BillingStartDate>
			<cfset local.sidnyExitDateAlert = true>
		</cfif>
		
		
		<cfoutput query="qryStudent">
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
					<div class="small-1 columns" id="billingStatusH#attributes.billingStudentId#">#billingstatus#</div>
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
						#ErrorMessage#<cfif len(#ErrorMessage#) GT 0>.<br></cfif>
						<cfif local.sidnyExitDateAlert>SIDNY data indicates student has exited before term start. </cfif>
						<cfif includeFlag EQ 0>Student NOT included in billing for this period.</cfif>
					</div>
				</div>
			</div> <!-- end header data -->
		</cfoutput>

	
	</cffunction>


</cfcomponent>