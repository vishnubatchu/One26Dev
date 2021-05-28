//Generated by wsdl2apex

public class servicesInformaticaComRtPrcCaiLoan {
    public class Prc_cai_loaner_mainRequest_element {
        public String in_loaner_request_id;
        private String[] in_loaner_request_id_type_info = new String[]{'in_loaner_request_id','http://services.informatica.com/rt/Prc_cai_loaner_main',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://services.informatica.com/rt/Prc_cai_loaner_main','false','false'};
        private String[] field_order_type_info = new String[]{'in_loaner_request_id'};
    }
    public class Prc_cai_loaner_mainResponse_element {
        public String error_message;
        public String status;
        private String[] error_message_type_info = new String[]{'error_message','http://services.informatica.com/rt/Prc_cai_loaner_main',null,'0','1','false'};
        private String[] status_type_info = new String[]{'status','http://services.informatica.com/rt/Prc_cai_loaner_main',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://services.informatica.com/rt/Prc_cai_loaner_main','false','false'};
        private String[] field_order_type_info = new String[]{'error_message','status'};
    }
    public class Prc_cai_loaner_main_Service {
        String loanerEndPoint = Label.LoanerRealTimeEndPoint;
        public String endpoint_x = loanerEndPoint;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x = Integer.valueOf(Label.LoanerLineItemTimeOut);
        private String[] ns_map_type_info = new String[]{'http://services.informatica.com/rt/Prc_cai_loaner_main', 'servicesInformaticaComRtPrcCaiLoan'};
        public servicesInformaticaComRtPrcCaiLoan.Prc_cai_loaner_mainResponse_element Prc_cai_loaner_main(String in_loaner_request_id) {
            servicesInformaticaComRtPrcCaiLoan.Prc_cai_loaner_mainRequest_element request_x = new servicesInformaticaComRtPrcCaiLoan.Prc_cai_loaner_mainRequest_element();
            request_x.in_loaner_request_id = in_loaner_request_id;
            servicesInformaticaComRtPrcCaiLoan.Prc_cai_loaner_mainResponse_element response_x;
            Map<String, servicesInformaticaComRtPrcCaiLoan.Prc_cai_loaner_mainResponse_element> response_map_x = new Map<String, servicesInformaticaComRtPrcCaiLoan.Prc_cai_loaner_mainResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'Prc_cai_loaner_main',
              'http://services.informatica.com/rt/Prc_cai_loaner_main',
              'Prc_cai_loaner_mainRequest',
              'http://services.informatica.com/rt/Prc_cai_loaner_main',
              'Prc_cai_loaner_mainResponse',
              'servicesInformaticaComRtPrcCaiLoan.Prc_cai_loaner_mainResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
}