/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-14-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class MarginHelper {
    public MarginHelper() {}

    public static List<OrderItem> refindMargins(List<Margin__c> newMarginList){

        List<OrderItem> orderItemFullList = new List<OrderItem>([
            SELECT Id, OrderId, Product2Id, Product2.ProductHierarchy__c, Order.AccountId, Order.Account.AccountGroup__c, Order.Account.Name, Order.AccountAddress__c, Order.AccountAddress__r.City__c, Order.AccountAddress__r.City__r.State__c, Order.AccountAddress__r.City__r.State__r.Country__c, MarginPercentage__c, TaxPercentage__c
            FROM OrderItem
        ]);

        List<OrderItem> orderItemList = OrderItemHelper.ruleMargin(orderItemFullList);

        return orderItemList;
    }

    public static List<Margin__c> checkMarginDuplicatedUpdated(List<Margin__c> newMarginList){

        List<Margin__c> buildedMarginList = new List<Margin__c>();

        System.debug('newMarginList' + newMarginList);

        List<Margin__c> oldMarginList = new List<Margin__c>([
            SELECT Id, ProductHierarchy__c, Product__c, AccountGroup__c, Account__c, DistributionCenter__c, City__c, State__c, Country__c, Status__c, Value__c
            FROM Margin__c
        ]);

        for(Margin__c iOldMargin : oldMarginList){
            for(Margin__c iNewMargin : newMarginList){
                if(iOldMargin.Id == iNewMargin.Id){
                    if(iOldMargin.ProductHierarchy__c != iNewMargin.ProductHierarchy__c ){
                        iOldMargin.ProductHierarchy__c = iNewMargin.ProductHierarchy__c;
                    }
                    
                    if(iOldMargin.Product__c != iNewMargin.Product__c ){
                        iOldMargin.Product__c = iNewMargin.Product__c;
                    }
                    
                    if(iOldMargin.AccountGroup__c != iNewMargin.AccountGroup__c ){
                        iOldMargin.AccountGroup__c = iNewMargin.AccountGroup__c;
                    }
                    
                    if(iOldMargin.Account__c != iNewMargin.Account__c ){
                        iOldMargin.Account__c = iNewMargin.Account__c;
                    }
                    
                    if(iOldMargin.DistributionCenter__c != iNewMargin.DistributionCenter__c ){
                        iOldMargin.DistributionCenter__c = iNewMargin.DistributionCenter__c;
                    }
                    
                    if(iOldMargin.City__c != iNewMargin.City__c ){
                        iOldMargin.City__c = iNewMargin.City__c;
                    }
                    
                    if(iOldMargin.State__c != iNewMargin.State__c ){
                        iOldMargin.State__c = iNewMargin.State__c;
                    }
                    
                    if(iOldMargin.Country__c != iNewMargin.Country__c ){
                        iOldMargin.Country__c = iNewMargin.Country__c;
                    }
                }
            }
            
            buildedMarginList.add(iOldMargin);
        }

        return MarginHelper.checkMarginDuplicated(buildedMarginList);
    }

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
                && iOldMargin.Country__c            == iNewMargin.Country__c 
                && iOldMargin.Value__c              == iNewMargin.Value__c){
                    iNewMargin.addError(Label.MarginDuplicateError);
                } else {
                    buildedMarginList.add(iNewMargin);
                }
            }
        }

        return buildedMarginList;
    }
}
