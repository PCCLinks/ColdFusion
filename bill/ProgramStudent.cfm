<cfinclude template="includes/header.cfm" />

<cfinvoke component="LookUp" method="getMaxTerm" returnvariable="maxTerm"></cfinvoke>
<cfset Variables.MaxTerm = #maxTerm#>
<cfset Session.Term = Variables.MaxTerm>

<!--- Program --->
<cfset Variables.Program = "">
<cfif structKeyExists(Session, "Program")>
	<cfset  Variables.Program = Session.Program>
</cfif>
<cfinvoke component="LookUp" method="getPrograms" returnvariable="programs"></cfinvoke>
<cfinvoke component="LookUp" method="getCurrentYearTerms" returnvariable="terms"></cfinvoke>
<cfinvoke component="LookUp" method="getCurrentProgramYear" returnvariable="programYear"></cfinvoke>

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
.filterEntry{
	color:blue;
}
</style>


<ul class="tabs" data-tabs id="index-tabs" style="display:none;">
	<li class="tabs-title is-active">
		<a href="#gridTab" aria-selected="true">List</a>
	</li>
	<li class="tabs-title" id="index-tabs-detail">
		<a href="#detailTab" id="detailTableLabel">Detail</a>
	</li>
</ul>


<!-- tab content -->
<div class="tabs-content" data-tabs-content="index-tabs" id="index-tabs-content" style="display:none">
  	<div class = "tabs-panel is-active" id="gridTab">

		<!-- Filter -->
		<div class="row"><!--->
			<div class="small-3 columns">
				<label for="Term">Latest Term:
					<select name="term" id="term">
						<option value="" > --Select Last Term Billed-- </option>
					<cfoutput query="terms">
						<option value="#term#" <cfif Variables.MaxTerm EQ #term#> selected </cfif> > #termDescription# </option>
					</cfoutput>
					</select>
				</label>
			</div>--->
			<div class="small-8 columns">
				<label for="Program">Program:
					<select name="program" id="program" style="width:200px">
						<option disabled <cfif Variables.Program EQ ""> selected </cfif> value="" > --Select Program-- </option>
						<cfoutput query="programs">
							<option value="#programName#" <cfif Variables.Program EQ #programName#> selected </cfif> > #programName# </option>
						</cfoutput>
					</select>
				</label>
			</div>
			<div class="small-4 columns">
			</div>
		</div> <!-- end Filter row -->

		<div class="callout primary"><b>Click row to see details on a student</b></div>

		<div class="row">
			<div class="small-12 columns">
				<table id="dt_table_list" class="hover" cellspacing="0" width="100%">
					<caption class="visually-hide">"Program data"</caption>
					<thead>
						<tr><th colspan="3" class="tooltipformat">
							<span data-tooltip aria-haspopup="true" class="has-tip" data-disable-hover="false" tabindex="1" title="Filter GNumber, Name or other entries by entering the information into the header boxes below." >Filter...</span>
							</th>
							<th colspan="3" class="tooltipformat">
								<span data-tooltip aria-haspopup="true" class="has-tip" data-disable-hover="false" tabindex="1" title="Click row to see student detail" >Click row...</span>
							</th>
							<th colspan="5" class="tooltipformat">
								<span data-tooltip aria-haspopup="true" class="has-tip" data-disable-hover="false" tabindex="1" title="Sort multiple columns by holding down the <shift> key while clicking sort icon ^." >Sort multiple columns...</span>
							</th>
						</tr>
						<tr id="headerRow">
							<th id="coach">Coach</th>
							<th id="bannerGNumber">G</th>
							<th id="firstname">First name</th>
							<th id="LASTNAME">Last name</th>
							<th id="SchoolDistrict">School District</th>
							<th id="Program">Program</th>
							<th id="ExitDate">Program Exit</th>
							<th id="Program">Latest Term</th>
							<th id="CurrentTermNoOfCredits">Current Term Credits</th>
							<th id="PrevTermNoOfCredits">Prev Term Credits</th>
							<th id="BillingStatus">Last Billing Status</th>
							<th id="BillingStudentId"></th>
						</tr>
						<tr id="searchRow">
							<th><input type="text" placeholder="Coach" class="filterEntry" ></th>
							<th><input type="text" id="gNumberPlaceholder" placeholder="G" class="filterEntry" /></th>
							<th><input type="text" id="firstNamePlaceholder" placeholder="First name" class="filterEntry" /></th>
							<th><input type="text" id="lastNamePlaceholder" placeholder="Last name" class="filterEntry" /></th>
							<th><input type="text" placeholder="School District" class="filterEntry" /></th>
							<th><input type="text" placeholder="Program" class="filterEntry" /></th>
							<th><input type="text" placeholder="Exit Date" class="filterEntry" /></th>
							<th><input type="text" id="termPlaceholder" placeholder="Term" value="<cfoutput>#Variables.MaxTerm#</cfoutput>" class="filterEntry" /></th>
							<th><input type="text" placeholder="Current Term Credits" class="filterEntry" /></th>
							<th><input type="text" placeholder="Prev Term Credits" class="filterEntry" /></th>
							<th><input type="text" id="billingStatusPlaceholder" placeholder="Billing Status" class="filterEntry" /></th>
							<th></th>
						</tr>
					</thead>
					<tbody>
					</tbody>
				</table>
			</div> <!-- end columns -->
		</div><!-- end row -->
 	</div> <!-- end grid tab content>

	<!-- term tab content -->
	<div class = "tabs-panel" id="detailTab">
    	<div id="detail" ><cfinclude template="ProgramStudentDetail.cfm"></div>
  	</div>
