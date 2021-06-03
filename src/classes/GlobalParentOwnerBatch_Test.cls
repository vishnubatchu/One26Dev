@isTest
public class GlobalParentOwnerBatch_Test {
	@testSetup static void setup() {
      Profile salesUserProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Profile' LIMIT 1];
      List<User>  testUserList=new List<User>();
      for(Integer i=0;i<2;i++){
          String orgId = userInfo.getOrganizationId();
          String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
          Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
          String uniqueName = orgId + dateString + randomInt;
          testUserList.add(new User(firstname = 'Test',
                              lastName = 'User '+(i+1),
                              email = uniqueName + '@test' + orgId + '.org',
                              Username = uniqueName + '@test' + orgId + '.org',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias = uniqueName.substring(18, 23),
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              ProfileId = salesUserProfile.Id,
                              isActive = True,
                              UserRoleId = null));  
        }
        insert testUserList;
        
      Account globalParentAcc=new Account(Name='Global Parent Test Acc',RecordTypeId=getRecordTypeIdByName('Global Parent'),OwnerId=testUserList[0].Id	);
      insert globalParentAcc;
        
      Account siteAcc=new Account(Name='Site Test Acc',RecordTypeId=getRecordTypeIdByName('Site'),
                                 Global_Ultimate_Parent__c=globalParentAcc.Id,Site_Use_Code__c='SHIP_TO',Status__c='Active',
                                 Site_Use_Status__c='Active',shippingcity='New York',shippingcountry='USA',Type='Customer',
                                      Org_ID__c= '2');
      insert siteAcc;
        
      List<Account> accList=new List<Account>(); 
        for(Integer i=1;i<=6;i++){
            accList.add(new Account(Name='Test Acc '+i,RecordTypeId=getRecordTypeIdByName('Customer Account'),
                                   Global_Ultimate_Parent__c=globalParentAcc.Id,Status__c='Active'));
        }  
        insert accList;
        
        List<Contact> contactList=new List<Contact>();
        Integer index=1;
        for(Account eachAcc:accList){
           contactList.add(new Contact(LastName='Test Contact '+index,AccountId=eachAcc.Id));
            index++;
        }  
        insert contactList;
        
        List<Opportunity> oppList=new List<Opportunity>();
        index=1;
        for(Account eachAcc:accList){
           oppList.add(new Opportunity(CloseDate=System.today(),AccountId=eachAcc.Id,ForecastCategoryName='Pipeline',
                      Name='Test Opp '+index,StageName='Qualifying',Project_Name__c='Test',RecordTypeId=getRecordTypeIdByName('Aftermarket')));
            index++;
        } 
        insert oppList;
        
        List<Quote> quoteList=new List<Quote>();
        index=1;
        for(Opportunity eachOpp:oppList){
           quoteList.add(new Quote(OpportunityId=eachOpp.Id,Account__c=eachOpp.AccountId,Name='Test Quote '+index));
            index++;
        }
        insert quoteList;
        
        List<Order> orderList=new List<Order>();
        index=1;
        for(Opportunity eachOpp:oppList){
           orderList.add(new Order(Legacy_Id__c='12345'+index,OpportunityId=eachOpp.Id,AccountId=eachOpp.AccountId,Name='Test Quote '+index,
                        EffectiveDate=System.today(),Status='Draft'));
            index++;
        }
        insert orderList;
        
        List<Order_Line__c> orderLineList=new List<Order_Line__c>();
        //index=1;
        for(Order eachOrder:orderList){
           orderLineList.add(new Order_Line__c(Order__c=eachOrder.Id,Customer_Name__c=eachOrder.AccountId));
            //index++;
        }
        insert orderLineList;
        
        List<Case> caseList=new List<Case>();
        //index=1;
        for(Account eachAcc:accList){
           caseList.add(new Case(RecordTypeId=getRecordTypeIdByName('RMA Request'),Failure_Location__c='Dead on Arrival',AccountId=eachAcc.Id,
                       Finisar_Sales_Manager__c=UserInfo.getUserId(),Requested_Service__c='Loaner Return',Billing_Type__c='Others',
                                Ship_To_Address__c=siteAcc.Id,Ship_To_Customer__c=eachAcc.Id));
            //index++;
        }  
        insert caseList;
    }
    
    @isTest static void testGlobalParentOwnerBatch() {
        User testUser=[Select Id from User where lastName='User 2'];
        Account globalParentAcc=[Select Id from Account where Name='Global Parent Test Acc'];
        globalParentAcc.OwnerId=testUser.Id;
        update globalParentAcc;
        Test.startTest();
        GlobalParentOwner_Batch batchObj = new GlobalParentOwner_Batch();
        DataBase.executeBatch(batchObj);
        Test.stopTest();
        List<Contact> cntctList=[Select Id from Contact];
        List<ContactShare> cntctShrList=[Select Id from ContactShare where UserOrGroupId=:testUser.Id and ContactAccessLevel='Read'
                                        and RowCause='Manual' and ContactId in: cntctList];
        
        System.assertEquals(cntctList.size(),
                             cntctShrList.size());
    }
    
    
    
    static Id getRecordTypeIdByName(String recordTypeName){
       return [Select Id from RecordType where Name=:recordTypeName].Id;
    }
}