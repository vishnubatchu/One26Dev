@isTest
public class UpdateGlobalUltimateParentBatchTest {
    @testSetup static void setup() {
        Profile salesUserProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Profile Clone' LIMIT 1];
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
        list<Account> globalParentList = new list<Account>();
        Account globalParentAcc=new Account(Name='Global Parent Test Acc',shippingcountry = 'USA',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Global_Parent').getRecordTypeId(),OwnerId=testUserList[0].Id	);
         globalParentList.add(globalParentAcc);
        Account globalParentAcc2=new Account(Name='Global Parent Test Acc2',shippingcountry = 'USA',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Global_Parent').getRecordTypeId()	);
         globalParentList.add(globalParentAcc2);
        insert globalParentList;
       
        Account topLevelAccount = new Account(Name='child1 ',ParentId = globalParentList[1].Id,Global_Ultimate_Parent__c=globalParentList[0].Id,shippingcountry = 'USA',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Party_Account').getRecordTypeId(),
                                     Status__c='Active'); 
        insert topLevelAccount;
         Account customerAccount=new Account(Name='customerAcc',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
                                     Site_Use_Code__c='SHIP_TO',Status__c='Active',ParentId = topLevelAccount.Id,
                                     Site_Use_Status__c='Active',shippingcity='New York',shippingcountry='USA',Type='Customer',
                                     Org_ID__c= '2');
        insert customerAccount;
    
  
        
        List<Contact> contactList=new List<Contact>();
        for(integer i = 0 ; i < 5 ; i++){
            contactList.add(new Contact(LastName='Test Contact '+i,FirstName = 'test',AccountId=customerAccount.Id));
        }  
        insert contactList;
        
        List<Opportunity> oppList=new List<Opportunity>();
        for(integer i = 0 ; i < 5 ; i++){
            oppList.add(new Opportunity(CloseDate=System.today(),AccountId=customerAccount.Id,ForecastCategoryName='Pipeline',
                                        Name='Test Opp '+i,StageName='Qualifying',Project_Name__c='Test',RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Aftermarket').getRecordTypeId()));
        } 
        insert oppList;
        
        List<Quote> quoteList=new List<Quote>();
       integer index=1;
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
        
    }
    
    @isTest static void testGlobalParentChange() {
        User testUser=[Select Id from User where lastName='User 2'];
        Account childAcc=[Select Id from Account where Name='customerAcc'];
        Account globalParent=[Select Id from Account where Name='Global Parent Test Acc2'];
        childAcc.Global_Ultimate_Parent__c=globalParent.Id;
        update childAcc;
        Test.startTest();
        UpdateGlobalUltimateParentBatch batchObj = new UpdateGlobalUltimateParentBatch();
        DataBase.executeBatch(batchObj);
        Test.stopTest();
          list<Account> finalList = [select id,Global_Parent_Updated__c from Account where Global_Parent_Updated__c = True]; 
     
    }
       @isTest static void testDoSubListHelperMethod() {
        Test.startTest();
        List<Account> orderList=[Select Id from Account];
        List<List<Sobject>> sObjectList=new List<List<Sobject>>();
        sObjectList = UpdateGlobalUltimateParentBatchHelper.doSubList(orderList);
        System.assertEquals(1,sObjectList.size());
        Test.stopTest();
    }
     @isTest static void testCreateCSVHelperMethod() {
        Test.startTest();
         list<Account> globalParentList = new list<Account>();
         for(integer i= 0; i<3 ; i++){
            Account globalParentAcc2=new Account(Name='Global Parent Test Acc2'+ i,shippingcountry = 'USA',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Global_Parent').getRecordTypeId()	);
         globalParentList.add(globalParentAcc2);  
         }
          Database.SaveResult[] srList = Database.insert(globalParentList, True); 
      string  sObjectList = UpdateGlobalUltimateParentBatchHelper.createCSVBody('Account',srList);
      //  System.assertEquals(1,sObjectList.size());
        Test.stopTest();
    }
}