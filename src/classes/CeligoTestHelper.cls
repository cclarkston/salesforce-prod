public with sharing class CeligoTestHelper {
		
	//read the celigo test helper settings to find the fields and values that need to be filled
	//the passed in SObject is filled with those values
	//the passed in SObject is changed
	public static void fillSobject(SObject o){
		fillSobject(o, false);
	}
	
	//read the celigo test helper settings to find the fields and values that need to be filled
	//the passed in SObject is filled with those values
	//the passed in SObject is changed
	public static void fillSobject(SObject o, Boolean isUpdate){
		//get the SObject type in string
		//strip the package name space from the typeString
		String typeString = o.getSobjectType().getDescribe().getName().toLowerCase().replaceFirst('^\\w+__(?!c$)','');
		//query the celigo test helper setting
		celigo_test_fields__c setting = celigo_test_fields__c.getInstance(typeString);
		if(setting == null)return;
		//read the string value
		if(setting.Test_Fields__c == null)return;	
		fillFields(o, typeString, setting.Test_Fields__c, isUpdate);
	}
	
	public static void fillFields(SObject o, String objtype, String fields){
		fillFields(o, objtype, fields, false);
	}
	
	//takes an sojbect and a string of name value pairs
	//fill the objects fields with the values
	public static void fillFields(SObject o, String objtype, String fields, Boolean isUpdate){
		String[] namevalues = fields.trim().split('(?<!\\\\),',0);
		for(String namevalue: namevalues){
			String[] nv = namevalue.split('(?<!\\\\):',2);
			if(nv.size()!=2)continue;
			String fldname = nv[0].replaceAll('(?<!\\\\)\\\\','').trim();
			String fldval = nv[1].replaceAll('(?<!\\\\)\\\\','').trim();
			if(fldname == null || fldname == '' ||fldval == null || fldval =='')continue;
			//system.debug('CeligoTestHelper:'+fldname+','+fldval);
			CeligoTestHelper.fillField(o,objtype,fldname,fldval, isUpdate);
		}
	}
	
	//fill the field with fldname on sobject o with fldval as the value
	private static void fillField(SObject o, String sobjtype, String fldname, String fldval, Boolean isUpdate){
		
		if(!isUpdate){
			//verify the field value is valid and iscreateable
			if(!CeligoSObjectDescribe.isCreateable(sobjtype+'.'+fldname))return;
		}else{
			if(!CeligoSObjectDescribe.isUpdateable(sobjtype+'.'+fldname))return;
		}
		
		//get the field value type
		Schema.DisplayType fldtype = CeligoSObjectDescribe.getType(sobjtype+'.'+fldname);
		//system.debug('CeligoTestHelper:filling '+fldname+','+fldval);
		//switch the type
		try{
			if(fldtype==Schema.DisplayType.Boolean){
				o.put(fldname,Boolean.valueOf(fldval));
			}else if(fldtype== Schema.DisplayType.Combobox){
				o.put(fldname,fldval);
			}else if(fldtype== Schema.DisplayType.Currency){
				o.put(fldname,Decimal.valueOf(fldval));
			}else if(fldtype== Schema.DisplayType.Date){
				o.put(fldname,Date.valueOf(fldval));
			}else if(fldtype== Schema.DisplayType.DateTime){
				o.put(fldname,Datetime.valueOf(fldval));
			}else if(fldtype== Schema.DisplayType.Double){
				o.put(fldname,Double.valueOf(fldval));
			}else if(fldtype== Schema.DisplayType.Email){
				o.put(fldname,fldval);
			}else if(fldtype== Schema.DisplayType.EncryptedString){
				o.put(fldname,fldval);
			}else if(fldtype== Schema.DisplayType.ID){
				o.put(fldname,(Id)fldval);
			}else if(fldtype== Schema.DisplayType.Integer){
				o.put(fldname,Integer.valueOf(fldval));
			}else if(fldtype== Schema.DisplayType.MultiPicklist){
				o.put(fldname,fldval);
			}else if(fldtype== Schema.DisplayType.Percent){
				o.put(fldname,Double.valueOf(fldval));
			}else if(fldtype== Schema.DisplayType.Phone){
				o.put(fldname,fldval);
			}else if(fldtype== Schema.DisplayType.Picklist){
				o.put(fldname,fldval);
			}else if(fldtype== Schema.DisplayType.Reference){
				o.put(fldname,fldval);
			}else if(fldtype== Schema.DisplayType.String){
				o.put(fldname,fldval);
			}else if(fldtype== Schema.DisplayType.TextArea){
				o.put(fldname,fldval);
			//}else if(fldtype== Schema.DisplayType.Time){
				//String[] t = fldval.split(':',4);
				//Integer h = Integer.valueOf(t[0]);
				//Integer m = Integer.valueOf(t[1]);
				//Integer s = Integer.valueOf(t[2]);
				//Integer ms = Integer.valueOf(t[3]);
				//o.put(fldname,Time.newInstance(h,m,s,ms));
			}else if(fldtype== Schema.DisplayType.URL){
				o.put(fldname,fldval);
			}else{
				//do nothing
			}
		}catch(Exception e){
			system.debug(e.getMessage());
			system.debug(e.getLineNumber());
			system.debug(e.getStackTraceString());
		}
	}
}