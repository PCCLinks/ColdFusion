<cfset data = Session.attendanceEntryPrint>


<cfquery name="classes" dbtype="query">
	select crn, crse, subj, title
	from data
	group by crn, crse, subj, title
	order by crn
</cfquery>
<cfset ss = spreadsheetNew("true")>
<cfset filename="AttendanceEntry-#DateFormat(Now(), 'yyyy-mm-dd')#.xlsx">
<cfheader name="Content-Disposition" value="attachment; filename=#filename#" >

<cfset SpreadsheetAddRow(ss, "#Session.attendanceEntryTitle#")>
<cfset SpreadsheetAddRow(ss, "")>
<cfset SpreadsheetAddRow(ss, "CRN, G,Firstname,Lastname, Attendance,Scheduled,Exclude Student,Exclude Class") >
<cfset spreadsheetFormatRow(ss, {bold=true}, 1)>
<cfset spreadsheetFormatRow(ss, {bold=true}, 3)>
<cfset rowNum = 4>
<cfoutput query="classes">
	<cfset SpreadsheetAddRow(ss, "#crn# #subj#: #crse# #title#") >
	<cfset spreadsheetFormatCell(ss, {bold=true, fgcolor="grey_25_percent" }, #rowNum#,1)>
	<cfset spreadsheetFormatCell(ss, {bold=true, fgcolor="grey_25_percent" }, #rowNum#,2)>
	<cfset spreadsheetFormatCell(ss, {bold=true, fgcolor="grey_25_percent" }, #rowNum#,3)>
	<cfset spreadsheetFormatCell(ss, {bold=true, fgcolor="grey_25_percent" }, #rowNum#,4)>
	<cfset spreadsheetFormatCell(ss, {bold=true, fgcolor="grey_25_percent" }, #rowNum#,5)>
	<cfset spreadsheetFormatCell(ss, {bold=true, fgcolor="grey_25_percent" }, #rowNum#,6)>
	<cfset spreadsheetFormatCell(ss, {bold=true, fgcolor="grey_25_percent" }, #rowNum#,7)>
	<cfset spreadsheetFormatCell(ss, {bold=true, fgcolor="grey_25_percent" }, #rowNum#,8)>
	<cfset rowNum = rowNum + 1>
		<!---><tr style="background-color:rgb(241,241,241)">
			<td >#crn# #subj#: #crse# #title#</td>
		</tr>--->
		<cfquery name="class" dbtype="query">
			select crn, crse, subj, title, bannergnumber, firstname, lastname, attendance, MaxPossibleAttendance, includestudent, includeclass
			from data
			where crn = '#classes.crn#'
		</cfquery>
		<cfloop query="class">
			<cfset SpreadsheetAddRow(ss, "#crn#,#bannerGNumber#,#firstname#,#lastname#,#attendance#,#MaxPossibleAttendance#,#includestudent#,#includeclass#")>
			<cfset rowNum = rowNum + 1>
		</cfloop>
</cfoutput>
<!---><cfspreadsheet action="write" filename="C:\Users\arlette.slachmuylder\Downloads\test.xlsx" name="ss"  sheet=1 sheetname="courses" overwrite=true>
--->


<cfset bin = spreadsheetReadBinary(ss)>
<cfcontent type="application/vnd-ms.excel" variable="#bin#" reset="true">






