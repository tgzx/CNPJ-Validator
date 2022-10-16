/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-15-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

trigger TaxTrigger on Tax__c (before insert, before update, after delete) {

    TaxTriggerHandler handler = new TaxTriggerHandler(
        Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap
    );

    switch on Trigger.operationType {
        when BEFORE_INSERT{
            handler.beforeInsert();
        }

        //CORRIGIR
        // when AFTER_DELETE{
        //     handler.afterDelete();
        // }

        when BEFORE_UPDATE{
            handler.beforeUpdate();
        }
    }
}