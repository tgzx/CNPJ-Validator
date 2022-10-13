/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-13-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class OrderItemHelper {
    public OrderItemHelper() {}

    public static List<OrderItem> ruleMargin(List<OrderItem> orderItemList){
        
        Set<Id> orderItemSetId = new Set<Id>();

        for(OrderItem orderItemBuildList : orderItemList){
            orderItemSetId.add(orderItemBuildList.Id);
        }

        Map<Id, Margin__c> marginMapList = new Map<Id, Margin__c>([
            SELECT Id, ProductHierarchy__c, Product__c, AccountGroup__c, Account__c, DistributionCenter__c, City__c, State__c, Country__c, Status__c, Value__c
            FROM Margin__c
        ]);

        List<OrderItem> orderItemFullList = new List<OrderItem>([
            SELECT Id, OrderId, Product2Id, Product2.ProductHierarchy__c, Order.AccountId, Order.Account.AccountGroup__c, Order.AccountAddress__c, Order.AccountAddress__r.City__c, Order.AccountAddress__r.City__r.State__c, Order.AccountAddress__r.City__r.State__r.Country__c, MarginPercentage__c, TaxPercentage__c
            FROM OrderItem 
            WHERE Id IN: orderItemSetId
        ]);

        List<OrderItem> orderItemBuildedList = new List<OrderItem>();

        for(OrderItem iOrderItem : orderItemFullList){

            Decimal marginValue = 0;
            Integer score = 0;
            Integer scoreNew = 0;

            for(Margin__c iMargin : marginMapList.values()){

                if(score < scoreNew || scoreNew == 0){

                    score = 0;
                    
                    if(iMargin.Product__c == iOrderItem.Product2Id){
                        score = score + 1000;
                    } else if(iMargin.ProductHierarchy__c == iOrderItem.Product2.ProductHierarchy__c){
                        score = score + 800;
                    }
                    
                    if(iMargin.Account__c == iOrderItem.Order.AccountId){
                        score = score + 500;
                    } else if(iMargin.AccountGroup__c == iOrderItem.Order.Account.AccountGroup__c){
                        score = score + 400;
                    }
                    
                    if(iMargin.City__c == iOrderItem.Order.AccountAddress__r.City__c){
                        score = score + 300;
                    } else if(iMargin.State__c == iOrderItem.Order.AccountAddress__r.City__r.State__c){
                        score = score + 200;
                    } else if(iMargin.Country__c == iOrderItem.Order.AccountAddress__r.City__r.State__r.Country__c){
                        score = score + 100;
                    }
                    
                
                    if(score >= 100 && score < 400){
                        marginValue = iMargin.Value__c;
                        System.debug('marginValue marginCountry ==> ' + marginValue);
                        // marginCountry.add(iMargin);
                    } else if(score >= 200 && score < 300){
                        marginValue = iMargin.Value__c;
                        System.debug('marginValue marginState ==> ' + marginValue);
                        // marginState.add(iMargin);
                    } else if(score >= 300 && score < 400){
                        marginValue = iMargin.Value__c;
                        System.debug('marginValue marginCity ==> ' + marginValue);
                        // marginCity.add(iMargin);
                    } else if(score >= 400 && score < 500){
                        marginValue = iMargin.Value__c;
                        System.debug('marginValue marginAccountGroup ==> ' + marginValue);
                        // marginAccountGroup.add(iMargin);
                    } else if(score >= 500 && score < 800){
                        marginValue = iMargin.Value__c;
                        System.debug('marginValue marginAccount ==> ' + marginValue);
                        // marginAccount.add(iMargin);
                    } else if(score >= 800 && score < 1000){
                        marginValue = iMargin.Value__c;
                        System.debug('marginValue marginProductHierarchy ==> ' + marginValue);
                        // marginProductHierarchy.add(iMargin);
                    } else if(score >= 1000){
                        marginValue = iMargin.Value__c;
                        System.debug('marginValue marginProduct ==> ' + marginValue);
                        // marginProduct.add(iMargin);
                    }
                    System.debug('score =>> ' + score);
                    scoreNew = score;
                    System.debug('scoreNew =>> ' + scoreNew);
                }
            }

            iOrderItem.MarginPercentage__c = marginValue;
            
            orderItemBuildedList.add(iOrderItem);
        }

        return orderItemBuildedList;
    }
}