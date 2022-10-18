/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-14-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public with sharing class MarginTriggerHandler {
    List<Margin__c> oldRecords {get; set;} // trigger.old
    List<Margin__c> newRecords {get; set;} // trigger.new
    Map<Id, Margin__c> oldMap {get; set;} // trigger.oldMap
    Map<Id, Margin__c> newMap {get; set;} // trigger.newMap

    public MarginTriggerHandler(List<Margin__c> oldRecords, List<Margin__c> newRecords, Map<Id, Margin__c> oldMap, Map<Id, Margin__c> newMap) {
        this.oldRecords = oldRecords;
        this.newRecords = newRecords;
        this.oldMap = oldMap;
        this.newMap = newMap;
    }

    public void beforeInsert(){
        MarginHelper.checkMarginDuplicated(this.newRecords);
    }

    // FUNCIONA MELHOR SE TIVER UM CAMPO STATUS EM PEDIDO, PARA RECALCULAR A PRECIFICAÇÃO APENAS DOS PEDIDOS EM ABERTO
    public void afterDelete(){
        List<OrderItem> orderItemList = MarginHelper.refindMargins(this.oldRecords);

        update orderItemList;
    }

    public void beforeUpdate(){
        // MarginHelper.checkMarginDuplicatedUpdated(this.newRecords);
        MarginHelper.checkMarginDuplicated(this.newRecords);
    }
}