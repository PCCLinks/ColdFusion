<cfinclude template="includes/header.cfm" />


<style>
.dayB{
	width:60px;
}
</style>
<div class="callout" style="margin-top:5px">
<div class="row">
	<div class="small-3 columns">
		<label>Term Begin Date:
			<cfoutput><input id="billingStartDate" value="#url.billingStartDate#" readonly type="text" > </cfoutput>
		</label>
	</div>
	<div class="small-3 columns">
		<label>Term End Date:
			<cfoutput><input id="billingEndDate" value="#url.billingEndDate#" readonly type="text"></cfoutput>
		</label>
	</div>
	<div class="small-3 columns" style="margin-top:15px">
		<div class="callout">
			<b>Number of Billable Days: <span id="numDays">0</span></b>
		</div>
	</div>
	<div class="small-3 columns" style="margin-top:25px" ><input class="button medium" value="Save" onClick="javascript:saveDays()"></div>
</div>
</div>
<div id="calendar"></div>
<script>
	$(document).ready(function(){
		buildCalendar();
	});

	var numDays = 0;
	function buildCalendar(){
		var dt = $('#billingStartDate').val().split('/');
		var billingStartDate = new Date($('#billingStartDate').val());
		var billingEndDate = new Date($('#billingEndDate').val());
		var y = dt[2];
		var m = dt[0]-1;
		var lastDayOfMonth = new Date(y, m+1, 0).getDate();
		var day = new Date(y, m, 1).getDay();
		var html = getHeading() + '<div class="row">';
		for(i = 0; i < day; i++){
			html += '<div class="small-1 columns">X</div>';
		}
		var excludeDay = "";
		for(i = 1; i <= lastDayOfMonth; i++){
			dt = new Date(y, m, i);
			if(dt < billingStartDate || dt > billingEndDate){
				excludeDay = "alert";
			}else{
				day = dt.getDay();
				if(day > 0 && day < 6){
					numDays += 1;
					excludeDay = ""
				}else{
					excludeDay = "alert";
				}
			}
			html += '<div class="small-1 columns"><a class="button dayB ' + excludeDay + '"  id="d' + i + '" href="javascript:flip(' + i + ')">' + i + '</a></div>';
			if(day == 6){
				html += '<div class="small-5 columns"></div></div><div class="row">';
				day = 0;
			}else{
				day += 1;
			}
		}
		html += '<div class="small-5 columns"></div></div>';
		$('#calendar').html(html);
		$('#numDays').html(numDays);
	}
	function flip(day){
		if($('#d'+day).hasClass('alert')){
			$('#d'+day).removeClass('alert');
			numDays += 1;
		}else{
			$('#d'+day).addClass('alert');
			numDays -= 1;
		}

		$('#numDays').html(numDays);
	}
	function getHeading(){
		return '<div class="row">' +
					'<div class="small-1 columns">Sun</div>' +
					'<div class="small-1 columns">Mon</div>' +
					'<div class="small-1 columns">Tues</div>' +
					'<div class="small-1 columns">Wed</div>' +
					'<div class="small-1 columns">Thurs</div>' +
					'<div class="small-1 columns">Fri</div>' +
					'<div class="small-1 columns">Sat</div>' +
					'<div class="small-5 columns"></div>' +
				'</div>';
	}
	function saveDays(){
		window.location="SetUpBilling.cfm?type=Attendance&billabledays="+numDays;
	}

</script>

<cfinclude template="includes/footer.cfm" />