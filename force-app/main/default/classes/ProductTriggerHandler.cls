public with sharing class ProductTriggerHandler {
    List<Product2> oldRecords {get; set;} // trigger.old
    List<Product2> newRecords {get; set;} // trigger.new
    Map<Id, Product2> oldMap {get; set;} // trigger.oldMap
    Map<Id, Product2> newMap {get; set;} // trigger.newMap

    public ProductTriggerHandler(List<Product2> oldRecords, List<Product2> newRecords, Map<Id, Product2> oldMap, Map<Id, Product2> newMap) {
        this.oldRecords = oldRecords;
        this.newRecords = newRecords;
        this.oldMap = oldMap;
        this.newMap = newMap;
    }

    public void beforeInsert(){
        ProductHelper.verifyCodeProduct(this.newRecords);
    }

    public void beforeUpdate(){
        ProductHelper.verifyCodeProduct(this.newRecords);
    }
}