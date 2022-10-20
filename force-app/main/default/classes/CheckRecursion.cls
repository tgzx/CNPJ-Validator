/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-19-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public with sharing class CheckRecursion {
    public CheckRecursion() {}

    private static boolean run = true;

    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        } else {
            return run;
        }
    }
}
