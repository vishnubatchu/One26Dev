public class GlobalParentOwnerBatch_Helper {
    public static Map<String,List<SObject>> getShareRcrdsTobeDeletedOrInserted(List<Account> accountList,boolean isOwnerChange){
        System.debug('getShareRcrdsTobeDeletedOrInserted(List<Account>,boolean) - start');
        Map<String,List<SObject>> finalReturnMap=new Map<String,List<SObject>>();
        if(accountList!=null && !accountList.isEmpty()){
            
            Set<Id> previousOwnerIdSet=new Set<Id>();
            for(Account eachAcc:accountList){
                if(isOwnerChange){
                    previousOwnerIdSet.add(eachAcc.Global_Parent_Previous_Owner__c);
                }else{
                    if(eachAcc.Changed_Global_Parent_Old_Owner__c!=null){
                        previousOwnerIdSet.add(eachAcc.Changed_Global_Parent_Old_Owner__c);
                    }
                    
	            }
                
            }
            System.debug('previousOwnerIdSet'+previousOwnerIdSet);
            processReturnedMap(getContactShareRecords(accountList,previousOwnerIdSet),finalReturnMap);
            processReturnedMap(getOppShareRecords(accountList,previousOwnerIdSet),finalReturnMap);
            processReturnedMap(getQuoteShareRecords(accountList,previousOwnerIdSet),finalReturnMap);
            processReturnedMap(getOrderShareRecords(accountList,previousOwnerIdSet),finalReturnMap);
            processReturnedMap(getOrderLineShareRecords(accountList,previousOwnerIdSet),finalReturnMap);
            processReturnedMap(getCaseShareRecords(accountList,previousOwnerIdSet),finalReturnMap);
            
        }
        System.debug('finalReturnMap'+finalReturnMap);
        System.debug('getShareRcrdsTobeDeletedOrInserted(List<Account>,boolean) - end');
        return finalReturnMap;
        
    }
    
    
	public static Map<String,List<Sobject>> getContactShareRecords(List<Account> accountList,Set<Id> previousOwnerIdSet){
       	Map<String,List<Sobject>> contactShareRecordsMap=new Map<String,List<Sobject>>();
        List<Sobject> cntctShrListTobeInsrtd=new List<ContactShare>();
        List<Sobject> cntctShrListTobeDltd=new List<ContactShare>();
        List<Contact> contactList=[Select Id,Account.Global_Parent_Previous_Owner__c,Account.Global_Ultimate_Parent__r.OwnerId,(Select Id from Shares where RowCause='Manual' 
                                   and ContactAccessLevel='Read' and UserOrGroupId IN :previousOwnerIdSet) 
                                   from Contact 
                                   where AccountId IN: accountList];
        for(Contact eachCon:contactList){
            if(eachCon.Shares!=null){
                cntctShrListTobeDltd.addAll(eachCon.Shares);
            }
            cntctShrListTobeInsrtd.add(new ContactShare(ContactId=eachCon.Id,UserOrGroupId=eachCon.Account.Global_Ultimate_Parent__r.OwnerId,
                                                       RowCause='Manual',ContactAccessLevel='Read'));
        }
        contactShareRecordsMap.put('deleteList',cntctShrListTobeDltd);
        contactShareRecordsMap.put('insertList',cntctShrListTobeInsrtd);
        return contactShareRecordsMap;
    }

    public static Map<String,List<Sobject>> getOppShareRecords(List<Account> accountList,Set<Id> previousOwnerIdSet){
        Map<String,List<Sobject>> oppShareRecordsMap=new Map<String,List<Sobject>>();
        List<Sobject> oppShrListTobeInsrtd=new List<OpportunityShare>();
        List<Sobject> oppShrListTobeDltd=new List<OpportunityShare>();
        List<Opportunity> oppList=[Select Id,Account.Global_Parent_Previous_Owner__c,Account.Global_Ultimate_Parent__r.OwnerId,(Select Id from Shares where RowCause='Manual' 
                                   and OpportunityAccessLevel='Read' and UserOrGroupId IN :previousOwnerIdSet) 
                                   from Opportunity 
                                   where AccountId IN: accountList];
        for(Opportunity eachOpp:oppList){
            if(eachOpp.Shares!=null){
                oppShrListTobeDltd.addAll(eachOpp.Shares);
            }
            oppShrListTobeInsrtd.add(new OpportunityShare(OpportunityId=eachOpp.Id,UserOrGroupId=eachOpp.Account.Global_Ultimate_Parent__r.OwnerId,
                                                       RowCause='Manual',OpportunityAccessLevel='Read'));
        }
        oppShareRecordsMap.put('deleteList',oppShrListTobeDltd);
        oppShareRecordsMap.put('insertList',oppShrListTobeInsrtd);
        return oppShareRecordsMap;
    }
    
    public static Map<String,List<Sobject>> getQuoteShareRecords(List<Account> accountList,Set<Id> previousOwnerIdSet){
        Map<String,List<Sobject>> quoteShareRecordsMap=new Map<String,List<Sobject>>();
        List<Sobject> quoteShrListTobeInsrtd=new List<QuoteShare>();
        List<Sobject> quoteShrListTobeDltd=new List<QuoteShare>();
        List<Quote> quoteList=[Select Id,Account.Global_Parent_Previous_Owner__c,Account.Global_Ultimate_Parent__r.OwnerId,(Select Id from Shares where RowCause='Manual' 
                                   and AccessLevel='Read' and UserOrGroupId IN :previousOwnerIdSet) 
                                   from Quote 
                                   where AccountId IN: accountList];
        for(Quote eachQuote:quoteList){
            if(eachQuote.Shares!=null){
                quoteShrListTobeDltd.addAll(eachQuote.Shares);
            }
            quoteShrListTobeInsrtd.add(new QuoteShare(ParentId=eachQuote.Id,UserOrGroupId=eachQuote.Account.Global_Ultimate_Parent__r.OwnerId,
                                                       RowCause='Manual',AccessLevel='Read'));
        }
        quoteShareRecordsMap.put('deleteList',quoteShrListTobeDltd);
        quoteShareRecordsMap.put('insertList',quoteShrListTobeInsrtd);
        return quoteShareRecordsMap;
    }
    
    public static Map<String,List<Sobject>> getOrderShareRecords(List<Account> accountList,Set<Id> previousOwnerIdSet){
        Map<String,List<Sobject>> orderShareRecordsMap=new Map<String,List<Sobject>>();
        List<Sobject> orderShrListTobeInsrtd=new List<OrderShare>();
        List<Sobject> orderShrListTobeDltd=new List<OrderShare>();
        List<Order> orderList=[Select Id,Account.Global_Parent_Previous_Owner__c,Account.Global_Ultimate_Parent__r.OwnerId,(Select Id from Shares where RowCause='Manual' 
                                   and OrderAccessLevel='Read' and UserOrGroupId IN :previousOwnerIdSet) 
                                   from Order 
                                   where AccountId IN: accountList];
        for(Order eachOrder:orderList){
            if(eachOrder.Shares!=null){
                orderShrListTobeDltd.addAll(eachOrder.Shares);
            }
            orderShrListTobeInsrtd.add(new OrderShare(OrderId=eachOrder.Id,UserOrGroupId=eachOrder.Account.Global_Ultimate_Parent__r.OwnerId,
                                                       RowCause='Manual',OrderAccessLevel='Read'));
        }
        orderShareRecordsMap.put('deleteList',orderShrListTobeDltd);
        orderShareRecordsMap.put('insertList',orderShrListTobeInsrtd);
        return orderShareRecordsMap;
    }
    
    public static Map<String,List<Sobject>> getOrderLineShareRecords(List<Account> accountList,Set<Id> previousOwnerIdSet){
        Map<String,List<Sobject>> orderLineShareRecordsMap=new Map<String,List<Sobject>>();
        List<Sobject> orderLineShrListTobeInsrtd=new List<Order_Line__Share>();
        List<Sobject> orderLineShrListTobeDltd=new List<Order_Line__Share>();
        List<Order_Line__c> orderLineList=[Select Id,Customer_Name__r.Global_Parent_Previous_Owner__c,Customer_Name__r.Global_Ultimate_Parent__r.OwnerId,(Select Id from Shares where RowCause='Manual' 
                                   and AccessLevel='Read' and UserOrGroupId IN :previousOwnerIdSet) 
                                   from Order_Line__c 
                                   where Customer_Name__c IN: accountList];
        for(Order_Line__c eachOrderLine:orderLineList){
            if(eachOrderLine.Shares!=null){
                orderLineShrListTobeDltd.addAll(eachOrderLine.Shares);
            }
            orderLineShrListTobeInsrtd.add(new Order_Line__Share(ParentId=eachOrderLine.Id,UserOrGroupId=eachOrderLine.Customer_Name__r.Global_Ultimate_Parent__r.OwnerId,
                                                       RowCause='Manual',AccessLevel='Read'));
        }
        orderLineShareRecordsMap.put('deleteList',orderLineShrListTobeDltd);
        orderLineShareRecordsMap.put('insertList',orderLineShrListTobeInsrtd);
        return orderLineShareRecordsMap;
    }
    
    
    public static Map<String,List<Sobject>> getCaseShareRecords(List<Account> accountList,Set<Id> previousOwnerIdSet){
        Map<String,List<Sobject>> caseShareRecordsMap=new Map<String,List<Sobject>>();
        List<Sobject> caseShrListTobeInsrtd=new List<CaseShare>();
        List<Sobject> caseShrListTobeDltd=new List<CaseShare>();
        List<Case> caseList=[Select Id,Account.Global_Parent_Previous_Owner__c,Account.Global_Ultimate_Parent__r.OwnerId,(Select Id from Shares where RowCause='Manual' 
                                   and CaseAccessLevel='Read' and UserOrGroupId IN :previousOwnerIdSet) 
                                   from Case 
                                   where AccountId IN: accountList];
        for(Case eachCase:caseList){
            if(eachCase.Shares!=null){
                caseShrListTobeDltd.addAll(eachCase.Shares);
            }
            caseShrListTobeInsrtd.add(new CaseShare(CaseId=eachCase.Id,UserOrGroupId=eachCase.Account.Global_Ultimate_Parent__r.OwnerId,
                                                       RowCause='Manual',CaseAccessLevel='Read'));
        }
        caseShareRecordsMap.put('deleteList',caseShrListTobeDltd);
        caseShareRecordsMap.put('insertList',caseShrListTobeInsrtd);
        return caseShareRecordsMap;
    }
    
    public static void processReturnedMap(Map<String,List<Sobject>> shareRecMap,Map<String,List<SObject>> finalReturnMap){
        System.debug('processReturnedMap(Map<String,List<Sobject>>,Map<String,List<SObject>>) - start');
        System.debug('shareRecMap==>'+shareRecMap);
        if(shareRecMap!=null && !shareRecMap.isEmpty()){
             List<SObject> shareRecordsToBeDeleted=new List<SObject>();
            List<SObject> shareRecordsToBeInserted=new List<SObject>();
            if(finalReturnMap!=null && !finalReturnMap.isEmpty()){
                if(finalReturnMap.containsKey('deleteList') && finalReturnMap.get('deleteList')!=null && !finalReturnMap.get('deleteList').isEmpty()){
                    shareRecordsToBeDeleted.addAll(finalReturnMap.get('deleteList'));
                }
                if(finalReturnMap.containsKey('insertList') && finalReturnMap.get('insertList')!=null && !finalReturnMap.get('insertList').isEmpty()){
                    shareRecordsToBeInserted.addAll(finalReturnMap.get('insertList'));
                }
            }
            if(shareRecMap.containsKey('deleteList') && shareRecMap.get('deleteList')!=null && !shareRecMap.get('deleteList').isEmpty()){
         		shareRecordsToBeDeleted.addAll(shareRecMap.get('deleteList'));
            }
            if(shareRecMap.containsKey('insertList') && shareRecMap.get('insertList')!=null && !shareRecMap.get('insertList').isEmpty()){
                shareRecordsToBeInserted.addAll(shareRecMap.get('insertList'));
            }
            finalReturnMap.put('deleteList',shareRecordsToBeDeleted);
            finalReturnMap.put('insertList',shareRecordsToBeInserted);
        }
        System.debug('processReturnedMap(Map<String,List<Sobject>>,Map<String,List<SObject>>) - end');
    }
    
}