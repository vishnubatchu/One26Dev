@isTest
public class LeadTriggerTest {
	@isTest
    public static void testUpdateIndvidual(){
        Lead testLead = new Lead(FirstName = 'test first', LastName = 'test last', 
                                 Company = 'test company', Market__c = '10 - DSP', Display_ISO_Country__c = 'Albania');
        insert testLead;
    }
}