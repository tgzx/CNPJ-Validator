/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-18-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class MarginHelper {
    public MarginHelper() {}

    public static List<Margin__c> checkMarginDuplicated(List<Margin__c> newMarginList){

        List<Margin__c> buildedMarginList = new List<Margin__c>();

        List<Margin__c> oldMarginList = new List<Margin__c>([
            SELECT Id, ProductHierarchy__c, Product__c, AccountGroup__c, Account__c, DistributionCenter__c, City__c, State__c, Country__c, Status__c, Value__c
            FROM Margin__c
        ]);
        
        for(Margin__c iNewMargin : newMarginList){
            for(Margin__c iOldMargin : oldMarginList){
                if(iOldMargin.ProductHierarchy__c   == iNewMargin.ProductHierarchy__c 
                && iOldMargin.Product__c            == iNewMargin.Product__c 
                && iOldMargin.AccountGroup__c       == iNewMargin.AccountGroup__c 
                && iOldMargin.Account__c            == iNewMargin.Account__c 
                && iOldMargin.DistributionCenter__c == iNewMargin.DistributionCenter__c 
                && iOldMargin.City__c               == iNewMargin.City__c 
                && iOldMargin.State__c              == iNewMargin.State__c 
                && iOldMargin.Country__c            == iNewMargin.Country__c){
                    iNewMargin.addError(Label.MarginDuplicateError);
                } else {
                    buildedMarginList.add(iNewMargin);
                }
            }
        }

        return buildedMarginList;
    }
}
