/// <reference path='../../../typings/slatwallTypescript.d.ts' />
/// <reference path='../../../typings/tsd.d.ts' />
class SWSkuPriceEditController{
    
    public skuId;
    public currencyCode;
    public bundledSkuSkuId; 
    public bundledSkuCurrencyCode;
   
    public sku; 
    
    public collectionConfig; 
    
    //@ngInject
    constructor(
        private collectionConfigService,
        private $hibachi
    ){
        if(angular.isUndefined(this.skuId) && angular.isDefined(this.bundledSkuSkuId)){
            this.skuId = this.bundledSkuSkuId;
        }
        if(angular.isUndefined(this.currencyCode) && angular.isDefined(this.bundledSkuCurrencyCode)){
            this.currencyCode = this.bundledSkuCurrencyCode;
        }
        if(angular.isUndefined(this.skuId) && angular.isUndefined(this.sku)){
            throw("You must provide a skuID to SWSkuPriceSingleEditController");
        }
        if(angular.isUndefined(this.sku)){
            this.$hibachi.getEntity("Sku", this.skuId).then(
                (sku)=>{
                    if(angular.isDefined(sku)){
                        this.sku = this.$hibachi.newEntity('Sku');
                        angular.extend(this.sku.data, sku);
                    } else { 
                        throw("There was a problem fetching the sku in SWSkuPriceSingleEditController");
                    }
                },
                (reason)=>{
                    throw("SWSkuPriceEdit had trouble fetchin its sku because" + reason);
                }
           ); 
        }
    }    

}

class SWSkuPriceEdit implements ng.IDirective{
    public templateUrl;
    public restrict = 'EA';
    public scope = {}; 
    public bindToController = {
        skuId:"@",
        bundledSkuSkuId:"@",
        bundledSkuCurrencyCode:"@",        
        currencyCode:"@",
        sku:"=?"
    };
    public controller = SWSkuPriceEditController;
    public controllerAs="swSkuPriceEdit";
   
   
    public static Factory(){
        var directive = (
            skuPartialsPath,
			slatwallPathBuilder
        )=> new SWSkuPriceEdit(
            skuPartialsPath,
			slatwallPathBuilder
        );
        directive.$inject = [
            'skuPartialsPath',
			'slatwallPathBuilder'
        ];
        return directive;
    }
    constructor(
		skuPartialsPath,
	    slatwallPathBuilder
    ){
        this.templateUrl = slatwallPathBuilder.buildPartialsPath(skuPartialsPath)+"skupriceedit.html";
    }
}
export{
    SWSkuPriceEdit,
    SWSkuPriceEditController
}
