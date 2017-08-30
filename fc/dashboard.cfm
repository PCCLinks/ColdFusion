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


<!---
<cfquery name="futureConnectStatus">
	select case when CAST(right(cohort,1) as char(50)) = '1' then 'Portland'
				when CAST(right(cohort,1) as char(50)) = '2' then 'Beaverton'
				when CAST(right(cohort,1) as char(50)) = '3' then 'Hillsboro'
				else 'State' end as fund_source

	, CASE WHEN statusInternal = 'A' THEN 'ACTIVE'
		WHEN statusInternal = 'B' THEN 'BREAK'
		WHEN statusInternal = 'C' THEN 'COMPLETE'
		WHEN statusInternal = 'X' THEN 'EXIT'
		ELSE 'OTHER' END AS statusInternal
	, count(*) as studentCounts
	, (SELECT COUNT(*) FROM futureConnect WHERE (case when CAST(right(cohort,1) as char(50)) = '1' then 'Portland'
				when CAST(right(cohort,1) as char(50)) = '2' then 'Beaverton'
				when CAST(right(cohort,1) as char(50)) = '3' then 'Hillsboro'
				else 'State' end) = (case when CAST(right(fc1.cohort,1) as char(50)) = '1' then 'Portland'
				when CAST(right(fc1.cohort,1) as char(50)) = '2' then 'Beaverton'
				when CAST(right(fc1.cohort,1) as char(50)) = '3' then 'Hillsboro'
				else 'State' end)
                ) as fundingSourceStudentCount

	FROM futureConnect fc1
	GROUP BY fund_source, statusInternal
</cfquery>

<cfquery name="futureConnectCohort">
	select case when CAST(right(cohort,1) as char(50)) = '1' then 'Portland'
				when CAST(right(cohort,1) as char(50)) = '2' then 'Beaverton'
				when CAST(right(cohort,1) as char(50)) = '3' then 'Hillsboro'
				else 'State' end as fund_source

	, CONVERT(LEFT(COHORT,4), unsigned integer) Cohort
	, sum(case when statusInternal <> 'X' then 1 else 0 end) as nonExitCounts

	, (SELECT COUNT(*) FROM futureConnect WHERE (case when CAST(right(cohort,1) as char(50)) = '1' then 'Portland'
				when CAST(right(cohort,1) as char(50)) = '2' then 'Beaverton'
				when CAST(right(cohort,1) as char(50)) = '3' then 'Hillsboro'
				else 'State' end) = (case when CAST(right(fc1.cohort,1) as char(50)) = '1' then 'Portland'
				when CAST(right(fc1.cohort,1) as char(50)) = '2' then 'Beaverton'
				when CAST(right(fc1.cohort,1) as char(50)) = '3' then 'Hillsboro'
				else 'State' end)

                and

				CONVERT(LEFT(COHORT,4), unsigned integer) = CONVERT(LEFT(fc1.COHORT,4), unsigned integer)

                ) as fundingSourceStudentCount

	FROM futureConnect fc1
	GROUP BY fund_source, Cohort
</cfquery>


<cfquery dbtype="query" name="fcTotal" >
  SELECT sum(studentCounts) as TotalNumberStudents
   FROM futureConnectStatus;
</cfquery>




<cfquery dbtype="query" name="fcFundingSource">
  SELECT fund_source
	, sum(studentCounts) NumberStudents
  FROM futureConnectStatus
  GROUP BY fund_source;
 </cfquery>


<cfquery dbtype="query" name="fcOutcome">
  SELECT fund_source
	, statusInternal

	, (SUM(studentCounts)/ MAX(fundingSourceStudentCount)) Outcome

	FROM futureConnectStatus
	GROUP BY fund_source, statusInternal

	ORDER BY 1,2;
</cfquery>



<cfquery dbtype="query" name="fcOutcomeByCohort">
  SELECT fund_source
	, Cohort
	, SUM(nonExitCounts)/ MAX(fundingSourceStudentCount) Outcome

	FROM futureConnectCohort
	GROUP BY fund_source, Cohort

	ORDER BY 1,2;
</cfquery>
--->

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
			   	select fc1.FundedBy
				, CASE WHEN statusInternal = 'A' THEN 'ACTIVE'
					WHEN statusInternal = 'B' THEN 'BREAK'
					WHEN statusInternal = 'C' THEN 'COMPLETE'
					WHEN statusInternal = 'X' THEN 'EXIT'
					ELSE 'OTHER' END AS statusInternal
			    ,count(*)/(select count(*) from futureConnect fc2 where fc2.fundedBy = fc1.FundedBy) outcomeByFund
				FROM futureConnect fc1
			    WHERE fundedBy = <cfqueryparam value="#fcFundingSource.fundedBy#">
				GROUP BY FundedBy, CASE WHEN statusInternal = 'A' THEN 'ACTIVE'
					WHEN statusInternal = 'B' THEN 'BREAK'
					WHEN statusInternal = 'C' THEN 'COMPLETE'
					WHEN statusInternal = 'X' THEN 'EXIT'
					ELSE 'OTHER' END
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
					,#graphId#
					,'rgba(144, 103, 167, 1.0)'
					,'lightgrey', 1.0, "Retention Trend");
			</script>
			</div> <!-- end row line chart-->
		</div> <!-- end column for fund source -->
	</cfoutput> <!---- End Output of fcFundingSource --->
</cfloop> <!--- End Loop fcFundingSource --->


<!--- footer --->
<cfinclude template="includes/footer.cfm" />
