/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-25-2022
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
        OrderHelper.checkOrderFields(this.newRecords, this.oldRecords);
    }

    public void afterUpdate(){
        List<OrderItem> orderItemList = OrderHelper.checkOrderFields(this.newRecords, this.oldRecords);
        update orderItemList;
    }
}