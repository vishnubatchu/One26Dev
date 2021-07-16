trigger QuoteItemPLMDashboardTrigger on Quote_Item__c (before Insert, after insert, after update, before update, after delete) {
      map<string,boolean> triggerOnOfMap = new map<string,boolean>();
    for(TriggerOnOf__mdt trg : [SELECT Id,MasterLabel,Deactivate__c  from TriggerOnOf__mdt ]){
        triggerOnOfMap.put(trg.MasterLabel,trg.Deactivate__c);
    }
    if(!triggerOnOfMap.get('QuoteItemPLMDashboardTrigger')){
    //Added by Akhilesh for bypass "getPLMApprover" if loginUse's 	Legacy Company is not "Finisar"
    user u = [select id, Legacy_Company__c  from user where id =: UserInfo.getUserId() ];
    //Added by Surendar
    if(Trigger.isUpdate && Trigger.isAfter ){
        QuoteLinesHelper.updatedQuoteSDEnddate(trigger.new, trigger.oldMap);
    } 
    if(trigger.isInsert && trigger.isBefore){
        system.debug('in trigger');
        if(u.Legacy_Company__c == 'Finisar '){
                 QuoteLinesHelper.getPLMApprover(trigger.new);
        }
    }
    if(Trigger.isUpdate && Trigger.isBefore ){
        List<Quote_Item__c> items = new List<Quote_Item__c>();
        for(Quote_Item__c qtitem : trigger.new){
            if(qtitem.product__c != trigger.oldMap.get(qtitem.id).Product__c){
                items.add(qtitem);
            }
        }
        if(items != null && !items.isEmpty() && u.Legacy_Company__c == 'Finisar ')
            QuoteLinesHelper.getPLMApprover(items);
    } 
    if(trigger.isDelete && trigger.isAfter){
        QuoteLinesHelper.updateBuonQuote(trigger.old);
    }
    }
}