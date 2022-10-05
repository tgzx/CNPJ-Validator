public with sharing class AccountTriggerHandler {
    List<Account> oldRecords {get; set;} // trigger.old
    List<Account> newRecords {get; set;} // trigger.new
    Map<Id, Account> oldMap {get; set;} // trigger.oldMap
    Map<Id, Account> newMap {get; set;} // trigger.newMap

    public AccountTriggerHandler(List<Account> oldRecords, List<Account> newRecords, Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        this.oldRecords = oldRecords;
        this.newRecords = newRecords;
        this.oldMap = oldMap;
        this.newMap = newMap;
    }

    public void beforeInsert(){
        AccountHelper.CPNJValidate(this.newRecords);
    }

    public void beforeUpdate(){
        AccountHelper.CPNJValidate(this.newRecords);
    }
}