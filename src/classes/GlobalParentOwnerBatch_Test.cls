@isTest
public class GlobalParentOwnerBatch_Test {
	@testSetup static void setup() {
      Account globalParentAcc=new Account(Name='Global Parent Test Acc',RecordTypeId=getRecordTypeIdByName('Global Parent'));
      insert globalParentAcc;
        
      List<Account> accList=new List<Account>(); 
        for(Integer i=1;i<=6;i++){
            accList.add(new Account(Name='Test Acc '+i,RecordTypeId=getRecordTypeIdByName('Customer Account'),
                                   Global_Ultimate_Parent__c=globalParentAcc.Id));
        }  
        
        List<Contact> contactList=new List<Contact>();
        Integer index=1;
        for(Account eachAcc:accList){
           contactList.add(new Contact(LastName='Test Contact'+index,AccountId=eachAcc.Id));
            index++;
        }        
    }
    
    
    
    static Id getRecordTypeIdByName(String recordTypeName){
       return [Select Id from RecordType where Name=:recordTypeName].Id;
    }
}