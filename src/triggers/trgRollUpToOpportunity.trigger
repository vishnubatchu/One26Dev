trigger trgRollUpToOpportunity on OpportunityLineItem (before insert,after insert, before update,after update, after delete) {
       map<string,boolean> triggerOnOfMap = new map<string,boolean>();
    for(TriggerOnOf__mdt trg : [SELECT Id,MasterLabel,Deactivate__c  from TriggerOnOf__mdt ]){
        triggerOnOfMap.put(trg.MasterLabel,trg.Deactivate__c);
    }
    if(!triggerOnOfMap.get('trgRollUpToOpportunity')){
    if (Trigger.isBefore) {
        if (Trigger.isInsert)    OpportunityProductHandler.updateBUNOnOpportunityProduct(trigger.New);
        if (Trigger.isUpdate)    OpportunityProductHandler.updateBUNOnOpportunityProduct(trigger.New);
    }  
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert)    OpportunityProductHandler.RollUpBUN(trigger.New);
        if (Trigger.isUpdate)    OpportunityProductHandler.RollUpBUN(trigger.New);
        if(trigger.IsDelete)     OpportunityProductHandler.RollUpBUN(System.trigger.old);
    }    
    }      
}