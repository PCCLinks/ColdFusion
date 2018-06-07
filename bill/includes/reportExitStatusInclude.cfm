<cfset data = Session.exitStatusReport>

<cfset isHillsboro = false>
<cfif data.schooldistrict EQ 'Hillsboro'>
	<cfset isHillsboro = true>
</cfif>

<!--- set up for different district requirements --->
<cfif isHillsboro>
	<cfset columns = "Last Name, First Name, Gender, Ethnicity, DOB, Grade, Entry Date, Exit Date, Exit Status">
	<cfset colfirst = 1>
	<cfset collast = 2>
	<cfset colgender = 3>
	<cfset colethnicity = 4>
	<cfset coldob = 5>
	<cfset colgrade = 6>
	<cfset colentry = 7>
	<cfset colexit = 8>
	<cfset colexitreason = 9>
<cfelse>
	<cfset columns = "Last Name, First Name, DOB, Grade, Entry Date, Exit Date, Exit Status">
	<cfset collast = 1>
	<cfset colfirst = 2>
	<cfset coldob = 3>
	<cfset colgrade = 4>
	<cfset colentry = 5>
	<cfset colexit = 6>
	<cfset colexitreason = 7>
</cfif>


<!--- TAB BY Program --->
<cfquery name="programs" dbtype="query">
	select upper(program) as Program, schooldistrict
	from data
	group by program, schooldistrict
	order by program, schooldistrict
</cfquery>

<cfset rowHeight = 20>
<cfset filename="#programs.schooldistrict# exit status #DateFormat(data.billingStartDate,'mmmm')# #DateFormat(data.billingStartDate,'yyyy')#.xlsx">
<cfheader name="Content-Disposition" value="attachment; filename=""#filename#""" >

<cfset i = 1>
<cfloop query="programs">
	<cfset tabName = replace(replace(replace(replace(programs.program, 'ATTENDANCE', 'GED'),'YTC', 'YtC'),'GtC', 'HSC'),'CREDIT', 'Credit')>
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

	<!--- Sheet heading --->
	<cfset SpreadsheetAddRow(ss, "#programs.schooldistrict# Exit Status #tabName# #DateFormat(data.billingStartDate,'mmmm')# #DateFormat(data.billingStartDate,'YYYY')#")>
	<cfset SpreadsheetMergeCells(ss, 1, 1, 1, colexitreason) >
	<cfset spreadsheetFormatRow(ss, {bold=true,alignment="center",font="Calibri",fontsize="20", italic=true }, 1)>
	<cfset SpreadsheetSetRowHeight(ss, 1, 30)>

	<!--- column headers --->
	<cfset SpreadsheetAddRow(ss, columns)>
	<cfset spreadsheetFormatCellRange(ss, {bottomborder="thin",leftborder="thin", rightborder="thin", topborder="thin", fgcolor="grey_25_percent",font="Arial",fontsize="10"}, 2,1,2,colexitreason)>
	<cfset SpreadsheetSetRowHeight(ss, 2, rowHeight)>

	<cfset rowNum = 3>
	<cfloop query="students">
		<cfif isHillsboro>
			<cfset SpreadsheetAddRow(ss, "#lastname#, #firstname#, #gender#, #ethnicity#, #DOB#, #Grade#, #EntryDate#, #ExitDate#, #ExitReason#")>
			<!--- gender --->
			<cfset SpreadsheetFormatCell(ss, {dataformat="0",font="Arial",fontsize="10", alignment="center"}, rowNum, colgender)>
			<!--- ethnicity --->
			<cfset SpreadsheetFormatCell(ss, {font="Arial",fontsize="10"}, rowNum, colethnicity)>
		<cfelse>
			<cfset SpreadsheetAddRow(ss, "#lastname#, #firstname#, #DOB#, #Grade#, #EntryDate#, #ExitDate#, #ExitReason#")>
		</cfif>
		<!--- lastname, firstname --->
		<cfset SpreadsheetFormatCellRange(ss, {font="Arial",fontsize="10"}, rowNum, collast, rowNum, colfirst)>
		<!--- dob --->
		<cfset SpreadsheetFormatCell(ss, {dataformat="m/d/yyyy",font="Arial",fontsize="10"}, rowNum, coldob)>
		<!--- grade --->
		<cfset SpreadsheetFormatCell(ss, {dataformat="0",font="Arial",fontsize="10", alignment="center"}, rowNum, colgrade)>
		<!--- entry date, exit date --->
		<cfset SpreadsheetFormatCellRange(ss, {dataformat="m/d/yyyy",font="Arial",fontsize="10"}, rowNum, colentry, rowNum, colexit)>
		<!--- exit reason --->
		<cfset SpreadsheetFormatCell(ss, {dataformat="0",font="Arial",fontsize="10", alignment="center"}, rowNum, colexitreason)>
		<cfset SpreadsheetSetRowHeight(ss, rowNum, rowHeight)>
		<cfset rowNum = rowNum + 1>
	</cfloop>
	<cfset i = i + 1>
</cfloop>

<cfset bin = spreadsheetReadBinary(ss)>
<cfcontent type="application/vnd-ms.excel" variable="#bin#" reset="true">