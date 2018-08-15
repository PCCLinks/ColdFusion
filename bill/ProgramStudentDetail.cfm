

<!-- Next and Previous Buttons
	Calls javascript from parent page
	ProgramStudent.cfm
--->
<div class="row" id="nextButtons" style="display:none">
	<div class="large-4 columns">
		<input id="prevStudent" name="prevStudent" type="button" class="button small" value="<< Prev Student in List" onClick="javascript:gridPrevious();">
	</div>
	<div class="large-2 columns">
		<input id="nextStudent" name="nextStudent" type="button" class="button small" value="Next Student in List>>" onClick="javascript:gridNext();">
	</div>
</div>


<!-- Header Tabs -->
<span id="headerTabs"></span>

<hr>
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
			<div class="small-5 columns">
				<!-- Billed Classes  -->
				<div class="row" style="margin-bottom:50px" id="billedClasses">
				</div> <!-- end billed classes -->
			</div> <!-- end lefthand column -->

			<!-- blank column -->
			<div class="small-1 columns"></div>

			<!-- righthand column -->
			<div class="small-6 columns">
				<!-- past classes -->
				<div class="row" id="pastClasses">
				</div><!-- end past classes -->
			</div> <!-- end righthand column -->

		</div> <!-- end class information -->
	</div> <!-- end class content container -->

	<!-- billing content container -->
	<div class= "tabs-panel" id="Billing">
	</div> <!-- end billing content container -->
</div> <!-- End Class vs Billing Header Content Container -->



<script>
	<!-- from ProgramStudentDetail.cfm -->
	function getStudent(billingStudentId, fnComplete, showNext){
		if(showNext){
			$('#nextButtons').css("display", "block");
		}else{
			$('#nextButtons').css("display", "none");
		}
		$.get("includes/programStudentHeaderTabsInclude.cfm?billingStudentId="+ billingStudentId, function(data){
				$('#headerTabs').html(data);
			}).done(function(){
				programStudentHeaderInit();
				$('#headerTabs').foundation();

				$.get("includes/billedClassesInclude.cfm", function(data){
					$('#billedClasses').html(data);
				}).done(function(){
					billedClassesInit();
					$('#billedClasses').foundation();
				});

				$.get("includes/pastClassesInclude.cfm", function(data){
					$('#pastClasses').html(data);
				}).done(function(){
					pastClassesInit();
					$('#pastClasses').foundation();
				});

				$.get("includes/billingStudentTabInclude.cfm", function(data){
					$('#Billing').html(data);
				}).done(function(){
					formatDatePicker();
					billingStudentTabInit();
					$('#Billing').foundation();

					//keep tabs in sync
					 $('#term-header-tabs').on('change.zf.tabs', function() {
					      var tabId = $('div[data-tabs-content="'+$(this).attr('id')+'"]').find('.tabs-panel.is-active').attr('id');
			      		  $('#billing-tabs').foundation('selectTab', $('#'+tabId.replace('H','B')), false);
			  		 });
			  		  $('#billing-tabs').on('change.zf.tabs', function() {
					      var tabId = $('div[data-tabs-content="'+$(this).attr('id')+'"]').find('.tabs-panel.is-active').attr('id');
			    		  $('#term-header-tabs').foundation('selectTab', $('#'+tabId.replace('B','H')), false);
			  		 });

					var selectedBillingStudentId;
					$.get('DoSearch.cfc?method=getMostRecentTermBillingStudentId', function(data){
						selectedBillingStudentId = parseInt(data);
					}).done(function(){
						fnComplete(selectedBillingStudentId);
					});
				})
			});
	}

 </script>


