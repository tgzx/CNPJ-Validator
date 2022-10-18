/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-18-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public with sharing class OrderItemTriggerHandler {
    List<OrderItem> oldRecords {get; set;}
    List<OrderItem> newRecords {get; set;}
    Map<Id, OrderItem> oldMap {get; set;}
    Map<Id, OrderItem> newMap {get; set;}

    public OrderItemTriggerHandler(List<OrderItem> oldRecords, List<OrderItem> newRecords, Map<Id, OrderItem> oldMap, Map<Id, OrderItem> newMap) {
        this.oldRecords = oldRecords;
        this.newRecords = newRecords;
        this.oldMap = oldMap;
        this.newMap = newMap;
    }

    public void beforeInsert(){
        List<Order> orderListBuilded = OrderItemHelper.checkInsertionOrderItem(this.newRecords);
        update orderListBuilded;
    }

    public void beforeUpdate(){
        OrderItemHelper.checkInsertionOrderItem(this.newRecords);
    }

    public void afterUpdate(){
        List<Order> orderListBuilded = OrderItemHelper.checkInsertionOrderItem(this.newRecords);
        update orderListBuilded;
    }

    public void afterDelete(){

        Map<Id, Order> orderMapBuilded = OrderItemHelper.calcPriceDelete(this.oldRecords);

        List<Order> orderListBuilded = new List<Order>();

        for(Order iOrder : orderMapBuilded.values()){
            orderListBuilded.add(iOrder);
        }

        update orderListBuilded;
    }
}