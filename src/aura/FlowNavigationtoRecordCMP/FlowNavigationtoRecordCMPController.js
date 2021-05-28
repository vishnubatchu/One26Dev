({
	invoke : function(component, event, helper) {
		
        var navigationEvt= $A.get('e.force:navigateToSObject');
                  
        navigationEvt.setParams({
            "recordId" :component.get('v.newRecord')
        })
        
        navigationEvt.fire();
	}
})