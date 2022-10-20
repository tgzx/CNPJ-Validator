/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-20-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public with sharing class OrderTriggerHandler {
    List<Order> oldRecords {get; set;}
    List<Order> newRecords {get; set;}
    Map<Id, Order> oldMap {get; set;}
    Map<Id, Order> newMap {get; set;}

    public OrderTriggerHandler(List<Order> oldRecords, List<Order> newRecords, Map<Id, Order> oldMap, Map<Id, Order> newMap) {
        this.oldRecords = oldRecords;
        this.newRecords = newRecords;
        this.oldMap = oldMap;
        this.newMap = newMap;
    }

    public void beforeUpdate(){
        if(checkRecursion.runOnce()){
            OrderHelper.checkAccountOrder(this.newRecords);
            List<OrderItem> orderItemList = OrderHelper.checkAccountOrderUpdate(this.newRecords, this.oldRecords);
            //OrderItemHelper.calcPrice(orderItemList);
        }
    }

    public void afterUpdate(){
        // System.debug('afterUpdate');
        // if(checkRecursion.runOnce()){
        //     System.debug('afterUpdate');
        //     Map<Id, Order> orderMapBuilded = OrderHelper.recalcOrder(this.newRecords);
        //     List<Order> orderListBuilded = new List<Order>();
        //     for(Order iOrder : orderMapBuilded.values()){
        //         orderListBuilded.add(iOrder);
        //     }
        //     System.debug('afterUpdate');
        //     update orderListBuilded;
        // }
    }
}