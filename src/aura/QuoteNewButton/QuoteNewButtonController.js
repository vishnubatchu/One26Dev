({     
    doInit: function(component) {
        
        component.set("v.URLName", window.location.pathname);
        console.log('URL----'+component.get("v.URLName"));
        
    },
    Save :function(component, event, helper) {
        console.log('inside Save--> '+component.get('v.AccountID'));
        var recinstance = component.get("v.QuoteInstance");
        var lAccountId = component.get("v.QuoteInstance.Account__c");
        
       // console.log('recinstance----'+JSON.stringify(recinstance)); 
        console.log('lAccountId5----'+JSON.stringify(component.get('v.AccountID'))); 
        var action = component.get("c.saveQuote1");
        action.setParams({
            "aAccountId":JSON.stringify(component.get('v.AccountID'))
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            console.log('result12---'+result);
            console.log('state---'+state);
            if(result != null && state==='SUCCESS') {
               console.log('testtt record successful');
                component.set("v.QuoteInstance",result);
                var quoteId = component.get("v.QuoteInstance.Id");
                console.log('quoteId---'+quoteId);
                var URLVal = component.get("v.URLName");
                console.log('URLVal---'+URLVal);
                if(URLVal == '/apex/QuoteNewButtonPage'){
                    var replyEvent = $A.get("e.c:QuoteNewButtonEvent");
                    replyEvent.setParams({ "recordIdRec" : quoteId});
                    replyEvent.fire();   
                }
               // else if(URLVal == '/lightrapport/s/quote/Quote/Recent'){
                 else if(URLVal == '/lightrapport/s/quote/Quote/Default'){   
                    var sObjectEvent = $A.get("e.force:navigateToSObject");
                    sObjectEvent.setParams({
                        "recordId": quoteId,
                        "slideDevName": "detail"
                    });
                    sObjectEvent.fire();
                    window.location.reload();
                }
             
            }
            
        });
        $A.enqueueAction(action);        
    }
})