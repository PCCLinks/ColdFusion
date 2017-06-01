
<cfinvoke component="fc" method="getStudentTermMetrics" id=#url.id# returnvariable="studentTermMetrics"></cfinvoke>
<cfinvoke component="fc" method="getCoursesByStudent" id=#url.id# returnvariable="coursesByStudent"></cfinvoke>



	<script>
			function buildChart(type, labels, data, ctx, bgcolors, bcolors, yAxesMax, yAxesStep, title){
				//var ctx = document.getElementById(chartid);
				var myChart = new Chart(ctx, {
					type: type,
					data: {
						labels: labels,
						datasets: [{
							data: data,

							backgroundColor: bgcolors,
				            borderColor: bcolors,
						    borderWidth: 1,
							fill: false,
						}]
					},

					options: {
						title:{
						text: title,
						display: true
						},
					    responsive: true,

						legend:{
					           display:false
					    },

					    scales: {
						   xAxes: [{
						        gridLines: {
						            display: false,
						        }
						    }],
						    yAxes: [{
							  gridLines: {
							  	display:false
							  },
						      ticks: {
						        beginAtZero: true,
						        max: yAxesMax,
						        stepSize: yAxesStep,

						      },

						    }]
					      }
					    }

				});
		}
	</script>



<!--- Main Title --->
<div class="callout primary">
<cfoutput><h3>#studentTermMetrics.STU_NAME# <br> #studentTermMetrics.STU_ID#</h3>
</cfoutput>
</div>


<div class="row expanded columns">
<cfoutput>
	<div class="small-6 columns">
		<div class="card">
			<div class="card-divider">GPA</div>
			<!--- Create Unique Id Per Chart --->
			<cfset graphId= '#studentTermMetrics.STU_ID#' & "gpa">
			<canvas id="#graphId#"></canvas>
			<!--- Build chart gpa by term --->
			<script>
				buildChart('line',['#ValueList(studentTermMetrics.TERM, "','")#'],[#ValueList(studentTermMetrics.T_GPA,",")#], #graphId#, 'lightgrey', 'darkblue', 4, 0.5, 'GPA');
			</script>
		</div> <!-- end card div -->
	</div> <!-- end col div -->
	<div class="small-6 columns">
		<div class="card">
			<div class="card-divider">Credits Earned</div>
			<cfset graphId= '#studentTermMetrics.STU_ID#' & "t_earned">
			<canvas id="#graphId#"></canvas>
			<!--- Build chart earned credits by term --->
			<script>
				buildChart('bar',['#ValueList(studentTermMetrics.TERM, "','")#'],[#ValueList(studentTermMetrics.T_EARNED,",")#], #graphId#, 'lightgrey', 'darkblue', 30, 5, 'CREDITS EARNED');
			</script>
		</div><!-- end card div -->
	</div> <!-- end col div -->
</cfoutput>
</div> <!-- end row div -->
<div class="row expanded columns">
<div class="small-12 columns">
<table id="dt_table" cellspacing="1" width="95%" class="unstriped compact";>
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
<tr <cfif PASSED eq "N"> style = "background-color:rgb(255, 255, 128);" </cfif>>
	<td>#coursesByStudent.TERM#</td>
	<td>#coursesByStudent.CRSE#</td>
	<td>#coursesByStudent.SUBJ#</td>
	<td>#coursesByStudent.TITLE#</td>
	<td>#coursesByStudent.CREDITS# </td>
	<td>#coursesByStudent.GRADE# </td>
	<td>#coursesByStudent.PASSED#</td>
</tr>
</cfoutput>
</tbody>
</table>
</div>
</div>

<cfsavecontent variable="pcc_scripts">
  <script>
	$(document).ready(function() {
		$('#dt_table').DataTable({
			searching: false,
			paging: false,
			info: false,
			columns:[{data:'Term'},{data:'CRSE'},{data:'SUBJ'},{data:'Title'},{data:'Credits'},{data:'Grade'},{data:'Passed'}],
	    	rowGroup: {
	    		dataSrc: 'Term'
	    	},

	    });
	});
	function buildChart(type, labels, data, ctx, bgcolors, bcolors, yAxesMax, yAxesStep, title){
	//var ctx = document.getElementById(chartid);
		var myChart = new Chart(ctx, {
			type: type,
			data: {
				labels: labels,
				datasets: [{
					data: data,
					backgroundColor: bgcolors,
		            borderColor: bcolors,
				    borderWidth: 1,
					fill: false,
				}]
			},
			options: {
				title:{
					text: title,
					display: true
				},
			    responsive: true,
				legend:{
		           display:false
			    },
			    scales: {
				   xAxes: [{
			        gridLines: {
			            display: false,
			        }
				    }],
				    yAxes: [{
					  gridLines: {
					  	display:false
					  },
			     	 ticks: {
			        	beginAtZero: true,
			        	max: yAxesMax,
			        	stepSize: yAxesStep,
			      		},
		    		}]
				}
		}
	});
	}
  </script>
</cfsavecontent>


