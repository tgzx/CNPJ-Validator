/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-18-2022
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

    public static List<OrderItem> checkAccountOrderUpdate(List<Order> newOrderList, List<Order> oldOrderList){
        List<Order> orderListFull = new List<Order>([
            SELECT Id, AccountId, Account.AccountGroup__c, Account.Name, AccountAddress__c, AccountAddress__r.City__c, AccountAddress__r.City__r.State__c, AccountAddress__r.City__r.State__r.Country__c, DistributionCenter__c
            FROM Order
        ]);
        Set<Id> orderIdSet = new Set<Id>();

        for(Order iNewOrder : newOrderList){
            for(Order iBuildOrder : orderListFull){
                if(iNewOrder.Id == iBuildOrder.Id){


                    if(iNewOrder.Account.AccountGroup__c != iBuildOrder.Account.AccountGroup__c && iNewOrder.Account.AccountGroup__c != null){
                        iBuildOrder.Account.AccountGroup__c = iNewOrder.Account.AccountGroup__c;
                    }

                    if(iNewOrder.Account.Name != iBuildOrder.Account.Name && iNewOrder.Account.Name != null){
                        iBuildOrder.Account.Name = iNewOrder.Account.Name;
                    }

                    if(iNewOrder.AccountAddress__c != iBuildOrder.AccountAddress__c && iNewOrder.AccountAddress__c != null){
                        iBuildOrder.AccountAddress__c = iNewOrder.AccountAddress__c;
                    }

                    if(iNewOrder.AccountAddress__r.City__c != iBuildOrder.AccountAddress__r.City__c && iNewOrder.AccountAddress__r.City__c != null){
                        iBuildOrder.AccountAddress__r.City__c = iNewOrder.AccountAddress__r.City__c;
                    }

                    if(iNewOrder.AccountAddress__r.City__r.State__c != iBuildOrder.AccountAddress__r.City__r.State__c && iNewOrder.AccountAddress__r.City__r.State__c != null){
                        iBuildOrder.AccountAddress__r.City__r.State__c = iNewOrder.AccountAddress__r.City__r.State__c;
                    }

                    if(iNewOrder.AccountAddress__r.City__r.State__r.Country__c != iBuildOrder.AccountAddress__r.City__r.State__r.Country__c && iNewOrder.AccountAddress__r.City__r.State__r.Country__c != null){
                        iBuildOrder.AccountAddress__r.City__r.State__r.Country__c = iNewOrder.AccountAddress__r.City__r.State__r.Country__c;
                    }

                    if(iNewOrder.DistributionCenter__c != iBuildOrder.DistributionCenter__c && iNewOrder.DistributionCenter__c != null){
                        iBuildOrder.DistributionCenter__c = iNewOrder.DistributionCenter__c;
                    }


                }
            }
        }

        for(Order iOrder : newOrderList){
            orderIdSet.add(iOrder.Id);
        }

        List<OrderItem> orderItemForRecalcList = new List<OrderItem>([
            SELECT Id, Product2Id, FinalPrice__c, OrderId, ListPrice, FreightCost__c, TaxPercentage__c, MarginPercentage__c, UnitPrice, NoMarginPrice__c, Discount__c, Quantity, ProductionCost__c, Product2.ProductHierarchy__c
            FROM OrderItem
            WHERE OrderId IN: orderIdSet
        ]);

        for(OrderItem iOrderItem : orderItemForRecalcList){
            iOrderItem.TaxPercentage__c = 0;
            iOrderItem.FreightCost__c = 0;
            iOrderItem.MarginPercentage__c = 0;
        }

        List<OrderItem> orderItemListBuilded = recalcUpdateOrder(orderItemForRecalcList, orderListFull);

        for(Order iOrder : newOrderList){
            for(OrderItem iOrderItem : orderItemListBuilded){
                if(iOrderItem.OrderId == iOrder.Id){
                    if(iOrderItem.TaxPercentage__c == null || iOrderItem.TaxPercentage__c == 0 || iOrderItem.FreightCost__c == null || iOrderItem.FreightCost__c == 0 || iOrderItem.MarginPercentage__c == null || iOrderItem.MarginPercentage__c == 0){
                        iOrder.addError(Label.NoParametersFoundedForOrder);
                    }
                }
            }
        }
        
        return orderItemListBuilded;
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

    public static Map<Id, Order> recalcOrder(List<Order> newOrderList){

        Map<Id, Order> orderMapBuilded = new Map<Id, Order>([
            SELECT Id, Status, OrderTotalPrice__c
            FROM Order
        ]);

        List<OrderItem> orderItemList = new List<OrderItem>([
            SELECT Id, Product2Id, Product2.ProductHierarchy__c, MarginPercentage__c, TaxPercentage__c
            FROM OrderItem
        ]);

        for(Order iOrder : newOrderList){
            if(iOrder.OrderTotalPrice__c == null){
                iOrder.OrderTotalPrice__c = 0;
            }

            Decimal finalPrice = iOrder.OrderTotalPrice__c;

            for(OrderItem iOrderItem : orderItemList){
                if(iOrderItem.OrderId == iOrder.Id){
                    if(iOrderItem.ProductionCost__c == null){
                        iOrderItem.ProductionCost__c = 0;
                    }
    
                    if(iOrderItem.ListPrice != null && iOrderItem.TaxPercentage__c != null){
                        iOrderItem.ProductionCost__c = iOrderItem.UnitPrice * iOrderItem.Quantity;
                        finalPrice += iOrderItem.FinalPrice__c = (iOrderItem.ProductionCost__c + iOrderItem.FreightCost__c) * (1 + (iOrderItem.TaxPercentage__c/100)) * (1 + (iOrderItem.MarginPercentage__c/100));
                        iOrderItem.NoMarginPrice__c = (iOrderItem.ProductionCost__c + iOrderItem.FreightCost__c) * (1 + (iOrderItem.TaxPercentage__c/100));
                        iOrderItem.Discount__c = (iOrderItem.FinalPrice__c - iOrderItem.UnitPrice) / iOrderItem.FinalPrice__c;
                    }
    
                    iOrder.OrderTotalPrice__c = finalPrice;
                }
            }

            orderMapBuilded.put(iOrder.Id, iOrder);
            
        }

        return orderMapBuilded;
    }

    public static List<OrderItem> findTax(List<OrderItem> orderItemList, Map<Id, Tax__c> TaxMapList, List<Order> orderList){
        
        List<OrderItem> orderItemBuildedList = new List<OrderItem>();
        
        for(OrderItem iOrderItem : orderItemList){
            
            Decimal taxValue = 0;

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