<cfinclude template="includes/header.cfm">


<cfset error = "Undefined">
<cfif StructKeyExists(Session, "Error")>
	<cfset error = Session.Error>
</cfif>
<cfif StructKeyExists(Form, "Error")>
	<cfset error = UrlDecode(Form.Error)>
</cfif>

<div class="callout warning">
<h5>Unexpected Error in the application. This error has been logged and IT staff notified.</h5>
</div>
<p>Error:</p>
<cfoutput>#error#</cfoutput>

<ul class="accordion" data-accordion data-allow-all-closed="true">
	<cfif StructKeyExists(Session, "exception") >
 	<li class="accordion-item" data-accordion-item>
    	<a href="#Exception" class="accordion-title">Exception</a>
 		<div class="accordion-content" data-tab-content>
			<cfdump var="#Session.exception#" label="Exception">
		</div>
	</li>
	</cfif>
	<cfif StructKeyExists(Session, "thrownError") >
 		<li class="accordion-item is-active" data-accordion-item>
    	<a href="#" class="accordion-title">Thrown Error</a>
 		<div class="accordion-content" data-tab-content>
      		<cfdump var="#Session.thrownError#" label="ThrownError">
		</div>
	</li>
	</cfif>
	<li class="accordion-item" data-accordion-item>
    	<a href="#Session" class="accordion-title">Session</a>
 		<div class="accordion-content" data-tab-content>
			<cfdump var="#Session#" label="Session">
		</div>
	</li>
	<li class="accordion-item" data-accordion-item>
    	<a href="#URL" class="accordion-title">URL</a>
 		<div class="accordion-content" data-tab-content>
			<cfdump var="#url#" label="URL">
		</div>
	</li>
</ul>


<cfinclude template="includes/footer.cfm">