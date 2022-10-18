/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-18-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class FreightTriggerHandler {
    List<Freight__c> oldRecords {get; set;} // trigger.old
    List<Freight__c> newRecords {get; set;} // trigger.new
    Map<Id, Freight__c> oldMap {get; set;} // trigger.oldMap
    Map<Id, Freight__c> newMap {get; set;} // trigger.newMap

    public FreightTriggerHandler(List<Freight__c> oldRecords, List<Freight__c> newRecords, Map<Id, Freight__c> oldMap, Map<Id, Freight__c> newMap) {
        this.oldRecords = oldRecords;
        this.newRecords = newRecords;
        this.oldMap = oldMap;
        this.newMap = newMap;
    }

    public void beforeInsert(){
        FreightHelper.checkFreightDuplicated(this.newRecords);
    }

    public void beforeUpdate(){
        FreightHelper.checkFreightDuplicated(this.newRecords);
    }
}