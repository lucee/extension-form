<cfset qTest = queryNew("ID,Name,Company")>
<cfset queryAddRow(qTest,1)>
<cfset querySetCell(qTest, "ID", 1)>
<cfset querySetCell(qTest, "Name", "Pothys")>
<cfset querySetCell(qTest, "Company", "Mitrahsoft-Emps")>
<cfset queryAddRow(qTest,1)>
<cfset querySetCell(qTest, "ID", 2)>
<cfset querySetCell(qTest, "Name", "Siva")>
<cfset querySetCell(qTest, "Company", "Mitrahsoft-Emps")>
<cfset queryAddRow(qTest,1)>
<cfset querySetCell(qTest, "ID", 2)>
<cfset querySetCell(qTest, "Name", "Saravana")>
<cfset querySetCell(qTest, "Company", "Mitrahsoft-CEO")>
<cf_form action="Test.cfm" method="POST">
	<!--- <cf_input name="inp1" type="text" value="Test"/> --->
	<cf_select name="Test" query="qTest" value="ID" display="Name" group="Company" selected="2">
	</cf_select>
</cf_form>