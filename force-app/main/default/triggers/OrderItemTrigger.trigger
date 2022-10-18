/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-18-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

trigger OrderItemTrigger on OrderItem (before insert, before update, after insert, after delete) {

    OrderItemTriggerHandler handler = new OrderItemTriggerHandler(
        Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap
    );

    switch on Trigger.operationType {
        when BEFORE_INSERT{
            handler.beforeInsert();
        }

        when AFTER_UPDATE{
            handler.afterUpdate();
        }

        when AFTER_DELETE{
            handler.afterDelete();
        }

        when BEFORE_UPDATE{
            handler.beforeUpdate();
        }
    }
}