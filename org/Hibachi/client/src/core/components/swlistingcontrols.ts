/// <reference path='../../../typings/hibachiTypescript.d.ts' />
/// <reference path='../../../typings/tsd.d.ts' />

class SWListingControlsController {
    private selectedSearchColumn;
    private filterPropertiesList;
    private collectionConfig;
    private paginator;
    private searchText;
    private backupColumnsConfig;
    private displayOptionsClosed:boolean=true;
    private filtersClosed:boolean=true;
    private newFilterPosition;
    private itemInUse;

    //@ngInject
    constructor(
        public $hibachi,
        public metadataService,
        public collectionService,
        public observerService
    ) {
        this.backupColumnsConfig = this.collectionConfig.getColumns();
        this.filterPropertiesList = {};

        $hibachi.getFilterPropertiesByBaseEntityName(this.collectionConfig.baseEntityAlias).then((value)=> {
            metadataService.setPropertiesList(value, this.collectionConfig.baseEntityAlias);
            this.filterPropertiesList[this.collectionConfig.baseEntityAlias] = metadataService.getPropertiesListByBaseEntityAlias(this.collectionConfig.baseEntityAlias);
            metadataService.formatPropertiesList(this.filterPropertiesList[this.collectionConfig.baseEntityAlias], this.collectionConfig.baseEntityAlias);
        });

        this.observerService.attach(this.filterActions, 'filterItemAction');

    }
    public filterActions =(res)=>{
        if(res.action == 'add'){
            this.paginator.setCurrentPage(1);
        }
        this.filtersClosed = true;
    };

    public selectSearchColumn = (column?)=>{
        this.selectedSearchColumn = column;
        if(this.searchText){
            this.search();
        }
    };

    public getSelectedSearchColumnName = () =>{
        return (angular.isUndefined(this.selectedSearchColumn)) ? 'All' : this.selectedSearchColumn.title;
    };

    public setKeywords = () =>{
        this.collectionConfig.setKeywords(this.searchText);
        this.search();
    };

    private search =()=>{
        if(angular.isDefined(this.selectedSearchColumn)){
            this.backupColumnsConfig = angular.copy(this.collectionConfig.getColumns());
            var collectionColumns = this.collectionConfig.getColumns();
            for(var i = 0; i < collectionColumns.length; i++){
                if(collectionColumns[i].propertyIdentifier != this.selectedSearchColumn.propertyIdentifier){
                    collectionColumns[i].isSearchable = false;
                }
            }
            this.paginator.setCurrentPage(1);
            this.collectionConfig.setColumns(this.backupColumnsConfig);
        }else{
            this.paginator.setCurrentPage(1);
        }
    };

    private addSearchFilter=()=>{
        if(angular.isUndefined(this.selectedSearchColumn) || !this.searchText) return;

        var keywords = this.searchText.split(" ");
        for(var i = 0; i < keywords.length; i++){
            this.collectionConfig.addLikeFilter(
                this.selectedSearchColumn.propertyIdentifier,
                keywords[i]
            );
        }

        this.searchText = '';
        this.collectionConfig.setKeywords(this.searchText);
        this.paginator.setCurrentPage(1);
    };

    public toggleDisplayOptions=()=>{
        this.displayOptionsClosed = !this.displayOptionsClosed;
    };

    private setItemInUse = (booleanValue)=>{
        this.itemInUse = booleanValue;
    };

    public removeFilter = (array, index, reloadCollection:boolean=true)=>{
        array.splice(index, 1);
        if(reloadCollection){
            this.paginator.setCurrentPage(1);
        }
    };

    public toggleFilters = ()=>{
        if(this.filtersClosed) {
            this.filtersClosed = false;
            this.newFilterPosition = this.collectionService.newFilterItem(this.collectionConfig.filterGroups[0].filterGroup,this.setItemInUse);
        }
    };

    public selectFilterItem = (filterItem) =>{
        this.filtersClosed = false;
        this.collectionService.selectFilterItem(filterItem);
    };

}

class SWListingControls  implements ng.IDirective{

    public static $inject = ['corePartialsPath', 'hibachiPathBuilder'];
    public templateUrl;
    public restrict = 'E';
    public scope = {};

    public bindToController =  {
        collectionConfig : "=",
        paginator : "=",
        getCollection : "&"
    };
    public controller = SWListingControlsController;
    public controllerAs = 'swListingControls';

    constructor(
        public collectionPartialsPath,
        public hibachiPathBuilder
    ){
        this.templateUrl = this.hibachiPathBuilder.buildPartialsPath(this.collectionPartialsPath) + "listingcontrols.html";
    }

    public static Factory(){
        var directive = (
            corePartialsPath,
            hibachiPathBuilder
        )=> new SWListingControls(
            corePartialsPath,
            hibachiPathBuilder
        );
        directive.$inject = [ 'corePartialsPath', 'hibachiPathBuilder'];
        return directive;
    }
}

export{
    SWListingControls
}