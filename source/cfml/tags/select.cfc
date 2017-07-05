component {
	this.QUERY_POSITION_ABOVE = 0;
	this.QUERY_POSITION_BELOW = 1;
	this.query=nullValue();
	this.selected=nullValue();
	this.value=nullValue();
	this.display=nullValue();
	this.passthrough=nullValue();
	this.nl = chr(10) & chr(13);

	this.attributes = {};

	public function init(required boolean hasEndTag, component parent) {
		variables.hasEndTag = arguments.hasEndTag;
		variables.parent = arguments.parent;
	}

	public boolean function onStartTag( struct attributes, struct caller ){
		this.attributes = attributes;
		attributes.query = caller[attributes.query];
		if(!isNull(attributes.query)) {
			local.qMeta = getMetaData(attributes.query);
			local.colList = "";
			arrayEach(qMeta, function(itm, idx){colList=listAppend(colList, itm.name)});
			if(isNull(attributes.value))
				throw "if you have defined attribute query for tag select, you must also define attribute value";
			else if(!listFindNoCase(colList, attributes.value))
				throw "invalid value for attribute [value], there is no column in query with name [" & attributes.value & "]";

			if(!isNull(attributes.display) && !listFindNoCase(colList, attributes.display))
				throw "invalid value for attribute [display], there is no column in query with name [" & attributes.display & "]";

			if(!isNull(attributes.group) && !listFindNoCase(colList, attributes.group))
				throw "invalid value for attribute [group], there is no column in query with name [" & attributes.group & "]";

			if(structKeyExists(variables, "parent") && isInstanceOf(parent, "form")){
				tagDetails = {};
				structAppend(tagDetails, attributes, true);
				arrayAppend(parent.inputs,tagDetails);
			}else{
				throw "Tag cfselect must be inside a cfform tag";
			}

			checkAttributes();
			setAttributeDefaults();

			result = "";
			result &= "<select";

			for( attr in attributes ){
				if(listFindNoCase("name,id", attr))
					result &= " #attr#=""#attributes[attr]#""";
			}

			if(!isNull(attributes.passthrough))
				result &= " #attributes.passthrough#";
			result &= ">#this.nl#";

			if(!isNull(attributes.queryPosition) && lCase(attributes.queryPosition) == "above" ){
				result &= processQueryData(attributes);
			}

			getPageContext().forceWrite(result);
		}
		return variables.hasEndTag;
	}

	public boolean function onEndTag( struct attributes, struct caller, string generatedContent ){
		result = "";
		if(!isNull(attributes.queryPosition) && lCase(attributes.queryPosition) == "below" ){
			result &= processQueryData(attributes);
		}
		result &= "</select>";
		getPageContext().forceWrite(result);
		return false;
	}

	// Private functions
	private string function processQueryData(){
		local.res = "";
		local.attributes = duplicate(this.attributes);
		// write query options
		if(!isNull(attributes.query)){
			rowCount = attributes.query.recordCount;
			currentGroup = nullValue();
			hasDisplay = !isNull(attributes.display);
			hasGroup = !isNull(attributes.group);
			for(var i=1;i<=rowCount;i++){
				v = attributes.query[attributes.value][i];
				d = hasDisplay?attributes.query[attributes.display][i]:v;
				s = selected(v,attributes.selected, attributes.caseSensitive);
				if(hasGroup){
					tmp = attributes.query[attributes.group][i];
					if(isNull(currentGroup) || currentGroup != tmp){
						if(!isNull(currentGroup))
							local.res &= "</optgroup>#this.nl#";
						local.res &= "<optgroup label=""#tmp#"">#this.nl#";
						currentGroup=tmp;
					}
				}
				local.res &= "<option" & s & " value=""#v#"">" & d & "</option>#this.nl#";
			}
			if(hasGroup)local.res &= "</optgroup>#this.nl#";
		}
		return local.res;
	}

	private void function setAttributeDefaults(){
		local.attributes = duplicate(this.attributes);
		if(isNull(attributes.queryPosition) || !len(attributes. queryPosition))
			attributes.queryPosition = "above";
		if(isNull(attributes.selected))
			attributes.selected = "";
		if(isNull(attributes.caseSensitive))
			attributes.caseSensitive = false;

		structAppend(this.attributes, local.attributes, true);
	}


	private void function checkAttributes(){
        variables.attributesList = "class,style,id,multiple,name,size,tabindex,title,dir,lang,onblur,onchange,onclick,ondblclick,onmousedown,onmouseup,onmouseover,onmousemove,onmouseout,onkeypress,onkeydown,onkeyup,onfocus,message,onerror,required,passthrough,query,display,dataformatas,datafld,datasrc,disabled,disabled,selected,value,group,height,label,queryposition,tooltip,visible,width,enabled,casesensitive";

        if( len(this.attributes.name) && reFindNoCase("[^a-zA-Z0-9-_:.]+", this.attributes.name) )
        throw "value of attribute name [" & this.attributes.name & "] is invalid, only the following characters are allowed [a-z,A-Z,0-9,-,_,:,.]";

        for(attr in this.attributes){
            if(!listFindNoCase(attributesList, attr)){
                throw "invalid #attr# for cfselect tag";
            }
            if(listFindNoCase("required,disabled,editable,visible,caseSensitive", attr)){
                if(!isBoolean(this.attributes[attr]) && len(this.attributes[attr]))
					throw "value of attribute #attr# must be boolean";
            }else if(listFindNoCase("size,height,width", attr)){
                if(!isnumeric(this.attributes[attr]))
                    throw "value of attribute #attr# must be numeric";
            }
        }
        if(structKeyExists(this.attributes, "queryPosition") && len(this.attributes.queryPosition))
            if(!listFindNoCase("above,below", this.attributes.queryPosition)){
                throw "attribute queryPosition for tag select has an invalid value #this.attributes.queryPosition#,
				valid values are [above, below]";
        }
    }

	private string function selected(string str, string sel, boolean caseSensitive) {
		if(!isNull(sel)) {
			for(var i=1;i<=listLen(sel);i++) {
				if(caseSensitive) {
					if(str.toString() == listGetAt(sel, i).toString())
						return " selected";
				}
				else {
					if(lCase(str.toString()) == lCase(listGetAt(sel, i).toString()))
						return " selected";
				}
			}
		}
		return "";
	}
}