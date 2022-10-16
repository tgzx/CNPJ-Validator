/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-16-2022
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

                    if(iNewOrder.Status == 'Activated' || iOldOrder.Status == 'Activated'){
                        iNewOrder.addError(Label.NoAllowChangeOrderFields);
                    }
                }
            }
        }
    }
}
