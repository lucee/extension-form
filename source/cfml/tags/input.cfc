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
    this.VALIDATE_REGULAR_EXPRESSION="regex";

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

    public function init(required boolean hasEndTag, component parent) {
        variables.hasEndTag = arguments.hasEndTag;
        variables.parent = arguments.parent;
    };

    public void function onEndTag( struct attributes) {
        this.attributes = attributes;
        setAttributeDefaults();
        checkAttributes();

        if(attributes.validate == this.VALIDATE_REGULAR_EXPRESSION && isnull(attributes.pattern)){
            throw ("when validation type regular_expression is seleted, the pattern attribute is required");
        }
        
        if(IsInstanceOf(variables.parent,"Form")) {
            variables.parent.setInput(this);
            if(attributes.type == "datefield" && variables.parent.attributs.FORMAT_FLASH != "#parent.FORMAT_FLASH#"){
                throw ("type [datefield] is only allowed if form format is flash");
            }
        }
        else { 
            throw ("Tag must be inside a form tag");
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
        if( len(this.attributes.name) && reFindNoCase("[^a-zA-Z0-9-_:.]+", this.attributes.name) )
            throw "value of attribute name [" & this.attributes.name & "] is invalid, only the following characters are allowed [a-z,A-Z,0-9,-,_,:,.]";
    }

    private void function setAttributeDefaults(){
        local.attributes = duplicate(this.attributes);
        if(attributes.validate == "regex")
           attributes.validate = "regular_expression";
        if(attributes.validate == "float")
           attributes.validate = "numeric";
        if(attributes.validate == "integer")
           attributes.validate = "int";
        if(attributes.validate == "telephone")
           attributes.validate = "phone";
        if(attributes.validate == "zipcode")
           attributes.validate = "zip";
        if(attributes.validate == "social_security_number")
           attributes.validate = "ssn";
        if(isNull(attributes.name))
            attributes.name = "";
        if(isNull(attributes.type))
            attributes.method = "text";
        if(isNull(attributes.value))
            attributes.format = "";
        structAppend(this.attributes, local.attributes, true);
    }
}

