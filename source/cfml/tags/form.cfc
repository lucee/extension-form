component {
	this.metadata.attributetype="fixed";
	this.metadata.hint="Builds a form with CFML custom control tags that provide more functionality than standard HTML form input elements (XML and Flash type not supported).";

	this.metadata.attributes={
		name: "",
		action: "",
		method: "get",
		format: "html",
		onmouseover: ""
	};

	this.FORMAT_HTML = "html";
	this.FORMAT_FLASH = "flash";
	this.FORMAT_XML = "xml";
	this.DEFAULT_ARCHIVE = "/lucee/formtag-applet.cfm";
	this.DEFAULT_FORM = "/lucee/formtag-form.cfm";
	this.WMODE_WINDOW = "window";
	this.WMODE_TRANSPARENT = "transparent";
	this.WMODE_OPAQUE = "opaque";
	this.inputs = [];
	this.attributes = {};
	this.nl = chr(10) & chr(13);

	/**
	* invoked after tag is constructed
	* @parent the parent cfc custom tag, if there is one
	* */
	public function init(required boolean hasEndTag, component parent) {
		variables.hasEndTag = arguments.hasEndTag;
	}

	public boolean function onStartTag( struct attributes, struct caller ){
		this.attributes = attributes;
		setAttributeDefaults();
		checkAttributes();

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

		getPageContext().forceWrite(result);

		return variables.hasEndTag;
	}

	public boolean function onEndTag( struct attributes, struct caller, string generatedContent ){
		getPageContext().forceWrite(generatedContent);
		return false;
	}

	// Private functions
	private void function checkAttributes(){
		if(!"xml,html,flash".findNoCase(this.attributes.format))
			throw "invalid value [" & this.attributes.format & "] for attribute format, for this attribute only the following values are supported " & "[xml, html, flash]";
		else if(lcase(this.attributes.format)!=this.FORMAT_HTML)
			throw "format [" & this.attributes.format & "] is not supported, only the following formats are supported [html]";

		if( len(this.attributes.name) && reFindNoCase("[^a-zA-Z0-9-_:.]+", this.attributes.name) )
			throw "value of attribute name [" & this.attributes.name & "] is invalid, only the following characters are allowed [a-z,A-Z,0-9,-,_,:,.]";

		if(!isNull(this.attributes.preserveData))
			throw "attribute preserveData for tag form is not supported at the moment";

		if(!"window,transparent,opaque".findNoCase(this.attributes.wmode))
			throw "invalid value [" & this.attributes.wmode & "] for attribute wmode, for this attribute only the following values are supported " & "[window, transparent, opaque]";
	}

	private void function setAttributeDefaults(){
		local.attributes = duplicate(this.attributes);
		if(isNull(attributes.action))
			attributes.action = "";
		if(isNull(attributes.method))
			attributes.method = "get";
		if(isNull(attributes.format))
			attributes.format = "html";
		if(isNull(attributes.name))
			attributes.name = "";
		if(isNull(attributes.wmode))
			attributes.wmode = "window";
		if(isNull(attributes.FORMAT_FLASH))
			attributes.FORMAT_FLASH = "flash";
		

		structAppend(this.attributes, local.attributes, true);
	}

	package void function setInput(input inp){
		arrayAppend(this.inputs,inp);
	}
}