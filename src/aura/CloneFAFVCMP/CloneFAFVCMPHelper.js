({
	loadFAFVRecord : function(component,event,helper) {
		console.log('helper************'+component.get('v.FAFVRecordId'));
        var getFAFVRecordAction = component.get('c.getFAFVRecord');
        getFAFVRecordAction.setParams({
            'FAFVRecId' :component.get('v.FAFVRecordId')
        });
        getFAFVRecordAction.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                console.log(response.getReturnValue());
                alert('Clone Successfully Record Name is '+response.getReturnValue());
                /*
               var cloneToastMessage = $A.get("e.force:showToast");
                    			cloneToastMessage.setParams({
                                    title:'Clone FA/FV',
                       				 message: 'Clone Successfully Record Name is '+response.getReturnValue(),
                                     messageTemplate: 'Record {0} created! See it {1}!',
          							 duration:' 2000',
            							key: 'info_alt',
        							    type: 'success',
       								     mode: 'pester'
                    				});
                  
                    			cloneToastMessage.fire();
                */
                   			
            }
        });
          
        $A.enqueueAction(getFAFVRecordAction);
      
        
	}
})