</div>

<cfsavecontent variable="pcc_scripts">
	<script>
		var indexOfCoach = 0;
		var indexOfGNumber = 1;
		var indexOfFirstName = 2;
		var indexOfLastName = 3;
		var indexOfProgram = 5;
		var indexOfExitDate = 6;
		var indexOfMaxTerm = 7;
		var indexOfBillingStatus = 10;
		var indexOfBillingStudentId = 11;
		var table_list;
		var txtShowActive = 'Show Active Only';
		var txtShowAll = 'Include Non-Active Students';
		var txtShowInProgress = 'Needs Review Only';
		var txtShowAllStatus = 'Include Already Reviewed';
		var selectedRow;
		var selectedData;
		var searchBillingStudentId = <cfoutput><cfif structKeyExists(Session, "searchBillingStudentId")>#Session.searchBillingStudentId#<cfelse>0</cfif></cfoutput>;

		$.fn.dataTable.ext.errMode = 'throw';

		<!-- document.ready -->
		$(document).ready(function() {
			setUpTableList();

			$('#program').change(function(){
				table_list.column(indexOfProgram).search($('#program').val(),false,false).draw();
			});
			table_list.column(indexOfMaxTerm).search("<cfoutput>#Variables.MaxTerm#</cfoutput>").draw();

			table_list.on('click', 'tr', function () {
				if($(this).attr("id") != "searchRow" && $(this).attr("id") != "headerRow"){
					selectedRow =  table_list.row( this );
			        selectedData = table_list.row( this ).data();
			        goToDetail();
				}
		    } )

		});
		<!-- end document.ready -->


		<!-- setUpTableList -->
		function setUpTableList(program){
			table_list = $('#dt_table_list').DataTable({
				processing:true,
				ajax:{
					url: "programbilling.cfc?method=getProgramStudentList",
					data: getParameters,
					dataSrc:'DATA',
					error: function (xhr, textStatus, thrownError) {
					        handleAjaxError(xhr, textStatus, thrownError);
						}
				},
				dom: '<"top"iB>rt<"bottom"flp>',
				select: {
            		style: 'single'
        		},
				language:{ processing: "Loading data..."},
				columnDefs:[
         				{targets: indexOfBillingStudentId, visible: false, searchable: true}
         			],
         		buttons: [
	            	//Active Students Button
	            	{
	            	  text: txtShowAll,
	            	  action: function( e, table, node, config ){
						filterShowActive(table, this);
	            	  }
	            	},
	            	//Reviewed Students Button
	            	{
	            	  text: txtShowInProgress,
	            	  action: function( e, table, node, config ){
						filterShowReview(table, this);
	            	  }
	            	}
            	],
            	initComplete:function(){
            		doSearchForStudent();
            	}
			});
			//hide main filter
			$(".dataTables_filter").hide();
			table_list = $('#dt_table_list').DataTable();
			// Apply the search
			table_list.columns().every( function () {
				var that = this;
				$( 'input', this.header() ).on( 'keyup change', function () {
					table_list.search('').columns().search('').draw();
					if (that.search() !== this.value ) {
							that.search( this.value ).draw();
					}
				});
			});
		}
		<!-- end setUpTableList -->

		/* called when grid setup completed. Needed when search called from search screen
		 or specific student linked from different page, i.e. footer javascript method getBillingStudent */
		function doSearchForStudent(){
			var searchGNumber = '<cfoutput><cfif structKeyExists(Session, "searchGNumber")>#Session.searchGNumber#</cfif></cfoutput>';
			var searchFirstName = '<cfoutput><cfif structKeyExists(Session, "searchFirstName")>#Session.searchFirstName#</cfif></cfoutput>';
			var searchLastName = '<cfoutput><cfif structKeyExists(Session, "searchLastName")>#Session.searchLastName#</cfif></cfoutput>';

			<!--- so that next time, the search criteria does not repeat when page is reloaded --->
			<cfinvoke component = "DoSearch" method="clearSearchCriteria" >

			if(searchBillingStudentId != 0){
				getStudent(searchBillingStudentId, completeLoadDetail);
			}else{
				//set in header from search form
				if(searchFirstName != ''){
					$('#firstNamePlaceholder').val(searchFirstName);
					table_list.column(indexOfFirstName).search(searchFirstName, false, false).draw();
				}
				if(searchLastName != ''){
					$('#lastNamePlaceholder').val(searchLastName);
					table_list.column(indexOfLastName).search(searchLastName, false, false).draw();
				}
				if(searchGNumber != ''){
					$('#gNumberPlaceholder').val(searchGNumber);
					table_list.column(indexOfGNumber).search(searchGNumber, false, false).draw();
				}
				$('#index-tabs').css('display', 'block');
				$('#index-tabs-content').css('display', 'block');
			}
		}

		function callSaveActionEvent(billingStudentId, fieldName, fieldValue, caller){
			$('body').trigger({
				type: "saveAction",
				billingStudentId: billingStudentId,
				field: fieldName,
				value: fieldValue,
				caller: caller
			});
		}

		<!-- table list functions -->
		function getParameters(){
		 	return {programYear: '<cfoutput>#Variables.programYear#</cfoutput>', program: $('#program').val()};
		}
		function filterShowActive(table, button) {
			var filter =  button.text() == txtShowActive ? "<cfoutput>#Variables.MaxTerm#</cfoutput>" : "";
			table_list.column(indexOfMaxTerm).search(filter).draw();
			$('#termPlaceholder').val(filter);
			buttonText = button.text() == txtShowActive ? txtShowAll : txtShowActive;
	        button.text(buttonText);
		}
		function filterShowReview(table, button) {
			var filter =  button.text() == txtShowInProgress ? "IN PROGRESS" : "";
			table_list.column(indexOfBillingStatus).search(filter).draw();
			$('#billingStatusPlaceholder').val(filter);
			buttonText = (button.text() == txtShowAllStatus ? txtShowInProgress : txtShowAllStatus);
	        button.text(buttonText);
		}
		<!-- end table list functions -->

		<!-- goToDetail - Row Click -->
		function goToDetail(){
			document.body.style.cursor = 'wait';
			var billingStudentId = selectedData[indexOfBillingStudentId];
			var showNext = (table_list.rows({search:'applied'}).count() > 1);
			getStudent(billingStudentId, completeLoadDetail, showNext);
		}
		<!-- end goToDetail -->

		function completeLoadDetail(selectedBillingStudentId){
			$(document).off("saveAction");
			$(document).on("saveAction", programStudentSaveActionHandler);

			if(!selectedRow){
				//called from different page to display student - set selected row now
				table_list.search('').columns().search('');
				table_list.column(indexOfBillingStudentId).search(selectedBillingStudentId);
				var rows = table_list.rows({search:'applied'});
				if(rows.length > 0){
					var idx = rows.indexes()[0];
					table_list.rows(idx).select();
					table_list.row(idx).scrollTo();
					selectedRow =  table_list.row( idx );
			        selectedData = table_list.row( idx ).data();
				}
				var gNumber = selectedData[indexOfGNumber];
				$('#gNumberPlaceholder').val(gNumber);
				table_list.column(indexOfGNumber).search(gNumber).draw();
			}

			//$('#detail').foundation();

			$('#detailTableLabel').text(selectedData[indexOfFirstName] + " " + selectedData[indexOfLastName]);
			$('#index-tabs-detail').click();
			$('#index-tabs').css('display', 'block');
			$('#index-tabs-content').css('display', 'block');
			window.scrollTo(0,0);
			document.body.style.cursor = 'pointer';
		}

		<!-- next and prev options -->
		function gridNext(){
			var next;

			//collection of selected row indexes in the order being displayed
			var indexes = table_list.rows({search:'applied'}).indexes();

			//iterate through, to find out the position of the current row
			$.each(indexes, function(i, index){
				if(index == selectedRow.index()){
					next = i + 1;
				}
			});

			//are we at the bottom of the page?
			var pageNo = table_list.page.info().page+1; //0 based add 1 for usage in denominator
			if(table_list.page.len() == next/pageNo){
				table_list.page('next').draw( 'page' );
			}
			//move down to the next row and select it
			table_list.rows(indexes[next]).select();
			$(table_list.row(indexes[next]).node()).click();
		}
		function gridPrevious(){
			var indexes = table_list.rows({search:'applied'}).indexes();
			var prev;
			$.each(indexes, function(i, index){
				if(index == selectedRow.index()){
					prev = i - 1;
				}
			});

			table_list.rows(indexes[prev]).select();
			$(table_list.row(indexes[prev]).node()).click();
		}

		function programStudentSaveActionHandler(e){
			switch(e.field){
				case 'exitDate':
					selectedData[indexOfExitDate] = e.value;
					break;
				case 'Program':
					selectedData[indexOfProgram] = e.value;
					break;
				case 'billingStatus':
					selectedData[indexOfBillingStatus] = e.value;
					break;
			}

			selectedRow.data(selectedData);
		}
		<!-- end next and prev options -->
</script>
</cfsavecontent>
<cfinclude template="includes/footer.cfm" />
