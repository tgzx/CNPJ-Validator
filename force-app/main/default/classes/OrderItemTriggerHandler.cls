/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-20-2022
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
        OrderItemHelper.checkInsertionOrderItem(this.newRecords);
    }

    public void beforeUpdate(){
        if(checkRecursion.runOnce()){
            OrderItemHelper.checkInsertionOrderItem(this.newRecords);
        }
    }
}