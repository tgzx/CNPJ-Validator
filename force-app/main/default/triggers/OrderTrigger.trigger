/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-15-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

trigger OrderTrigger on Order (before insert, before update, after insert) {

    OrderTriggerHandler handler = new OrderTriggerHandler(
        Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap
    );

    switch on Trigger.operationType {
        when BEFORE_INSERT{
            handler.beforeInsert();
        }

        // when AFTER_INSERT{
        //     handler.afterInsert();
        // }

        when BEFORE_UPDATE{
            handler.beforeUpdate();
        }
    }
}