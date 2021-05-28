({
    init : function(component, event, helper) {
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__FAFVCustomUI',
            },
            state: {
                "c__recID": component.get('v.recordId')
            }
        };
        component.set("v.pageReference", pageReference);
        component.set("v.myBool", false);
     },
     handleClick: function(component, event, helper) {
        var navService = component.find("navService");
        var pageReference = component.get("v.pageReference");
          var defaultUrl = "#";
        navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                 console.log('navService');
                 console.log('URL');
               window.open(url);
            }), $A.getCallback(function(error) {
            }));
        location.reload();
    }
})