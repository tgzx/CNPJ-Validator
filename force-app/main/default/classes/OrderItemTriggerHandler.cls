/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-12-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public with sharing class OrderItemTriggerHandler {
    List<OrderItem> oldRecords {get; set;} // trigger.old
    List<OrderItem> newRecords {get; set;} // trigger.new
    Map<Id, OrderItem> oldMap {get; set;} // trigger.oldMap
    Map<Id, OrderItem> newMap {get; set;} // trigger.newMap

    public OrderItemTriggerHandler(List<OrderItem> oldRecords, List<OrderItem> newRecords, Map<Id, OrderItem> oldMap, Map<Id, OrderItem> newMap) {
        this.oldRecords = oldRecords;
        this.newRecords = newRecords;
        this.oldMap = oldMap;
        this.newMap = newMap;
    }

    public void afterInsert(){
        List<OrderItem> orderItemList = OrderItemHelper.ruleMargin(this.newRecords);

        update orderItemList;
    }

    public void beforeUpdate(){
    }
}