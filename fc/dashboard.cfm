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

<cfquery name="fcTotal">
  SELECT COUNT(*) TotalNumberStudents
   FROM futureConnect;
</cfquery>

<cfquery name="fcCampusCount">
  SELECT campus
	, COUNT(*) NumberStudents
  FROM futureConnect
  GROUP BY campus;


</cfquery>

<cfquery name="fcOutcome">
  SELECT campus
		, CASE WHEN statusInternal = 'A' THEN 'ACTIVE'
			WHEN statusInternal = 'B' THEN 'BREAK'
			WHEN statusInternal = 'C' THEN 'COMPLET'
			WHEN statusInternal = 'X' THEN 'EXIT'
			ELSE 'OTHER' END AS statusInternal
	, ROUND(count(*) / (SELECT COUNT(*) FROM futureConnect WHERE campus = fc1.campus),2) Outcome
	FROM futureConnect fc1
	GROUP BY campus, statusInternal
	ORDER BY 1,2;
</cfquery>

<!--- Main Title --->
<cfoutput query="fcTotal">
<div>
	<div class="callout primary">
		<h2 span style = "text-align:center">
		<span style="font-size:3.6rem;line-height:4rem;font-weight:300; vertical-align: top;"> #TotalNumberStudents#</span><br />
		<span style="font-size:1.4rem;line-height:2rem;">Future Connect Students Since Inception</span>
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
				<span style="font-size:2.25rem;line-height:3rem;;font-weight:300;">#campus#</span><br/>
				<span style="font-size:1.5rem;line-height:1.5rem;">#NumberStudents# students</span><br/>
			</div> <!-- end row  count -->
			<br class="clear">
			<br class="clear">
			<!--- row bar chart --->
			<div class="row">
				<cfquery name="fcOutcome">
					SELECT CASE WHEN statusInternal = 'A' THEN 'ACTIVE'
					        WHEN statusInternal = 'B' THEN 'BREAK'
					        WHEN statusInternal = 'C' THEN 'COMPLETE'
			    		    WHEN statusInternal = 'X' THEN 'EXIT'
			        		ELSE 'OTHER' END AS Status
						,ROUND(count(*) / (SELECT COUNT(*) FROM futureConnect WHERE campus = fc1.campus),2) Outcome
				    FROM futureConnect fc1
			    	WHERE campus = <cfqueryparam value="#campus#">
			    	GROUP BY campus, statusInternal;
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
			<cfquery name="fcOutcomeTrend">
				  	SELECT CONVERT(LEFT(COHORT,4), unsigned integer) Year, ROUND(COUNT(CASE WHEN statusInternal <> 'X' THEN bannerGNumber END) / COUNT(*),2)  NonExits
					FROM futureConnect
					WHERE campus = '#Campus#'
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
