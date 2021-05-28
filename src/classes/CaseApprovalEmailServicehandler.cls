global class  CaseApprovalEmailServicehandler  implements Messaging.InboundEmailHandler {
    public static ID headerID;
    public static String headerObjectName;
    public static String action;
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.Inboundenvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String fromAddress = envelope.fromAddress;
        User user = [select id, name, UserRole.name from user where email = :fromAddress And isActive=True limit 1];
        List < String > plaintextbody = email.plainTextBody.split('\n', 0);
        if(plaintextbody.size()>0){
            action = plaintextbody.get(0).split(':').size()>1 ? plaintextbody.get(0).split(':').get(1).trim():'';
            
            for (String bodyString: plaintextbody) {
                IF(bodyString.contains('Id : [')) {
                    headerID = bodyString.substringAfter('Id : [').remove(']');
                }
                
            }	
            headerObjectName = headerID!=Null?headerId.getSObjectType().getDescribe().getName():'';
         
            
        }        
        if (CommonConstants.approvalActions.contains(action)) {
           // Group groupObj= [Select id,name from group where type ='Queue' and name ='CFO Queue'];
             Case caseObj = [Select id, CFO_User__c from case where id =:  headerID];
           Case_Approvers__mdt  cA = [SELECT MasterLabel,CFO_User__c FROM Case_Approvers__mdt  WHERE MasterLabel = 'Case BU GM Approvers'];
            User u = [select id, Email from User where Email =: cA.CFO_User__c Limit 1];
            List <ProcessInstanceWorkitem > pItemRecordList = New List<ProcessInstanceWorkitem>([Select Id,ActorId,ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =:headerID and ActorId =:u.id Limit 1]);
           
            if(pItemRecordList.size()>0){
                for(ProcessInstanceWorkitem pitemObj : pItemRecordList){
                    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                    req2.setComments('Approving request.');
                    req2.setAction('Approve');
                    req2.setWorkitemId(pitemObj.Id);
                    Approval.ProcessResult result2 = Approval.process(req2);
                }
                
            }
        }
            if (CommonConstants.rejectionActions.contains(action)) {
                System.debug('Inside Approve');
             Case_Approvers__mdt  cA = [SELECT MasterLabel,CFO_User__c FROM Case_Approvers__mdt  WHERE MasterLabel = 'Case BU GM Approvers'];
             Case caseObj = [Select id, CFO_User__c from case where id =:  headerID];
                User u = [select id, Email from User where Email =: cA.CFO_User__c Limit 1];
                List <ProcessInstanceWorkitem > pItemRecordList = New List<ProcessInstanceWorkitem>([Select Id,ActorId,ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =:headerID and ActorId =:u.id]);
                System.debug('pItemRecordList'+pItemRecordList);
                if(pItemRecordList.size()>0){
                    for(ProcessInstanceWorkitem pitemObj : pItemRecordList){
                        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                        req2.setComments('Rejecting request.');
                        req2.setAction('Reject');
                        req2.setWorkitemId(pitemObj.id);
                        Approval.ProcessResult result2 = Approval.process(req2);
                    }
                    
                }
                
            }
            
     
        return result;
    }
}