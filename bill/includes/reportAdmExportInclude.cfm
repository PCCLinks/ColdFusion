<cfset data = Session.admReport>

<!--- TAB BY Program --->
<cfquery name="programs" dbtype="query">
	select upper(program) as Program, schooldistrict
	from data
	group by program, schooldistrict
	order by program, schooldistrict
</cfquery>

<cfset isHillsboro = false>
<cfif data.schooldistrict EQ 'Hillsboro'>
	<cfset isHillsboro = true>
</cfif>

<cfset rowHeight = 20>
<cfset filename="#programs.schooldistrict# #DateFormat(data.beginDate,'mmmm')# #DateFormat(data.beginDate,'yyyy')#.xlsx">
<cfheader name="Content-Disposition" value="attachment; filename=""#filename#""" >

<cfset i = 1>
<cfloop query="programs">
	<cfset tabName = replace(replace(programs.program, 'ATTENDANCE', 'GED'),'YTC', 'YtC')>
	<cfif i EQ 1>
		<cfset ss = spreadsheetNew("#tabName#", "true")>
	<cfelse>
		<cfset SpreadsheetCreateSheet(ss, "#tabName#")>
		<cfset SpreadsheetSetActiveSheet(ss, "#tabName#") >
	</cfif>
	<cfquery name="students" dbtype="query">
		select *
		from data
		where UPPER(program) = '#programs.program#'
		order by lastname, firstname
	</cfquery>
	<cfset rownum = 1>
	<cfset SpreadsheetAddRow(ss, "#programs.schooldistrict# School District")>
	<cfset SpreadsheetMergeCells(ss, rownum, 1, rownum, 8) >
	<cfset spreadsheetFormatRow(ss, {bold=true,alignment="center",font="Calibri",fontsize="11"}, rownum)>
	<cfset SpreadsheetSetRowHeight(ss, rownum, rowHeight)>

	<cfset rownum = 2>
	<cfset SpreadsheetAddRow(ss, "Attendance Report--#DateFormat(data.beginDate,'mmmm')# #DateFormat(data.beginDate,'d')# - #DateFormat(data.endDate,'mmmm d yyyy')# Totals")>
	<cfset SpreadsheetMergeCells(ss, rownum, rownum, 1, 8) >
	<cfset spreadsheetFormatRow(ss, {bold=true,alignment="center",font="Calibri",fontsize="11"}, rownum)>
	<cfset SpreadsheetSetRowHeight(ss, rownum, rowHeight)>
	<cfset SpreadsheetAddRow(ss, "All Students Enrolled at PCC/#tabName#")>

	<cfset rownum = 3>
	<cfset SpreadsheetMergeCells(ss, rownum, rownum, 1, 8) >
	<cfset spreadsheetFormatRow(ss, {bold=true,alignment="center",font="Calibri",fontsize="11"}, rownum)>
	<cfset SpreadsheetSetRowHeight(ss, rownum, rowHeight)>

	<cfset rownum = 4>
	<cfset SpreadsheetAddRow(ss, "Last Name, First Name, Entry Date, Exit Date, Large Grp., Inter. Grp., Small Grp., Tutorial")>
	<cfset maxCol = 8>
	<cfif programs.program EQ 'YTC ELL ATTENDANCE' AND programs.schooldistrict EQ 'Hillsboro'>
		<cfset SpreadsheetAddColumn(ss, "Days Present", rownum, 9, false)>
		<cfset SpreadsheetAddColumn(ss, "Days Absent", rownum, 10, false)>
		<cfset maxCol = 10>
	</cfif>
	<cfset spreadsheetFormatCellRange(ss, {bottomborder="thin",leftborder="thin", rightborder="thin", topborder="thin", fgcolor="grey_25_percent",font="Arial",fontsize="10"}, rownum,1,rownum,maxCol)>
	<cfset SpreadsheetSetRowHeight(ss, rownum, rowHeight)>

	<cfset rowNum = 5>
	<cfloop query="students">
		<cfset SpreadsheetAddRow(ss, "#lastname#, #firstname#, #entrydate#, #exitdate#, #LargeGrp#, #InterGrp#, #SmallGrp#, #Tutorial#")>
		<cfif programs.program EQ 'YTC ELL ATTENDANCE' AND programs.schooldistrict EQ 'Hillsboro'>
			<cfset SpreadsheetAddColumn(ss, "#DaysPresent#", rownum, 9, false)>
			<cfset SpreadsheetAddColumn(ss, "#DaysAbsent#", rownum, 10, false)>
		</cfif>
		<cfset SpreadsheetFormatCellRange(ss, {font="Arial",fontsize="10"}, rowNum, 1, rowNum, 2)>
		<cfset SpreadsheetFormatCellRange(ss, {dataformat="m/d/yyyy",font="Arial",fontsize="10"}, rowNum, 3, rowNum, 4)>
		<cfset SpreadsheetFormatCellRange(ss, {dataformat="0.0",font="Arial",fontsize="10"}, rowNum, 5, rowNum, 7)>
		<cfif programs.program EQ 'YTC ELL ATTENDANCE' AND programs.schooldistrict EQ 'Hillsboro'>
			<cfset SpreadsheetFormatCellRange(ss, {dataformat="0",font="Arial",fontsize="10"}, rowNum, 9, rowNum, 10)>
		</cfif>
		<cfset SpreadsheetSetRowHeight(ss, rowNum, rowHeight)>
		<cfset rowNum = rowNum + 1>
	</cfloop>
	<cfset i = i + 1>
</cfloop>

<cfset bin = spreadsheetReadBinary(ss)>
<cfcontent type="application/vnd-ms.excel" variable="#bin#" reset="true">