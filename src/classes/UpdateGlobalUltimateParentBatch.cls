global class UpdateGlobalUltimateParentBatch implements Database.Batchable <sObject>,Database.Stateful{ 
    global String query;
    global list<Account> topAccountList = new list<Account>();
    global map<id,Account> globalMap = new map<id,Account>();
    global set<id> allAccFailedId=new set<id>();
    global set<id> allAccSuccessId=new set<id>();
    global set<id> allOppFailedId=new set<id>();
    global set<id> allOppSuccessId=new set<id>();
    global set<id> allOrdrFailedId=new set<id>();
    global set<id> allOrdrSuccessId=new set<id>();
    global set<id> allQuoteFailedId=new set<id>();
    global set<id> allQuoteSuccessId=new set<id>();
    
    // Start
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        topAccountList= [select id, Global_Parent_Updated__c,Global_Ultimate_Parent__c   from account where Global_Parent_Updated__c  = True];
        system.debug('topAccountList ' + topAccountList);
        globalMap = new map<id,Account>();
        for(account ac : topAccountList){
            globalMap.put(ac.id,ac);
        }
        query = 'select id,Global_Parent_Updated__c,Global_Ultimate_Parent__c ,Parent.Id,Parent.parent.Id,Parent.parent.parent.Id,Parent.parent.parent.parent.Id,' +
            '(select id,Global_Ultimate_Account__c from Opportunities   ),' +
            '(select id,Global_Ultimate_Account__c from Orders)' 
            + 'from Account where Parent.Id In: topAccountList Or Parent.Parent.Id In: topAccountList Or Parent.Parent.Parent.Id In: topAccountList Or Parent.parent.parent.parent.Id In: topAccountList Or Id In: topAccountList';
        return Database.getQueryLocator(query);
    }
    
    //Execute this method update global parent of all releted Account,order,opportunity of top level account 
    global void execute(Database.BatchableContext BC,List<sObject> batch)
    {
        list<opportunity> updateOpp = new list<opportunity>();
        list<Account> updateAcc = new list<Account>();
        list<Order> updateOrder = new list<Order>();
        list<Quote> updateQuote = new list<Quote>();
        list<Account> AccountHierachyList  = batch;
        //Account update List Creation 
        for(Account ac : AccountHierachyList){
            string globalParentId = '';
            boolean UpdateFlaf = false;
            if(globalMap.get(ac.Parent.Id) != null){
                globalParentId =  globalMap.get(ac.Parent.Id).Global_Ultimate_Parent__c ;
            }else if(globalMap.get(ac.Parent.Parent.Id) != null){
                globalParentId =  globalMap.get(ac.Parent.Parent.Id).Global_Ultimate_Parent__c ;
            }else if(globalMap.get(ac.Id) != null){
                globalParentId =  globalMap.get(ac.Id).Global_Ultimate_Parent__c ;  
            }else if(globalMap.get(ac.Parent.Parent.Parent.Id) != null){
                globalParentId =  globalMap.get(ac.Parent.Parent.Parent.Id).Global_Ultimate_Parent__c ;  
            }else if(globalMap.get(ac.Parent.Parent.Parent.Parent.Id) != null){
                globalParentId =  globalMap.get(ac.Parent.Parent.Parent.Parent.Id).Global_Ultimate_Parent__c ;  
            }
            ac.Global_Ultimate_Parent__c = globalParentId;
            updateAcc.add(ac);
            // opportunity Update List Creation
            for(opportunity op : ac.Opportunities){
                op.Global_Ultimate_Account__c = globalParentId;
                updateOpp.add(op);
            }
            //Order Update List Creation
            for(Order O : ac.Orders){
                O.Global_Ultimate_Account__c = globalParentId;
                updateOrder.add(O);
            }
        }
       
        // Quote update List Creation 
       list<Quote> qtList = [select id,Account__c,Account__r.Parent.Parent.Parent.Parent.Id,Account__r.Parent.Parent.Parent.Id,Account__r.Parent.Parent.Id,Account__r.Id,Account__r.Parent.Id,Global_Ultimate_Account__c  from Quote Where Account__c In:updateAcc ];
           if(qtList.size() > 0 && qtList != null){
           for(Quote Qt : qtList){
            if(globalMap.get(Qt.Account__r.Parent.Id) != null){
                Qt.Global_Ultimate_Account__c =  globalMap.get(Qt.Account__r.Parent.Id).Global_Ultimate_Parent__c ;
            }else if(globalMap.get(Qt.Account__r.Parent.Parent.Id) != null){
                Qt.Global_Ultimate_Account__c  =  globalMap.get(Qt.Account__r.Parent.Parent.Id).Global_Ultimate_Parent__c ;
            }else if(globalMap.get(Qt.Account__r.Id) != null){
                Qt.Global_Ultimate_Account__c  =  globalMap.get(Qt.Account__r.Id).Global_Ultimate_Parent__c ;  
            }else if(globalMap.get(Qt.Account__r.Parent.Parent.Parent.Id) != null){
                Qt.Global_Ultimate_Account__c  =  globalMap.get(Qt.Account__r.Parent.Parent.Parent.Id).Global_Ultimate_Parent__c ;  
            }else if(globalMap.get(Qt.Account__r.Parent.Parent.Parent.Parent.Id) != null){
                Qt.Global_Ultimate_Account__c  =  globalMap.get(Qt.Account__r.Parent.Parent.Parent.Parent.Id).Global_Ultimate_Parent__c ;  
            } 
            updateQuote.add(Qt); 
        }
    }
        
        if(updateAcc.size() > 0 && updateAcc != null ){
            //Update Account
            database.SaveResult[] accResult=database.update(updateAcc,false);
            //Account Success Fail List
            for(Integer i=0; i < accResult.size(); i++) {
                if(accResult.get(i).isSuccess()) {
                    System.debug('Records are updated Successfully');
                    allAccSuccessId.add(accResult.get(i).Id);
                } 
                else if(!accResult.get(i).isSuccess()) {
                    Database.Error errors =  accResult.get(i).getErrors().get(0);
                    System.debug('Error Occurs While Processing The Record'+errors.getMessage());
                    allAccFailedId.add(updateAcc.get(i).Id);
                }
            }
            //GlobalParentOwnerBatch_Helper call
            list<Account> acSharing = [select id,Changed_Global_Parent_Old_Owner__c from Account where Id in:allAccSuccessId ]; 
            if(acSharing.size() > 0 && acSharing != null){
                GlobalParentOwnerBatch_Helper.getShareRcrdsTobeDeletedOrInserted(acSharing,False);
            }
        }
        if(updateOpp.size() > 0 && updateOpp != null ){
            //Update Opportunity
            database.SaveResult[] oppResult=database.update(updateOpp,false);
            //opportunity Success Fail List
            for(Integer i=0; i < oppResult.size(); i++) {
                if(oppResult.get(i).isSuccess()) {
                    System.debug('Records are updated Successfully');
                    allOppSuccessId.add(oppResult.get(i).Id);
                } 
                else if(!oppResult.get(i).isSuccess()) {
                    Database.Error errors =  oppResult.get(i).getErrors().get(0);
                    System.debug('Error Occurs While Processing The Record'+errors.getMessage());
                    allOppFailedId.add(updateOpp.get(i).Id);
                }
            }
            
        }
        if(updateOrder.size() > 0 && updateOrder != null ){
            //Update Order
            database.SaveResult[] ordrResult=database.update(updateOrder,false);
            //Order Success Fail List
            for(Integer i=0; i < ordrResult.size(); i++) {
                if(ordrResult.get(i).isSuccess()) {
                    System.debug('Records are updated Successfully');
                    allOrdrSuccessId.add(ordrResult.get(i).Id);
                } 
                else if(!ordrResult.get(i).isSuccess()) {
                    Database.Error errors =  ordrResult.get(i).getErrors().get(0);
                    System.debug('Error Occurs While Processing The Record'+errors.getMessage());
                    allOrdrSuccessId.add(updateOrder.get(i).Id);
                }
            }
        }
       
        if(updateQuote.size() > 0 && updateQuote != null ){
            //Update Quote
            database.SaveResult[] quoteResult=database.update(updateQuote,false);
            //Quote Success Fail List
            for(Integer i=0; i < quoteResult.size(); i++) {
                if(quoteResult.get(i).isSuccess()) {
                    System.debug('Records are updated Successfully');
                    allQuoteSuccessId.add(quoteResult.get(i).Id);
                } 
                else if(!quoteResult.get(i).isSuccess()) {
                    Database.Error errors =  quoteResult.get(i).getErrors().get(0);
                    System.debug('Error Occurs While Processing The Record'+errors.getMessage());
                    allQuoteFailedId.add(updateQuote.get(i).Id);
                }
            }
        }
      
    }
    
    //Finish this method Reset "global parent update" flag to false
    global void finish(Database.BatchableContext BC) {
        list<Account> finaAccllist = [select id,Global_Parent_Updated__c from Account where id in:allAccSuccessId];
        list<Account> ResetFlaglist = new list<Account>();
        if(finaAccllist.size() > 0 && finaAccllist != null){
            for(Account reset : finaAccllist){
                reset.Global_Parent_Updated__c = false;
                reset.Changed_Global_Parent_Old_Owner__c = null;
                ResetFlaglist.add(reset); 
            }
            update ResetFlaglist;
        }
    }
}