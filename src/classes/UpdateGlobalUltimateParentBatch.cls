/**
     * Created by : Akhilesh
     * Date : 31th May 2021
     * Description: This Batch class has implemented as per below logic
     * a) If the Global Ultimate Parent is changed on a Top-Level Account or a Customer that serves as the immediate parent of a child account, then the child’s Global Ultimate Parent should match that of its immediate paren.
     * b) When the Global_Ultimate_Parent__c is changed on an Account that is populated in Opportunity.AccountId, Quote.AccountId, 
     * and Order.AccountId, a batch class properly updates Opportunity.Global_Ultimate_Account__c, 
     * Quote.Global_Ultimate_Account__c, and Order.Global_Ultimate_Account__c to reflect the Account’s Global_Ultimate_Parent__c
     */
public class UpdateGlobalUltimateParentBatch implements Database.Batchable <sObject>,Database.Stateful{ 
    public String query;
    public map<id,Account> accountMap = new map<id,Account>();
    public List<Id> accountlist = new list<Id>();
    public set<id> allAccSuccessId=new set<id>();
    public string csvBody;
    public string headerValue;
    public  List<GlobalParentOwnerBatch_Helper.CustomError> errorList = new List<GlobalParentOwnerBatch_Helper.CustomError>();
    //Header and body for faild record CSV file.
     public UpdateGlobalUltimateParentBatch(){
        csvBody = '';
        headerValue = 'Id,object, Error Message \n';
    }
    
    // Start Method : In start method we are fatching all the account and related child account where Global_Parent_Updated__c is true 
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        accountMap = new Map<Id, Account>([select id, Global_Parent_Updated__c,Global_Ultimate_Parent__c,Changed_Global_Parent_Old_Owner__c   from Account where Global_Parent_Updated__c  = True]);
        accountlist.addAll(accountMap.keySet());
        query = 'select id,Global_Parent_Updated__c,Global_Ultimate_Parent__c ,Parent.Id,Parent.parent.Id,Parent.parent.parent.Id,Parent.parent.parent.parent.Id ' +
            'from Account where Parent.Id In: accountlist Or Parent.Parent.Id In: accountlist Or Parent.Parent.Parent.Id In: accountlist Or Parent.parent.parent.parent.Id In: accountlist Or Id In: accountlist';
        return Database.getQueryLocator(query);
    }
    //Execute Method : Updating all the child account , and related Quote,order,Opportunity "Global_Ultimate_Account__c" and calling "GlobalParentOwnerBatch_Helper" with list of account. 
    public void execute(Database.BatchableContext BC,List<sObject> batch)
    {
        UpdateGlobalUltimateParentBatchHelper.returnValue  ret = UpdateGlobalUltimateParentBatchHelper.updateGlobalParent(batch,accountMap);
      csvBody += ret.csvBody;
        allAccSuccessId.addAll(ret.allAccSuccessId);
    }
    
    //Finish Method : Sending faild record to admin and reset "Global_Parent_Updated__c" flag
    public void finish(Database.BatchableContext BC) {
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
        list<Account> resetFlaglist = new list<Account>();
        if(finaAccllist.size() > 0 && finaAccllist != null){
            for(Account reset : finaAccllist){
                reset.Global_Parent_Updated__c = false;
                reset.Changed_Global_Parent_Old_Owner__c = null;
                resetFlaglist.add(reset); 
            }
            try{
            update resetFlaglist;
            }catch(Exception e){
                system.debug('**Error at line number---'+e.getLineNumber() + ' - '+ e.getMessage());
            }
        }
    }
}