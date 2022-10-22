/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-20-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

trigger OrderTrigger on Order (before update, after update) {

    OrderTriggerHandler handler = new OrderTriggerHandler(
        Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap
    );

    switch on Trigger.operationType {

        when BEFORE_UPDATE{
            handler.beforeUpdate();
        }
        
        when AFTER_UPDATE{
            handler.afterUpdate();
        }
    }
}