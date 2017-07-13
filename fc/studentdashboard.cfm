<!--- called by student.cfm as a cfinclude
 pidm and cohort variable set by student.cfm --->

<cfparam name="studentparam_pidm">
<cfparam name="studentparam_bannerGNumber">
<cfparam name="studentparam_cohort">

<cfinvoke component="fc" method="getStudentTermMetrics" bannerGNumber="#studentparam_bannerGNumber#" returnvariable="studentTermMetrics"></cfinvoke>
<cfinvoke component="fc" method="getCoursesByStudent" pidm="#studentparam_pidm#" cohort="#studentparam_cohort#" returnvariable="coursesByStudent"></cfinvoke>

<style>
	.top-bar img { height: 75px; position:relative; width: 150px; background:#e6e6e6; }
	.highlight { background-color:rgb(255, 255, 128) !important; }
</style>

<script>
function buildChart(type, labels, data, ctx, bgcolors, bcolors, yAxesMax, yAxesStep){
		var myChart = new Chart(ctx, {
			type: type,
			data: {
				labels: labels,
					lineThickness: 3,
					datasets: [{
					data: data,
					backgroundColor: bgcolors,
		            borderColor: bcolors,
				    borderWidth: 1,
					fill: false,
				}]
			},
			options: {
				responsive: true,
				legend:{
		           display:false
			    },
			    scales: {
				   xAxes: [{
				        gridLines: {
				            display: false,
				        }
				    }], //end xAxis
				    yAxes: [{
					  gridLines: {
					  	display:false
					  },
				      ticks: {
				        fontSize: 14,
						beginAtZero: true,
				        max: yAxesMax,
				        stepSize: yAxesStep,
				      },
				    }] //end yAxis
				  } //end scales
				} //end options
		}); //end chart
	} //end build chart
</script>

<div class="row">
	<cfoutput>
		<div class="small-6 columns">
			<div class="card">
				<div class="card-divider">
					GPA
				</div>
				<!--- Create Unique Id Per Chart --->
				<cfset graphId= '#studentTermMetrics.STU_ID#' & "gpa">
				<canvas id="#graphId#">
				</canvas>
				<!--- Build chart gpa by term --->
				<script>
					buildChart('line',['#ValueList(studentTermMetrics.TERM, "','")#'],[#ValueList(studentTermMetrics.T_GPA,",")#], '#graphId#', 'rgba(144, 103, 167, 1.0)', 'rgba(144, 103, 167, 1.0)', 4, 0.5);
				</script>
			</div>
		</div>
		<div class="small-6 columns">
			<div class="card">
				<div class="card-divider">
					CREDITS EARNED
				</div>
				<cfset graphId= '#studentTermMetrics.STU_ID#' & "t_earned">
				<canvas id="#graphId#">
				</canvas>
				<!--- Build chart earned credits by term --->
				<script>
					buildChart('bar',['#ValueList(studentTermMetrics.TERM, "','")#'],[#ValueList(studentTermMetrics.T_EARNED,",")#], '#graphId#', 'rgba(144, 103, 167, 1.0)', 'rgba(144, 103, 167, 1.0)', 30, 5);
				</script>
			</div>
		</div>
	</cfoutput>
</div>
<!-- end row -->
<br class="clear" />
<table id="dt_table" cellspacing="1" width="95%" class="unstriped compact" ;>
	<thead>
		<tr>
			<th id="Term">Term</th>
			<th id="CRSE">CRSE</th>
			<th id="SUBJ">SUBJ</th>
			<th id="Title">Title</th>
			<td id="Credits">Credits</td>
			<th id="Grade">Grade</th>
			<th id="Passed">Passed</th>
		</tr>
	</thead>
	<tbody>
	<cfoutput query="coursesByStudent">
		<tr <cfif PASSED eq "N"> class="highlight" </cfif> 	>
			<td>#coursesByStudent.TERM#</td>
			<td>#coursesByStudent.CRSE#</td>
			<td>#coursesByStudent.SUBJ#</td>
			<td>#coursesByStudent.TITLE#</td>
			<td>#coursesByStudent.CREDITS#</td>
			<td>#coursesByStudent.GRADE#</td>
			<td>#coursesByStudent.PASSED#</td>
		</tr>
	</cfoutput>
	</tbody>
</table>

<cfsavecontent variable="studentdashboard_script">
<script>
	$(document).ready(function() {
		$('#dt_table').DataTable({
			searching: false,
			paging: false,
			info: false,
			columns:[{data:'Term'},{data:'CRSE'},{data:'SUBJ'},{data:'Title'},{data:'Credits'},{data:'Grade'},{data:'Passed'}],
	    	orderFixed: [0, "desc" ],
	    	rowGroup: {
	    		dataSrc: 'Term'
	    	}
	    }); //end datatable
	}); //end document.ready
</script>
</cfsavecontent>
