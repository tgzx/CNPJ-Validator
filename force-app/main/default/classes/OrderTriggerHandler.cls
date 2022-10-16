/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-15-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public with sharing class OrderTriggerHandler {
    List<Order> oldRecords {get; set;} // trigger.old
    List<Order> newRecords {get; set;} // trigger.new
    Map<Id, Order> oldMap {get; set;} // trigger.oldMap
    Map<Id, Order> newMap {get; set;} // trigger.newMap

    public OrderTriggerHandler(List<Order> oldRecords, List<Order> newRecords, Map<Id, Order> oldMap, Map<Id, Order> newMap) {
        this.oldRecords = oldRecords;
        this.newRecords = newRecords;
        this.oldMap = oldMap;
        this.newMap = newMap;
    }

    public void beforeInsert(){

    }

    public void beforeUpdate(){
        OrderHelper.checkAccountOrder(this.newRecords);
    }
}