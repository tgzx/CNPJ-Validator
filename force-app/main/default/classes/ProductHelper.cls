public with sharing class ProductHelper {
    public ProductHelper() {}

    public static void verifyCodeProduct(List<Product2> newProductList){
        List<Product2> productQueryList = [
            SELECT Id, ProductCode
            FROM Product2
        ];

        for (Product2 newProduct : newProductList) {
            for (Product2 queryProduct : productQueryList) {
                if(newProduct.ProductCode == queryProduct.ProductCode){
                    newProduct.addError(Label.UniqueCodeProduct);
                }
            }            
        }
    }
}