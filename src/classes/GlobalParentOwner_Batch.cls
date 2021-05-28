public class GlobalParentOwner_Batch implements Database.Batchable<sObject>,Database.Stateful{
	List<Account> failedAccountRecords = new List<Account>();
    List<Account> successfullyProcessedAccounts = new List<Account>();
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        System.debug('start(Database.BatchableContext) - start');
        String accountQueryStr='Select Id,Global_Parent_Previous_Owner__c,Global_Ultimate_Parent__r.OwnerId from Account where Global_Parent_Previous_Owner__c!=null';
        System.debug('start(Database.BatchableContext) - end');
        return Database.getQueryLocator(accountQueryStr);
    }
    public void execute(Database.BatchableContext bc, List<Account> accountList){
        System.debug('execute(Database.BatchableContext,List<Account>) - start');
        System.debug('accountList'+accountList.size());
        // process each batch of records
        if(accountList!=null && !accountList.isEmpty()){
            try{
            Map<String,List<SObject>> shareRecordsMap=GlobalParentOwnerBatch_Helper.getShareRcrdsTobeDeletedOrInserted(accountList,true);
            System.debug('shareRecordsMap==>'+shareRecordsMap);
            if(shareRecordsMap!=null && !shareRecordsMap.isEmpty()){
                List<Sobject> listOfShareRecTobeDeleted=new List<Sobject>();
                List<Sobject> listOfShareRecTobeInserted=new List<Sobject>();
                if(shareRecordsMap.containsKey('deleteList') && shareRecordsMap.get('deleteList')!=null
                   && !shareRecordsMap.get('deleteList').isEmpty()){
                       listOfShareRecTobeDeleted.addAll(shareRecordsMap.get('deleteList'));
                   }
                 if(shareRecordsMap.containsKey('insertList') && shareRecordsMap.get('insertList')!=null
                   && !shareRecordsMap.get('insertList').isEmpty()){
                       listOfShareRecTobeInserted.addAll(shareRecordsMap.get('insertList'));
                   }
                if(!listOfShareRecTobeDeleted.isEmpty() && !listOfShareRecTobeInserted.isEmpty()){
                    
                   	delete  listOfShareRecTobeDeleted;
                    insert listOfShareRecTobeInserted;
                    
                }else if(!listOfShareRecTobeInserted.isEmpty()){
                    insert listOfShareRecTobeInserted;
                }
                
            }
              successfullyProcessedAccounts.addAll(accountList);  
            }catch(Exception excpn){
                System.debug('Exception occured==>'+excpn.getMessage());
                failedAccountRecords.addAll(accountList);
            }
        
        }
        System.debug('execute(Database.BatchableContext,List<Account>) - end');
    }
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        if(successfullyProcessedAccounts!=null && !successfullyProcessedAccounts.isEmpty()){
            for(Account eachAcc:successfullyProcessedAccounts){
                eachAcc.Global_Parent_Previous_Owner__c=null;
            }
            update successfullyProcessedAccounts;
        }
    }
    
}