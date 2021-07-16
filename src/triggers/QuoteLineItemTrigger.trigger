trigger QuoteLineItemTrigger on Quote_Item__c (before insert, before update) {
      map<string,boolean> triggerOnOfMap = new map<string,boolean>();
    for(TriggerOnOf__mdt trg : [SELECT Id,MasterLabel,Deactivate__c  from TriggerOnOf__mdt ]){
        triggerOnOfMap.put(trg.MasterLabel,trg.Deactivate__c);
    }
    if(!triggerOnOfMap.get('QuoteLineItemTrigger')){
  if(trigger.isBefore && trigger.isInsert){
        QuoteLineItemTriggerHelper.updateConverionValue(trigger.new);
    }
    if(trigger.isBefore && trigger.isUpdate){
        QuoteLineItemTriggerHelper.updateConverionValue(trigger.newMap, trigger.oldMap);
        QuoteLineItemTriggerHelper.updateunitPrice(trigger.new, trigger.oldMap);
    }
    }
}