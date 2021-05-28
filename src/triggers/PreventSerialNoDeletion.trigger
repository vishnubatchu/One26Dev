trigger PreventSerialNoDeletion on Serial_Number__c (before delete) {
   String uRoleId = userinfo.getProfileId();
Profile ur = [Select id, Name from Profile where id  =: uRoleId ]; 
    if(ur.Name == 'System Administrator'){
    }else{
 for(Serial_Number__c sn : trigger.old){
        sn.adderror('Serial Number Cannot be deleted');
 } 
    }
}