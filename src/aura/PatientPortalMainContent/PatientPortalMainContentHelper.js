({
    getUIDisplayed : function (component) {
      var action = component.get('c.getUIThemeDescription')
      action.setCallback(this, function (response) {
        var state = response.getState()
        if (component.isValid() && state === 'SUCCESS') {
          var result = response.getReturnValue()
          component.set('v.theme_ui', result)
        }
      })
      $A.enqueueAction(action)
    },
	getBaseUrl : function(component,event) {
        var action = component.get("c.getBaseUrl");
        
         action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.baseUrl",a.getReturnValue()); 
            } else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError());
            }
        });
        
        $A.enqueueAction(action);
	},
    getAccountInfo : function(component,event) {
        var action = component.get("c.getAccountInfo");
        action.setParams({ accountId: '0011W00001sF9fJ' });
        //action.setParams({ accountId: '0014000001DzVq5' });

      	action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.accountSimpleRecord",a.getReturnValue()); 
                this.getCenterInfo(a.getReturnValue().Center__c, component);
                this.getUrls(a.getReturnValue().Id, component, event);
            } else if (a.getState() === "ERROR") {
                component.set("v.accountRecordError", a.getError()); 
                $A.log("Errors", a.getError());
            }
        });
        
        $A.enqueueAction(action);
	},   
    getUrls : function(Id, component, event) {
        var action = component.get("c.getBaseUrl");
        
         action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var baseUrl = a.getReturnValue();
                component.set("v.preQUrl", component.get("v.baseUrl") + "/apex/lending_app?accountId=" + component.get("v.accountSimpleRecord.Id"));
                component.set("v.healthHistoryUrl", component.get("v.baseUrl") + "/apex/check_in?accountId=" + component.get("v.accountSimpleRecord.Id"));
            } else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError());
            }
        });
        
        $A.enqueueAction(action);
    },
    getCenterInfo : function(Id, component) {    	
        var action = component.get("c.getCenterInfo");
        action.setParams({
        	centerId: Id
        });
        
     	action.setCallback(this, function(a) {
            console.log(a.getState() );
            if (a.getState() === "SUCCESS") {
                component.set("v.centerSimpleRecord", a.getReturnValue()); 
            } else if (a.getState() === "ERROR") {
                component.set("v.centerRecordError", a.getError()); 
                $A.log("Errors", a.getError());
            }
      	});

        $A.enqueueAction(action);
    }
})