/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-15-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class TaxHelper {
    public TaxHelper() {}

    public static List<OrderItem> refindTaxs(List<Tax__c> oldTaxList){

        List<OrderItem> orderItemFullList = new List<OrderItem>([
            SELECT Id, OrderId, Product2Id, Product2.ProductHierarchy__c, Order.AccountId, Order.Account.AccountGroup__c, Order.Account.Name, Order.AccountAddress__c, Order.AccountAddress__r.City__c, Order.AccountAddress__r.City__r.State__c, Order.AccountAddress__r.City__r.State__r.Country__c, TaxPercentage__c, MarginPercentage__c
            FROM OrderItem
        ]);

        List<OrderItem> orderItemList = OrderItemHelper.ruleTax(orderItemFullList);

        return orderItemList;
    }

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
