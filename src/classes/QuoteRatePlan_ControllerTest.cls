@isTest(seeAllData = false)
private class QuoteRatePlan_ControllerTest {
    @isTest
    static void testRateController(){
        Test.loadData(Pricebook2.sObjectType, 'PriceListTestdata');
        List<Account> acc = TestDataFactory.createAccounts(1);
        system.debug('price book '+[Select id,Name from Pricebook2]);
        system.debug('standard '+ Test.getStandardPricebookId());
        List<Opportunity> opp = TestDataFactory.createOpportunity(1, acc[0].Id);
        List<Product2> prd = TestDataFactory.createProducts('2', 2, false);
        List<Pricebook2> pricel = [Select Id from Pricebook2 Where Name = 'Laser Part List' AND CurrencyIsoCode = 'USD'];
        system.debug('pricel '+pricel);
        opp[0].Pricebook2Id = pricel[0].Id;
        opp[0].CurrencyIsoCode = 'USD';
        update opp;
        PriceBookEntry pb = [Select Id from PriceBookEntry Where product2Id = :prd[0].Id AND CurrencyIsoCode = 'USD' AND PriceBook2Id = :pricel[0].Id limit 1];
        List<OpportunityLineItem> oppLines = TestDataFactory.creatOppLine(opp[0].Id, 2, prd[0].Id, pb.id);
        //TestDataFactory.createOppRatePla(oppLines[0].Id, 10, 100);
        List<Quote> qts = TestDataFactory.createQuote(opp[0].Id, pricel[0].Id, 1);
        List<Quote_Item__c> qLines =  TestDataFactory.createQuoteLines(qts[0].Id, prd[0].Id, pb.id, 1);
       // TestDataFactory.createQuoteRatePlan(qLines[0].Id, 20, 100);
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(qLines[0]);
        QuoteRatePlan_Controller testAccPlan = new QuoteRatePlan_Controller(sc);
        //PageReference pageRef = Page.OpportunityRatePlan;
        //Test.setCurrentPage(pageRef);
        testAccPlan.addNewRow();
        testAccPlan.CancelAction();
        QuoteRatePlan__c rate = new QuoteRatePlan__c(SequenceNumber__c = 9, SalesPrice__c = 20);
        testAccPlan.quoteTier.add(rate);
        testAccPlan.saveAction();
        test.stopTest();
    }
}