<cfset data = Session.attendanceEntryPrint>


<!--- TAB BY CRN --->
<cfquery name="classes" dbtype="query">
	select crn, crse, subj, title
	from data
	group by crn, crse, subj, title
	order by crn
</cfquery>

<cfset ss = spreadsheetNew("ByCRN", "true")>
<cfset filename="#Session.attendanceEntryTitle#.xlsx">
<cfheader name="Content-Disposition" value="attachment; filename=#filename#" >

<cfset SpreadsheetAddRow(ss, "#Session.attendanceEntryTitle#")>
<cfset SpreadsheetAddRow(ss, "CRN, G,Firstname,Lastname, Attendance,Scheduled,Exclude Student,Exclude Class") >
<cfset spreadsheetFormatRow(ss, {bold=true}, 1)>
<cfset spreadsheetFormatRow(ss, {bold=true}, 2)>
<cfset rowNum = 3>
<cfoutput query="classes">
	<cfset SpreadsheetAddRow(ss, "")>
	<cfset rowNum = rowNum + 1>
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
<!--- END Tab by CRN --->


<!--- TAB by Student --->

<cfquery name="districtprogram" dbtype="query">
	select schooldistrict, program
	from data
	group by schooldistrict, program
	order by schooldistrict, program
</cfquery>

<cfset SpreadsheetCreateSheet(ss, "ByStudent")>
<cfset SpreadsheetSetActiveSheet(ss, "ByStudent") >

<cfset SpreadsheetAddRow(ss, "#Session.attendanceEntryTitle#")>
<cfset SpreadsheetAddRow(ss, "")>
<cfset SpreadsheetAddRow(ss, "CRN, Subj,Crse,Title, Attendance,Scheduled,Exclude Class") >
<cfset spreadsheetFormatRow(ss, {bold=true}, 1)>
<cfset spreadsheetFormatRow(ss, {bold=true}, 3)>
<cfset rowNum = 4>
<cfset spreadsheetFormatRow(ss, {bold=true}, rowNum)>
<cfloop query="districtprogram" >
	<cfset SpreadsheetAddRow(ss, "#schooldistrict#-#program#") >
	<cfset SpreadsheetFormatCellRange(ss, {bold=true, fgcolor="grey_25_percent" }, #rowNum#,1,#rowNum#,4)>
	<cfset rowNum = rowNum + 1>
	<cfquery name="students" dbtype="query">
		select bannerGNumber, firstname, lastname, includestudent
		from data
		where schooldistrict = '#districtprogram.schooldistrict#'
			and program = '#districtprogram.program#'
		group by bannerGNumber, firstname, lastname, includestudent
		order by lastname
	</cfquery>
	<cfloop query="students">
		<cfset SpreadsheetAddRow(ss, "#bannerGNumber#, #firstname#, #lastname#, #includestudent#") >
		<cfset spreadsheetFormatCellRange(ss, {bold=true}, #rowNum#,1,#rowNum#,7)>
		<cfset rowNum = rowNum + 1>
		<cfquery name="studentclass" dbtype="query">
			select crn, crse, subj, title, attendance, MaxPossibleAttendance, includeclass
			from data
			where bannerGNumber = '#students.bannerGNumber#'
		</cfquery>
		<cfloop query="studentclass">
			<cfset SpreadsheetAddRow(ss, "#crn#, #subj#, #crse#, #title#, #attendance#, #MaxPossibleAttendance#, #includeclass#")>
			<cfset rowNum = rowNum + 1>
		</cfloop>
	</cfloop>
	<cfset SpreadsheetAddRow(ss, "")>
	<cfset rowNum = rowNum + 1>
</cfloop>

<cfset SpreadsheetCreateSheet(ss, "Data")>
<cfset SpreadsheetSetActiveSheet(ss, "Data") >


<cfset SpreadsheetAddRow(ss, "CRN,School District, Program, G,Firstname,Lastname, Attendance,Scheduled,Exclude Class") >
<cfset spreadsheetFormatRow(ss, {bold=true}, 1)>
<cfset spreadsheetFormatRow(ss, {bold=true}, 3)>
<cfset rowNum = 2>
<cfset spreadsheetFormatRow(ss, {bold=true}, rowNum)>
<cfoutput query="data">
	<cfset SpreadsheetAddRow(ss, "#crn#,#schooldistrict#,#program#,#bannerGNumber#,#firstname#,#lastname#,#attendance#,#MaxPossibleAttendance#,#includestudent#,#includeclass#")>
	<cfset rowNum = rowNum + 1>
</cfoutput>



<cfset SpreadsheetSetActiveSheet(ss, "ByCRN") >



<!---><cfspreadsheet action="write" filename="C:\Users\arlette.slachmuylder\Downloads\test.xlsx" name="ss"  sheet=1 sheetname="courses" overwrite=true>
--->


<cfset bin = spreadsheetReadBinary(ss)>
<cfcontent type="application/vnd-ms.excel" variable="#bin#" reset="true">






