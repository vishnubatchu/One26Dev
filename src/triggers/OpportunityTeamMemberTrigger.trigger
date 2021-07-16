/**
 * Name : OpportunityTeamMemberTrigger
 * created date: 25/05/2020
 * created By : Surendar
 * Description : adding validation when Non WSS users are added on WSS Opportunity sales team
**/
trigger OpportunityTeamMemberTrigger on OpportunityTeamMember (before insert) {
          map<string,boolean> triggerOnOfMap = new map<string,boolean>();
    for(TriggerOnOf__mdt trg : [SELECT Id,MasterLabel,Deactivate__c  from TriggerOnOf__mdt ]){
        triggerOnOfMap.put(trg.MasterLabel,trg.Deactivate__c);
    }
    if(!triggerOnOfMap.get('OpportunityTeamMemberTrigger')){
    if(trigger.isInsert && trigger.isBefore){
        OpportunityTeamMemberTriggerHelper.checkUserRole(trigger.new);
    }
    }
}