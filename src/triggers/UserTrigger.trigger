trigger UserTrigger on User (after insert, after update) {
     map<string,boolean> triggerOnOfMap = new map<string,boolean>();
    for(TriggerOnOf__mdt trg : [SELECT Id,MasterLabel,Deactivate__c  from TriggerOnOf__mdt ]){
        triggerOnOfMap.put(trg.MasterLabel,trg.Deactivate__c);
    }
    if(!triggerOnOfMap.get('UserTrigger')){
    if(trigger.isInsert && trigger.isAfter){
        UserTriggerHelper.addUserInPubicGroup(trigger.new);
    } 
    if(trigger.isUpdate && Trigger.isAfter){
        UserTriggerHelper.updateGroupDetails(trigger.oldMap, trigger.new);
    }
    }
}