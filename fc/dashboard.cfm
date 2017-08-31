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
						fontSize: 14,
			        	autoSkip: false
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
			        autoSkip: false,
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

<cfquery name="fcTotal" >
  SELECT count(*) as TotalNumberStudents
   FROM futureConnect;
</cfquery>

<cfquery  name="fcFundingSource">
  SELECT fundedBy
  , count(*) as NumberStudents
  FROM futureConnect
  WHERE FundedBy IN ('City of Portland','City of Beaverton', 'City of Hillsboro', 'State')
  GROUP BY fundedBy
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

<!--- Loop One Cell Per fund source --->
<cfloop query="fcFundingSource">
	<cfoutput>
		<div class="small-3 columns">
			<!--- row count --->
			<div class="row" style="text-align: center">
				<span style="font-size:2.25rem;line-height:3rem;;font-weight:300;">#fcFundingSource.fundedBy#</span><br/>
				<span style="font-size:1.5rem;line-height:1.5rem;">#fcFundingSource.NumberStudents# students</span><br/>
			</div> <!-- end row  count -->
			<br class="clear">
			<br class="clear">
			<!--- row bar chart --->
			<div class="row">

				<cfquery name="fcOutcomeBySource" >
				   	SELECT allStatusCities.fundedBy
						,allStatusCities.statusInternal
				    	,IFNULL(count(*)/(select count(*) from futureConnect fc2 where fc2.fundedBy = fc1.FundedBy),0) outcomeByFund
					FROM
						(SELECT * FROM
							 (SELECT CAST('A' as char) as Code, 'ACTIVE' as statusInternal
								  UNION SELECT 'B', 'BREAK'
								  UNION SELECT  'C', 'COMPLETE'
								  UNION SELECT 'X' , 'EXIT'
								  UNION SELECT 'O', 'OTHER') allStatuses,
		                      (SELECT CAST('City of Beaverton' as CHAR) fundedBy
		                       UNION SELECT 'City of Hillsboro'
		                       UNION SELECT 'City of Portland'
		                       UNION SELECT 'State') allCities) allStatusCities
	                   LEFT OUTER JOIN  futureConnect fc1 ON (allStatusCities.Code = fc1.statusInternal
									OR (fc1.statusInternal not in ('A','B','C','X') and code = 'O'))
							and allStatusCities.fundedBy = fc1.fundedBy
				    WHERE allStatusCities.fundedBy = <cfqueryparam value="#fcFundingSource.fundedBy#">
					GROUP BY allStatusCities.fundedBy, allStatusCities.statusInternal
				</cfquery>
				<!--- Create Unique Id Per Chart --->
				<cfset graphId= '#replace(fcFundingSource.fundedBy,' ','','all')#' & "barchart">
				<div id="wrapper" style="position: relative; height: 25vh">
					<canvas id="#graphId#"></canvas>
				</div>
				<!--- Build chart with Status as labels, and Outcome as data --->
				<script>
					buildChart('bar',['#ValueList(fcOutcomeBySource.StatusInternal, "','")#']
							,[#ValueList(fcOutcomeBySource.outcomeByFund,",")#]
							,"#graphId#"
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
			   	select fc1.FundedBy
			    , Cohort
				, sum(case when statusInternal <> 'X' then 1 else 0 end) / count(*) as nonExits
				FROM futureConnect fc1
				WHERE fundedBy = <cfqueryparam value="#fcFundingSource.fundedBy#">
				group by fundedBy, Cohort;
			</cfquery>

			<!--- Create Unique Id Per Chart --->
			<cfset graphId= '#replace(fcFundingSource.fundedBy,' ','','all')#' & "trendchart">
			<div id="wrapper" style="position: relative; height: 25vh">
				<canvas id="#graphId#"></canvas>
			</div>
			<!--- Build chart with Status as labels, and Outcome as data --->
			<script>
				buildChart('line',['#ValueList(fcOutcomeTrend.Cohort, "','")#']
					,[#ValueList(fcOutcomeTrend.nonExits,",")#]
					,"#graphId#"
					,'rgba(144, 103, 167, 1.0)'
					,'lightgrey', 1.0, "Retention Trend");
			</script>
			</div> <!-- end row line chart-->
		</div> <!-- end column for fund source -->
	</cfoutput> <!---- End Output of fcFundingSource --->
</cfloop> <!--- End Loop fcFundingSource --->


<!--- footer --->
<cfinclude template="includes/footer.cfm" />
