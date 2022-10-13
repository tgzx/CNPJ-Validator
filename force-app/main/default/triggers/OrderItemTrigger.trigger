/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-12-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

trigger OrderItemTrigger on OrderItem (before insert, before update, after insert) {

    OrderItemTriggerHandler handler = new OrderItemTriggerHandler(
        Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap
    );

    switch on Trigger.operationType {
        // when BEFORE_INSERT{
        //     handler.beforeInsert();
        // }

        when AFTER_INSERT{
            handler.afterInsert();
        }

        // when BEFORE_UPDATE{
        //     handler.beforeUpdate();
        // }
    }
}