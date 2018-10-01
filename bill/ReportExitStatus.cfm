<cfinclude template="includes/header.cfm">

<cfinvoke component="LookUp" method="getSchools" returnvariable="schools"></cfinvoke>
<cfinvoke component="LookUp" method="getAttendanceBillingStartDates" returnvariable="billingDates"></cfinvoke>
<cfinvoke component="LookUp" method="getFirstOpenAttendanceDateorLastClosed" returnvariable="latestMonth"></cfinvoke>

<div class="callout primary">Exit Status Report</div>
<!-- Filter -->
<div class="row">
	<div class="small-2 columns">
		<label for="billingStartDate">Month Start Date:
			<select name="billingStartDate" id="billingStartDate">
				<option disabled selected value="" > --Select Month Start Date-- </option>
			<cfoutput query="billingDates">
				<option value="#billingStartDate#" <cfif billingStartDate EQ latestMonth> selected </cfif>  > #DateFormat(billingStartDate,'mm-dd-yy')# </option>
			</cfoutput>
			</select>
		</label>
	</div>
	<div class="small-2 columns">
		<label for="District">District:
			<select name="district" id="district">
			<!--->	<option disabled selected value="" > --Select District-- </option>--->
			<cfoutput query="schools">
				<option value="#keySchoolDistrictID#" > #schooldistrict# </option>
			</cfoutput>
			</select>
		</label>
	</div>
	<div class="small-10 columns"></div>
</div> <!-- end Filter row -->
<table id="dt_table">
	<thead>
		<tr>
			<th>Last Name</th>
			<th>First Name</th>
			<th>Gender</th>
			<th>Ethnicity</th>
			<th>DOB</th>
			<th>Grade</th>
			<th>Entry Date</th>
			<th>Exit Date</th>
			<th>Exit Status</th>
		</tr>
	</thead>
</table>



<cfsavecontent variable="pcc_scripts">
	<script>

		$(document).ready(function() {
		    $('#dt_table').DataTable({
		    	processing:true,
				ajax:{
					url: 'report.cfc?method=exitStatusReport',
					data: getParameters,
					dataSrc:'DATA',
					error: function (xhr, textStatus, thrownError) {
					        handleAjaxError(xhr, textStatus, thrownError);
					}
				},
				dom: '<"top"iB>rt<"bottom"flp>',
				language:{ processing: "Loading data..."},
				buttons:[
					{text: "export",
            	  		action: function( e, table, node, config ){
							window.open('includes/reportExitStatusInclude.cfm');
            	  		}
            	  	}
            	  ]
		    });

			//hide main filter
			$(".dataTables_filter").hide();

			table = $('#dt_table').DataTable();
			$('#billingStartDate').change(function(){
				table.ajax.reload();
			});
			$('#district').change(function(){
				table.ajax.reload();
				setColumnVisibility();
			});

			setColumnVisibility();
		});

		function setColumnVisibility(){
			if($('#district').val() == 4){
				table.column(2).visible(true);
				table.column(3).visible(true);
			}else{
				table.column(2).visible(false);
				table.column(3).visible(false);
			}
		}

		function getParameters(){
			param = '';
			if($('#district').val() != null)
				param = param + '&districtid=' + $('#district').val();
			if($('#program').val() != null)
				param = param + '&program=' + $('#program').val();
			param = param + '&billingStartDate=' + $('#billingStartDate').val();
		 	return param;
		}


	</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm">