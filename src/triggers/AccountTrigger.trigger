trigger AccountTrigger on Account (after insert,after update,before insert,before update) {
     map<string,boolean> triggerOnOfMap = new map<string,boolean>();
    for(TriggerOnOf__mdt trg : [SELECT Id,MasterLabel,Deactivate__c  from TriggerOnOf__mdt ]){
        triggerOnOfMap.put(trg.MasterLabel,trg.Deactivate__c);
    }
    if(!triggerOnOfMap.get('AccountTrigger')){
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            AccountTriggerHelper.afterInsert(Trigger.new);
        }
        list<Account> updateAccList = new list<Account>();
        if(Trigger.isUpdate){
            for(Account ac : Trigger.New){
                if(trigger.oldMap.get(ac.id).Global_Ultimate_Parent__c != ac.Global_Ultimate_Parent__c)
                    updateAccList.add(ac);
            }
            if(updateAccList != null && updateAccList.size()> 0)
                       UpdateSubAccountGlobalUltimateParent.updateSubAccount(updateAccList);

            AccountTriggerHelper.afterUpdate(Trigger.oldMap, Trigger.newMap);
            AccountTriggerHelper.updateOrderLines(trigger.new, trigger.oldMap);
            //AccountTriggerHelper.updateSharing(trigger.newMap, trigger.oldMap);
            AccountTriggerHelper.updateGlblPrntPrevOwner(trigger.new, trigger.oldMap);
        } 
    }
    }
}