//Generated by wsdl2apex

public class servicesInformaticaComRtPrcCaiQuot {
    public class prc_cai_quote_mainRequest_element {
        public String in_quote_number;
        private String[] in_quote_number_type_info = new String[]{'in_quote_number','http://services.informatica.com/rt/prc_cai_quote_main',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://services.informatica.com/rt/prc_cai_quote_main','false','false'};
        private String[] field_order_type_info = new String[]{'in_quote_number'};
    }
    public class prc_cai_quote_mainResponse_element {
        public String out_error_message;
        public String out_status;
        private String[] out_error_message_type_info = new String[]{'out_error_message','http://services.informatica.com/rt/prc_cai_quote_main',null,'0','1','false'};
        private String[] out_status_type_info = new String[]{'out_status','http://services.informatica.com/rt/prc_cai_quote_main',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://services.informatica.com/rt/prc_cai_quote_main','false','false'};
        private String[] field_order_type_info = new String[]{'out_error_message','out_status'};
    }
    public class prc_cai_quote_main_Service {
        String quoteEndPoint = Label.QuoteRealTimeEndPoint;
        public String endpoint_x = quoteEndPoint;
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x = Integer.valueOf(Label.QuoteLineItemTimeOut);
        private String[] ns_map_type_info = new String[]{'http://services.informatica.com/rt/prc_cai_quote_main', 'servicesInformaticaComRtPrcCaiQuot'};
        public servicesInformaticaComRtPrcCaiQuot.prc_cai_quote_mainResponse_element prc_cai_quote_main(String in_quote_number) {
            servicesInformaticaComRtPrcCaiQuot.prc_cai_quote_mainRequest_element request_x = new servicesInformaticaComRtPrcCaiQuot.prc_cai_quote_mainRequest_element();
            request_x.in_quote_number = in_quote_number;
            servicesInformaticaComRtPrcCaiQuot.prc_cai_quote_mainResponse_element response_x;
            Map<String, servicesInformaticaComRtPrcCaiQuot.prc_cai_quote_mainResponse_element> response_map_x = new Map<String, servicesInformaticaComRtPrcCaiQuot.prc_cai_quote_mainResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'prc_cai_quote_main',
              'http://services.informatica.com/rt/prc_cai_quote_main',
              'prc_cai_quote_mainRequest',
              'http://services.informatica.com/rt/prc_cai_quote_main',
              'prc_cai_quote_mainResponse',
              'servicesInformaticaComRtPrcCaiQuot.prc_cai_quote_mainResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
}