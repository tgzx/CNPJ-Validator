/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-24-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ExceptionCatcher {
    public ExceptionCatcher() {}

    public static void updateDML(List<OrderItem> orderItemList){
        try {
            update orderItemList;
        } catch (System.DmlException e) {

        }
    }
}
