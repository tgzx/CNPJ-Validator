/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-18-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class TaxHelper {
    public TaxHelper() {}

    public static List<Tax__c> checkTaxDuplicated(List<Tax__c> newTaxList){

        List<Tax__c> buildedTaxList = new List<Tax__c>();

        List<Tax__c> oldTaxList = new List<Tax__c>([
            SELECT Id, Product__c, DistributionCenter__c, State__c, Status__c, TaxCosts__c
            FROM Tax__c
        ]);
        
        for(Tax__c iNewTax : newTaxList){
            for(Tax__c iOldTax : oldTaxList){
                if(iOldTax.Product__c            == iNewTax.Product__c 
                && iOldTax.DistributionCenter__c == iNewTax.DistributionCenter__c 
                && iOldTax.State__c              == iNewTax.State__c){
                    iNewTax.addError(Label.TaxDuplicateError);
                } else {
                    buildedTaxList.add(iNewTax);
                }
            }
        }

        return buildedTaxList;
    }
}
