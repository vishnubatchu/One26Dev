public with sharing class CreateFVReport {

//public static List<serialNumberFAAnalysisWrapper> serialNumbertable {get;set;}
public Order_line__c orderline { get; set; }
public List<Serial_Number__c> serialnumberList { get; set; }
public  List<FA_FV_Detail__c> fafvdetaillist{get;set;}
public static List<FA_FV_Analysis__c> fvAnalysisList { get; set; }
public static Map<Id,set<String>> fatosnMap { get; set; }
public createFVReport()
  {
         Id orderlineId = ApexPages.currentPage().getParameters().get('orderLine');
        String serialId =ApexPages.currentPage().getParameters().get('selectedSerialNumber');
         List<String> lstserialId = serialId.split(',');
        this.orderline=getOrderlineData(orderlineId);
        this.fafvdetaillist = getFVDetail(lstserialId);
        //this.serialnumberList = getSerialNumberData(lstserialId);
        //this.fvAnalysisList = getFAFVData(lstserialId);
        //this.serialNumbertable= prepareMapforSerialNumberTable(lstserialId);
  }

 public static Order_line__c getOrderlineData(Id orderlineId)
    {
        Order_line__c orderLine = [select id,Reported_Problem__c,Name,order__r.RMA_Request__r.CaseNumber,order__r.PoNumber,RMA_Received_Date__c,Owner.name,FA_FV_Completion_Date__c,order__r.Account.name,Part_Number__r.name,order__r.End_Customer__c,Marketing_Part__c
                                   from Order_line__c where id=:orderlineId];
       System.debug(orderLine);
        return orderLine;
    }
   public static List<Serial_Number__c> getSerialNumberData(List<String> lstserialId){
        List<Serial_Number__c> lstSerial =[Select id,Name,Customer_Serial_Number__c,Date_Code__c,Order_Line__r.Return_Reason__c
                                           from Serial_Number__c where id IN:lstserialId];
        system.debug('lstSerial'+lstSerial);
        return lstSerial;
    }
     public static List<FA_FV_Analysis__c> getFAFVData(List<String> lstserialId){ 
        fatosnMap = new Map<Id,set<String>>();
        Id recordType = Schema.SObjectType.FA_FV_Analysis__c.getRecordTypeInfosByName().get('FV Analysis').getRecordTypeId();
        Set<Id> fvids = new Set<Id>();
        Map<Id,List<String>> fvMap = new  Map<Id,List<String>>();
        List<FA_FV_Detail__c> fvdetailList =[select Serial_Number__c,Serial_Number__r.Name,Serial_Number__r.Customer_Serial_Number__c,FA_FV__c from FA_FV_Detail__c where Serial_Number__c IN:lstserialId ];
        system.debug('FADetail==='+fvdetailList);
        for(FA_FV_Detail__c fD:fvdetailList){
            fvids.add(fD.FA_FV__c);
            if(!fatosnMap.containsKey(fD.FA_FV__c)){
                fatosnMap.put(fD.FA_FV__c,new set<string>{fD.Serial_Number__r.Name});
            }else{
                fatosnMap.get(fD.FA_FV__c).add(fD.Serial_Number__r.Name);
            }
            
        } 
        System.debug('FAFVId=='+fvids);
 
        system.debug('FAtoSNMap==='+fatosnMap);
        List<FA_FV_Analysis__c> fvAnalysisList = [select id,Final_Function_Test__c,Temp_BERT__c  FROM FA_FV_Analysis__c where Id in :fvids];

        return fvAnalysisList;
    }
  public static List<FA_FV_Detail__c> getFVDetail(List<String> lstserialId)
  {
         System.debug('*********FA Detail Records**************');
          Id recordType = Schema.SObjectType.FA_FV_Analysis__c.getRecordTypeInfosByName().get('FV Analysis').getRecordTypeId();
      return [select Serial_Number__r.Name,Serial_Number__r.Date_Code__c,FA_FV__r.Final_Function_Test__c,FA_FV__r.Temp_BERT__c  From FA_FV_Detail__c where Serial_Number__c in :lstserialId  and FA_FV__r.RecordTypeId =:recordType ];
  }
}