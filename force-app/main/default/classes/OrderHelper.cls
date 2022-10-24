/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-24-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class OrderHelper {
    public OrderHelper() {}

    public static void checkAccountAndFieldsOrder(List<Order> newOrderList){
        List<Order> oldOrderList = new List<Order>([
            SELECT Id, AccountId, Status
            FROM Order
        ]);

        for(Order iNewOrder : newOrderList){
            for(Order iOldOrder : oldOrderList){
                if(iNewOrder.Id == iOldOrder.Id){
                    if(iNewOrder.Status == 'Activated' && iOldOrder.Status == 'Activated'){
                        iNewOrder.addError(Label.NoAllowChangeOrderFields);
                    } else if(iNewOrder.AccountId != iOldOrder.AccountId){
                        iNewOrder.addError(Label.NoAllowChangeOrderAccount);
                    }    
                }
            }
        }
    }

    public static List<OrderItem> checkOrderFields(List<Order> newOrderList, List<Order> oldOrderList){

        checkAccountAndFieldsOrder(newOrderList);

        Map<Id, Order> oldOrderMap = buildMapFromTriggerOld(oldOrderList);

        Map<Id, Order> newOrderMap = buildMapFromTriggerNew(newOrderList);

        Map<Id, Order> newOrderBuildMap = new Map<Id, Order>([
            SELECT Id, AccountId, Account.AccountGroup__c, Account.Name, AccountAddress__c, AccountAddress__r.City__c, AccountAddress__r.City__r.State__c, AccountAddress__r.City__r.State__r.Country__c, DistributionCenter__c
            FROM Order
        ]);
        
        for(Order iNewOrder : newOrderMap.values()){
            for(Order iOldOrder : oldOrderMap.values()){
                if(iNewOrder.Id == iOldOrder.Id){
                    if(iOldOrder.Account.AccountGroup__c != iNewOrder.Account.AccountGroup__c || iOldOrder.Account.Name != iNewOrder.Account.Name || iOldOrder.AccountAddress__c != iNewOrder.AccountAddress__c || iOldOrder.AccountAddress__r.City__c != iNewOrder.AccountAddress__r.City__c || iOldOrder.AccountAddress__r.City__r.State__c != iNewOrder.AccountAddress__r.City__r.State__c || iOldOrder.AccountAddress__r.City__r.State__r.Country__c != iNewOrder.AccountAddress__r.City__r.State__r.Country__c || iOldOrder.DistributionCenter__c != iNewOrder.DistributionCenter__c){
                        newOrderBuildMap.put(iNewOrder.Id, iNewOrder);
                    }
                }
            }
        }

        Set<Id> newOrderIdSet = new Set<Id>();

        for(Order iOrder : newOrderMap.values()){
            newOrderIdSet.add(iOrder.Id);
        }

        List<OrderItem> orderItemForRecalcList = new List<OrderItem>([
            SELECT Id, Product2Id, FinalPrice__c, OrderId, ListPrice, FreightCost__c, TaxPercentage__c, MarginPercentage__c, UnitPrice, Discount__c, Quantity, Product2.ProductHierarchy__c, Product2.Name
            FROM OrderItem
            WHERE OrderId IN: newOrderIdSet
        ]);
        
        List<OrderItem> orderItemListBuildedTax = OrderItemHelper.findTax(orderItemForRecalcList, newOrderBuildMap.values());
        List<OrderItem> orderItemListBuildedMargin = OrderItemHelper.findMargin(orderItemListBuildedTax, newOrderBuildMap.values());
        List<OrderItem> orderItemListBuildedFreight = OrderItemHelper.findFreight(orderItemListBuildedMargin, newOrderBuildMap.values());
        List<OrderItem> orderItemListRecalculated = OrderItemHelper.calcPrice(orderItemListBuildedFreight);

        verifyEmptyFields(orderItemListRecalculated, newOrderList);

        return orderItemListRecalculated;
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
            for(Order iOrderListUnit : orderList){
                iOrder.DistributionCenter__c = iOrderListUnit.DistributionCenter__c;
            }

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
            for(Order iOrderListUnit : orderList){
                iOrder.DistributionCenter__c = iOrderListUnit.DistributionCenter__c;
            }

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

    public static void verifyEmptyFields(List<OrderItem> orderItemListRecalculated, List<Order> orderList){
        for(Order iOrder : orderList){
            for(OrderItem iOrderItem : orderItemListRecalculated){
                if(iOrder.Id == iOrderItem.OrderId){
                    if(iOrderItem.TaxPercentage__c == null || iOrderItem.TaxPercentage__c == 0){
                        iOrder.addError('Não foi encontrado Imposto para ' + iOrderItem.Product2.Name);
                    }
    
                    if (iOrderItem.FreightCost__c == null || iOrderItem.FreightCost__c == 0){
                        iOrder.addError('Não foi encontrado Frete para ' + iOrderItem.Product2.Name);
                    }
    
                    if (iOrderItem.MarginPercentage__c == null || iOrderItem.MarginPercentage__c == 0){
                        iOrder.addError('Não foi encontrado Margem para ' + iOrderItem.Product2.Name);
                    }
                }
            }
        }
    }
}
