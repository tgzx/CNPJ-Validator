/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-13-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

trigger MarginTrigger on Margin__c (before insert, before update, after delete) {

    MarginTriggerHandler handler = new MarginTriggerHandler(
        Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap
    );

    switch on Trigger.operationType {
        when BEFORE_INSERT{
            handler.beforeInsert();
        }

        when AFTER_DELETE{
            handler.afterDelete();
        }

        when BEFORE_UPDATE{
            handler.beforeUpdate();
        }
    }
}