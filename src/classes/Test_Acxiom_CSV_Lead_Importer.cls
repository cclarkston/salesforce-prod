@IsTest(SeeAllData = true)
private class Test_Acxiom_CSV_Lead_Importer
{
	static testmethod void testfileupload(){
		StaticResource testdoc = [SELECT ID, Body FROM StaticResource WHERE Name ='TestAcxiomUploader'];
		Axciom_CSV_Lead_Importer testUpload = new Axciom_CSV_Lead_Importer();
		testUpload.contentFile = testdoc.Body;
		testUpload.ReadFile();
		testUpload.getuploadedIDs();
	}
}