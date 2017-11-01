<cfinclude template="includes/header.cfm">

<cfinvoke component="Report" method="overageReport" returnvariable="data">
	<cfinvokeargument name="gtcOrYes" value="#url.Program#">
</cfinvoke>

<div class="callout primary">
<cfif url.program EQ 'gtc'>GTC<cfelse>YES</cfif> Overage Report
</div>
<cfif url.program EQ 'gtc'>
	<cfset desc = 'Credits'>
<cfelse>
	<cfset desc = 'Days'>
</cfif>

<table id="dt_table">
	<thead>
		<tr>
			<th>Last Name</th>
			<th>First Name</th>
			<th>G</th>
			<cfoutput>
			<th>Total #desc#</th>
			<th>#desc# Remaining</th>
			</cfoutput>
			<th style="display:none;"></th>
		</tr>
		<tr id="searchRow">
			<th><input type="text" placeholder="Last Name"></th>
			<th><input type="text" placeholder="First Name" /></th>
			<th><input type="text" placeholder="G" /></th>
			<th></th>
			<th></th>
			<th style="display:none;"></th>
		</tr>
	</thead>
	<tbody>
		<cfoutput query="data">
		<tr>
			<td>#lastname#</td>
			<td>#firstname#</td>
			<td><a href="javascript:goToDetail(#billingStudentId#);">#bannerGNumber#</a></td>
			<cfif url.program EQ 'gtc'>
			<td>#NumberFormat(credits,'99.99')#</td>
			<td>#36.00-credits#</td>
			<cfelse>
			<td>#NumberFormat(days,'99.99')#</td>
			<td>#NumberFormat(175.00-days,'99.99')#</td>
			</cfif>
			<td style="display:none;">#billingStudentId#</td>
		</tr>
		</cfoutput>
	</tbody>
</table>


<cfsavecontent variable="pcc_scripts">
	<script>
		$(document).ready(function() {
		    $('#dt_table').DataTable({
				dom: '<"top"iB>rt<"bottom"flp>',
				order: [3, 'desc'],
				buttons:[
					{extend: 'csv',
            	  		text: 'export'
            	  	}
            	  ]
		    });

			//hide main filter
			$(".dataTables_filter").hide();
		} );

		function goToDetail(billingStudentId){
			sessionStorage.setItem("showNext", true);
			var dt = $('#dt_table').DataTable();
			var billingStudentList = dt.columns({search:'applied'}).data()[5];
			sessionStorage.setItem("billingStudentList", billingStudentList);
			var data = $.param({data:encodeURIComponent(JSON.stringify(sessionStorage))});
  			$.post("SaveSession.cfm", data, function(){
  				window.open('programStudentDetail.cfm?billingStudentId='+billingStudentId);
  			});
		}

	</script>
</cfsavecontent>

<cfinclude template="includes/footer.cfm">