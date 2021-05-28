({
	  doInit : function(component, event, helper) {
          
        
    },
    setStartandEndPoint:function(component,event)
    {
        console.log('dummy '+JSON.stringify(component.get('v.FAFVDetailslist')));
        console.log(event.getParam('startPoint'));
        component.set('v.startPoint',event.getParam('startPoint'));
        component.set('v.endPoint',event.getParam('endPoint'));
    }
    
})