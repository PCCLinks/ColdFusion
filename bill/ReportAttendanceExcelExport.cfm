
<cfset data = Session.reportAttendanceData>
<cfset ss = spreadsheetNew("true")>
<cfset filename="AttendanceEntry-#data.schooldistrict#-#DateFormat(Now(), 'yyyy-mm-dd')#.xlsx">

<cfset l = "All Students at">
<cfif data.Program EQ "gtc">
	<cfset l = l & "PCC/HSC">
<cfelse>
	<cfset l = l & "#data.Program#">
</cfif>
<cfset l = l & "Between #data.ReportStartDate# and #data.ReportEndDate#" >

<cfheader name="Content-Disposition" value="attachment; filename=#filename#" >

<cfset lastcol = 15>
<cfset rownum=1>
<cfset SpreadsheetMergeCells(ss, rownum, rownum, 1, 6)>
<cfset SpreadsheetMergeCells(ss, rownum, rownum, 7, lastcol)>
<cfset SpreadsheetAddColumn(ss, "#data.schooldistrict#",rownum,1,false)>
<cfset SpreadsheetAddColumn(ss, "Alternative Education Program", rownum, 7, false)>
<cfset SpreadsheetFormatCellRange(ss, {bold=true, bottomBorder="thin", fontsize=8}, rownum,1,rownum,lastcol)>
<cfset rownum=rownum+1>

<cfset SpreadsheetAddRow(ss, "")>
<cfset rownum=rownum+1>
<cfset SpreadsheetMergeCells(ss, rownum, rownum, 1, lastcol)>
<cfset SpreadsheetAddColumn(ss, "Monthly Attendance And Days Enrolled - Public School Days", rownum, 1, false)>
<cfset SpreadsheetFormatCellRange(ss, {bold=true, fontsize=16}, rownum,1,rownum,lastcol)>
<cfset rownum=rownum+1>
<cfset SpreadsheetMergeCells(ss, rownum, rownum, 1, lastcol)>
<cfset SpreadsheetAddColumn(ss, "#l#",rownum,1,false)>
<cfset SpreadsheetFormatCellRange(ss, {bold=true}, rownum,1,rownum,lastcol)>
<cfset rownum=rownum+1>
<cfset SpreadsheetAddRow(ss, "")>
<cfset rownum=rownum+1>

<cfset SpreadsheetAddRow(ss, "Student,,,,,,,DOB,,Entry Date,,Exit Date") >
<cfset SpreadsheetFormatCellRange(ss, {bold=true}, rownum,1,rownum,lastcol)>
<cfset rownum=rownum+1>
<cfset SpreadsheetAddRow(ss, ",Jun, Jul, Aug, Sept, Oct, Nov, Dec, Jan, Feb, Mar, Apr, May, Attend, Enrl") >
<cfset SpreadsheetFormatCellRange(ss, {bold=true}, rownum,1,rownum,lastcol)>
<cfset rownum=rownum+1>
<!---><cfset spreadsheetFormatRow(ss, {bold=true, bottomBorder="thick"}, 3)>--->
<cfset SpreadsheetAddRow(ss, "No Plan Assigned")>
<cfset SpreadsheetFormatCellRange(ss, {bold=true}, rownum,1,rownum,lastcol)>
<cfset rownum=rownum+1>

<cfoutput query="data">
	<cfset SpreadsheetMergeCells(ss, rownum, rownum, 8, 9)>
	<cfset SpreadsheetMergeCells(ss, rownum, rownum, 10, 11)>
	<cfset SpreadsheetMergeCells(ss, rownum, rownum, 12, 13)>
	<cfset SpreadsheetAddColumn(ss, "'#name#'",rownum,1,false)>
	<cfset SpreadsheetAddColumn(ss, "#DateFormat(dob,'m/d/y')#",rownum, 8, false)>
	<cfset SpreadsheetAddColumn(ss, "#DateFormat(enrolleddate,'m/d/y')#",rownum,10, false)>
	<cfset SpreadsheetAddColumn(ss, "#DateFormat(exitdate,'m/d/y')#",rownum,12, false)>
	<cfset rownum=rownum+1>

	<cfset SpreadsheetAddRow(ss, ",#Jun#, #Jul#, #Aug#, #Sept#, #Oct#, #Nov#, #Dcm#, #Jan#, #Feb#, #Mar#, #Apr#, #May#, #Attnd#, #Enrl#") >
	<cfset rownum = rownum+1>
</cfoutput>
<cfquery dbtype="query" name="totals">
		select count(*) cnt, sum(Jun) Jun, sum(Jul) Jul, sum(Aug) Aug,
			sum(Sept) Sept, sum(Oct) Oct, sum(Nov) Nov, sum(Dcm) Dcm,
			sum(Jan) Jan, sum(Feb) Feb, sum(Mar) Mar, sum(Apr) Apr,
			sum(May) May,
			sum(attnd) Attnd, sum(enrl) enrl
		from data
</cfquery>
<cfoutput query="totals">
	<cfset SpreadsheetAddRow(ss, "Total, #cnt#, #Jun#, #Jul#, #Aug#, #Sept#, #Oct#, #Nov#, #Dcm#, #Jan#, #Feb#, #Mar#, #Apr#, #May#, #Attnd#, #Enrl#") >
</cfoutput>


<cfset bin = spreadsheetReadBinary(ss)>
<cfcontent type="application/vnd-ms.excel" variable="#bin#" reset="true">

