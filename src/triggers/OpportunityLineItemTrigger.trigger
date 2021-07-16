trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert, before update, after delete) {
      map<string,boolean> triggerOnOfMap = new map<string,boolean>();
    for(TriggerOnOf__mdt trg : [SELECT Id,MasterLabel,Deactivate__c  from TriggerOnOf__mdt ]){
        triggerOnOfMap.put(trg.MasterLabel,trg.Deactivate__c);
    }
    if(!triggerOnOfMap.get('OpportunityLineItemTrigger')){
    if(trigger.isBefore && trigger.isupdate){
        OpportunityLineItemTriggerHelper.updateUnitPriceFromProductTier(trigger.new, trigger.oldMap);
    }
    if(trigger.isDelete && trigger.isAfter){
        OpportunityLineItemTriggerHelper.updateSortOrder(trigger.old);
    }
    if(trigger.isInsert && trigger.isBefore){
        OpportunityLineItemTriggerHelper.updateSortOrderonLines(trigger.new);
    }
    }
}