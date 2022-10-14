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

        Set<Id> productSetId = new Set<Id>();

        for(OrderItem iOrderItem : orderItemList){
            productSetId.add(iOrderItem.Product2Id);
        }

        Map<Id, Margin__c> marginMapList = new Map<Id, Margin__c>([
            SELECT Id, ProductHierarchy__c, Product__c, AccountGroup__c, Account__c, DistributionCenter__c, City__c, State__c, Country__c, Status__c, Value__c
            FROM Margin__c
            WHERE Status__c = 'Aprovado'
            AND Product__c IN: productSetId
        ]);

        List<OrderItem> orderItemMarginFindedList = new List<OrderItem>();
            
        orderItemMarginFindedList = findMargin(orderItemList, marginMapList);

        return orderItemMarginFindedList;
    }

    public static List<OrderItem> findMargin(List<OrderItem> orderItemList, Map<Id, Margin__c> marginMapList){

        List<OrderItem> orderItemBuildedList = new List<OrderItem>();
        
        for(OrderItem iOrderItem : orderItemList){
            
            Decimal marginValue = 0;
            Integer score = 0;
            Integer oldScore = 0;
            
            System.debug('score => ' + score);
            for(Margin__c iMargin : marginMapList.values()){

                score = 0;
                    
                if(iMargin.Product__c == iOrderItem.Product2Id && iMargin.Product__c != null){
                    score = score + 1000;
                } else if(iMargin.ProductHierarchy__c == iOrderItem.Product2.ProductHierarchy__c && iMargin.ProductHierarchy__c != null){
                    score = score + 800;
                }
                
                if(iMargin.Account__c == iOrderItem.Order.AccountId && iMargin.Account__c != null){
                    score = score + 500;
                } else if(iMargin.AccountGroup__c == iOrderItem.Order.Account.AccountGroup__c && iMargin.AccountGroup__c != null){
                    score = score + 400;
                }
                
                if(iMargin.City__c == iOrderItem.Order.AccountAddress__r.City__c && iMargin.City__c != null){
                    score = score + 300;
                } else if(iMargin.State__c == iOrderItem.Order.AccountAddress__r.City__r.State__c && iMargin.State__c != null){
                    score = score + 200;
                } else if(iMargin.Country__c == iOrderItem.Order.AccountAddress__r.City__r.State__r.Country__c && iMargin.Country__c != null){
                    score = score + 100;
                }

                System.debug('score =>> ' + score + ' oldScore ==> ' + oldScore);
                if(score > oldScore || oldScore == 0){

                    if(score >= 100 && score < 400){
                        marginValue = iMargin.Value__c;
                        System.debug('marginValue marginCountry ==> ' + marginValue);
                    } else if(score >= 200 && score < 300){
                        marginValue = iMargin.Value__c;
                        System.debug('marginValue marginState ==> ' + marginValue);
                    } else if(score >= 300 && score < 400){
                        marginValue = iMargin.Value__c;
                        System.debug('marginValue marginCity ==> ' + marginValue);
                    } else if(score >= 400 && score < 500){
                        marginValue = iMargin.Value__c;
                        System.debug('marginValue marginAccountGroup ==> ' + marginValue);
                    } else if(score >= 500 && score < 800){
                        marginValue = iMargin.Value__c;
                        System.debug('marginValue marginAccount ==> ' + marginValue);
                    } else if(score >= 800 && score < 1000){
                        marginValue = iMargin.Value__c;
                        System.debug('marginValue marginProductHierarchy ==> ' + marginValue);
                    } else if(score >= 1000){
                        marginValue = iMargin.Value__c;
                        System.debug('marginValue marginProduct ==> ' + marginValue);
                    }

                    oldScore = score;
                }
            }

            iOrderItem.OrderItemNote__c = iOrderItem.Order.Account.Name;
            iOrderItem.MarginPercentage__c = marginValue;

            if(score == 0){
                iOrderItem.addError(Label.NoMarginFinded);
            } 

            orderItemBuildedList.add(iOrderItem);
        }

        return orderItemBuildedList;
    }
}