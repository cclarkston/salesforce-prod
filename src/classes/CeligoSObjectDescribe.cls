public with sharing class CeligoSObjectDescribe {
    //place holder for the global object list
    private static Map<String, Schema.SObjectType> d;
    
    //constructor
    private static void getSObjectDescription(){
      	if(CeligoSObjectDescribe.d==null)
      		CeligoSObjectDescribe.d = Schema.getGlobalDescribe();
    }
    
    //check if certain sobject is available for the org by sobject name
    public static boolean existsSObj(String name){
      	CeligoSObjectDescribe.getSObjectDescription();
    	return CeligoSObjectDescribe.d.containsKey(name);
    }
        
    //check if a field exsists for an sobject by providing a string in the format of '<sobject name>.<fieldname>'
    //eg: 'account.name'
    public static boolean existsSObjField(String field){
     	CeligoSObjectDescribe.getSObjectDescription();
	    if(field==null)return false;
	    String[] s = field.split('\\.',2);
	    Schema.SObjectType sobjtype = null;
	    if(s==null||s.size()!=2)return false;
	    //validate the sobject name
	    if( CeligoSObjectDescribe.d.containskey(s[0])){
	      sobjtype =  CeligoSObjectDescribe.d.get(s[0]);
	    }else{
	      return false;
	    }
	    //validate the field exists
	    return  sobjtype.getDescribe().fields.getMap().containskey(s[1]);
    }
    
   public static boolean isAccessible(String field){
        if(field==null)return false;
        String[] s = field.split('\\.',2);
        if(s==null||s.size()!=2)return false;
        //validate the sobject name
        if(!CeligoSObjectDescribe.existsSObj(s[0]))return false;
        Schema.SObjectType objtype = CeligoSObjectDescribe.d.get(s[0]);
        Map<String,Schema.SObjectField> fields = objtype.getDescribe().fields.getMap();
        if(!fields.containskey(s[1]))return false;
        return fields.get(s[1]).getDescribe().isAccessible();
    }
    
    public static boolean isCreateable(String field){
      if(field==null)return false;
        String[] s = field.split('\\.',2);
        if(s==null||s.size()!=2)return false;
        //validate the sobject name
        if(!CeligoSObjectDescribe.existsSObj(s[0]))return false;
        Schema.SObjectType objtype = CeligoSObjectDescribe.d.get(s[0]);
        Map<String,Schema.SObjectField> fields = objtype.getDescribe().fields.getMap();
        if(!fields.containskey(s[1]))return false;
        return fields.get(s[1]).getDescribe().isCreateable();
    }
    
    public static boolean isUpdateable(String field){
      	if(field==null)return false;
        String[] s = field.split('\\.',2);
        if(s==null||s.size()!=2)return false;
        //validate the sobject name
        if(!CeligoSObjectDescribe.existsSObj(s[0]))return false;
        Schema.SObjectType objtype = CeligoSObjectDescribe.d.get(s[0]);
        Map<String,Schema.SObjectField> fields = objtype.getDescribe().fields.getMap();
        if(!fields.containskey(s[1]))return false;
        return fields.get(s[1]).getDescribe().isUpdateable();
    }
    
    public static boolean isNillable(String field){
      	if(field==null)return false;
        String[] s = field.split('\\.',2);
        if(s==null||s.size()!=2)return false;
        //validate the sobject name
        if(!CeligoSObjectDescribe.existsSObj(s[0]))return false;
        Schema.SObjectType objtype = CeligoSObjectDescribe.d.get(s[0]);
        Map<String,Schema.SObjectField> fields = objtype.getDescribe().fields.getMap();
        if(!fields.containskey(s[1]))return false;
        return fields.get(s[1]).getDescribe().isNillable();
    }
    
     public static Schema.DisplayType getType(String field){
      	if(field==null)return null;
        String[] s = field.split('\\.',2);
        if(s==null||s.size()!=2)return null;
        //validate the sobject name
        if(!CeligoSObjectDescribe.existsSObj(s[0]))return null;
        Schema.SObjectType objtype = CeligoSObjectDescribe.d.get(s[0]);
        Map<String,Schema.SObjectField> fields = objtype.getDescribe().fields.getMap();
        if(!fields.containskey(s[1]))return null;
        return fields.get(s[1]).getDescribe().getType();
    }
    
    public static List <Schema.PicklistEntry> getPicklistValues(String field){
      	if(field==null)return null;
        String[] s = field.split('\\.',2);
        if(s==null||s.size()!=2)return null;
        //validate the sobject name
        if(!CeligoSObjectDescribe.existsSObj(s[0]))return null;
        Schema.SObjectType objtype = CeligoSObjectDescribe.d.get(s[0]);
        Map<String,Schema.SObjectField> fields = objtype.getDescribe().fields.getMap();
        if(!fields.containskey(s[1]))return null;
       	return  fields.get(s[1]).getDescribe().getPicklistValues();
    }
}