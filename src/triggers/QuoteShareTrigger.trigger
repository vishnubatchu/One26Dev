trigger QuoteShareTrigger on Quote (after insert,after update,before update) {
      map<string,boolean> triggerOnOfMap = new map<string,boolean>();
    for(TriggerOnOf__mdt trg : [SELECT Id,MasterLabel,Deactivate__c  from TriggerOnOf__mdt ]){
        triggerOnOfMap.put(trg.MasterLabel,trg.Deactivate__c);
    }
    if(!triggerOnOfMap.get('QuoteShareTrigger')){
    if(!QuoteLinesHelper.isUpdatedQuoteSDEndDate){
        If(Trigger.isInsert && Trigger.isAfter){
            QuoteShareTriggerHelper.accessToInsideSales(Trigger.NewMap);
            QuoteShareTriggerHelper.provideAccesstoExternalUserInSameCompany(Trigger.NewMap);
        }
        
        If(Trigger.isUpdate && Trigger.isAfter){
            QuoteShareTriggerHelper.updateSalesChannelShare(Trigger.newMap,Trigger.oldMap);
        }
        // Moving PLM Dashboard Code from Line Item to header.Calculation of Gross Profit and Contribution Profit
        IF(Trigger.isUpdate && Trigger.isBefore){
            QuoteItemPLMDashboardTriggerHelper.UpdateQuotePLMDashboardDetails(trigger.OldMap,Trigger.NewMap);
        }
    }
    }
}