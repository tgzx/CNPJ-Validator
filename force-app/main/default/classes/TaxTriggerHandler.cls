/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-15-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public with sharing class TaxTriggerHandler {
    List<Tax__c> oldRecords {get; set;} // trigger.old
    List<Tax__c> newRecords {get; set;} // trigger.new
    Map<Id, Tax__c> oldMap {get; set;} // trigger.oldMap
    Map<Id, Tax__c> newMap {get; set;} // trigger.newMap

    public TaxTriggerHandler(List<Tax__c> oldRecords, List<Tax__c> newRecords, Map<Id, Tax__c> oldMap, Map<Id, Tax__c> newMap) {
        this.oldRecords = oldRecords;
        this.newRecords = newRecords;
        this.oldMap = oldMap;
        this.newMap = newMap;
    }

    public void beforeInsert(){
        TaxHelper.checkTaxDuplicated(this.newRecords);
    }

    // FUNCIONA MELHOR SE TIVER UM CAMPO STATUS EM PEDIDO, PARA RECALCULAR A PRECIFICAÇÃO APENAS DOS PEDIDOS EM ABERTO
    public void afterDelete(){
        List<OrderItem> orderItemList = TaxHelper.refindTaxs(this.oldRecords);

        update orderItemList;
    }

    public void beforeUpdate(){
        // TaxHelper.checkTaxDuplicatedUpdated(this.newRecords);
        TaxHelper.checkTaxDuplicated(this.newRecords);
    }
}