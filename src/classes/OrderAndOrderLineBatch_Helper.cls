public class OrderAndOrderLineBatch_Helper {
    
    //This method inserts share records
    public static List<CustomError> updateOrderAndInsertShareRecords(List<Sobject> orderAndOrderLineList){
        List<CustomError> errorList=new List<CustomError>();
        if(orderAndOrderLineList!=null && !orderAndOrderLineList.isEmpty()){
            try{
                List<Order> orderListToUpdate=new List<Order>();
                List<OrderShare> orderShrListTobeInsrtd=new List<OrderShare>();
				List<Order_Line__Share> orderLineShrListTobeInsrtd=new List<Order_Line__Share>();
                for(Sobject eachSobj:orderAndOrderLineList){
                    if(eachSobj.Id.getSObjectType().getDescribe().getName()=='Order'){
                        Order orderRec=(Order)eachSobj;
                        if(orderRec.AccountId!=null && orderRec.Account.Global_Ultimate_Parent__c!=null){
                            Order OrderRecTobeUpdated=new Order();
                			OrderRecTobeUpdated.Id=orderRec.Id;
                            OrderRecTobeUpdated.Global_Ultimate_Account__c=orderRec.Account.Global_Ultimate_Parent__c;
                            orderListToUpdate.add(OrderRecTobeUpdated);
                            if(orderRec.OwnerId!=orderRec.Account.Global_Ultimate_Parent__r.OwnerId){
                                orderShrListTobeInsrtd.add(new OrderShare(OrderId=orderRec.Id,UserOrGroupId=orderRec.Account.Global_Ultimate_Parent__r.OwnerId,
                                                                          RowCause='Manual',OrderAccessLevel='Read'));
                            }
                        }
                    }else{
                        Order_Line__c OrderLineRec=(Order_Line__c)eachSobj;
                        if(OrderLineRec.Order__c!=null && 
                           OrderLineRec.Order__r.AccountId!=null && OrderLineRec.Order__r.Account.Global_Ultimate_Parent__c!=null
                          	&& OrderLineRec.OwnerId!=OrderLineRec.Order__r.Account.Global_Ultimate_Parent__r.OwnerId){
							orderLineShrListTobeInsrtd.add(new Order_Line__Share(ParentId=OrderLineRec.Id,UserOrGroupId=OrderLineRec.Order__r.Account.Global_Ultimate_Parent__r.OwnerId,
                                                                          RowCause='Manual',AccessLevel='Read'));
                        }
                    }
                }
                
                List<SObject> listOfShareRecTobeInserted=new List<Sobject>();
                
                if(!listOfShareRecTobeInserted.isEmpty()){
                    system.debug('listOfShareRecTobeInserted@@@@@' + listOfShareRecTobeInserted.size());
                    Database.SaveResult[] srList = Database.insert(listOfShareRecTobeInserted, false);
                    // Iterate through each returned result
                    for (Database.SaveResult sr : srList) {
                        if (sr.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            System.debug('Successfully inserted share record. share record ID: ' + sr.getId());
                        }
                        else {
                            String message='';
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Fields that affected this error: ' + err.getFields());
                                message+= err.getMessage();
                            }
                            errorList.add(new CustomError('','','Insert',message));
                        }
                    }
                }
            }catch(Exception excpn){
                System.debug('Exception occured==>'+excpn.getMessage());
                errorList.add(new CustomError('','','','Exception occured==>'+excpn.getMessage()));
            }
        }
        return errorList;
    }
    
    
    
    public class CustomError
    {
        public String id{get;set;}
        public String objectName{get;set;}
        public String operation{get;set;}
        public String message{get;set;}
        CustomError(String id,String objectName,String operation,String message){
            this.id=id;
            this.objectName=objectName;
            this.operation=operation;
            this.message=message;
        }
    }
}