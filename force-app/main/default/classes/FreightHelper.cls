/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-18-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class FreightHelper {
    public FreightHelper() {}

    public static List<Freight__c> checkFreightDuplicated(List<Freight__c> newFreightList){

        List<Freight__c> buildedFreightList = new List<Freight__c>();

        List<Freight__c> oldFreightList = new List<Freight__c>([
            SELECT Id, ProductHierarchy__c, Product__c, DistributionCenter__c, City__c, State__c, Country__c, Status__c, Value__c
            FROM Freight__c
        ]);
        
        for(Freight__c iNewFreight : newFreightList){
            for(Freight__c iOldFreight : oldFreightList){
                if(iOldFreight.ProductHierarchy__c   == iNewFreight.ProductHierarchy__c 
                && iOldFreight.Product__c            == iNewFreight.Product__c
                && iOldFreight.DistributionCenter__c == iNewFreight.DistributionCenter__c 
                && iOldFreight.City__c               == iNewFreight.City__c 
                && iOldFreight.State__c              == iNewFreight.State__c 
                && iOldFreight.Country__c            == iNewFreight.Country__c){
                    iNewFreight.addError(Label.FreightDuplicateError);
                } else {
                    buildedFreightList.add(iNewFreight);
                }
            }
        }

        return buildedFreightList;
    }
}