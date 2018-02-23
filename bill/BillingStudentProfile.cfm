<cfinclude template="includes/header.cfm">
<cfinvoke component="ProgramBilling" method="getBillingStudentProfile"  returnvariable="data">
	<cfinvokeargument name="contactId" value="#url.contactId#">
</cfinvoke>


<cfoutput query="data">
<div class="callout primary">Student Billing Profile for #firstname# #lastname# (#bannerGNumber#)</div>


<form id="formProfile" name="formProfile">
	<input type="hidden" id="contactID" name="contactId" value="#contactID#">
 <div class="row">
	 <div class="small-12 medium-4 columns">
	   <label for="bannerGNumber">
	     <span class="label required">G Number:</span>
	     <input name="bannerGNumber" type="text" id="bannerGNumber" readonly value="#bannerGNumber#" />
	   </label>
	 </div>
	 <div class="small-12 medium-4 columns">
	   <label for="firstname">
	     <span class="label required">First name:</span>
	     <input name="firstname" type="text" id="firstname" value="#firstname#"/>
	   </label>
	 </div>
	 <div class="small-12 medium-4 columns">
	   <label for="lastname">
	     <span class="label required">Last name:</span>
	     <input name="lastname" type="text" id="lastname" value="#lastname#"/>
	   </label>
	 </div>
</div> <!-- end row -->
 <div class="row">
	 <div class="small-12 medium-4 columns">
	   <label for="DOB">
	     <span class="label required">DOB:</span>
	     <input name="DOB" type="text" id="DOB" class="fdatepicker" value="#DOB#"/>
	   </label>
	 </div>
	 <div class="small-12 medium-4 columns">
	   <label for="gender">
	     <span class="label required">Gender:</span>
	     <select name="gender" id="gender" >
	     	<option value="1" <cfif gender EQ 1>selected</cfif>>Male</option>
	     	<option value="2" <cfif gender EQ 2>selected</cfif>>Female</option>
	     	<option value="0" <cfif gender EQ 0>selected</cfif>>Not Specified</option>
	     </select>
	   </label>
	 </div>
	 <div class="small-12 medium-4 columns">
	   <label for="ethnicity">
	     <span class="label required">Ethnicity:</span>
	     <select name="ethnicity" id="ethnicity" >
			<option value="African American"  <cfif ethnicity EQ "African American">selected</cfif>>African American</option>
	     	<option value="Asian American" <cfif ethnicity EQ 1>selected</cfif>>Asian American</option>
	     	<option value="European American" <cfif ethnicity EQ "Asian American">selected</cfif>>European American</option>
	     	<option value="Hispanic American" <cfif ethnicity EQ "European American">selected</cfif>>Hispanic American</option>
	     	<option value="Native American" <cfif ethnicity EQ "Hispanic American">selected</cfif>>Native American</option>
	     	<option value="Not Specified" <cfif ethnicity EQ "Not Specified">selected</cfif>>Not Specified</option>
	     </select>
	   </label>
	 </div>
</div> <!-- end row -->
 <div class="row">
	 <div class="small-12 medium-4 columns">
	   <label for="Address">
	     <span class="label required">Address:</span>
	     <input name="Address" type="text" id="Address" value="#Address#"/>
	   </label>
	 </div>
	 <div class="small-12 medium-4 columns">
	   <label for="city">
	     <span class="label required">City:</span>
	     <input name="City" type="text" id="City" value="#City#"/>
	   </label>
	 </div>
	 <div class="small-6 medium-2 columns">
	   <label for="state">
	     <span class="label required">State:</span>
	     <input name="state" type="text" id="state" value="#state#" />
	   </label>
	 </div>
	 <div class="small-6 medium-2 columns">
	   <label for="zip">
	     <span class="label required">Zip:</span>
	     <input name="zip" type="text" id="zip" value="#Zip#"/>
	   </label>
	 </div>
</div> <!-- end row -->
</form>


</cfoutput>

<cfsavecontent variable="pcc_scripts">
<script>
	var saveInterval = 1000*60*2;
   	var doSave = setInterval(saveContent, saveInterval);
	//save before leaving
   	$(window).bind('beforeunload', function(){
   		//debugger;
  		saveContent();
	});

	function saveContent(){
		//debugger;
		 $.ajax({
            type: 'post',
            url: 'programBilling.cfc?method=updateBillingStudentProfile',
            data: $("form").serialize(),
            error: function (xhr, textStatus, thrownError) {
				 handleAjaxError(xhr, textStatus, thrownError);
			}
          });
	}

</script>
</cfsavecontent>
<cfinclude template="includes/footer.cfm">