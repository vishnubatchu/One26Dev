public class UpdateGlobalParentLookupsBatchHelper {

    //This method deletes  and insert share records
    public static List<CustomError> deleteAndInsertShareRecords(List<Account> accountList){
        List<CustomError> errorList=new List<CustomError>();
        if(accountList!=null && !accountList.isEmpty()){
            try{
                   List<Sobject> listOfShareRecTobeInserted=getShareRcrdsTobeDeletedOrInserted(accountList);
                    if(!listOfShareRecTobeInserted.isEmpty()){
                        list<list<Sobject>> soblistOfList = new list<list<Sobject>>();
                        if(listOfShareRecTobeInserted.size()>10000){
                            soblistOfList.addAll(doSubList(listOfShareRecTobeInserted));
                        } else{
                            soblistOfList.add(listOfShareRecTobeInserted);
                        }
                        if(!soblistOfList.isEmpty()){
                            for(list<Sobject> sl : soblistOfList){
                                continue;
                                Database.SaveResult[] srList = Database.insert(sl, True); 
                                continue;
                                for (Database.SaveResult sr : srList) {
                                    if (sr.isSuccess()) {
                                        // Operation was successful, so get the ID of the record that was processed
                                        System.debug('Successfully inserted share record. share record ID: ' + sr.getId());
                                    }
                                    else {
                                        String message='';
                                        // Operation failed, so get all errors                
                                        for(Database.Error err : sr.getErrors()) {
                                            System.debug('The following error has occurred.');                    
                                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                            System.debug('Fields that affected this error: ' + err.getFields());
                                            message+= err.getMessage();
                                        }
                                        errorList.add(new CustomError('','','Insert',message));
                                    }
                                }
                                continue;
                            } 
                        }
                        
                        // Iterate through each returned result
                        
                    }
             
            }catch(Exception excpn){
                System.debug('Exception occured==>'+excpn.getMessage());
                errorList.add(new CustomError('','','','Exception occured==>'+excpn.getMessage()));
            }
        }
        return errorList;
    }
    
    //This method get all related records to be inserted or deleted
    public static List<Sobject> getShareRcrdsTobeDeletedOrInserted(List<Account> accountList){
        List<SObject> finalReturnList=new list<SObject>();
        if(accountList!=null && !accountList.isEmpty()){
            finalReturnList.addAll(getContactShareRecords(accountList));
            finalReturnList.addAll(getOppShareRecords(accountList));
            finalReturnList.addAll(getQuoteShareRecords(accountList));
            finalReturnList.addAll(getOrderShareRecords(accountList));
            finalReturnList.addAll(getOrderLineShareRecords(accountList));
            finalReturnList.addAll(getCaseShareRecords(accountList));
            
        }
        return finalReturnList;
        
    }
    
    //This method get all contact records to be inserted or deleted
    public static List<Sobject> getContactShareRecords(List<Account> accountList){
            List<Sobject> cntctShrListTobeInsrtd=new List<ContactShare>();
        if(accountList!=null && !accountList.isEmpty()){
            List<Contact> contactList=[Select Id,Account.Global_Parent_Previous_Owner__c,Account.Changed_Global_Parent_Old_Owner__c,Account.Global_Ultimate_Parent__r.OwnerId,OwnerId,(Select Id,ContactId,UserOrGroupId  from Shares where RowCause='Manual' 
                                                                                                                                                                                       and ContactAccessLevel='Read' ) 
                                       from Contact 
                                       where AccountId IN: accountList];
            for(Contact eachCon:contactList){
            
                if(eachCon.OwnerId!=eachCon.Account.Global_Ultimate_Parent__r.OwnerId){
                    cntctShrListTobeInsrtd.add(new ContactShare(ContactId=eachCon.Id,UserOrGroupId=eachCon.Account.Global_Ultimate_Parent__r.OwnerId,
                                                                RowCause='Manual',ContactAccessLevel='Read'));
                }
            }
        }
        return cntctShrListTobeInsrtd;
    }
    
    //This method get all opp records to be inserted or deleted
    public static List<Sobject> getOppShareRecords(List<Account> accountList){
                    List<Sobject> oppShrListTobeInsrtd=new List<OpportunityShare>();

        if(accountList!=null && !accountList.isEmpty()){
            List<Opportunity> oppList=[Select Id,Account.Global_Parent_Previous_Owner__c,Account.Changed_Global_Parent_Old_Owner__c,Account.Global_Ultimate_Parent__r.OwnerId,OwnerId,(Select Id,OpportunityId,UserOrGroupId from Shares where RowCause='Manual' 
                                                                                                                                                                                       and OpportunityAccessLevel='Read' ) 
                                       from Opportunity 
                                       where AccountId IN: accountList];
            for(Opportunity eachOpp:oppList){
            
                if(eachOpp.OwnerId!=eachOpp.Account.Global_Ultimate_Parent__r.OwnerId){
                    oppShrListTobeInsrtd.add(new OpportunityShare(OpportunityId=eachOpp.Id,UserOrGroupId=eachOpp.Account.Global_Ultimate_Parent__r.OwnerId,
                                                                  RowCause='Manual',OpportunityAccessLevel='Read'));
                }
            }
          
        }
        return oppShrListTobeInsrtd;
    }
    
    //This method get all quote records to be inserted or deleted
    public static List<Sobject> getQuoteShareRecords(List<Account> accountList){
                    List<Sobject> quoteShrListTobeInsrtd=new List<QuoteShare>();
        if(accountList!=null && !accountList.isEmpty()){
            List<Quote> quoteList=[Select Id,Account__r.Global_Parent_Previous_Owner__c,Account__r.Changed_Global_Parent_Old_Owner__c,Account__r.Global_Ultimate_Parent__r.OwnerId,OwnerId,(Select Id,ParentId,UserOrGroupId from Shares where RowCause='Manual' 
                                                                                                                                                                                            and AccessLevel='Read' ) 
                                   from Quote 
                                   where Account__c IN: accountList];
            for(Quote eachQuote:quoteList){

                if(eachQuote.OwnerId!=eachQuote.Account__r.Global_Ultimate_Parent__r.OwnerId){
                    quoteShrListTobeInsrtd.add(new QuoteShare(ParentId=eachQuote.Id,UserOrGroupId=eachQuote.Account__r.Global_Ultimate_Parent__r.OwnerId,
                                                              RowCause='Manual',AccessLevel='Read'));
                }
            }
        }
        return quoteShrListTobeInsrtd;
    }
    
    //This method get all order records to be inserted or deletede
    public static List<Sobject> getOrderShareRecords(List<Account> accountList){
                    List<Sobject> orderShrListTobeInsrtd=new List<OrderShare>();
        if(accountList!=null && !accountList.isEmpty()){
            List<Order> orderList=[Select Id,Account.Global_Parent_Previous_Owner__c,Account.Changed_Global_Parent_Old_Owner__c,Account.Global_Ultimate_Parent__r.OwnerId,OwnerId,(Select Id,OrderId,UserOrGroupId from Shares where RowCause='Manual' 
                                                                                                                                                                                   and OrderAccessLevel='Read' ) 
                                   from Order 
                                   where AccountId IN: accountList];
            for(Order eachOrder:orderList){
               
                if(eachOrder.OwnerId!=eachOrder.Account.Global_Ultimate_Parent__r.OwnerId){
                    orderShrListTobeInsrtd.add(new OrderShare(OrderId=eachOrder.Id,UserOrGroupId=eachOrder.Account.Global_Ultimate_Parent__r.OwnerId,
                                                              RowCause='Manual',OrderAccessLevel='Read'));
                }
            }
        }
        return orderShrListTobeInsrtd;
    }
    
    //This method get all order line records to be inserted or deleted
    public static List<Sobject> getOrderLineShareRecords(List<Account> accountList){
        List<Sobject> orderLineShrListTobeInsrtd=new List<Order_Line__Share>();
        if(accountList!=null && !accountList.isEmpty()){
            List<Order_Line__c> orderLineList=[Select Id,Customer_Name__r.Global_Parent_Previous_Owner__c,Customer_Name__r.Changed_Global_Parent_Old_Owner__c,Customer_Name__r.Global_Ultimate_Parent__r.OwnerId,OwnerId,(Select Id,ParentId,UserOrGroupId from Shares where RowCause='Manual' 
                                                                                                                                                                                                                          and AccessLevel='Read' ) 
                                               from Order_Line__c 
                                               where Customer_Name__c IN: accountList];
            for(Order_Line__c eachOrderLine:orderLineList){
             
                if(eachOrderLine.OwnerId!=eachOrderLine.Customer_Name__r.Global_Ultimate_Parent__r.OwnerId){
                    orderLineShrListTobeInsrtd.add(new Order_Line__Share(ParentId=eachOrderLine.Id,UserOrGroupId=eachOrderLine.Customer_Name__r.Global_Ultimate_Parent__r.OwnerId,
                                                                         RowCause='Manual',AccessLevel='Read'));
                }
            }
        }
        return orderLineShrListTobeInsrtd;
    }
    
    //This method get all case records to be inserted or deleted
    public static List<Sobject> getCaseShareRecords(List<Account> accountList){
         List<Sobject> caseShrListTobeInsrtd=new List<CaseShare>();
        if(accountList!=null && !accountList.isEmpty()){
            List<Case> caseList=[Select Id,Account.Global_Parent_Previous_Owner__c,Account.Changed_Global_Parent_Old_Owner__c,Account.Global_Ultimate_Parent__r.OwnerId,OwnerId,(Select Id,CaseId,UserOrGroupId from Shares where RowCause='Manual' 
                                                                                                                                                                                 and CaseAccessLevel='Read') 
                                 from Case 
                                 where AccountId IN: accountList];
            for(Case eachCase:caseList){
               
                if(eachCase.OwnerId!=eachCase.Account.Global_Ultimate_Parent__r.OwnerId){
                    caseShrListTobeInsrtd.add(new CaseShare(CaseId=eachCase.Id,UserOrGroupId=eachCase.Account.Global_Ultimate_Parent__r.OwnerId,
                                                            RowCause='Manual',CaseAccessLevel='Read'));
                }
            }
        }
        return caseShrListTobeInsrtd;
    }
        
    //This method sends email with attachment if batch fails to process any records 
    public static void sendEmail(String csvContent){
        Messaging.EmailFileAttachment csvAttcmnt = new Messaging.EmailFileAttachment ();
        blob csvBlob = Blob.valueOf (csvContent);
        string csvname= 'ErrorList.csv';
        csvAttcmnt.setFileName (csvname);
        csvAttcmnt.setBody (csvBlob);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toEmailIdList=new List<String>();
        String toEmailIdStr=System.Label.Global_Parent_Owner_Account_Update_Batch_Notification_EmaildId;
        if(toEmailIdStr!=null && toEmailIdStr.trim()!=''){
            if(toEmailIdStr.contains(',')){
                toEmailIdList=toEmailIdStr.split(',');
            }else{
                toEmailIdList.add(toEmailIdStr);
            }
        }
        String[] toAddresses = toEmailIdList; 
        mail.setToAddresses(toAddresses);
        mail.setSubject('GlobalParentOwner_Batch Failed');
        mail.setPlainTextBody('PFA error file attached.');
        mail.setFileAttachments (new Messaging.EmailFileAttachment []{csvAttcmnt});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    //create Sub List if list has more then 10000 record 
    public static list<list<Sobject>> doSubList(List<Sobject> recordList)
    {
        list<list<Sobject>> sublistOfList = new list<list<Sobject>>();
        decimal listsize = recordList.size();
        decimal recordCount = listsize.divide(10000, 2);
        long interval = recordCount.round(System.RoundingMode.CEILING);
        decimal recordCount2 = listsize.divide(interval, 2);
        long secondInterval = recordCount2.round(System.RoundingMode.CEILING);
        List<Sobject> shareRecordList = new List<Sobject>();
        for(Sobject sh : recordList){
            if(shareRecordList.size() <=  secondInterval){
                shareRecordList.add(sh);
            }else{
                sublistOfList.add(shareRecordList);
                shareRecordList = new List<Sobject>();
                shareRecordList.add(sh);
            }
        }
        sublistOfList.add(shareRecordList);
        
        return sublistOfList;
    }
    
    public class CustomError
    {
        public String id{get;set;}
        public String objectName{get;set;}
        public String operation{get;set;}
        public String message{get;set;}
        CustomError(String id,String objectName,String operation,String message){
            this.id=id;
            this.objectName=objectName;
            this.operation=operation;
            this.message=message;
        }
    }
}