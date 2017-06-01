	<cfsavecontent variable="pcc_menu">
	<nav class="top-bar" >
    <ul class="menu">
	  <li><img src="/PCCLinks/images/fclogo.png"/></li>
      <li class="active"><a href="dashboard.cfm">Home</a></li>
      <li><a href="caseload.cfm">Caseload</a></li>

	  </ul>
	</nav>
</cfsavecontent>
<cfinclude template="includes/header.cfm" />

	<script>
			function buildChart(type, labels, data, ctx, bgcolors, bcolors){
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
						}]
					},

					options: {
					    responsive: false,

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
						        max: 1,
						        stepSize: .25,
						          callback: function(value) {
						               return (value*100) + "%"
						           }
						      },

						    }]
					      }
					    }

				});
		}
	</script>



	<cfquery name="fcTotal" datasource="pcclinks">
	  SELECT COUNT(*) TotalNumberStudents
	   FROM pcc_links.fc;
	</cfquery>

	<cfquery name="fcCampusCount" datasource="pcclinks">
	  SELECT CASE CAMPUS WHEN 'CAS' THEN 'CASCADE'
			WHEN 'SYL' THEN 'SYLVANIA'
			WHEN 'RC' THEN 'ROCK CREEK'
		ELSE CAMPUS END AS CampusName
		, Campus
		, COUNT(*) NumberStudents
	  FROM pcc_links.fc fc1
	  WHERE Campus IN ('CAS','SE','SYL','RC')
	  GROUP BY CAMPUS;
	</cfquery>

	<cfquery name="fcOutcome" datasource="pcclinks">
	  SELECT CAMPUS
			, CASE WHEN STATUSABCX = 'A' THEN 'ACTIVE'
				WHEN STATUSABCX = 'B' THEN 'BREAK'
				WHEN STATUSABCX = 'C' THEN 'COMPLETED'
				WHEN STATUSABCX = 'X' THEN 'EXIT'
				ELSE 'OTHER' END AS Status
		, ROUND(count(*) / (SELECT COUNT(*) FROM pcc_links.fc WHERE Campus = fc1.Campus),2) Outcome
		FROM pcc_links.fc fc1
		GROUP BY CAMPUS, STATUSABCX
		ORDER BY 1,2;
	</cfquery>

	<!--- Main Title --->
	<table width = "100px">
	<cfoutput query="fcTotal">

	<tr>
		<td colspan = "4" width = "100%" height: 700p>

		<div class="callout primary">
			<h2 span style = "text-align:center">
			<span style="font-size:3.6rem;line-height:4rem;font-weight:300; vertical-align: top;"> #TotalNumberStudents#</span><br />
			<span style="font-size:1.4rem;line-height:2rem;">FUTURE CONNECT STUDENTS SINCE INCEPTION</span>
			</h2>
		</div>
		</td>
	</tr>
	</cfoutput>

	<!--- Loop One Cell Per Campus --->
	<tr>
	<cfloop query="fcCampusCount">
		<cfoutput>
			<td width = "25%" height = 750px align="center" "valign:top">
				<span style="font-size:3.6rem;line-height:4rem;font-weight:300">#NumberStudents#</span><br/>
				<span style="font-size:1.4rem;line-height:2rem;">#CampusName# Students</span><br/>
				<cfquery name="fcOutcome" datasource="pcclinks">
					SELECT CASE WHEN STATUSABCX = 'A' THEN 'ACTIVE'
				        WHEN STATUSABCX = 'B' THEN 'BREAK'
				        WHEN STATUSABCX = 'C' THEN 'COMPLETED'
				        WHEN STATUSABCX = 'X' THEN 'EXIT'
				        ELSE 'OTHER' END AS Status
					,ROUND(count(*) / (SELECT COUNT(*) FROM pcc_links.fc WHERE Campus = fc1.Campus),2) Outcome
				    FROM pcc_links.fc fc1
				    WHERE Campus = <cfqueryparam value="#campus#">
				    GROUP BY CAMPUS, STATUSABCX;
				</cfquery>

				<!--- Create Unique Id Per Chart --->
				<cfset graphId= '#campus#' & "barchart">
				<canvas id="#graphId#"></canvas>
				<!--- Build chart with Status as labels, and Outcome as data --->
				<script>
					buildChart('bar',['#ValueList(fcOutcome.Status, "','")#'],[#ValueList(fcOutcome.Outcome,",")#], #graphId#,
								[ 'rgba(255, 99, 132, 0.2)',
				                'rgba(54, 162, 235, 0.2)',
				                'rgba(255, 206, 86, 0.2)',
				                'rgba(75, 192, 192, 0.2)',
				              ],
				               [ 'rgba(255, 99, 132, 0.2)',
				                'rgba(54, 162, 235, 0.2)',
				                'rgba(255, 206, 86, 0.2)',
				                'rgba(75, 192, 192, 0.2)',
								]);
				</script>

				<cfquery name="fcOutcomeTrend" datasource="pcclinks">
					  	SELECT CONVERT(LEFT(COHORT,4), unsigned integer) Year, ROUND(COUNT(CASE WHEN STATUSABCX <> 'X' THEN G END) / COUNT(*),2)  NonExits
						FROM pcc_links.fc
						WHERE Campus = '#Campus#'
						GROUP BY LEFT(COHORT,4)
				</cfquery>
				<!--- Create Unique Id Per Chart --->
				<cfset graphId= '#campus#' & "trendchart">
				<canvas id="#graphId#"></canvas>
				<!--- Build chart with Status as labels, and Outcome as data --->

				<script>
					buildChart('line',['#ValueList(fcOutcomeTrend.Year, "','")#'],[#ValueList(fcOutcomeTrend.NonExits,",")#], #graphId#, 'lightgrey', 'darkblue');

				</script>

		</cfoutput> <!---- End Output of fcCampusCount --->
	</cfloop> <!--- End Loop fcCampusCount --->
			</td>
			</tr>
			</table>
