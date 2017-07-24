component{

	this.attributes = {};
	this.inputs = [];
	this.TYPE_TEXT= "text";
	this.TYPE_RADIO="radio";
	this.TYPE_CHECKBOX="checkbox";
	this.TYPE_PASSWORD="password";
	this.TYPE_BUTTON="button";
	this.TYPE_FILE="file";
	this.TYPE_HIDDEN="hidden";
	this.TYPE_IMAGE="image";
	this.TYPE_RESET="reset";
	this.TYPE_SUBMIT="submit";
	this.TYPE_DATEFIELD="datefield";

	this.VALIDATE_DATE="date";
	this.VALIDATE_EURODATE="eurodate";
	this.VALIDATE_TIME="time";
	this.VALIDATE_CREDITCARD="creditcard";
	this.VALIDATE_FLOAT="float";
	this.VALIDATE_INTEGER="integer";
	this.VALIDATE_TELEPHONE="telephone";
	this.VALIDATE_ZIPCODE="zipcode";
	this.VALIDATE_SOCIAL_SECURITY_NUMBER="social_security_number";
	this.VALIDATE_REGULAR_EXPRESSION="regular_expression";

	this.VALIDATE_USDATE="usdate";
	this.VALIDATE_RANGE="range";
	this.VALIDATE_BOOLEAN="boolean";
	this.VALIDATE_EMAIL="email";
	this.VALIDATE_URL="url";
	this.VALIDATE_UUID="uuid";
	this.VALIDATE_GUID="guid";
	this.VALIDATE_MAXLENGTH="maxlength";
	this.VALIDATE_NOBLANKS="noblanks";
	this.nl = chr(10) & chr(13);

	this.DAYNAMES_DEFAULT = "S,M,T,W,Th,F,S";
	this.MONTHNAMES_DEFAULT = "January,February,March,April,May,June,July,August,September,October,November,December";

	public function init(required boolean hasEndTag, component parent) {
		variables.hasEndTag = arguments.hasEndTag;
		variables.parent = arguments.parent;
	};

	public void function onEndTag( struct attributes) {
		this.attributes = attributes;
		param name="attributes.validate" default="";
		param name="attributes.pattern" default="";
		checkAttributes();
		setAttributeDefaults();

		if(len(attributes.validate)){
			if(attributes.validate == this.VALIDATE_REGULAR_EXPRESSION && isnull(attributes.pattern)){
				throw "when validation type regular_expression is seleted, the pattern attribute is required";
			}
		}
		if(len(attributes.range)){
			range = this.attributes.range
			rangeMatch = REMatch("^[0-9]*(\,([0-9])*)*$", attributes.range);
			if(!arrayLen(rangeMatch)){
				throw "attribute range has an invalid value [" & attributes.range & "], must be string list with numbers, Example: [number_from,number_to], [number_from], [number_from,], [,number_to]";
			}
			range = this.attributes.range;
			arr = listToArray(range, "");
			if(listLen(range) == 1){
				if(arr[1] == ","){
					this.attributes.minimum = 0;
					this.attributes.maximum = listFirst(range);
				} else{
					this.attributes.minimum = listFirst(range);
					this.attributes.maximum = 0;
				}
			}
			else{
				this.attributes.minimum = listFirst(range);
				this.attributes.maximum = listLast(range);
			}
		}

		if(len(attributes.dayNames)){
			if(ListFindNoCase(this.DAYNAMES_DEFAULT,attributes.dayNames) EQ 0){
				throw "value of attribute [daynames] must contain a string list with 7 values, now there are [" & this.DAYNAMES_DEFAULT &"]  values";
			} else{
				this.DAYNAMES_DEFAULT = duplicate(attributes.dayNames);
			}
		}

		if(len(attributes.monthNames)){
			if(ListFindNoCase(this.MONTHNAMES_DEFAULT,attributes.monthNames) EQ 0){
				throw "value of attribute [MonthNames] must contain a string list with 12 values, now there are  [" & this.MONTHNAMES_DEFAULT &"] values";
			} else{
				this.MONTHNAMES_DEFAULT = duplicate(attributes.monthNames);
			}
		}
		if(len(attributes.firstDayOfWeek)){
			if(attributes.firstDayOfWeek<0 || attributes.firstDayOfWeek>6){
				throw "value of attribute [firstDayOfWeek] must conatin a numeric value between 0-6";
			}
		}

		validAttribute ="creditcard,date,eurodate,integer,float,regular,social_security_number,telephone,time,zipcode";
		if(len(this.attributes.validate)){
			if(validAttribute.findNoCase(this.attributes.validate) EQ 0){
				throw "attribute validate has an invalid value [" & this.attributes.validate & "] valid values for attribute validate are [creditcard, date, eurodate, float, integer, regular, social_security_number, telephone, time, zipcode]"; 
			}
		}

		if(IsInstanceOf(variables.parent,"Form")) {
			variables.parent.setInput(this);
			if(attributes.type == "datefield" && variables.parent.attributes.FORMAT_FLASH != "parent.FORMAT_FLASH"){
				throw "type [datefield] is only allowed if form format is flash";
			}
		} else {
			throw "Tag must be inside a form tag" ;
		}

		result = "";
		result &= "<script language = ""JavaScript"" type=""text/javascript"">#this.nl#";
		result &= "#this.nl#</script>";
		result &= "<input";

		for( attr in attributes )
			result &= " #attr#=""#attributes[attr]#""";

		if(!isNull(attributes.passthrough))
			result &= " #passthrough#";
		result &= ">";
		getPageContext().forceWrite(result);
	}

	private void function checkAttributes(){
		variables.attributesList = "class,style,id,accept,accesskey,align,alt,autocomplete,autofocus,border,datafld,datasrc,form,formaction,formenctype,formmethod,formnovalidate,formtarget,lang,list,dir,dataformatas,disabled,enabled,ismap,readonly,usemap,onblur,onchange,onclick,ondblclick,onfocus,onkeydown,onkeypress,onkeyup,onmousedown,onmousemove,onmouseup,onselect,onmouseout,onmouseover,tabindex,title,value,size,maxlength,checked,daynames,firstdayofweek,monthnames,label,mask,max,min,multiple,placeholder,notab,hspace,type,onerror,onvalidate,passthrough,pattern,range,required,name,message,monthnames,height,input,passthrough,tooltip,validateat,visible,width,validate";

		variables.attributesNotSupported = "autosuggest,autosuggestBindDelay,autosuggestMinLength,bind,bindAttribute,bindOnLoad,delimiter,maxResultsDisplayed,onBindError,showAutosuggestLoadingIcon,sourceForTooltip,typeahead";

		if( len(this.attributes.name) && reFindNoCase("[^a-zA-Z0-9-_:.]+", this.attributes.name) )
		throw "value of attribute name [" & this.attributes.name & "] is invalid, only the following characters are allowed [a-z,A-Z,0-9,-,_,:,.]";

		for(attr in this.attributes){
			if(!listFindNoCase(attributesList, attr)){
				throw "invalid #attr# for cfinput tag";
			}
			else if(listFindNoCase(attributesNotSupported, attr)){
				throw "attribute #attr# is not supported";
			}

			if(listFindNoCase("required,visible,bindOnLoad,showAutosuggestLoadingIcon,typeahead", attr)){
			   if(!isBoolean(this.attributes[attr]) && len(this.attributes[attr]))
					throw "value of attribute #attr# must be boolean";
			}

			if(listFindNoCase("autosuggestBindDelay,autosuggestMinLength,maxResultsDisplayed,maxLength,firstDayOfWeek", attr)){
				if(!isnumeric(this.attributes[attr]))
					throw "value of attribute #attr# must be numeric";
			}
		}
	}

	private void function setAttributeDefaults(){
		local.attributes = duplicate(this.attributes);

		if(attributes.validate == "regex")
		   attributes.validate = "regular_expression";
		if(attributes.validate == "numeric")
		   attributes.validate = "float";
		if(attributes.validate == "integer")
		   attributes.validate = "int";
		if(attributes.validate == "phone")
		   attributes.validate = "telephone";
		if(attributes.validate == "zip")
		   attributes.validate = "zipcode";
		if(attributes.validate == "ssn")
		   attributes.validate = "social_security_number";
		
		if(isNull(attributes.name))
			attributes.name = "";
		if(isNull(attributes.type))
			attributes.type = "text";
		if(isNull(attributes.value))
			attributes.value = "";
		if(isNull(attributes.validate))
			attributes.validate = "";
		if(isNull(attributes.pattern)) 
			attributes.pattern = "";
		if(isNull(attributes.dayNames))
			attributes.dayNames = "";
		if(isNull(attributes.monthNames))
			attributes.monthNames = ""; 
		if(isNull(attributes.firstDayOfWeek))
			attributes.firstDayOfWeek = ""; 
		if(isNull(attributes.range))
			attributes.range = "";
		structAppend(this.attributes, local.attributes, true);
	}
}



