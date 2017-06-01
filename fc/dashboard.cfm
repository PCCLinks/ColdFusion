<!--- header --->
<cfinclude template="includes/header.cfm" />

<!--- main content --->
<script>
function buildChart(type, labels, data, ctx, bgcolors, bcolors, ymax, title){
	var myChart = new Chart(ctx, {
		type: type,
		data: {
			labels: labels,
			datasets: [{
				data: data,
				backgroundColor: bgcolors,
	            borderColor: bcolors,
			    borderWidth: 1,
			}] //datasets
		}, //data

		options: {
		    responsive: true,
		    maintainAspectRatio: false,
			legend:{
	           display:false
		    },
		    scales: {
			   xAxes: [{
			        gridLines: {
			            display: false,
			        },
					ticks:{
						fontSize: 14
					}
			    }], //xAxes
			    yAxes: [{
				  gridLines: {
				  	display:false
				  },
			      ticks: {
			      	fontSize: 14,
			        beginAtZero: true,
			        max: ymax,
			        stepSize: .25,
			        callback: function(value) {
			        	return (value*100) + "%"
			        }
			      }, //ticks
			    }] //yAxes
		      } //scales
		    } //options
		}); //chart
} //function buildChart
</script>

<cfquery name="fcTotal" datasource="pcclinks">
  SELECT COUNT(*) TotalNumberStudents
   FROM pcc_links.fc;
</cfquery>

<cfquery name="fcCampusCount" datasource="pcclinks">
  SELECT CASE CAMPUS WHEN 'CAS' THEN 'CASCADE'
		WHEN 'SYL' THEN 'SYLVANIA'
		WHEN 'RC' THEN 'ROCK CREEK'
		WHEN'SE' THEN 'SOUTHEAST'
		ELSE CAMPUS
		END AS CampusName
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
			WHEN STATUSABCX = 'C' THEN 'COMPLET'
			WHEN STATUSABCX = 'X' THEN 'EXIT'
			ELSE 'OTHER' END AS Status
	, ROUND(count(*) / (SELECT COUNT(*) FROM pcc_links.fc WHERE Campus = fc1.Campus),2) Outcome
	FROM pcc_links.fc fc1
	GROUP BY CAMPUS, STATUSABCX
	ORDER BY 1,2;
</cfquery>

<!--- Main Title --->
<cfoutput query="fcTotal">
<div>
	<div class="callout primary">
		<h2 span style = "text-align:center">
		<span style="font-size:3.6rem;line-height:4rem;font-weight:300; vertical-align: top;"> #TotalNumberStudents#</span><br />
		<span style="font-size:1.4rem;line-height:2rem;">FUTURE CONNECT STUDENTS SINCE INCEPTION</span>
		</h2>
	</div>
</div>
</cfoutput>

<!--- Loop One Cell Per Campus --->
<cfloop query="fcCampusCount">
	<cfoutput>
		<div class="small-3 columns">
			<!--- row count --->
			<div class="row" style="text-align: center">
				<span style="font-size:2.25rem;line-height:3rem;;font-weight:300;">#CampusName#</span><br/>
				<span style="font-size:1.5rem;line-height:1.5rem;">#NumberStudents# students</span><br/>
			</div> <!-- end row  count -->
			<br class="clear">
			<br class="clear">
			<!--- row bar chart --->
			<div class="row">
				<cfquery name="fcOutcome" datasource="pcclinks">
					SELECT CASE WHEN STATUSABCX = 'A' THEN 'ACTIVE'
					        WHEN STATUSABCX = 'B' THEN 'BREAK'
					        WHEN STATUSABCX = 'C' THEN 'COMPLETE'
			    		    WHEN STATUSABCX = 'X' THEN 'EXIT'
			        		ELSE 'OTHER' END AS Status
						,ROUND(count(*) / (SELECT COUNT(*) FROM pcc_links.fc WHERE Campus = fc1.Campus),2) Outcome
				    FROM pcc_links.fc fc1
			    	WHERE Campus = <cfqueryparam value="#campus#">
			    	GROUP BY CAMPUS, STATUSABCX;
				</cfquery>
				<!--- Create Unique Id Per Chart --->
				<cfset graphId= '#campus#' & "barchart">
				<div id="wrapper" style="position: relative; height: 25vh">
					<canvas id="#graphId#"></canvas>
				</div>
				<!--- Build chart with Status as labels, and Outcome as data --->
				<script>
					buildChart('bar',['#ValueList(fcOutcome.Status, "','")#']
							,[#ValueList(fcOutcome.Outcome,",")#]
							,#graphId#
							, ['rgba(190, 190, 190, 1.0)',
			                'rgba(190, 190, 190, 1.0)',
			                'rgba(110, 182, 99, 1.0)',
			                'rgba(242, 142, 43,0.8)',
			              	]
			               , ['rgba(190, 190, 190, 1.0)',
			                'rgba(190, 190, 190, 1.0)',
			                'rgba(110, 182, 99, 1.0)',
			                'rgba(242, 142, 43,0.8)',
							]
							,0.75, "Outcome");
				</script>
			</div> <!--- end row bar chart --->
			<br class="clear">
			<br class="clear">
			<!--- row line chart --->
			<div class="row">
			<cfquery name="fcOutcomeTrend" datasource="pcclinks">
				  	SELECT CONVERT(LEFT(COHORT,4), unsigned integer) Year, ROUND(COUNT(CASE WHEN STATUSABCX <> 'X' THEN G END) / COUNT(*),2)  NonExits
					FROM pcc_links.fc
					WHERE Campus = '#Campus#'
					GROUP BY LEFT(COHORT,4)
			</cfquery>
			<!--- Create Unique Id Per Chart --->
			<cfset graphId= '#campus#' & "trendchart">
			<div id="wrapper" style="position: relative; height: 25vh">
				<canvas id="#graphId#"></canvas>
			</div>
			<!--- Build chart with Status as labels, and Outcome as data --->
			<script>
				buildChart('line',['#ValueList(fcOutcomeTrend.Year, "','")#']
					,[#ValueList(fcOutcomeTrend.NonExits,",")#]
					,#graphId#
					,'rgba(144, 103, 167, 1.0)'
					,'lightgrey', 1.0, "Retention Trend");
			</script>
			</div> <!-- end row line chart-->
		</div> <!-- end column for campus -->
	</cfoutput> <!---- End Output of fcCampusCount --->
</cfloop> <!--- End Loop fcCampusCount --->

<!--- footer --->
<cfinclude template="includes/footer.cfm" />
