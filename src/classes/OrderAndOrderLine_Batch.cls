/*
* Created by : Pooja U
* Date : 23rd June 2021
* Description: 
*/
public class OrderAndOrderLine_Batch implements Database.Batchable<sObject>,Database.Stateful{
    List<Sobject> orderAndOrderLineListToUpdate=new List<Sobject>();
    public List<Sobject> start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        System.debug('start(Database.BatchableContext) - start');
        List<Sobject> orderAndOrderLineList=new List<Sobject>();
        List<Order> orderList=[Select Id,AccountId,Account.Global_Ultimate_Parent__c,Account.Global_Ultimate_Parent__r.OwnerId,OwnerId
                               from Order 
                               where Integration_Flag__c=true and Batch_Flag__c=false];
        orderAndOrderLineList.addAll(orderList);
        List<Order_Line__c> orderLineList=[Select Id,Order__c,Order__r.AccountId,Order__r.Account.Global_Ultimate_Parent__r.OwnerId,Customer_Name__c,Customer_Name__r.Global_Ultimate_Parent__c,Customer_Name__r.Global_Ultimate_Parent__r.OwnerId,OwnerId 
                                           from Order_Line__c 
                                           where Integration_Flag__c=true and Batch_Flag__c=false];
        orderAndOrderLineList.addAll(orderLineList);
        System.debug('start(Database.BatchableContext) - end');
        return orderAndOrderLineList;
    }
    public void execute(Database.BatchableContext bc, List<Sobject> orderAndOrderLineList){
        System.debug('execute(Database.BatchableContext,List<Sobject>) - start');
        if(orderAndOrderLineList!=null && !orderAndOrderLineList.isEmpty()){
            orderAndOrderLineListToUpdate.addAll(orderAndOrderLineList);
            
            
            
            
        }
        System.debug('execute(Database.BatchableContext,List<Sobject>) - end');
    }
    public void finish(Database.BatchableContext bc){
    }
}