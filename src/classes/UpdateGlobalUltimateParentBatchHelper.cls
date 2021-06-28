/**
     * Created by : Akhilesh
     * Date : 31th May 2021
     * Description: This is a helper class for UpdateGlobalUltimateParentBatch has implemented as per below logic
     * a) If the Global Ultimate Parent is changed on a Top-Level Account or a Customer that serves as the immediate parent of a child account, then the child’s Global Ultimate Parent should match that of its immediate paren.
     * b) When the Global_Ultimate_Parent__c is changed on an Account that is populated in Opportunity.AccountId, Quote.AccountId, 
     * and Order.AccountId, a batch class properly updates Opportunity.Global_Ultimate_Account__c, 
     * Quote.Global_Ultimate_Account__c, and Order.Global_Ultimate_Account__c to reflect the Account’s Global_Ultimate_Parent__c
     */
public class UpdateGlobalUltimateParentBatchHelper {
    
    public static returnValue updateGlobalParent(List<Account> accountList,map<id,Account> globalParentMap ){
        returnValue finalValue = new returnValue();
        List<GlobalParentOwnerBatch_Helper.CustomError> errorList = new List<GlobalParentOwnerBatch_Helper.CustomError>();
        list<sobject> finalUpdateList = new list<sobject>();
        finalValue.allAccSuccessId  = new set<id>();
        //Account update List Creation 
        for(Account ac : accountList){
            boolean UpdateFlaf = false;
            string prntId = getParentId(ac,globalParentMap);
            if(prntId != ''){
                ac.Global_Ultimate_Parent__c = globalParentMap.get(prntId).Global_Ultimate_Parent__c;
                ac.Changed_Global_Parent_Old_Owner__c = globalParentMap.get(prntId).Changed_Global_Parent_Old_Owner__c;
                finalUpdateList.add(ac);
            }
        }
        // Order update List Creation 
        list<opportunity> opList = [select id,AccountId ,Account.Parent.Parent.Parent.Parent.Id,Account.Parent.Parent.Parent.Id,Account.Parent.Parent.Id,Account.Id,Account.Parent.Id,Global_Ultimate_Account__c   from opportunity Where AccountId  In:finalUpdateList ];
        if(opList.size() > 0 && opList != null){
            for(opportunity op : opList){
                string prntId = getParentId(op,globalParentMap);
                if(prntId != ''){
                    op.Global_Ultimate_Account__c = globalParentMap.get(prntId).Global_Ultimate_Parent__c;
                    finalUpdateList.add(op); 
                }
            }
        }
        
        // Order update List Creation 
        list<Order> ordList = [select id,AccountId ,Account.Parent.Parent.Parent.Parent.Id,Account.Parent.Parent.Parent.Id,Account.Parent.Parent.Id,Account.Id,Account.Parent.Id,Global_Ultimate_Account__c   from Order Where AccountId  In:finalUpdateList ];
        if(ordList.size() > 0 && ordList != null){
            for(Order ord : ordList){
                string prntId = getParentId(ord,globalParentMap);
                if(prntId != ''){
                    ord.Global_Ultimate_Account__c = globalParentMap.get(prntId).Global_Ultimate_Parent__c;
                    finalUpdateList.add(ord); 
                }
            }
        }
        
        // Quote update List Creation 
        list<Quote> qtList = [select id,Account__c,Account__r.Parent.Parent.Parent.Parent.Id,Account__r.Parent.Parent.Parent.Id,Account__r.Parent.Parent.Id,Account__r.Id,Account__r.Parent.Id,Global_Ultimate_Account__c  from Quote Where Account__c In:finalUpdateList ];
        if(qtList.size() > 0 && qtList != null){
            for(Quote Qt : qtList){
                string prntId = getParentId(Qt,globalParentMap);
                if(prntId != ''){
                    Qt.Global_Ultimate_Account__c = globalParentMap.get(prntId).Global_Ultimate_Parent__c;
                    finalUpdateList.add(Qt); 
                }
            }
        }
        //Update finalUpdateList
        try{
            if(finalUpdateList.size() > 0 && finalUpdateList != null ){
                 list<list<Sobject>> soblistOfList = new list<list<Sobject>>();
                        if(finalUpdateList.size()>10000){
                            soblistOfList.addAll(doSubList(finalUpdateList));
                        } else{
                            soblistOfList.add(finalUpdateList);
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
                                       // errorList.add(new CustomError('','','Insert',message));
                                    }
                                }
                                continue;
                            } 
                        }
            }
        }catch(Exception e){
            system.debug('**Error at line number---'+e.getLineNumber() + ' - '+ e.getMessage());
        }
       
        //GlobalParentOwnerBatch_Helper call
        list<Account> acSharing = [select id,Changed_Global_Parent_Old_Owner__c from Account where Id in:finalValue.allAccSuccessId ]; 
        if(acSharing.size() > 0 && acSharing != null){
            // GlobalParentOwnerBatch_Helper.getShareRcrdsTobeDeletedOrInserted(acSharing,False);
            errorList=GlobalParentOwnerBatch_Helper.deleteAndInsertShareRecords(acSharing,false);
            for(GlobalParentOwnerBatch_Helper.CustomError err : errorList){
                finalValue.csvBody += err.ID+ ',';
                finalValue.csvBody += err.objectName + ','; 
                finalValue.csvBody += err.message + ','; 
                finalValue.csvBody += '\n';
            }
        }
        return finalValue;
        
    }
    public static string createCSVBody(string ObjName ,database.SaveResult[] updateResult){
        string body = '';
        
        for(Integer i=0; i < updateResult.size(); i++) {
            if(updateResult.get(i).isSuccess()) {
                System.debug('Records are updated Successfully for ' + updateResult.get(i).Id);
            } 
            else if(!updateResult.get(i).isSuccess()) {
                body += updateResult.get(i).Id + ',';
                body += ObjName + ',';
                string errorMsg = '';
                for(Database.Error error : updateResult[i].getErrors()){
                    errorMsg += error.getMessage() + ',';
                }
                errorMsg = errorMsg.removeEnd(',');
                body += '"'+errorMsg + '"' + ','; 
                body += '\n';
            }
        }
        return body;
    }
    public static string  getParentId(sobject obj, map<id,Account> globalParentMap){
        string parentId = '';
        if(obj.Id.getSObjectType().getDescribe().getName() == 'Account'){
            Account Acc = (Account)obj; 
            if(globalParentMap.get(Acc.Parent.Id) != null){
                parentId = Acc.Parent.Id;
            }else if(globalParentMap.get(Acc.Parent.Parent.Id) != null){
                parentId = Acc.Parent.Parent.Id;  
            }else if(globalParentMap.get(Acc.Id) != null){
                parentId = Acc.Id;
            }else if(globalParentMap.get(Acc.Parent.Parent.Parent.Id) != null){
                parentId = Acc.Parent.Parent.Parent.Id;
            }else if(globalParentMap.get(Acc.Parent.Parent.Parent.Parent.Id) != null){
                parentId = Acc.Parent.Parent.Parent.Parent.Id;
            } 
        }else if(obj.Id.getSObjectType().getDescribe().getName() == 'Quote'){
            Quote qt = (Quote)obj; 
            if(globalParentMap.get(qt.Account__r.Parent.Id) != null){
                parentId = qt.Account__r.Parent.Id;
            }else if(globalParentMap.get(qt.Account__r.Parent.Parent.Id) != null){
                parentId = qt.Account__r.Parent.Parent.Id;  
            }else if(globalParentMap.get(qt.Account__r.Id) != null){
                parentId = qt.Account__r.Id;
            }else if(globalParentMap.get(qt.Account__r.Parent.Parent.Parent.Id) != null){
                parentId = qt.Account__r.Parent.Parent.Parent.Id;
            }else if(globalParentMap.get(qt.Account__r.Parent.Parent.Parent.Parent.Id) != null){
                parentId = qt.Account__r.Parent.Parent.Parent.Parent.Id;
            } 
        }else if(obj.Id.getSObjectType().getDescribe().getName() == 'Opportunity'){
            Opportunity opp = (Opportunity)obj; 
            if(globalParentMap.get(opp.Account.Parent.Id) != null){
                parentId = opp.Account.Parent.Id;
            }else if(globalParentMap.get(opp.Account.Parent.Parent.Id) != null){
                parentId = opp.Account.Parent.Parent.Id;  
            }else if(globalParentMap.get(opp.Account.Id) != null){
                parentId = opp.Account.Id;
            }else if(globalParentMap.get(opp.Account.Parent.Parent.Parent.Id) != null){
                parentId = opp.Account.Parent.Parent.Parent.Id;
            }else if(globalParentMap.get(opp.Account.Parent.Parent.Parent.Parent.Id) != null){
                parentId = opp.Account.Parent.Parent.Parent.Parent.Id;
            } 
        }else if(obj.Id.getSObjectType().getDescribe().getName() == 'Order'){
            Order ord = (Order)obj; 
            if(globalParentMap.get(ord.Account.Parent.Id) != null){
                parentId = ord.Account.Parent.Id;
            }else if(globalParentMap.get(ord.Account.Parent.Parent.Id) != null){
                parentId = ord.Account.Parent.Parent.Id;  
            }else if(globalParentMap.get(ord.Account.Id) != null){
                parentId = ord.Account.Id;
            }else if(globalParentMap.get(ord.Account.Parent.Parent.Parent.Id) != null){
                parentId = ord.Account.Parent.Parent.Parent.Id;
            }else if(globalParentMap.get(ord.Account.Parent.Parent.Parent.Parent.Id) != null){
                parentId = ord.Account.Parent.Parent.Parent.Parent.Id;
            } 
        }
        return  parentId;
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
    public class returnValue
    {
        public String csvBody{get;set;}
        public set<id> allAccSuccessId{get;set;}
    }
}