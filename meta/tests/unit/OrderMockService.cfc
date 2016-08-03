/*

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

*/
component  extends="Slatwall.meta.tests.unit.MockService"{
	public void function init(){
		
	}
	
	// ============  Default data and settings  ==============
	public array function skipMockingWhitelist(required string entityname) {
		if(arguments.entityname == 'Order') {
			return ['orderNumber', //Won't be created if not placed
					'createdDateTime', 'createdByAccountID', 'modifiedDateTime', 'modifiedByAccountID'//Audit Properties
				   ];
		}
		throw("WriteList not found with entity #arguments.entityName#");
	}
	
	public any function returnDefaultTypeByPropertyName(required string propertyName) {
		var tempOrder = createMockMissingEntity('order');
		if(arguments.propertyName == 'orderType') {
			return returnTypeBySystemCode(tempOrder, 'orderType', 'otSalesOrder');
		}
		if(arguments.propertyName == 'orderStatusType') {
			return returnTypeBySystemCode(tempOrder, 'orderStatusType', 'ostNotPlaced');
		}
	}
	
	//================== Mocking Functions ======================
	public any function createCompleteMockOrder( struct orderData ){
		var mockOrder = createBasicMockEntity('Order', arguments.orderData, skipMockingWhitelist('order'));

		for(var property in request.slatwallScope.getService('HibachiService').getPropertiesByEntityName('Order')){
			
			//if property was not defined and hb_populateTestData=true or not defined then make generic mock data
			if(structKeyExists(property,'fieldType') && findNoCase('attribute', property.name) == 0) {
				
				if(property.fieldType == 'many-to-one') {
					if(structKeyExists(arguments.orderData, property.name)){
						mockOrder = createToOneAssociation(mockOrder, property.name, arguments.orderData[property.name]);
					} else {
						mockOrder = createToOneAssociation(mockOrder, property.name);
					}
				}else if(property.fieldType == 'many-to-many' || property.fieldType == 'one-to-many') {
					request.debug(property.name);
					if(structKeyExists(arguments.orderData, property.name)){
						mockOrder = createToManyAssociation(mockOrder, property.name, arguments.orderData[property.name]);
					} else {
						mockOrder = createToManyAssociation(mockOrder, property.name);
					}
				}
				
			}
		}
		
		return mockOrder;
	}
	
	public any function createElementalMockOrder (struct orderData) {
		
	}
	
	

	
	//--------------------------Mock Entity not fully created --------
/*	public any function createMockAccount() {
		var accountData = {
			accountID = ''
		};
		return createPersistedTestEntity('Account', accountData);
	}
	
	public any function createMockAccountAddress() {
		var accountAddressData = {
			accountAddressID = ''
		};
		return createPersistedTestEntity('accountAddress', accountAddressData);
	}
	
	public any function createMockAddress() {
		var addressData = {
			addressID = ''
		};
		return createPersistedTestEntity('Address', addressData);
	}
	
	public any function createMockLocation() {
		var locationData = {
			locationID = ''
		};
		return createPersistedTestEntity('Location', locationData);
	}
	
	public any function createMockOrderOrigin() {
		var orderOriginData = {
			orderOriginID = ''
		};
		return createPersistedTestEntity('OrderOrigin', orderOriginData);
	}
	
	public any function createMockOrder() {
		var orderData = {
			orderID = ''
		};
		return createPersistedTestEntity('Order', orderData);
	}
	public any function createMockPromotionCode() {
		var promotionCodeData = {
			promotionCodeID = ''
		};
		return createPersistedTestEntity('PromotionCode', promotionCodeData);
	}
	
	public any function createMockOrderItem() {
		var orderItemData = {
			orderItemID = ''
		};
		return createPersistedTestEntity('OrderItem', orderItemData);
	}
	public any function createMockPromotionApplied() {
		var PromotionAppliedData = {
			PromotionAppliedID = ''
		};
		return createPersistedTestEntity('PromotionApplied',PromotionAppliedData);
	}
	
	public any function createMockOrderDelivery() {
		var orderDeliveryData = {
			orderDeliveryID = ''
		};
		return createPersistedTestEntity('OrderDelivery', orderDeliveryData);
	}
	
	public any function createMockOrderFulfillment() {
		var orderFulfillmentData = {
			orderFulfillmentID = ''
		};
		return createPersistedTestEntity('orderFulfillment', orderFulfillmentData);
	}
	
	public any function createMockOrderPayment() {
		var orderPaymentData = {
			orderPaymentID = ''
		};
		return createPersistedTestEntity('OrderPayment', orderPaymentData);
	}
	
	public any function createMockorderReturn() {
		var orderReturnData = {
			orderReturnID = ''
		};
		return createPersistedTestEntity('orderReturn', orderReturnData);
	}
*/	
	
	//=============== Some special entities createMockXXX ===================
	public any function createOrderReturn(numeric fulfillAmount) {
		var orderReturnData = {
			orderReturnID = ''
		};
		if(!isNull(arguments.fulfillAmount)) {
			orderReturnData.fulfillmentRefundAmount = arguments.fulfillAmount;
		}
		return createPersistedTestEntity('OrderReturn', orderReturnData);
	}

	public any function createMockStockReceiver() {
		var data = {
			stockReceiverID = '',
			receiverType = 'LALA'
		};
		return createPersistedTestEntity('StockReceiver', data);
	}
}
