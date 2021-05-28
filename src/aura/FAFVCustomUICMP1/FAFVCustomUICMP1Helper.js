({
    getFAFVList : function(component, event) {
        console.log('get FAFV list');
        var action = component.get('c.getFAFVRecord');
        if(event.getParam('arguments').param1  ){
            component.set("v.orderId", event.getParam('arguments').param1);
        }
        action.setParams({
            'orderID' : component.get("v.orderId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
               
                component.set("v.SerialNoList", response.getReturnValue().sNoFinalList);
                component.set("v.FAFVList", response.getReturnValue().fafvAnalysisList);
                component.set("v.SerialNoMap", response.getReturnValue().SerialNoMap);
             
      
            
            }
        });
        $A.enqueueAction(action);
    },
   
  
})