global class UpdateGlobalUltimateParentBatch implements Database.Batchable <sObject>,Database.Stateful{ 
    global String query;
    global map<id,Account> globalMap = new map<id,Account>();
    global List<Id> topAcclist = new list<Id>();
    global set<id> allAccFailedId=new set<id>();
    global set<id> allAccSuccessId=new set<id>();
    global set<id> allOppFailedId=new set<id>();
    global set<id> allOppSuccessId=new set<id>();
    global set<id> allOrdrFailedId=new set<id>();
    global set<id> allOrdrSuccessId=new set<id>();
    global set<id> allQuoteFailedId=new set<id>();
    global set<id> allQuoteSuccessId=new set<id>();
    global string csvBody;
    global string headerValue;
    
     global UpdateGlobalUltimateParentBatch(){
        csvBody = '';
        headerValue = 'Id,object, Error Message \n';
    }
    
    // Start
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        globalMap = new Map<Id, Account>([select id, Global_Parent_Updated__c,Global_Ultimate_Parent__c   from Account where Global_Parent_Updated__c  = True]);
        topAcclist.addAll(globalMap.keySet());
        query = 'select id,Global_Parent_Updated__c,Global_Ultimate_Parent__c ,Parent.Id,Parent.parent.Id,Parent.parent.parent.Id,Parent.parent.parent.parent.Id ' +
            'from Account where Parent.Id In: topAcclist Or Parent.Parent.Id In: topAcclist Or Parent.Parent.Parent.Id In: topAcclist Or Parent.parent.parent.parent.Id In: topAcclist Or Id In: topAcclist';
        system.debug('Quesry ' + query);
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
        }
        // Order update List Creation 
        list<opportunity> opList = [select id,AccountId ,Account.Parent.Parent.Parent.Parent.Id,Account.Parent.Parent.Parent.Id,Account.Parent.Parent.Id,Account.Id,Account.Parent.Id,Global_Ultimate_Account__c   from opportunity Where AccountId  In:updateAcc ];
        if(opList.size() > 0 && opList != null){
            for(opportunity op : opList){
                if(globalMap.get(op.Account.Parent.Id) != null){
                    op.Global_Ultimate_Account__c =  globalMap.get(op.Account.Parent.Id).Global_Ultimate_Parent__c ;
                }else if(globalMap.get(op.Account.Parent.Parent.Id) != null){
                    op.Global_Ultimate_Account__c =  globalMap.get(op.Account.Parent.Parent.Id).Global_Ultimate_Parent__c ;
                }else if(globalMap.get(op.Account.Id) != null){
                    op.Global_Ultimate_Account__c  =  globalMap.get(op.Account.Id).Global_Ultimate_Parent__c ;  
                }else if(globalMap.get(op.Account.Parent.Parent.Parent.Id) != null){
                    op.Global_Ultimate_Account__c  =  globalMap.get(op.Account.Parent.Parent.Parent.Id).Global_Ultimate_Parent__c ;  
                }else if(globalMap.get(op.Account.Parent.Parent.Parent.Parent.Id) != null){
                    op.Global_Ultimate_Account__c  =  globalMap.get(op.Account.Parent.Parent.Parent.Parent.Id).Global_Ultimate_Parent__c ;  
                } 
                updateOpp.add(op); 
            }
        }
        // Order update List Creation 
        list<Order> ordList = [select id,AccountId ,Account.Parent.Parent.Parent.Parent.Id,Account.Parent.Parent.Parent.Id,Account.Parent.Parent.Id,Account.Id,Account.Parent.Id,Global_Ultimate_Account__c   from Order Where AccountId  In:updateAcc ];
        if(ordList.size() > 0 && ordList != null){
            for(Order ord : ordList){
                if(globalMap.get(ord.Account.Parent.Id) != null){
                    ord.Global_Ultimate_Account__c =  globalMap.get(ord.Account.Parent.Id).Global_Ultimate_Parent__c ;
                }else if(globalMap.get(ord.Account.Parent.Parent.Id) != null){
                    ord.Global_Ultimate_Account__c =  globalMap.get(ord.Account.Parent.Parent.Id).Global_Ultimate_Parent__c ;
                }else if(globalMap.get(ord.Account.Id) != null){
                    ord.Global_Ultimate_Account__c  =  globalMap.get(ord.Account.Id).Global_Ultimate_Parent__c ;  
                }else if(globalMap.get(ord.Account.Parent.Parent.Parent.Id) != null){
                    ord.Global_Ultimate_Account__c  =  globalMap.get(ord.Account.Parent.Parent.Parent.Id).Global_Ultimate_Parent__c ;  
                }else if(globalMap.get(ord.Account.Parent.Parent.Parent.Parent.Id) != null){
                    ord.Global_Ultimate_Account__c  =  globalMap.get(ord.Account.Parent.Parent.Parent.Parent.Id).Global_Ultimate_Parent__c ;  
                } 
                updateOrder.add(ord); 
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
        try{
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
                       csvBody += updateAcc.get(i).Id + ',';
                        csvBody += 'Account' + ',';
                            string errorMsg = '';
                            for(Database.Error error : accResult[i].getErrors()){
                                errorMsg += error.getMessage() + ',';
                            }
                            errorMsg = errorMsg.removeEnd(',');
                            csvBody += '"'+errorMsg + '"' + ','; 
                            csvBody += '\n';
                    }
                }
                //GlobalParentOwnerBatch_Helper call
                list<Account> acSharing = [select id,Changed_Global_Parent_Old_Owner__c from Account where Id in:allAccSuccessId ]; 
                if(acSharing.size() > 0 && acSharing != null){
                    GlobalParentOwnerBatch_Helper.getShareRcrdsTobeDeletedOrInserted(acSharing,False);
                }
            }
        }catch(Exception e){
            system.debug('**Error at line number---'+e.getLineNumber() + ' - '+ e.getMessage());
        }
        try{
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
                          csvBody += updateOpp.get(i).Id + ',';
                        csvBody += 'Opportunity' + ',';
                            string errorMsg = '';
                            for(Database.Error error : oppResult[i].getErrors()){
                                errorMsg += error.getMessage() + ',';
                            }
                            errorMsg = errorMsg.removeEnd(',');
                            csvBody += '"'+errorMsg + '"' + ','; 
                            csvBody += '\n';
                    }
                }
                
            }
        }catch(Exception e){
            system.debug('**Error at line number---'+e.getLineNumber() + ' - '+ e.getMessage());
        }
        try{
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
                        csvBody += updateOrder.get(i).Id + ',';
                        csvBody += 'Order' + ',';
                            string errorMsg = '';
                            for(Database.Error error : ordrResult[i].getErrors()){
                                errorMsg += error.getMessage() + ',';
                            }
                            errorMsg = errorMsg.removeEnd(',');
                            csvBody += '"'+errorMsg + '"' + ','; 
                            csvBody += '\n';
                    }
                }
            }
        }catch(Exception e){
            system.debug('**Error at line number---'+e.getLineNumber() + ' - '+ e.getMessage());
        }
        try{
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
                          csvBody += updateQuote.get(i).Id + ',';
                        csvBody += 'Quote' + ',';
                            string errorMsg = '';
                            for(Database.Error error : quoteResult[i].getErrors()){
                                errorMsg += error.getMessage() + ',';
                            }
                            errorMsg = errorMsg.removeEnd(',');
                            csvBody += '"'+errorMsg + '"' + ','; 
                            csvBody += '\n';
                    }
                }
            }
        }catch(Exception e){
            system.debug('**Error at line number---'+e.getLineNumber() + ' - '+ e.getMessage());
        }
    }
    
    //Finish this method Reset "global parent update" flag to false
    global void finish(Database.BatchableContext BC) {
        //send Email
        String finalCsv = '';
                    if(csvBody != null && csvBody != ''){
                        finalCsv = headerValue + csvBody;
                    }
                    if( finalCsv != null && finalCsv != ''){
                        String csvname= 'GlobalParentAccount_Update_Errors.csv';
                        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
                        csvAttc.setFileName(csvname);
                        csvAttc.setBody(Blob.valueOf(finalCsv));
                        list<string> toAddresses = new list<string>();
                        Profile sys_adm_profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
                        for(user u : [SELECT id, Email FROM User WHERE ProfileId =:sys_adm_profile.Id]){
                           toAddresses.add(u.Email); 
                        }
                        String subject ='Account Update Error:';    
                        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
                        email.setSubject(subject);
                        email.setToAddresses(toAddresses );
                        email.setPlainTextBody('PFA error file attached.');
                        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
                        try{
                            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                        }catch(Exception e){
                            
                        }
                    }   
        list<Account> finaAccllist = [select id,Global_Parent_Updated__c from Account where id in:allAccSuccessId];
        list<Account> ResetFlaglist = new list<Account>();
        if(finaAccllist.size() > 0 && finaAccllist != null){
            for(Account reset : finaAccllist){
                reset.Global_Parent_Updated__c = false;
                reset.Changed_Global_Parent_Old_Owner__c = null;
                ResetFlaglist.add(reset); 
            }
            try{
            update ResetFlaglist;
            }catch(Exception e){
                system.debug('**Error at line number---'+e.getLineNumber() + ' - '+ e.getMessage());
            }
        }
    }
}