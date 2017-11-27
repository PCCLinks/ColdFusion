<cfinclude template="includes/header.cfm" />

<cfinvoke component="LookUp" method="getTerms" returnvariable="qryTerms"></cfinvoke>

<div class="callout primary">

<!--- query parameters --->
<form id="pageForm" action="attendanceGrid.cfm" method="post">
	<div class="row">
		<div class="small-4 columns">
			<label>Term:<br/>
				<select name="term" id="term"/>
					<option disabled selected value="" >
						--Select Term--
					</option>
					<cfoutput query="qryTerms">
					<option  value="#term#" >#termDescription#</option>
					</cfoutput>
				</select>
			</label>
		</div>
		<div class="small-2 columns">
			<label>CRN<br><input name="crn" ></label>
		</div>
		<div class="small-2 columns">
			<label>Month Start Date<br><input name="billingStartDate" id="billingStartDate" >
		</div>
		<div class="small-2 columns">
			<label><br/><input class="button" type="submit" name="submit" value="Get Attendance Rows" /></label>
		</div>
	</div>
</form>
<!--- end query parameters --->
</div> <!-- end div callout primary -->

<cfsavecontent variable="pcc_scripts">
<script type="text/javascript">
$('#billingStartDate').datepicker({ dateFormat: 'mm/dd/yy' });
</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm" />
