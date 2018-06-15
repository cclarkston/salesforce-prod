/**
* Clear Choice External API
* External Application allowing Third Party users to insert records in Salesforce
* Application validates incoming calls against the CCAPI__c table looking for approved API Keys and 
* matching them to the appropriate API
*
* CHANGE HISTORY
* ===============================================================================
* DATE            NAME                          DESC
* 2012-07-19     Chad Serpan            		Initial Build
* ===============================================================================
*
* @author Chad Serpan
* @version 1.0
* @copyright 2012-07-19
* @package CCAPI
* @example http://clearchoicecallcenter.com/CCAPI?APIKEY=[APIKEY]&LeadID=[LEADID]&XML=true
* @return String JSON / XML String
* @see pages::CCAPI.page
*
* @todo Security Update? Limit to incoming IP Address
* 
* ERROR CODES
* ===============================================================================
* 001		Invalid Session		APIKEY did not locate a valid API
* 002		No Data Provided	Caller didn't supply any data
* 003		No API Provided		Data was provided but there was no APIKEY
* 004		No Data Provided	Only the APIKEY was provided nothing else
* 005		Inappropriate API	APIKEY valid but API was not located
* 006		<Mixed>				There was something wrong with the XML Parser
* ===============================================================================
*/
public class CCAPI{
	private PageReference Page = ApexPages.currentPage();
	private Map<String, String> Perams = Page.getParameters();
	private Map<String, Object> myReturn = new Map<String, Object>();
	private String APIKEY;
	private CCAPI__c myCCAPI;
	
	/**
	* Run method called as action on pages::CCAPI.page
	* Results are stored to a String Map to be encoded based on users preferance
	*/
    public void runCCAPI(){
      try{
      //Make sure that the caller sent us something
	    if(Perams.isEmpty() != true) {
		  // Check to see if a the APIKEY was sent
		  if(Perams.containsKey('APIKEY') == true){
					// Check for appropriate number of variables
					if((Perams.containsKey('XML') == true && Perams.size() > 2)
						|| (Perams.containsKey('XML') == false && Perams.size() > 1)){
						APIKEY = Perams.get('APIKEY');
						// Select the API based on the APIKEY, if no Key is found throw error
						myCCAPI = [SELECT Name FROM CCAPI__c WHERE access_key__c = :APIKEY LIMIT 1 ];
						
						// *****************************************************************
						// *****************************************************************
						// API STACK :: INSERT NEW APIS HERE
						// Check to see if the API exists, if no API exists throw error			
						if(myCCAPI.Name == 'InfoCisionLead'){
							CCAPIInfoCisionLeadController API = new CCAPIInfoCisionLeadController();
		    				myReturn = API.run( APIKEY );
						}									
						else if(myCCAPI.Name =='Vantage') {
							//call the Vantage API here
							VantageAPIController API = new VantageAPIController();
							myReturn = API.run( APIKEY );
						}
						else if(myCCAPI.Name == 'ClearConnect') {
							CConnectAPIController API = new CConnectAPIController();
							myReturn = API.run( APIKEY );
						}												
						// *****************************************************************
						// *****************************************************************
						 else {
							myReturn.put('Success', 'False');
							myReturn.put('Error', '005');
							myReturn.put('Message', 'Inappropriate API');
						}
					} else {
						myReturn.put('Success', 'False');
						myReturn.put('Error', '004');
						myReturn.put('Message', 'No Data Provided');
					}
				} else {
					myReturn.put('Success', 'False');
					myReturn.put('Error', '003');
					myReturn.put('Message', 'No API Provided');
				}
			} else {
				myReturn.put('Success', 'False');
				myReturn.put('Error', '002');
				myReturn.put('Message', 'No Data Provided');
			}
		} catch (system.queryexception myLead){
			myReturn.put('Success', 'False');
			myReturn.put('Error', '001');
			myReturn.put('Message', 'Invalid Session Exception - ' + myLead.getmessage());
			myReturn.put('Line', mylead.getLineNumber());
			myReturn.put('Stack', mylead.getStackTraceString());			
		}
    }
    
    /**
    * Return API responce in the the appropriate format
    * @return String JSON String or XML String
    */
    public String getResult(){
		if(Perams.containsKey('XML') == true && Perams.get('XML').toLowerCase() == 'true'){
			return toXML(myReturn);
		} else {
			return JSON.serialize(myReturn);
		}
    }
    
    /**
    * Recursively loop through our Map object looking for child nodes.
    * If they are found then detect the type if Map then loop through Children
    *
    * @param Object myObjec
    * @param String Key
    * @param XmlStreamWriter myXML
    */
    private void recursiveXML(Object myObject, String Key, XmlStreamWriter myXML){
    	
    	try{
			Map <String, Object> myReturn = (Map<String, Object>) JSON.deserializeUntyped( JSON.serialize( myObject ) );
			String newKey = Key;
			if(newKey.endsWith('ies')){
				newKey = newKey.substring(0, newKey.length()-3 )+'y';
			} else if(newKey.endsWith('s')){
				newKey = newKey.substring(0, newKey.length()-1 );
			}
			for (String oldKey : myReturn.KeySet()){
				Object rObject = myReturn.get(oldKey);
		    	
		    	String testKey = Key;
				try{
					testKey = String.valueOf(Decimal.valueOf(oldKey));
					testKey = newKey;
				} catch (Exception e){
					testKey = oldKey;
				}
				myXML.writeStartElement(null, testKey, null);
						
				recursiveXML(rObject, oldKey, myXML);
				
				myXML.writeEndElement();
			}
		} catch (Exception e){
    		myXML.writeCharacters( ( myObject == null ) ? '' : String.valueOf( myObject ) );
		}
    }
    
    /**
    * Convert API Object to an XML String
    *
    * @param Map myObject
    * @return String XML String
    */
    public String toXML(Map <String, Object> myObject){
    	try{
			XmlStreamWriter myXML = new XmlStreamWriter();
			myXML.writeStartDocument(null, '1.0');
			myXML.writeStartElement(null, 'data', null);
			
			for (String Key : myObject.KeySet()){
				//recursiveXML(myObject.get(Key), Key, myXML);
				Object rObject = myObject.get(Key);
    			String Value = ( rObject == null ) ? '' : String.valueOf( rObject );
    			myXML.writeStartElement(null, Key, null);
				
				recursiveXML(rObject, Key, myXML);
				//myXML.writeCharacters( Value );
    			
				myXML.writeEndElement();
			}
			
			myXML.writeEndElement();
			myXML.writeEndDocument();
	       	String myXmlOutput = myXML.getXmlString();
			myXML.close();
			return myXmlOutput;
		} catch (Exception e){
			Map <String, String> myReturn = new Map<String, String>();
			myReturn.put('Success', 'False');
			myReturn.put('Error', '006');
			myReturn.put('Message', e.getMessage());
			return JSON.serialize(myReturn);
		}
    }
}