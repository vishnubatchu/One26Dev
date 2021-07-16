trigger CaseShareTrigger on Case (After insert,After update, Before delete) {
     map<string,boolean> triggerOnOfMap = new map<string,boolean>();
    for(TriggerOnOf__mdt trg : [SELECT Id,MasterLabel,Deactivate__c  from TriggerOnOf__mdt ]){
        triggerOnOfMap.put(trg.MasterLabel,trg.Deactivate__c);
    }
    if(!triggerOnOfMap.get('CaseShareTrigger')){
    If(Trigger.isInsert && Trigger.isAfter){
        CaseShareTriggerHelper.accessToSalesOrDistributor(Trigger.NewMap);
    }
    
    If(Trigger.isUpdate && Trigger.isAfter){
        System.debug('In after Update Trigger');
        CaseShareTriggerHelper.updateSalesRepAndDistributorShare(Trigger.newMap,Trigger.oldMap);
    }
    If(Trigger.isDelete){
        for(Case caseObj:Trigger.old){
            if(caseObj.Status == 'Pending RMA Admin Review' || caseObj.Status == 'Closed'){
                caseObj.addError('RMA Case cannot be deleted in current status.');
            }
            else 
                if(caseObj.Status == 'In Progress' && caseObj.Validation_Status__c != 'Completed')
                caseObj.addError('Serial Number Validation in progress. RMA Request cannot be deleted.');
        }
    }
    If(Trigger.isUpdate && Trigger.isBefore){
        for(Case caseObj:Trigger.old){
            if(caseObj.Status == 'In Progress' && caseObj.Validation_Status__c != 'Completed')
                caseObj.addError('Serial Number Validation in progress. RMA Case cannot be updated.');
        }
    } 
    }
}