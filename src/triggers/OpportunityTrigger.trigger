trigger OpportunityTrigger on Opportunity (before update , before insert , after update , after insert) {
    map<string,boolean> triggerOnOfMap = new map<string,boolean>();
    for(TriggerOnOf__mdt trg : [SELECT Id,MasterLabel,Deactivate__c  from TriggerOnOf__mdt ]){
        triggerOnOfMap.put(trg.MasterLabel,trg.Deactivate__c);
    }
    if(!triggerOnOfMap.get('OpportunityTrigger')){
     if(trigger.isUpdate && trigger.isAfter){
         //Commented the below code since Order creation logic is moved to flow.
        /*if(!OpportunityTriggerHelper.orderCreated)
            OpportunityTriggerHelper.createOrderonClosedOpps(trigger.oldMap, trigger.new);*/
    }
     Opportunity_Handler handler = new Opportunity_Handler(); 
     if(Trigger.isBefore && Trigger.isUpdate) 
    {
        handler.beforeUpdate(trigger.new);        
    }
    }
/**  commented  by Akhilesh     
for(opportunity o : trigger.new)
{
    list<Opportunity> rec = new list<Opportunity>();
    {
        rec.add(o);
    }
                
    Opportunity_Handler handler = new Opportunity_Handler(); 
    
    if(Trigger.isBefore && Trigger.isUpdate) 
    {
        handler.beforeUpdate(rec);        
    }
}
 **/           
}