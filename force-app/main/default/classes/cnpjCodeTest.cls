public with sharing class cnpjCodeTest {
    public cnpjCodeTest() {

    }

    public static void CPNJValidate(List<String> CNPJ){
        //String CNPJ = '10.403.748/0001-99';
        String[] CNPJChar = CNPJ.split('');
        String cnpjMontado = '';

        for (Integer i = 0; i < CNPJChar.size(); i++) {
            if('1234567890'.contains('' + CNPJChar[i])){
                cnpjMontado = cnpjMontado + CNPJChar[i];
            }
        }

        for (PriceMargin__c CNPJ : CNPJbackup){
            if (!CPNJValEngine(CNPJ)){
                CNPJ.addError(Label.CNPJValidate);
            }
        }
    }

    public static Boolean CPNJValEngine(String CNPJ){
        
        if (CNPJ == "00000000000000" || 
            CNPJ == "11111111111111" || 
            CNPJ == "22222222222222" || 
            CNPJ == "33333333333333" || 
            CNPJ == "44444444444444" || 
            CNPJ == "55555555555555" || 
            CNPJ == "66666666666666" || 
            CNPJ == "77777777777777" || 
            CNPJ == "88888888888888" || 
            CNPJ == "99999999999999"){
                return false;
        }


        return true;
    }
}
