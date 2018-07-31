<cfinclude template="includes/header.cfm">

<cfinvoke component="LookUp" method="getSchools" returnvariable="schools"></cfinvoke>
<cfinvoke component="LookUp" method="getAttendanceBillingStartDates" returnvariable="billingDates"></cfinvoke>
<cfinvoke component="LookUp" method="getFirstOpenAttendanceDate" returnvariable="latestMonth"></cfinvoke>
<cfinvoke component="Lookup" method="getCurrentProgramYear" returnvariable="programyear"></cfinvoke>

<div class="callout primary"><b><p>ADM Report</p></b>
<div id="heading"></div>
</div>
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
			<cfoutput query="schools">
				<option value="#keySchoolDistrictID#" > #schooldistrict# </option>
			</cfoutput>
			</select>
		</label>
	</div>
	<div class="small-10 columns" ></div>
</div> <!-- end Filter row -->
<table id="dt_table">
	<thead>
		<tr>
			<th>Last Name</th>
			<th>First Name</th>
			<th>Entry Date</th>
			<th>Exit Date</th>
			<th>Large Grp.</th>
			<th>Inter. Grp.</th>
			<th>Small Grp.</th>
			<th>Tutorial</th>
			<th>Days Present</th>
			<th>Days Absent</th>
		</tr>
	</thead>
	<tbody>
	</tbody>
</table>



<cfsavecontent variable="pcc_scripts">
	<script>
		$.fn.dataTable.ext.errMode = 'throw';
		$(document).ready(function() {
		    $('#dt_table').DataTable({
		    	processing:true,
				ajax:{
					url: 'report.cfc?method=admReport',
					data: getParameters,
					dataSrc:function(json){
						return json.DATA;
						},
					error: function (xhr, textStatus, thrownError) {
					        handleAjaxError(xhr, textStatus, thrownError)
						},
				},
				dom: '<"top"iB>rt<"bottom"flp>',
				language:{ processing: "Loading data..."},
				buttons:[
					{text: "export",
            	  		action: function( e, table, node, config ){
							window.open('reportAdmExport.cfm');
            	  		}
            	  	}
            	  ],
            	columDefs:[{target:[10,11,12,13], visible:false}]
		    });

			//hide main filter
			$(".dataTables_filter").hide();

			table = $('#dt_table').DataTable();
			$('#billingStartDate').change(function(){
				table.ajax.reload();
				updateHeader();
			});
			$('#district').change(function(){
				table.ajax.reload();
				setColumnVisibility();
			});

			setColumnVisibility();
			updateHeader();

		} );

		function updateHeader(){
			$.get('Report.cfc?method=getLastBillingGeneratedMessage&includeTitle=false&billingType=attendance&programYear=<cfoutput>#programyear#</cfoutput>', function(data){
				$('#heading').html(data);
			});
		}
		function getParameters(){
			param = '&billingStartDate=' + $('#billingStartDate').val();
			if($('#district').val() != null)
				param = param + '&districtid=' + $('#district').val();
			if($('#program').val() != null)
				param = param + '&program=' + $('#program').val();
		 	return param;
		}

		function setColumnVisibility(){
			if($('#district').val() == 4){
				table.column(8).visible(true);
				table.column(9).visible(true);
			}else{
				table.column(8).visible(false);
				table.column(9).visible(false);
			}
		}


	</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm">