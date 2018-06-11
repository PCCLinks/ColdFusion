<!--- called by student.cfm as a cfinclude --->



<style>
	.top-bar img { height: 75px; position:relative; width: 150px; background:#e6e6e6; }
	.highlight { background-color:rgb(255, 255, 128) !important; }
</style>


<div class="row">
		<div class="small-6 columns">
			<div class="card">
				<div class="card-divider">
					GPA
				</div>
				<canvas id="graphGPA">
				</canvas>
			</div>
		</div>
		<div class="small-6 columns">
			<div class="card">
				<div class="card-divider">
					CREDITS EARNED
				</div>
				<canvas id="graphCreditsEarned">
				</canvas>
			</div>
		</div>
</div>
<!-- end row -->
<br class="clear" />
<table id="dt_table_studentdashboard" cellspacing="1" width="95%" class="unstriped compact" ;>
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
	</tbody>
</table>




