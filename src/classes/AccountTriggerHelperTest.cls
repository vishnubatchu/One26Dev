@isTest
public class AccountTriggerHelperTest {
    @isTest
    public static void test(){
        Id siteRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId();
       	
        Id globalParentRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Parent').getRecordTypeId();

        Account parent = new Account(Name = 'Test ultimate ' + DateTime.now(), RecordTypeId = globalParentRT_Id,Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',ShippingCity = 'New York', ShippingCountry ='US');
        insert parent;
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        List<User> testUserList=new List<User>();
        System.runAs(usr){
        testUserList.add(new User(LastName='Usrlast1111',ProfileId=[SELECT Id from Profile where Name ='System Administrator'].Id,alias ='trsysy',Legacy_Company__c ='Finisar',
                                      Email='standarduser12@testorg.com',EmailEncodingKey='UTF-8',  LanguageLocaleKey='en_US', 
                                      LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', UserName='testuser12@finisar.com'));
            insert testUserList;
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Change_Account_Ownership'];
            insert new PermissionSetAssignment(AssigneeId = testUserList[0].id, PermissionSetId = ps.Id);
        }
        
       	Account acct = new Account(RecordTypeId = siteRT_Id, 
                                   Name = 'Test site ' + DateTime.now(), 
                                   ParentId = parent.Id,
                                   Global_Ultimate_Parent__c=parent.Id,
                                   ShippingState = 'NY',
                                   ShippingCity = 'Test City',
                                   ShippingCountry = 'IND',
                                   ShippingPostalCode = '560100',
                                   ShippingStreet = 'Test Street',
                                   Type = 'Site',
                                   AR_Amount__c = 0,
                                   Site_Use_Code__c='BILL_TO',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States'
                                  );
        insert acct; 
        
        acct.Type = 'Customer';
        acct.AR_Amount__c = 1;
                
        update acct;  
        
         System.runAs(testUserList[0]){
            parent.OwnerId=testUserList[0].Id;
            update parent;
        }
        
        System.assertEquals(1, acct.AR_Amount__c);
        System.assertEquals('Customer', acct.Type);
    }
    
   
}