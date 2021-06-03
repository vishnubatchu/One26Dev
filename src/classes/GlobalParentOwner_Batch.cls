public class GlobalParentOwner_Batch implements Database.Batchable<sObject>,Database.Stateful{
    List<GlobalParentOwnerBatch_Helper.CustomError> finalErrorList=new List<GlobalParentOwnerBatch_Helper.CustomError>();
    List<Account> accountListToUpdate=new List<Account>();
	string csvHeader = 'Record Id,Object Name,Operation, Error \n';
    string mainContent = csvHeader;
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
            accountListToUpdate.addAll(accountList);
            List<GlobalParentOwnerBatch_Helper.CustomError> errorList=GlobalParentOwnerBatch_Helper.deleteAndInsertShareRecords(accountList,true);
            //system.debug(errorList);
            if(errorList!=null && !errorList.isEmpty()){
                finalErrorList.addAll(errorList);
                for(GlobalParentOwnerBatch_Helper.CustomError eachError:errorList){
                    string errStr = eachError.id+','+eachError.objectName+','+eachError.operation+','+eachError.message +'\n';
                    mainContent += errStr;
                }
            }
        }
        System.debug('execute(Database.BatchableContext,List<Account>) - end');
    }
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        if(finalErrorList!=null && !finalErrorList.isEmpty()){
             GlobalParentOwnerBatch_Helper.sendEmail(mainContent);
        }
        if(accountListToUpdate!=null && !accountListToUpdate.isEmpty()){
            for(Account eachAcc:accountListToUpdate){
                eachAcc.Global_Parent_Previous_Owner__c=null;
            }
            update accountListToUpdate;
        }
    }
    
}