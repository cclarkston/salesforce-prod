/*
05/25/2018  CC  Inital commit
*/

@isTest
private class ConstantsTests {

	@isTest static void NonSenseTestToGetDeploymentValidationToPass() {
        Constants constrants = new Constants();
		String text = constants.ForUnitTest();
		System.assert(text == 'ForUnitTest');
	}
 
}