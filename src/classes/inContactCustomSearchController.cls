public class inContactCustomSearchController {


public List<EntityName> entityCollection {get; set;}
public String ValueToAppend {get; set;}
public string queryResult {get; set; }
public User user {get; set;}
public Boolean isSccView { get; set;}
//contructor for the main class 

    public inContactCustomSearchController(){
    
    //retrieve the query result from the userinfo object by performing an query
    user = [select id, SFDC_Query_Result__c from User where id = :Userinfo.getUserId()];                   
       queryResult = user.SFDC_Query_Result__c;
       isSccView =false;
       string isDtp =  ApexPages.currentPage().getParameters().get('isdtp');
       if(isDtp != null){
       isSccView = true;
       }
     //check queryResult null
      if(queryResult != null){ 
        processQueryString(queryResult);
      } 
    }
    
    private void processQueryString(string result){
    Boolean isEntityAlreadyExists;
    Integer index;
    entityCollection = new List<EntityName>(); 
    List<String> query = result.Split('\\|');
    if(query !=null){
        for(string content : query){
            EntityName entity = formList(content);
            isEntityAlreadyExists = false;
            index = 0;
            for(EntityName ent : entityCollection){
               
               if(entity.entityVal == ent.entityVal)
               {
                   isEntityAlreadyExists = true;
                   break;
               }
               index = index +1;
            }
            if(isEntityAlreadyExists){
            EntityName temp = entityCollection.get(index);
            temp.entityNameId.addAll(entity.entityNameId);
            entityCollection.set(index,temp);
            }
            else{
            entityCollection.add(entity);
            }
        }
    }
    else{
        entityCollection.add(formList(result));
    }   
    }
    
    private EntityName formList(string result){
        EntityName ent = new EntityName();
        List<String> contentSplit = result.Split('\\^');
        ent.entityVal = contentSplit[0];
        List<String> idName = contentSplit[1].Split(',');
        if(idName != null){
            for( string value : idName){                
                    ent.entityNameId.add(getNameId(value)); 
                }
            }   
        else{
            ent.entityNameId.add(getNameId(contentSplit[1])); 
        }
        return ent;
    }

    private EntityValue getNameId(String query){
            List<String> valueSplit = query.Split('~');
            if(valueSplit  != null){
                    EntityValue obj = new EntityValue();
                    obj.Name = valueSplit[1];
                    if(isSccView){
                    obj.Id = 'javascript:sforce.console.openPrimaryTab(null,\'/'+valueSplit[0] +'\',true)' ;                                  
                    }
                    else{
                    obj.Id = '/' + valueSplit[0];
                    }
                    return obj;
                }
            return null;
    }
    

public class EntityName{
public String entityVal { get; set; }
public List<EntityValue> entityNameId { get; set; }

    public EntityName(){    
    entityNameId = new List<EntityValue>();
    }


}

public class EntityValue{
public string Name { get; set;}
public string Id {get; set;}

}
}