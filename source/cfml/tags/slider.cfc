component {
	this.param = {};
	this.height = "height";
	this.width = "width";
	this.vspace = "vspace";
	this.hspace = "hspace";
	this.VALIDATE_RANGE="range";


	this.attributes = {};

	/**
	* invoked after tag is constructed
	* @parent the parent cfc custom tag, if there is one
	* */
	public function init(required boolean hasEndTag, component parent) {
		variables.hasEndTag = arguments.hasEndTag;
		if(!structKeyExists(arguments, "parent") || IsEmpty(arguments.parent))
			throw "Tag slider must be inside a form tag";
		variables.parent = arguments.parent;
	}

	public boolean function onStartTag( struct attributes, struct caller ){
		this.attributes = attributes;

		if(structisEmpty(attributes) || !structKeyExists(attributes, "name") || attributes.name == "") {
			throw "attribute Name is required for slider tag";
		}
		checkAttributes();
		setAttributeDefaults();
		result = "";
		result &= '<input type="hidden" name="#variables.parent.ATTRIBUTES.name#" value="">';
		result &= '<applet MAYSCRIPT code="thinlet.AppletLauncher" archive="context/formtag-applet.cfm?version=101" width="#attributes.width#" ';
		for(attr in attributes){
			if(listFindNoCase("height,hspace,vspace", attr)){
				if(attr > 0){
					result &= '#attr# = "#attributes[attr]#" '
				}
			}
		}
		if(attributes.align != "")
			result &= 'align = #attributes.align#'
		result &= '>'
		result &= '<param name="class" value="lucee.applet.SliderThinlet"></param>';
		result &= '<param name="form" value="#attributes.name#"></param>';
		result &= '<param name="element" value="#variables.parent.ATTRIBUTES.name#"></param>';
		paramList = "Bgcolor,Bold,Font,Fontsize,Italic,Label,Lookandfeel,Notsupported,Refreshlabel,Scale,Textcolor,Tickmarkimages,Tickmarklabels,Tickmarkmajor,Tickmarkminor,value,minimum,maximum"
		for(param in this.attributes){
			if(listFindNoCase(paramList, param))
			result &= '<param name="#param#" value="#this.attributes[param]#"></param>';
		}
		result &= '</applet>';
		getPageContext().forceWrite(result);

		return variables.hasEndTag;
	}


	private void function setAttributeDefaults(){
		local.attributes = duplicate(this.attributes);
		if(isNull(attributes.width) || !len(attributes.width))
			attributes.width = 40;
		for(attr in attributesList){
			if(listFindNoCase("italic,refreshlabel,vertical,ticketMarkMinor,bold", attr)){
				if(isNull(attributes[attr]) || !len(attributes[attr])){
					attributes[attr] = false;
				}
			}else if(listFindNoCase("vspace,width,hspace,value,scale,fontsize,height", attr)){
				if(isNull(attributes[attr]) || !len(attributes[attr])){
					attributes[attr] = 0;
				}
			}else if(listFindNoCase("textcolor,message,notsupported,align,lookandfeel,onvalidate,label,font,tickmarkimages, onError,bgcolor,tickmarklabels,range", attr)){
				if(isNull(attributes[attr])){
					attributes[attr] = "";
				}
			}
		}
		structAppend(this.attributes, local.attributes, true);
	}

	private void function checkAttributes(){
		variables.attributesList = "italic,refreshlabel,vertical,ticketMarkMinor,bold,vspace,width,hspace,value,scale,fontsize,height,textcolor,message,notsupported,align,lookandfeel,onvalidate,label,font,tickmarkimages, onError,bgcolor,tickmarklabels,range,name,width";
		if(len(this.attributes.name) && reFindNoCase("[^a-zA-Z0-9-_:.]+", this.attributes.name) ){
			throw "value of attribute name [" & this.attributes.name & "] is invalid, only the following characters are allowed [a-z,A-Z,0-9,-,_,:,.]";
		}

		for(attr in this.attributes){
			if(!listFindNoCase(attributesList, attr)){
				throw "invalid #attr# attributes for cfslider tag";
			}else if(listFindNoCase("italic,refreshlabel,vertical,ticketMarkMinor,bold", attr)){
				if(!isBoolean(this.attributes[attr]) && len(this.attributes[attr]))
					throw "value of attribute #attr# must be boolean";
			}else if(listFindNoCase("vspace,width,hspace,value,scale,fontsize,height", attr)){
				if(!isnumeric(this.attributes[attr]) && len(this.attributes[attr]))
					throw "value of attribute #attr# must be numeric";
			}
		}

		if(attr== "range" && len(this.attributes.range)){
			rangeMatch = REMatch("^[0-9]*(\,([0-9])*)*$", this.attributes.range);
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

		if(attr=="align" && len(this.attributes.align)){
			if(!listFindNoCase("top,left,bottom,baseline,texttop,absbottom,middle,absmiddle,right", this.attributes.align)){
				throw "value of attribute align #this.attributes.align# is invalid. valid alignments are [top,left,bottom,baseline,texttop,absbottom,middle,absmiddle,right]";
			}
		}

		if(attr=="lookandfeel" && len(this.attributes.lookandfeel)){
			if(!listFindNoCase("motif,windows,metal", this.attributes.lookandfeel)){
				throw "value of attribute lookandfeel #this.attributes.lookandfeel# is invalid. valid alignments are [motif,windows,metal]";
			}
		}
	}
}