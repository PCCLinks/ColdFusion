<cfinclude template="includes/header.cfm">

<cfinvoke component="LookUp" method="getMaxTerm" returnvariable="maxTerm"></cfinvoke>
<cfinvoke component="Report" method="overageReport" returnvariable="data">
	<cfinvokeargument name="gtcOrYes" value="#url.Program#">
</cfinvoke>

<style>
	table.dataTable thead th.tooltipformat {
		color:gray;
		font-size:x-small;
		border-bottom-style:none;
		padding-bottom:0px;
	}
	.dataTables_wrapper .dataTables_processing{
		top: 30% !important;
		height: 50px !important;
		background-color: lightGray;
	}
	.dt-buttons{
		float:right !important;
	}

</style>

<div class="callout primary">
<cfif url.program EQ 'gtc'>GtC<cfelse>YtC</cfif> Overage Report
</div>
<cfset desc = 'Credits'>
<!---><cfif url.program EQ 'gtc'>
	<cfset desc = 'Credits'>
<cfelse>
	<cfset desc = 'Days'>
</cfif>--->

<table id="dt_table">
	<thead>
		<tr><th colspan="2" class="tooltipformat">
				<span data-tooltip aria-haspopup="true" class="has-tip" data-disable-hover="false" tabindex="1" title="Sort multiple columns by holding down the <shift> key while clicking sort icon ^." >Sort multiple columns...</span>
			</th>
			<th colspan="1" class="tooltipformat">
				<span data-tooltip aria-haspopup="true" class="has-tip" data-disable-hover="false" tabindex="1" title="Click the GNumber to open a new tab with more student detail" >Click...</span>
			</th>
			<th colspan="1" class="tooltipformat">
				<span data-tooltip aria-haspopup="true" class="has-tip" data-disable-hover="false" tabindex="1" title="Shows the last term enrolled. Enter term in box below to limit or click 'Active' button" >Max term...</span>
			</th>
			<th colspan="3" class="tooltipformat">
				<span data-tooltip aria-haspopup="true" class="has-tip" data-disable-hover="false" tabindex="1" title="Filter coach or other entries by entering the information into the header boxes below." >Filter coach...</span>
			</th>
		</tr>
		<tr>
			<th>Last Name</th>
			<th>First Name</th>
			<th>G</th>
			<th>Max Term</th>
			<th>Coach</th>
			<cfoutput>
			<th>Total #desc#</th>
			<th>#desc# Remaining</th>
			</cfoutput>
			<th style="display:none;"></th>
		</tr>
		<tr id="searchRow">
			<th><input type="text" placeholder="Last Name"></th>
			<th><input type="text" placeholder="First Name" /></th>
			<th><input type="text" placeholder="G" style="width:100px"/></th>
			<th><input type="text" placeholder="Max Term" id="maxterm"  /></th>
			<th><input type="text" placeholder="Coach" /></th>
			<th><input type="text" placeholder="Total" /></th>
			<th><input type="text" placeholder="Remaining" /></th>
			<th style="display:none;"></th>
		</tr>
	</thead>
	<tbody>
		<cfoutput query="data">
		<tr>
			<td>#lastname#</td>
			<td>#firstname#</td>
			<td><a href="javascript:getBillingStudent(#billingStudentId#, true);">#bannerGNumber#</a></td>
			<td>#MaxTerm#</td>
			<td>#coach#</td>
			<!---><cfif url.program EQ 'gtc'>--->
			<td>#NumberFormat(credits,'99.99')#</td>
			<td>#36.00-credits#</td>
			<!---><cfelse>
			<td>#NumberFormat(days,'99.99')#</td>
			<td>#NumberFormat(175.00-days,'99.99')#</td>
			</cfif>--->
			<td style="display:none;">#billingStudentId#</td>
		</tr>
		</cfoutput>
	</tbody>
</table>


<cfsavecontent variable="pcc_scripts">
	<script>
		var txtShowActive = 'Show Active Only';
		var txtShowAll = 'Include Non-Active Students';

		$(document).ready(function() {
		    $('#dt_table').DataTable({
				dom: '<"top"iB>rt<"bottom"flp>',
				order: [3, 'desc'],
				buttons:[
					{extend: 'csv',
            	  		text: 'export',
	            	  	titleAttr:"Export data.  Results will be limited to what is showing in the grid, if limits have been applied.",
            	  	},
            	  	//Active Students Button
	            	{
	            	  text: txtShowActive,
	            	  titleAttr: "Limit to show by Max Term enrolled",
	            	  action: function( e, table, node, config ){
						filterShowActive(table, this);
	            	  }
	            	}
            	  ]
		    });

			//hide main filter
			$(".dataTables_filter").hide();
			table = $('#dt_table').DataTable();
			// Apply the search
			table.columns().every( function () {
				var that = this;
				$( 'input', this.header() ).on( 'keyup change', function () {
					if (that.search() !== this.value ) {
							that.search( this.value ).draw();
					}
				});
			});
		} );


		function filterShowActive(table, button) {
			filter =  button.text() == txtShowActive ? "<cfoutput>#Variables.MaxTerm#</cfoutput>" : "";
			table.column(3).search(filter).draw();
			$('#maxterm').val(filter);
			buttonText = button.text() == txtShowActive ? txtShowAll : txtShowActive;
	        button.text(buttonText);
		}

	</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm">