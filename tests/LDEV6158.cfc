component extends="org.lucee.cfml.test.LuceeTestCase" labels="form" {

	function run( testResults, testBox ) {
		describe( "LDEV-6158 cfform jakarta/javax compat", function() {

			it( title="cfform should not throw jakarta error on Lucee 6", body=function() {
				local.result = _internalRequest(
					template: "#createURI( 'LDEV6158' )#/LDEV6158.cfm"
				);
				expect( result.filecontent.trim() ).toInclude( "<form " );
			});

		});
	}

	private string function createURI( string calledName, boolean contract=true ) {
		var base = getDirectoryFromPath( getCurrentTemplatePath() );
		var baseURI = contract ? contractPath( base ) : "/test/#listLast( base, '\/' )#";
		return baseURI & "/" & calledName;
	}

}
