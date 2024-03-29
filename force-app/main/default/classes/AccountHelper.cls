/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-22-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public with sharing class AccountHelper {
    public AccountHelper() {}

    public static void CPNJValidate(List<Account> accountList){
        List<Account> accountCNPJList = new List<Account>();
        List<Account> oldAccountCNPJList = new List<Account>([
            SELECT Id, CNPJ__c
            FROM Account
        ]);

        for(Account iAccountCNPJ : accountList){

            String regexCNPJ;
            String numbersOnlyCNPJ = '';

            Pattern pattern = Pattern.compile('(\\d{2})[.](\\d{3})[.](\\d{3})[/](\\d{4})[-](\\d{2})');
            Matcher matcher = pattern.matcher(iAccountCNPJ.CNPJ__c);
            if(matcher.find()){
                regexCNPJ = matcher.replaceAll('$1.$2.$3/$4-$5');
            }

            String[] CNPJChar = iAccountCNPJ.CNPJ__c.split('');
    
            for (Integer i = 0; i < CNPJChar.size(); i++) {
                if('1234567890'.contains('' + CNPJChar[i])){
                    numbersOnlyCNPJ = numbersOnlyCNPJ + CNPJChar[i];
                }
            }
            
            if (iAccountCNPJ.CNPJ__c != regexCNPJ){
                iAccountCNPJ.addError('Insira o CNPJ com 14 dígitos e no seguinte formato: 99.999.999/9999-99');
            } else if (!CPNJValEngine(numbersOnlyCNPJ)){
                iAccountCNPJ.addError(Label.CNPJValidate);
            }

            for(Account iAccountCNPJOld : oldAccountCNPJList){
                if (iAccountCNPJ.CNPJ__c == iAccountCNPJOld.CNPJ__c){
                    iAccountCNPJ.addError(Label.DuplicateCNPJError);
                } 
            }
        }
    }

    public static Boolean CPNJValEngine(String CNPJ){

        Boolean testeBoolean = true;
        
        if (CNPJ == '00000000000000' || CNPJ == '11111111111111' || CNPJ == '22222222222222' || CNPJ == '33333333333333' || 
            CNPJ == '44444444444444' || CNPJ == '55555555555555' || CNPJ == '66666666666666' || CNPJ == '77777777777777' || 
            CNPJ == '88888888888888' || CNPJ == '99999999999999' || CNPJ.length() != 14){
            
                return false;
        }

        Integer sm, i, r, num, peso, dig13, dig14;

        List <String> cnpjString = CNPJ.split('');

        sm = 0;
        peso = 2;

        for (i = 11; i >= 0; i--) {

            num = Integer.valueOf(cnpjString[i]);
            sm = sm + (num * peso);
            peso = peso + 1;

            if (peso == 10){
                peso = 2;
            }
        }
    
        r = math.mod(sm, 11);

        if ((r == 0) || (r == 1)){
            dig13 = 0;
        } else {
            dig13 = Integer.valueOf(11 - r);
        }
    
        // Calculo do 2o. Digito Verificador
        sm = 0;
        peso = 2;
        
        for (i = 12; i >= 0; i--) {

            num = Integer.valueOf(cnpjString[i]);
            sm = sm + (num * peso);
            peso = peso + 1;

            if (peso == 10){
                peso = 2;         
            }            
        }
    
        r = math.mod(sm, 11);

        if ((r == 0) || (r == 1)){
            dig14 = 0;
        } else {
            dig14 = Integer.valueOf(11 - r);
        }
    
        // Verifica se os dígitos calculados conferem com os dígitos informados.
        if (dig13 == Integer.valueOf(cnpjString[12]) && dig14 == Integer.valueOf(cnpjString[13])){
            testeBoolean = true;
        } else {
            testeBoolean = false;
        }
        return testeBoolean;
    }
}