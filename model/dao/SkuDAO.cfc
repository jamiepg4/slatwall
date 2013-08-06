<!---

    Slatwall - An Open Source eCommerce Platform
    Copyright (C) ten24, LLC
	
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
	
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
	
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Linking this program statically or dynamically with other modules is
    making a combined work based on this program.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.
	
    As a special exception, the copyright holders of this program give you
    permission to combine this program with independent modules and your 
    custom code, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting program under terms 
    of your choice, provided that you follow these specific guidelines: 

	- You also meet the terms and conditions of the license of each 
	  independent module 
	- You must not alter the default display of the Slatwall name or logo from  
	  any part of the application 
	- Your custom code must not alter or create any files inside Slatwall, 
	  except in the following directories:
		/integrationServices/

	You may copy and distribute the modified version of this program that meets 
	the above guidelines as a combined work under the terms of GPL for this program, 
	provided that you include the source code of that other code when and as the 
	GNU GPL requires distribution of source code.
    
    If you modify this program, you may extend this exception to your version 
    of the program, but you are not obligated to do so.

Notes:

--->
<cfcomponent extends="HibachiDAO">
	
	<cfproperty name="nextOptionGroupSortOrder" type="numeric" />
	
	
	<cffunction name="getSkuStocksDeletableFlag" returnType="boolean" access="public">
		<cfargument name="skuID" type="string" required="true" />
		
		<cfset var rs = "" />
		
		<cfset var results = ormExecuteQuery("SELECT skuID
			FROM
				SlatwallSku ss
			WHERE
				ss.skuID = :skuID
			  AND (
			  	EXISTS( SELECT a.inventoryID as id FROM SlatwallInventory a WHERE stock.sku.skuID = :skuID )
			  	  OR
			  	EXISTS( SELECT a.orderDeliveryItemID as id FROM SlatwallOrderDeliveryItem a WHERE stock.sku.skuID = :skuID )
				  OR
			  	EXISTS( SELECT a.orderItemID as id FROM SlatwallOrderItem a WHERE stock.sku.skuID = :skuID )
				  OR
			  	EXISTS( SELECT a.physicalCountItemID as id FROM SlatwallPhysicalCountItem a WHERE stock.sku.skuID = :skuID )
			  	  OR
			  	EXISTS( SELECT a.stockAdjustmentDeliveryItemID as id FROM SlatwallStockAdjustmentDeliveryItem a WHERE stock.sku.skuID = :skuID )
			  	  OR
			  	EXISTS( SELECT a.stockAdjustmentItemID as id FROM SlatwallStockAdjustmentItem a WHERE fromStock.sku.skuID = :skuID )
			  	  OR
			  	EXISTS( SELECT a.stockAdjustmentItemID as id FROM SlatwallStockAdjustmentItem a WHERE toStock.sku.skuID = :skuID )
			  	  OR
			  	EXISTS( SELECT a.stockHoldID as id FROM SlatwallStockHold a WHERE stock.sku.skuID = :skuID )
			  	  OR
			  	EXISTS( SELECT a.stockReceiverItemID as id FROM SlatwallStockReceiverItem a WHERE stock.sku.skuID = :skuID )
			  	  OR
			  	EXISTS( SELECT a.vendorOrderItemID as id FROM SlatwallVendorOrderItem a WHERE stock.sku.skuID = :skuID )
			  )", { skuID = arguments.skuID }) />
		
		<cfif arrayLen(results)>
			<cfreturn false />
		</cfif>
		
		<cfreturn true />
	</cffunction>
	
	<cfscript>

	public any function getSkuBySkuCode( required string skuCode){
		return ormExecuteQuery( "SELECT ss FROM SlatwallSku ss LEFT JOIN ss.alternateSkuCodes ascs WHERE ss.skuCode = :skuCode OR ascs.alternateSkuCode = :skuCode", {skuCode=arguments.skuCode}, true ); 
	}
		
	// returns product skus which matches ALL options (list of optionIDs) that are passed in
	public any function getSkusBySelectedOptions(required string selectedOptions, string productID) {
		var params = [];
		var hql = "select distinct sku from SlatwallSku as sku 
					inner join sku.options as opt 
					where 
					0 = 0 ";
		for(var i=1; i<=listLen(arguments.selectedOptions); i++) {
			var thisOptionID = listGetat(arguments.selectedOptions,i);
			hql &= "and exists (
						from SlatwallOption o
						join o.skus s where s.id = sku.id
						and o.optionID = ?
					) ";
			arrayAppend(params,thisOptionID);
		}
		// if product ID is passed in, limit query to the product
		if(structKeyExists(arguments,"productID")) {
			hql &= "and sku.product.id = ?";
			arrayAppend(params,arguments.productID);	
		}
		return ormExecuteQuery(hql,params);
	}
	
	public any function searchSkusByProductType(string term,string productTypeID) {
		var q = new Query();
		var sql = "select skuID,skuCode from SlatwallSku where skuCode like :code";
		q.addParam(name="code",value="%#arguments.term#%",cfsqltype="cf_sql_varchar");
		if(structKeyExists(arguments,"productTypeID") && trim(arguments.productTypeID) != "") {
			sql &= " and productID in (select productID from SlatwallProduct where productTypeID in (:productTypeIDs))";
			q.addParam(name="productTypeIDs", value="#arguments.productTypeID#", cfsqltype="cf_sql_varchar", list="true");
		}
		q.setSQL(sql);
		var records = q.execute().getResult();
		var result = [];
		for(var i=1;i<=records.recordCount;i++) {
			result[i] = {
				"id" = records.skuID[i],
				"value" = records.skuCode[i]
			};
		}
		return result;
	}
	
	public array function getProductSkus(required any product, required any fetchOptions) {
		
		var hql = "SELECT sku FROM SlatwallSku sku ";
		if(fetchOptions) {
			if(arguments.product.getBaseProductType() eq "contentAccess") {
				hql &= "INNER JOIN FETCH sku.accessContents contents ";	
			} else if (arguments.product.getBaseProductType() eq "merchandise") {
				hql &= "INNER JOIN FETCH sku.options option ";
			} else if (arguments.product.getBaseProductType() eq "subscription") {
				hql &= "INNER JOIN sku.subscriptionTerm st ";
				hql &= "INNER JOIN FETCH sku.subscriptionBenefits sb ";
			}
		}
		var hql &= "WHERE sku.product.productID = :productID ";
		
		var skus = ORMExecuteQuery(hql,	{productID = arguments.product.getProductID()}, false, {ignoreCase="true"});
		
		return skus;
	}
	
	</cfscript>

	<cffunction name="getSortedProductSkusID">
		<cfargument name="productID" type="string" required="true" />
		
		<cfset var sorted = "" />
		
		<!--- TODO: test to see if this query works with DB's other than MSSQL and MySQL --->
		<cfquery name="sorted">
			SELECT
				SlatwallSku.skuID
			FROM
				SlatwallSku
			  INNER JOIN
				SlatwallSkuOption on SlatwallSku.skuID = SlatwallSkuOption.skuID
			  INNER JOIN
				SlatwallOption on SlatwallSkuOption.optionID = SlatwallOption.optionID
			  INNER JOIN
				SlatwallOptionGroup on SlatwallOption.optionGroupID = SlatwallOptionGroup.optionGroupID
			WHERE
				SlatwallSku.productID = <cfqueryparam value="#arguments.productID#" cfsqltype="cf_sql_varchar" />
			GROUP BY
				SlatwallSku.skuID
			ORDER BY
				<cfif getApplicationValue("databaseType") eq "MicrosoftSQLServer">
					SUM(SlatwallOption.sortOrder * POWER(CAST(10 as bigint), CAST((#getNextOptionGroupSortOrder()# - SlatwallOptionGroup.sortOrder) as bigint))) ASC
				<cfelse>
					SUM(SlatwallOption.sortOrder * POWER(10, #getNextOptionGroupSortOrder()# - SlatwallOptionGroup.sortOrder)) ASC
				</cfif>
		</cfquery>
		
		<cfreturn sorted />
	</cffunction>
	
	<cffunction name="getNextOptionGroupSortOrder" returntype="numeric" access="private">
		<cfif not structKeyExists(variables, "nextOptionGroupSortOrder")>
			<cfset variables.nextOptionGroupSortOrder = 1 />
			
			<cfset var rs = "" />
			
			<cfquery name="rs">
				SELECT max(SlatwallOptionGroup.sortOrder) as 'max' FROM SlatwallOptionGroup
			</cfquery>
			<cfif rs.recordCount>
				<cfset variables.nextOptionGroupSortOrder = rs.max + 1 />
			</cfif>
			
		</cfif>
		
		<cfreturn variables.nextOptionGroupSortOrder />
	</cffunction>
	
	<cffunction name="clearNextOptionGroupSortOrder" returntype="void" access="public">
		<cfif not structKeyExists(variables, "nextOptionGroupSortOrder")>
			<cfset structDelete(variables, "nextOptionGroupSortOrder") />
		</cfif>
	</cffunction>
	
</cfcomponent>
