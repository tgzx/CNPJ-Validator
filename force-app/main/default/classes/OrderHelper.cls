/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-20-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class OrderHelper {
    public OrderHelper() {}

    public static void checkAccountOrder(List<Order> newOrderList){
        List<Order> oldOrderList = new List<Order>([
            SELECT Id, AccountId, Status
            FROM Order
        ]);

        for(Order iNewOrder : newOrderList){
            for(Order iOldOrder : oldOrderList){
                if(iNewOrder.Id == iOldOrder.Id){
                    if(iNewOrder.AccountId != iOldOrder.AccountId){
                        iNewOrder.addError(Label.NoAllowChangeOrderAccount);
                    }
                    
                    if(iNewOrder.Status == 'Activated' && iOldOrder.Status == 'Activated'){
                        iNewOrder.addError(Label.NoAllowChangeOrderFields);
                    }
                }
            }
        }
    }

    public static List<OrderItem> checkActivatedOrder(List<OrderItem> orderItemList, List<Order> newOrderList){

        List<OrderItem> orderItemListActivated = new List<OrderItem>();

        for(Order iNewOrder : newOrderList){        
            for(OrderItem iOrderItem : orderItemList){
                if(iNewOrder.Status == 'Activated'){
                    orderItemListActivated.add(iOrderItem);
                }
            }    
        }

        return orderItemListActivated;
    }

    public static List<OrderItem> checkAccountOrderUpdate(List<Order> newOrderList, List<Order> oldOrderList){
        
        Map<Id, Order> oldOrderMap = buildMapFromTriggerOld(oldOrderList);

        Map<Id, Order> newOrderMap = buildMapFromTriggerNew(newOrderList);

        Map<Id, Order> orderBuildMap = new Map<Id, Order>([
            SELECT Id, AccountId, Account.AccountGroup__c, Account.Name, AccountAddress__c, AccountAddress__r.City__c, AccountAddress__r.City__r.State__c, AccountAddress__r.City__r.State__r.Country__c, DistributionCenter__c
            FROM Order
        ]);
        
        for(Order iNewOrder : newOrderMap.values()){
            for(Order iOldOrder : oldOrderMap.values()){
                if(iNewOrder.Id == iOldOrder.Id){
                    if(iOldOrder.Account.AccountGroup__c != iNewOrder.Account.AccountGroup__c || iOldOrder.Account.Name != iNewOrder.Account.Name || iOldOrder.AccountAddress__c != iNewOrder.AccountAddress__c || iOldOrder.AccountAddress__r.City__c != iNewOrder.AccountAddress__r.City__c || iOldOrder.AccountAddress__r.City__r.State__c != iNewOrder.AccountAddress__r.City__r.State__c || iOldOrder.AccountAddress__r.City__r.State__r.Country__c != iNewOrder.AccountAddress__r.City__r.State__r.Country__c || iOldOrder.DistributionCenter__c != iNewOrder.DistributionCenter__c){
                        orderBuildMap.put(iNewOrder.Id, iNewOrder);
                    }
                }
            }
        }

        system.debug('orderBuildMap = >' + orderBuildMap);

        Set<Id> newOrderIdSet = new Set<Id>();

        for(Order iOrder : newOrderMap.values()){
            newOrderIdSet.add(iOrder.Id);
        }

        List<OrderItem> orderItemForRecalcList = new List<OrderItem>([
            SELECT Id, Product2Id, FinalPrice__c, OrderId, ListPrice, FreightCost__c, TaxPercentage__c, MarginPercentage__c, UnitPrice, Discount__c, Quantity, Product2.ProductHierarchy__c, Product2.Name
            FROM OrderItem
            WHERE OrderId IN: newOrderIdSet
        ]);

        List<OrderItem> orderItemListBuildedMargin = OrderItemHelper.findTax(orderItemForRecalcList, orderBuildMap.values());
        List<OrderItem> orderItemListBuildedFreight = OrderItemHelper.findMargin(orderItemListBuildedMargin, orderBuildMap.values());
        List<OrderItem> orderItemListBuildedTax = OrderItemHelper.findFreight(orderItemListBuildedFreight, orderBuildMap.values());

        OrderItemHelper.calcPrice(orderItemListBuildedTax);

        System.debug('orderItemListBuilded => ' + orderItemListBuildedTax);

        // for(Order iOrder : newOrderList){
        //     for(OrderItem iOrderItem : orderItemListBuilded){
        //         if(iOrderItem.OrderId == iOrder.Id){
        //             if(iOrderItem.TaxPercentage__c == null || iOrderItem.TaxPercentage__c == 0){
        //                 iOrder.addError('Não foi encontrado Imposto para ' + iOrderItem.Product2.Name);
        //             }

        //             if (iOrderItem.FreightCost__c == null || iOrderItem.FreightCost__c == 0){
        //                 iOrder.addError('Não foi encontrado Frete para ' + iOrderItem.Product2.Name);
        //             }

        //             if (iOrderItem.MarginPercentage__c == null || iOrderItem.MarginPercentage__c == 0){
        //                 iOrder.addError('Não foi encontrado Margem para ' + iOrderItem.Product2.Name);
        //             }
        //         }
        //     }
        // }
        
        return orderItemListBuildedTax;
    }

    public static List<OrderItem> recalcUpdateOrder(List<OrderItem> orderItemList,  List<Order> orderList){

        Map<Id, Tax__c> TaxMapList = new Map<Id, Tax__c>([
            SELECT Id, Product__c, DistributionCenter__c, State__c, Status__c, TaxCosts__c
            FROM Tax__c
            WHERE Status__c = 'Aprovado'
        ]);

        Map<Id, Margin__c> marginMapList = new Map<Id, Margin__c>([
            SELECT Id, ProductHierarchy__c, Product__c, AccountGroup__c, Account__c, DistributionCenter__c, City__c, State__c, Country__c, Status__c, Value__c
            FROM Margin__c
            WHERE Status__c = 'Aprovado'
        ]);

        Map<Id, Freight__c> FreightMapList = new Map<Id, Freight__c>([
            SELECT Id, ProductHierarchy__c, Product__c, DistributionCenter__c, City__c, State__c, Country__c, Status__c, Value__c
            FROM Freight__c
            WHERE Status__c = 'Aprovado'
        ]);
        
        List<OrderItem> orderItemListBuildedMargin = findTax(orderItemList, TaxMapList, orderList);
        List<OrderItem> orderItemListBuildedFreight = findMargin(orderItemList, marginMapList, orderList);
        List<OrderItem> orderItemListBuildedTax = findFreight(orderItemList, FreightMapList, orderList);

        Map<OrderItem, OrderItem> orderItemMap = new Map<OrderItem, OrderItem>();

        for(OrderItem iOrderItem : orderItemListBuildedMargin){
            system.debug('iOrderItem ' + iOrderItem);
            orderItemMap.put(iOrderItem, iOrderItem);
        }

        for(OrderItem iOrderItem : orderItemListBuildedFreight){
            orderItemMap.put(iOrderItem, iOrderItem);
        }

        for(OrderItem iOrderItem : orderItemListBuildedTax){
            orderItemMap.put(iOrderItem, iOrderItem);
        }

        return orderItemMap.values();
    }

    public static Map<Id, Order> buildMapFromTriggerNew(List<Order> orderList){
        
        Set<Id> newOrderIdSet = new Set<Id>();
        Set<Id> accountSetId = new Set<Id>();
        Set<Id> addressSetId = new Set<Id>();

        Map<Id, Order> orderMap = new Map<Id, Order>([
            SELECT Id, AccountId, Account.AccountGroup__c, Account.Name, AccountAddress__c, AccountAddress__r.City__c, AccountAddress__r.City__r.State__c, AccountAddress__r.City__r.State__r.Country__c, DistributionCenter__c
            FROM Order
        ]);

        for(Order iOrder : orderList){
            newOrderIdSet.add(iOrder.Id);
            accountSetId.add(iOrder.AccountId);
            addressSetId.add(iOrder.AccountAddress__c);
        }
        List<Account> accountList = new List<Account>([
            SELECT Id, Account.AccountGroup__r.Id
            FROM Account
            WHERE Id IN: accountSetId
        ]);

        List<AccountAddress__c> addressList = new List<AccountAddress__c>([
            SELECT Id, City__c, City__r.State__c, City__r.State__r.Country__c
            FROM AccountAddress__c
            WHERE Id IN: addressSetId
        ]);

        for(Order iOrder : orderMap.values()){
            for(Account iAccount : accountList){
                iOrder.AccountId = iAccount.Id;
                iOrder.Account.AccountGroup__c = iAccount.AccountGroup__c;
            }

            for(AccountAddress__c iAddress : addressList){
                iOrder.AccountAddress__c = iAddress.Id;
                iOrder.AccountAddress__r.City__c = iAddress.City__c;
                iOrder.AccountAddress__r.City__r.State__c = iAddress.City__r.State__c;
                iOrder.AccountAddress__r.City__r.State__r.Country__c = iAddress.City__r.State__r.Country__c;
            }
        }

        return orderMap;
    }

    public static Map<Id, Order> buildMapFromTriggerOld(List<Order> orderList){
        
        Set<Id> newOrderIdSet = new Set<Id>();
        Set<Id> accountSetId = new Set<Id>();
        Set<Id> addressSetId = new Set<Id>();

        Map<Id, Order> orderMap = new Map<Id, Order>([
            SELECT Id, AccountId, Account.AccountGroup__c, Account.Name, AccountAddress__c, AccountAddress__r.City__c, AccountAddress__r.City__r.State__c, AccountAddress__r.City__r.State__r.Country__c, DistributionCenter__c
            FROM Order
        ]);

        for(Order iOrder : orderList){
            newOrderIdSet.add(iOrder.Id);
            accountSetId.add(iOrder.AccountId);
            addressSetId.add(iOrder.AccountAddress__c);
        }
        List<Account> accountList = new List<Account>([
            SELECT Id, Account.AccountGroup__r.Id
            FROM Account
            WHERE Id IN: accountSetId
        ]);

        List<AccountAddress__c> addressList = new List<AccountAddress__c>([
            SELECT Id, City__c, City__r.State__c, City__r.State__r.Country__c
            FROM AccountAddress__c
            WHERE Id IN: addressSetId
        ]);

        for(Order iOrder : orderMap.values()){
            for(Account iAccount : accountList){
                iOrder.AccountId = iAccount.Id;
                iOrder.Account.AccountGroup__c = iAccount.AccountGroup__c;
            }

            for(AccountAddress__c iAddress : addressList){
                iOrder.AccountAddress__c = iAddress.Id;
                iOrder.AccountAddress__r.City__c = iAddress.City__c;
                iOrder.AccountAddress__r.City__r.State__c = iAddress.City__r.State__c;
                iOrder.AccountAddress__r.City__r.State__r.Country__c = iAddress.City__r.State__r.Country__c;
            }
        }

        return orderMap;
    }

    // public static Map<Id, Order> recalcOrder(List<Order> newOrderList){

    //     Map<Id, Order> orderMapBuilded = new Map<Id, Order>([
    //         SELECT Id, Status, OrderTotalPrice__c
    //         FROM Order
    //     ]);

    //     List<OrderItem> orderItemList = new List<OrderItem>([
    //         SELECT Id, Product2Id, Product2.ProductHierarchy__c, MarginPercentage__c, TaxPercentage__c
    //         FROM OrderItem
    //     ]);

    //     for(Order iOrder : newOrderList){
    //         if(iOrder.OrderTotalPrice__c == null){
    //             iOrder.OrderTotalPrice__c = 0;
    //         }

    //         Decimal finalPrice = iOrder.OrderTotalPrice__c;

    //         for(OrderItem iOrderItem : orderItemList){
    //             if(iOrderItem.OrderId == iOrder.Id){
    //                 if(iOrderItem.ProductionCost__c == null){
    //                     iOrderItem.ProductionCost__c = 0;
    //                 }
    
    //                 if(iOrderItem.ListPrice != null && iOrderItem.TaxPercentage__c != null){
    //                     iOrderItem.ProductionCost__c = iOrderItem.UnitPrice * iOrderItem.Quantity;
    //                     finalPrice += iOrderItem.FinalPrice__c = (iOrderItem.ProductionCost__c + iOrderItem.FreightCost__c) * (1 + (iOrderItem.TaxPercentage__c/100)) * (1 + (iOrderItem.MarginPercentage__c/100));
    //                     iOrderItem.Discount__c = (iOrderItem.FinalPrice__c - iOrderItem.UnitPrice) / iOrderItem.FinalPrice__c;
    //                 }
    
    //                 iOrder.OrderTotalPrice__c = finalPrice;
    //             }
    //         }

    //         system.debug('finalPrice => ' + finalPrice);
    //         orderMapBuilded.put(iOrder.Id, iOrder);
            
    //     }

    //     return orderMapBuilded;
    // }

    public static List<OrderItem> findTax(List<OrderItem> orderItemList, Map<Id, Tax__c> TaxMapList, List<Order> orderList){
        
        List<OrderItem> orderItemBuildedList = new List<OrderItem>();
        
        for(OrderItem iOrderItem : orderItemList){
            for(Order iOrder : orderList){
                if(iOrderItem.OrderId == iOrder.Id){
                    for(Tax__c iTax : TaxMapList.values()){
                        if(iTax.Product__c == iOrderItem.Product2Id ){

                            if( iTax.DistributionCenter__c == iOrder.DistributionCenter__c ){

                                if( iTax.State__c == iOrder.AccountAddress__r.City__r.State__c){
                                }
                            }
                        }
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

    public static List<OrderItem> findFreight(List<OrderItem> orderItemList, Map<Id, Freight__c> FreightMapList, List<Order> orderList){

        List<OrderItem> orderItemFullList = new List<OrderItem>([
            SELECT Id, Product2Id, Product2.ProductHierarchy__c, MarginPercentage__c, TaxPercentage__c
            FROM OrderItem
        ]);
        
        List<OrderItem> orderItemBuildedList = new List<OrderItem>();
        
        for(OrderItem iOrderItem : orderItemList){

            Decimal freightValue = 0;
            Integer score = 0;
            Integer oldScore = 0;

            for(Order iOrder : orderList){
                if(iOrderItem.OrderId == iOrder.Id){
                    for(Freight__c iFreight : FreightMapList.values()){

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

                    iOrderItem.FreightCost__c = freightValue; 
        
                    orderItemBuildedList.add(iOrderItem);
                }
            }
        }
        
        return orderItemBuildedList;
    }

    public static List<OrderItem> findMargin(List<OrderItem> orderItemList, Map<Id, Margin__c> marginMapList, List<Order> orderList){

        List<OrderItem> orderItemBuildedList = new List<OrderItem>();
        
        for(OrderItem iOrderItem : orderItemList){

            Decimal marginValue = 0;
            Integer score = 0;
            Integer oldScore = 0;

            for(Order iOrder : orderList){
                if(iOrderItem.OrderId == iOrder.Id){
                    for(Margin__c iMargin : MarginMapList.values()){

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

                    iOrderItem.MarginPercentage__c = marginValue; 
        
                    orderItemBuildedList.add(iOrderItem);
                }
            }
        }

        return orderItemBuildedList;
    }
}
