


<style>

.dayB{
	/*height:25px;*/
	width:80%;
	margin:5px;
	border:1x;
	border-style:solid;
	padding-left:2px;
	padding-right:2px;
	padding-top:5px;
	padding-bottom:5px;
}

</style>
<div class="callout" style="margin-top:5px">
<div class="row">
	<div class="small-3 columns">
		<label>Begin Date:
			<cfoutput><input id="billableDaysStartDate" value="#url.billingStartDate#" readonly type="text" > </cfoutput>
		</label>
	</div>
	<div class="small-3 columns">
		<label>End Date:
			<cfoutput><input id="billableDaysEndDate" value="#url.billingEndDate#" readonly type="text"></cfoutput>
		</label>
	</div>
	<div class="small-3 columns" style="margin-top:15px">
		<div class="callout">
			<b>Billable: <span id="numDays">0</span></b>
		</div>
	</div>
	<div class="small-3 columns" style="margin-top:25px" ><input class="button small" value="Save" onClick="javascript:saveDays()"></div>
</div>
</div>
<div id="calendar"></div>
<script>
	var numDays = 0;
	var fnClose = null;

	function buildCalendar(parentFnClose){
		fnClose = parentFnClose;
		//putting in slashes for dashes, or else date converts incorrectly
		var billingStartDate = new Date($('#billableDaysStartDate').val().replace(/-/g, '\/'));
		var billingEndDate = new Date($('#billableDaysEndDate').val().replace(/-/g, '\/'));
		var y = billingStartDate.getFullYear();
		var m = billingStartDate.getMonth();
		var lastDayOfMonth = new Date(y, m+1, 0).getDate();
		var day = new Date(y, m, 1).getDay();
		var html = getHeading() + '<div class="row" >';
		for(i = 0; i < day; i++){
			html += '<div class="small-1 columns" >X</div>';
		}
		var excludeDay = "";
		var columns;
		for(i = 1; i <= lastDayOfMonth; i++){
			dt = new Date(y, m, i);
			if((day > 0 && day < 6)
				&& (dt >= billingStartDate && dt <= billingEndDate)){
				numDays += 1;
				excludeDay = "";
			}else{
				excludeDay = "alert";
			}
			columns = (day > 0 && day < 6) ? 2 : 1;
			html += '<div class="small-' + columns + ' columns" ><a class="button dayB ' + excludeDay + '"  id="d' + i + '" href="javascript:flip(' + i + ')" >' + i + '</a></div>';
			if(day == 6){
				html += '</div><div class="row">'
				day = 0;
			}else{
				day += 1;
			}
		}
		if(day > 0 && day < 6){
			for(i = day; i < 7; i++){
				html += '<div class="small-' + (i ==6 ? 1 : 2) +' columns" ></div>';
			}
		}
		html += '</div>';
		//html += '<div class="small-5 columns"></div></div>';
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
		return '<div class="row" >' +
					'<div class="small-1 columns">Sun</div>' +
					'<div class="small-2 columns">Mon</div>' +
					'<div class="small-2 columns">Tues</div>' +
					'<div class="small-2 columns">Wed</div>' +
					'<div class="small-2 columns">Thurs</div>' +
					'<div class="small-2 columns">Fri</div>' +
					'<div class="small-1 columns">Sat</div>' +
				'</div>';
	}
	function saveDays(){
		fnClose(numDays);
	}

</script>

