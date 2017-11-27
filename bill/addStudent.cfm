<cfsetting requesttimeout="180">
<cfinclude template="includes/header.cfm">

<cfinvoke component="LookUp" method="getTerms" returnvariable="qryTerms"></cfinvoke>
<cfinvoke component="LookUp" method="getLatestDates" returnvariable="qryDates"></cfinvoke>

<style>

	.dataTables_info{
		margin-right:10px !important;
	}
	.dataTables_wrapper .dataTables_filter{
		float:left;
		text-align:left;
	}
	.dataTables_filter input{
		width:75%;
		display: inline-block;
	}
	select {
		width:auto;
	}
	input{
		display:inline-block;
		width:auto;
	}

</style>

<div id="addStudent">
<form id="pageForm" action="javascript:setUpBilling();" method="post">
<div class="callout primary">
	<div class="row">
		<div class="small-12 columns">
			Add Student: <input id="bannerGNumber" name="bannerGNumber" type="text" readonly style="max-width:25%;display:inline-block">
		</div>
	</div>
	<div class="row">
		<div class="small-3 columns">
			<label>Term:<br/>
				<select name="term" id="term" >
					<option disabled selected value="" >
						--Select Term--
					</option>
					<cfoutput query="qryTerms">
					<option  value="#term#" <cfif qryDates.term EQ term>selected</cfif> >#termDescription#</option>
					</cfoutput>
				</select>
			</label>
		</div>
		<cfoutput>
		<div class="small-3 columns">
			<label>Term Begin Date:<br/>
				<input name="termBeginDate" id="termBeginDate" type="text"  readonly="true" value="#DateFormat(qryDates.termBeginDate,"short")#"/>
			</label>
		</div>
		<div class="small-3 columns">
			<label>Term Drop Date:<br/>
				<input name="termDropDate" id="termDropDate" type="text" readonly="true" value="#DateFormat(qryDates.termDropDate,"short")#"/>
			</label>
		</div>
		</cfoutput>
		<div class="small-3 columns"></div>
	</div>
	<div class="row">
		<cfoutput>
		<div class="small-3 columns">
			<label>Billing Start Date:<br/>
				<input name="billingStartDate" id="billingStartDate" type="text" class="fdatepicker" value="#DateFormat(qryDates.billingStartDate,"short")#"/>
			</label>
		</div>
		<div class="small-3 columns">
			<label>Billing End Date:<br/>
				<input name="billingEndDate" id="billingEndDate" type="text" class="fdatepicker" value="#DateFormat(qryDates.billingEndDate,"short")#"/>
			</label>
		</div>
		</cfoutput>
		<div class="small-6 columns">
			<br><input class="button" type="submit" name="submit" value="Add Student to Billing" />
			<input class="button" value="New Search" onClick="javascript:newSearch();">
		</div>
	</div>
	<div id="result"></div>
</div>
</form>
</div>

<div id="search">
	<div class="callout primary" >
		<div class="row">
			<div class="small-3 columns">
				First Name: <input name="firstNameSearch" id="firstNameSearch" >
			</div>
			<div class="small-3 columns">
				Last Name: <input name="lastNameSearch" id="lastNameSearch" >
			</div>
			<div class="small-3 columns">
				Banner GNumber: <input name="bannerGNumberSearch" id="bannerGNumberSearch" >
			</div>
			<div class="small-3 columns">
				<input type="button" class="button" value="Search" onClick="javascript:refreshTable()">
			</div>
		</div>
	</div>
	<table id="dt_table">
		<thead>
			<tr>
				<th>First Name</th>
				<th>Last Name</th>
				<th>G</th>
			</tr>
		</thead>
		<tbody></tbody>
	</table>
</div>

<cfsavecontent variable="pcc_scripts">
<script>
	var table;
	$(document).ready(function() {
		//intialize table
		$.fn.dataTable.ext.errMode = 'throw';

		table = $('#dt_table').DataTable( {
			processing:true,
			ajax:{
				url:"setUpBilling.cfc?method=getSIDNYData",
				type:'POST',
				data: function(d){
						d.firstname = $('#firstNameSearch').val();
						d.lastname = $('#lastNameSearch').val();
						d.bannerGNumber = $('#bannerGNumberSearch').val();
						},
				dataSrc:'DATA',
				error: function (xhr, textStatus, thrownError) {
				        handleAjaxError(xhr, textStatus, thrownError);
					}
			},
			columnDefs:[{targets:2,
			 	render: function ( data, type, row ) {
                 			return '<a href="javascript:addStudent(\''+data+'\')">' + data + '</a>';
            			}
			 	}]
		});
		$('#addStudent').hide();

		 $('body').on('change', '#term', function(e) {
		 	termValue = $('#term').val();
		 	setDate(termValue, 'TermBeginDate', 'termBeginDate');
		 	setDate(termValue, 'TermDropDate', 'termDropDate');
		 });
	})
	function setDate(term, displayField, idName){
		selectedTerm = term;
        var url = 'LookUp.cfc?method=getFilteredTerm&term=' + term + '&displayField='+ displayField + '&ReturnFormat=json';
        $.ajax({
            url: url,
            dataType: 'json',
            success: function(response){
            	$('#' + idName).val(response);
            },
            error: function(ErrorMsg){
                console.log('Error');
            }
        })
    }
	function refreshTable(){
		table.ajax.reload();
	}
	function addStudent(gNumber){
		$('#bannerGNumber').val(gNumber);
		$('#search').hide();
		$('#addStudent').show();
	}
	function newSearch(){
		$('#search').show();
		$('#addStudent').hide();
	}
	function setUpBilling(){
		$.ajax({
			url: 'SetUpBilling.cfc?method=createBillingStudent',
			dataType: "json",
			type: "POST",
			async: true,
			data: $('#pageForm').serialize(),
			success:function(data){
				$('#result').html(data);
			},
			error: function (jqXHR, exception) {
				//alert('Error');
				handleAjaxError(jqXHR, exception);
			}
		});
	}

</script>
</cfsavecontent>


<cfinclude template="includes/footer.cfm">