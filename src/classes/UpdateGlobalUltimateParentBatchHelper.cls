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
    
    public static string updateGlobalParent(List<Account> accountList){
        List<GlobalParentOwnerBatch_Helper.CustomError> errorList = new List<GlobalParentOwnerBatch_Helper.CustomError>();
        list<sobject> finalUpdateList = new list<sobject>();
        map<id,Account> parentMap = new map<id,Account>();
        string csvBody  = '';
    //GlobalParentOwnerBatch_Helper call
            errorList=GlobalParentOwnerBatch_Helper.deleteAndInsertShareRecords(accountList,false);
            for(GlobalParentOwnerBatch_Helper.CustomError err : errorList){
                csvBody += err.ID+ ',';
                csvBody += err.objectName + ','; 
                csvBody += err.message + ','; 
                csvBody += '\n';
            }
        // Order update List Creation 
        for(opportunity op : [select id,AccountId ,Account.Global_Ultimate_Parent__c,Global_Ultimate_Account__c   from opportunity Where AccountId  In: accountList ]){
            op.Global_Ultimate_Account__c = op.Account.Global_Ultimate_Parent__c;
            finalUpdateList.add(op); 
        }
        
        // Order update List Creation 
        for(Order ord : [select id,AccountId ,Account.Global_Ultimate_Parent__c,Global_Ultimate_Account__c   from Order Where AccountId  In:accountList ]){
            ord.Global_Ultimate_Account__c = ord.Account.Global_Ultimate_Parent__c;
            finalUpdateList.add(ord); 
        }
        
        
        // Quote update List Creation 
        for(Quote Qt : [select id,Account__c,Account__r.Global_Ultimate_Parent__c,Global_Ultimate_Account__c  from Quote Where Account__c In:accountList ]){
            Qt.Global_Ultimate_Account__c = Qt.Account__r.Global_Ultimate_Parent__c;
            finalUpdateList.add(Qt); 
        }
        
        //Update finalUpdateList
            if(finalUpdateList.size() > 0 && finalUpdateList != null ){
                        Database.SaveResult[] srList = Database.Update(finalUpdateList, false); 
                        for (Database.SaveResult sr : srList) {
                            if (sr.isSuccess()) {
                            }
                            else {
                                String message='';
                                // Operation failed, so get all errors                
                                for(Database.Error err : sr.getErrors()) {
                                    message+= err.getMessage();
                                }
                            }
                        } 
            }
        return csvBody;
    }
    public static string createCSVBody(string ObjName ,database.SaveResult[] updateResult){
        string body = '';
        
        for(Integer i=0; i < updateResult.size(); i++) {
            
            if(!updateResult.get(i).isSuccess() || Test.isRunningTest()) {
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
}