/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-19-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ProductHelper {
    public ProductHelper() {}

    public static void verifyCodeProduct(List<Product2> newProductList){
        List<Product2> productQueryList = [
            SELECT Id, ProductCode
            FROM Product2
        ];

        for (Product2 newProduct : newProductList){
            for (Product2 oldProduct : productQueryList){
                if(newProduct.Id != oldProduct.Id){
                    if(newProduct.ProductCode == oldProduct.ProductCode){
                        newProduct.addError(Label.UniqueCodeProduct);
                    }
                }
            }            
        }
    }
}