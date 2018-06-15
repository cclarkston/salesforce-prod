public class Axciom_CSV_Lead_Importer {
	// Based on code sample found at http://www.forcetree.com/2010/08/read-and-insert-records-from-csv-file.html and GitHub user edwinvijay
	// Looks for CSV file with Lead IDs in the first column... disregards any additional columns
	// Once it collects all the IDs, it submits them to the Acxiom class to make the Acxiom call and save the data to the database.

    public string nameFile{get;set;}
    public Blob contentFile{get;set;}
    String[] filelines = new String[]{};
    List<ID> lead_IDs;

    public Pagereference ReadFile() {
        try {
            //Convert the uploaded file which is in BLOB format into a string
            nameFile = blobToString( contentFile,'ISO-8859-1');
            //Now separate every row of the CSV file
            filelines = nameFile.split('\n');
            //Iterate through every line and add the first column's data to lead_IDs
            lead_IDs = new List<ID>();
            for (Integer i = 1; i < filelines.size(); i++) {
                String[] inputvalues = new String[]{};
                inputvalues = filelines[i].split(',');
                lead_IDs.add(inputvalues[0]);
            }
         }
         catch(Exception e) {ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured reading the CSV file'+e.getMessage()); ApexPages.addMessage(errormsg);}

        try {Acxiom.save_acxiom_data(lead_IDs);}
        catch (Exception e) {ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured inserting the records'+e.getMessage()); ApexPages.addMessage(errormsg);}
        return null;
    }

    public List<ID> getuploadedIDs() {
        if (lead_IDs != null) {
            if (lead_IDs.size() > 0) {return lead_IDs;}
            else 					 {return null;}
		}
        else {return null;}
    }
    /*
        This function converts the input CSV file in BLOB format into a string
        @param input    Blob data representing correct string in @inCharset encoding
        @param inCharset    encoding of the Blob data (for example 'ISO 8859-1')
    */
    public static String blobToString(Blob input, String inCharset) {
        String hex = EncodingUtil.convertToHex(input);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i) {bytes[i] =  hex.mid(i << 1, 2);}
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }

}