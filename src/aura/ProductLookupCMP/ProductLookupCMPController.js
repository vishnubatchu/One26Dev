({
    
    doInit :function(component,event,helper)
    {
      console.log('selected Item' +JSON.stringify(component.get('v.selItem')));  
    },
	itemSelected : function(component, event, helper) {
		helper.itemSelected(component, event, helper);
	}, 
    serverCall :  function(component, event, helper) {
		helper.serverCall(component, event, helper);
	},
    clearSelection : function(component, event, helper){
        helper.clearSelection(component, event, helper);
    } 
})