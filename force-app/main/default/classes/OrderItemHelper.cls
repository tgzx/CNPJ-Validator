/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-22-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class OrderItemHelper {
    public OrderItemHelper() {}

    public static List<OrderItem> checkInsertionOrderItem(List<OrderItem> orderItemList){
        
        List<OrderItem> orderItemListFull = queryAllFieldsForTriggerNew(orderItemList);
        Set<Id> orderIdSet = new Set<Id>();
        for(OrderItem iOrderItem : orderItemListFull){
            orderIdSet.add(iOrderItem.OrderId);
        }

        List<Order> orderList = new List<Order>([
            SELECT Id, AccountId, Account.AccountGroup__c, Account.Name, AccountAddress__c, AccountAddress__r.City__c, AccountAddress__r.City__r.State__c, AccountAddress__r.City__r.State__r.Country__c, DistributionCenter__c, Status
            FROM Order
            WHERE Id IN: orderIdSet
        ]);

        List<OrderItem> orderItemListActivated = checkActivatedOrder(orderItemListFull, orderList);

        for(OrderItem iOrderItem : orderItemListActivated){
            iOrderItem.addError(Label.NoAllowChangeOrderFields);
        }
        
        List<OrderItem> orderItemListBuildedMargin = findTax(orderItemListFull, orderList);
        List<OrderItem> orderItemListBuildedFreight = findMargin(orderItemListBuildedMargin, orderList);
        List<OrderItem> orderItemListBuildedTax = findFreight(orderItemListBuildedFreight, orderList);

        for(OrderItem iOrderItem : orderItemListBuildedTax){
            if(iOrderItem.TaxPercentage__c == 0 || iOrderItem.TaxPercentage__c == null){
                iOrderItem.addError(Label.NoParametersErrorMessageTax);
            }

            if(iOrderItem.MarginPercentage__c == 0 || iOrderItem.MarginPercentage__c == null){
                iOrderItem.addError(Label.NoParametersErrorMessageMargin);
            } 

            if(iOrderItem.FreightCost__c == 0 || iOrderItem.FreightCost__c == null){
                iOrderItem.addError(Label.NoParametersErrorMessageFreight);
            }
        }
        
        return calcPrice(orderItemListBuildedTax);
    }

    public static List<OrderItem> calcPrice(List<OrderItem> orderItemList){

        Set<Id> orderSetId = new Set<Id>();

        for(OrderItem iOrderItem : orderItemList){
            orderSetId.add(iOrderItem.OrderId);
        }

        List<Order> orderList = new List<Order>([
            SELECT Id, Status
            FROM Order
            WHERE Status = 'Draft' AND
            Id IN: orderSetId
        ]);
        
        for(Order iOrder : orderList){
            for(OrderItem iOrderItem : orderItemList){
                if(iOrder.Id == iOrderItem.OrderId){
                    if(iOrderItem.ListPrice != null && iOrderItem.TaxPercentage__c != null && iOrderItem.MarginPercentage__c != null && iOrderItem.FreightCost__c != null && iOrderItem.Quantity != 0){
                        iOrderItem.FinalPrice__c = ((iOrderItem.UnitPrice + iOrderItem.FreightCost__c) * (1 + (iOrderItem.TaxPercentage__c/100)) * (1 + (iOrderItem.MarginPercentage__c/100))) * iOrderItem.Quantity;
                        iOrderItem.Discount__c = (iOrderItem.FinalPrice__c - iOrderItem.UnitPrice) / iOrderItem.FinalPrice__c;
                    }
                }
            }
        }

        return orderItemList;
    }

    public static List<OrderItem> findTax(List<OrderItem> orderItemList, List<Order> orderList){

        Map<Id, Tax__c> TaxMapList = new Map<Id, Tax__c>([
            SELECT Id, Product__c, DistributionCenter__c, State__c, Status__c, TaxCosts__c
            FROM Tax__c
            WHERE Status__c = 'Aprovado'
        ]);

        List<OrderItem> orderItemFullList = new List<OrderItem>([
            SELECT Id, Product2Id, Product2.ProductHierarchy__c, MarginPercentage__c, TaxPercentage__c
            FROM OrderItem
        ]);
        
        List<OrderItem> orderItemBuildedList = new List<OrderItem>();
        
        for(OrderItem iOrderItem : orderItemList){
            
            iOrderItem.TaxPercentage__c = 0;

            for(Order iOrder : orderList){
                if(iOrderItem.OrderId == iOrder.Id){
                    for(Tax__c iTax : TaxMapList.values()){
                        if(iTax.Product__c == iOrderItem.Product2Id && iTax.DistributionCenter__c == iOrder.DistributionCenter__c && iTax.State__c == iOrder.AccountAddress__r.City__r.State__c){
                            iOrderItem.TaxPercentage__c = iTax.TaxCosts__c;
                        }
                    }

                    orderItemBuildedList.add(iOrderItem);
                }
            }
        }
        
        return orderItemBuildedList;
    }

    public static List<OrderItem> findFreight(List<OrderItem> orderItemList, List<Order> orderList){
        Map<Id, Freight__c> FreightMapList = new Map<Id, Freight__c>([
            SELECT Id, ProductHierarchy__c, Product__c, DistributionCenter__c, City__c, State__c, Country__c, Status__c, Value__c
            FROM Freight__c
            WHERE Status__c = 'Aprovado'
        ]);
        
        List<OrderItem> orderItemBuildedList = new List<OrderItem>();

        for(OrderItem iOrderItem : orderItemList){
            
            Decimal freightValue = 0;
            Integer score = 0;
            Integer oldScore = 0;

            for(Order iOrder : orderList){
                if(iOrderItem.OrderId == iOrder.Id){
                    for(Freight__c iFreight : FreightMapList.values()){
                        if ((iFreight.Product__c == iOrderItem.Product2Id  ||  iFreight.ProductHierarchy__c == iOrderItem.Product2.ProductHierarchy__c) 
                        && (iFreight.City__c == iOrder.AccountAddress__r.City__c || iFreight.State__c == iOrder.AccountAddress__r.City__r.State__c || iFreight.Country__c == iOrder.AccountAddress__r.City__r.State__r.Country__c)){

                            score = 0;

                            if(iFreight.Product__c == iOrderItem.Product2Id && iFreight.Product__c != null){
                                score = score + 1000;
                            } else if(iFreight.ProductHierarchy__c == iOrderItem.Product2.ProductHierarchy__c && iFreight.ProductHierarchy__c != null){
                                score = score + 800;
                            }
                            
                            if(iFreight.City__c == iOrder.AccountAddress__r.City__c && iFreight.City__c != null){
                                score = score + 300;
                            } else if(iFreight.State__c == iOrder.AccountAddress__r.City__r.State__c && iFreight.State__c != null){
                                score = score + 200;
                            } else if(iFreight.Country__c == iOrder.AccountAddress__r.City__r.State__r.Country__c && iFreight.Country__c != null){
                                score = score + 100;
                            }
            
                            if(score > oldScore || oldScore == 0){
            
                                if(score <= 100){
                                    freightValue = iFreight.Value__c;
                                } else if(score >= 200 && score < 300){
                                    freightValue = iFreight.Value__c;
                                } else if(score >= 300 && score < 800){
                                    freightValue = iFreight.Value__c;
                                } else if(score >= 800 && score < 1000){
                                    freightValue = iFreight.Value__c;
                                } else if(score >= 1000){
                                    freightValue = iFreight.Value__c;
                                }
            
                                oldScore = score;
                            } 
                        }
                    }

                    iOrderItem.FreightCost__c = freightValue;
                    orderItemBuildedList.add(iOrderItem);
                }
            }
        }
        
        return orderItemBuildedList;
    }

    public static List<OrderItem> findMargin(List<OrderItem> orderItemList, List<Order> orderList){

        Map<Id, Margin__c> marginMapList = new Map<Id, Margin__c>([
            SELECT Id, ProductHierarchy__c, Product__c, AccountGroup__c, Account__c, DistributionCenter__c, City__c, State__c, Country__c, Status__c, Value__c
            FROM Margin__c
            WHERE Status__c = 'Aprovado'
        ]);

        List<OrderItem> orderItemBuildedList = new List<OrderItem>();

        for(OrderItem iOrderItem : orderItemList){

            Decimal marginValue = 0;
            Integer score = 0;
            Integer oldScore = 0;

            for(Order iOrder : orderList){
                if(iOrderItem.OrderId == iOrder.Id){
                    for(Margin__c iMargin : MarginMapList.values()){

                        if ((iMargin.Product__c == iOrderItem.Product2Id || iMargin.ProductHierarchy__c == iOrderItem.Product2.ProductHierarchy__c) 
                        && (iMargin.Account__c == iOrder.AccountId || iMargin.AccountGroup__c == iOrder.Account.AccountGroup__c) 
                        && (iMargin.City__c == iOrder.AccountAddress__r.City__c || iMargin.State__c == iOrder.AccountAddress__r.City__r.State__c || iMargin.Country__c == iOrder.AccountAddress__r.City__r.State__r.Country__c)){

                            score = 0;

                            if(iMargin.Product__c == iOrderItem.Product2Id && iMargin.Product__c != null){
                                score = score + 1000;
                            } else if(iMargin.ProductHierarchy__c == iOrderItem.Product2.ProductHierarchy__c && iMargin.ProductHierarchy__c != null){
                                score = score + 800;
                            }
                            
                            if(iMargin.Account__c == iOrder.AccountId && iMargin.Account__c != null){
                                score = score + 500;
                            } else if(iMargin.AccountGroup__c == iOrder.Account.AccountGroup__c && iMargin.AccountGroup__c != null){
                                score = score + 400;
                            }
                            
                            if(iMargin.City__c == iOrder.AccountAddress__r.City__c && iMargin.City__c != null){
                                score = score + 300;
                            } else if(iMargin.State__c == iOrder.AccountAddress__r.City__r.State__c && iMargin.State__c != null){
                                score = score + 200;
                            } else if(iMargin.Country__c == iOrder.AccountAddress__r.City__r.State__r.Country__c && iMargin.Country__c != null){
                                score = score + 100;
                            }
            
                            if(score > oldScore){
            
                                if(score != 0 && score <= 100){
                                    marginValue = iMargin.Value__c;
                                } else if(score >= 200 && score < 300){
                                    marginValue = iMargin.Value__c;
                                } else if(score >= 300 && score < 400){
                                    marginValue = iMargin.Value__c;
                                } else if(score >= 400 && score < 500){
                                    marginValue = iMargin.Value__c;
                                } else if(score >= 500 && score < 800){
                                    marginValue = iMargin.Value__c;
                                } else if(score >= 800 && score < 1000){
                                    marginValue = iMargin.Value__c;
                                } else if(score >= 1000){
                                    marginValue = iMargin.Value__c;
                                }
            
                                oldScore = score;
                            }
                        }
                    }

                    iOrderItem.MarginPercentage__c = marginValue;
                    orderItemBuildedList.add(iOrderItem);
                }
            }
        }

        return orderItemBuildedList;
    }

    public static void checkQuantityPriceFields(List<OrderItem> orderItemList){
        List<Order> orderList = new List<Order>([
            SELECT Id, AccountId, Status
            FROM Order
        ]);

        for(OrderItem iOrderItem : orderItemList){
            for(Order iOrder : orderList){
                if(iOrderItem.OrderId == iOrder.Id){
                    if(iOrderItem.Quantity == 0 || iOrderItem.UnitPrice == 0){
                        iOrderItem.addError(Label.NoAllowZeroedFields);
                    }
                }
            }
        }
    }

    public static List<OrderItem> checkActivatedOrder(List<OrderItem> orderItemList, List<Order> newOrderList){

        List<OrderItem> orderItemListActivated = new List<OrderItem>();

        List<Order> oldOrderList = new List<Order>([
            SELECT Id, AccountId, Status
            FROM Order
        ]);

        for(Order iOldOrder : oldOrderList){
            for(Order iNewOrder : newOrderList){        
                for(OrderItem iOrderItem : orderItemList){
                    if(iNewOrder.Status == 'Draft' && iOldOrder.Status == 'Activated'){
                        orderItemListActivated.add(iOrderItem);
                    }
                }    
            }
        }

        return orderItemListActivated;
    }

    public static List<OrderItem> queryAllFieldsForTriggerNew(List<OrderItem> orderItemList){
        Set<Id> orderIdSet = new Set<Id>();
        Set<Id> product2SetId = new Set<Id>();
        
        for(OrderItem iOrderItem : orderItemList){
            product2SetId.add(iOrderItem.Product2Id);
            orderIdSet.add(iOrderItem.OrderId);
        }

        Map<Id, OrderItem> orderItemMap = new Map<Id, OrderItem>([
            SELECT Id, Product2Id, FinalPrice__c, OrderId, ListPrice, FreightCost__c, TaxPercentage__c, MarginPercentage__c, UnitPrice, Discount__c, Quantity, Product2.ProductHierarchy__c, Product2.Name
            FROM OrderItem
            WHERE Product2Id =: product2SetId
        ]);

        for(OrderItem iOrderItem : OrderItemList){
            orderItemMap.put(iOrderItem.Product2Id, iOrderItem);
        }

        return orderItemMap.values();
    }
}