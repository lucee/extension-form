component{
	this.metadata.attributetype="fixed";
	this.metadata.hint="Builds a form with CFML custom control tags that provide more functionality than standard HTML form input elements (XML and Flash type not supported).";

	this.metadata.attributes={
		name: "",
		action: "",
		method: "get"
	};

	this.FORMAT_HTML = 0;
    this.FORMAT_FLASH = 1;
    this.FORMAT_XML = 2;
	this.DEFAULT_ARCHIVE = "/lucee/formtag-applet.cfm";
	this.DEFAULT_FORM = "/lucee/formtag-form.cfm";
	this.WMODE_WINDOW = 0;
	this.WMODE_TRANSPARENT = 1;
	this.WMODE_OPAQUE = 2;
	this.nl = chr(10) & chr(13);

	/**
	* invoked after tag is constructed
	* @parent the parent cfc custom tag, if there is one
	* */

	public function init(required boolean hasEndTag, component parent) {
		variables.hasEndTag = arguments.hasEndTag;
		setOptionVars();
	};

	public boolean function onStartTag( struct attributes, struct caller ){
		writeDump("From Start");
		writeDump(arguments);
		contextPath = getPageContext().getHttpServletRequest().getContextPath();
		if(isNull(contextPath))
			contextPath = "";
		if(isNull(attributes.archive))
			attributes.archive = contextPath & this.DEFAULT_ARCHIVE;

		local.count = CreateUniqueId();

		if(isNull(attributes.name))
			attributes.name="CFForm_" & count;
		if(isNull(attributes.action))
			attributes.action="";
		attributes.name = trim(attributes.name);

		suffix = len(attributes.name)?"" & count:attributes.name;

		funcName="lucee_form_" & count;
		
		checkName="_CF_check" & suffix;
		resetName="_CF_reset" & suffix;
		loadName="_CF_load" & suffix;

		//boolean hasListener=false;
		if(isNull(attributes.onsubmit))
			attributes.onsubmit = "return " & funcName & ".check();";
		else
			attributes.onsubmit = "return " & checkName & "();";

		if(!isNull(attributes.onreset))
			attributes.onreset = "return " & resetName & "();";

		if(!isNull(attributes.onload))
			attributes.onload = "return " & loadName & "();";

		if(isNull(attributes.scriptSrc))
			attributes.scriptSrc = contextPath & this.DEFAULT_FORM;
		
		result = "";
		result &= "<script language=""JavaScript"" type=""text/javascript"" src=""#attributes.scriptSrc#""></script>#this.nl#";
		result &= "<script language = ""JavaScript"" type=""text/javascript"">#this.nl#";

		if(!isNull(attributes.onsubmit))
			result &= "function " & checkName & "() { if(" & funcName & ".check()){" & attributes.onsubmit & "return true;}else {return false;}}#this.nl#";
		else
			result &= "function " & checkName & "() { return " & funcName & ".check();}#this.nl#";

		if(!isNull(attributes.onreset))
			result &= "function " & resetName & "() {" & onreset & "}#this.nl#";
		if(!isNull(attributes.onload))
			result &= "function " & loadName & "() {" & onload & "}#this.nl#";
		result &= "#this.nl#</script>";

		result &= "<form";

		for( attr in attributes )
			result &= " #attr#=""#attributes[attr]#""";

		if(!isNull(attributes.passthrough))
            result &= " #passthrough#";

		result &= ">";

		// writeDump(result);abort;
		getPageContext().forceWrite(result);

		return variables.hasEndTag;
	}

	public boolean function onEndTag( struct attributes, struct caller, string generatedContent ){
		// writeDump("From End");
		// writeDump(arguments);
		return false;
	}

	// Private functions
	private void function setOptionVars(){
		variables.stOptions = {
			action: "",
			method: "get"
		};
	}

	private void function setDefaultValues(struct attributes){
		if (!structKeyExists(arguments.attributes, "action")) {
			arguments.attributes.action = "";
		};
		if (!structKeyExists(arguments.attributes, "method")) {
			arguments.attributes.method = "get";
		};
	}

}