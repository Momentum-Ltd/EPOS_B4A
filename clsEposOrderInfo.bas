B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=8.28
@EndOfDesignText@
'
' Class used to store all the customer-relevant details of a single order.
' This class is an extended version of clsEposCustomerOrder with all fields stored, as well as some additional fields.
'

#Region  Documentation
	'
	' Name......: clsEposOrderInfo
	' Release...: 4-
	' Date......: 07/04/21
	'
	' History
	' Date......: 15/08/18
	' Release...: 1
	' Created by: D Hathway
	' Details...: First release to support version tracking
	'
	' Date......: 21/08/18
	' Release...: 2
	' Amendee...: D Hathway
	' Details...: 
	'		Bugfix: Change in pDeserializeXml() to prevent exception when timestamp is 00:00 (e.g. waiting for payment)
	'
	' Date......: 01/01/19
	' Release...: 3
	' Overview..: Bugfix problem with devliverTo (#0056).
	' Amendee...: D Morris
	' Details...:  Mod: deliverTo removed and replaced with tableNumber and deliverToTable.	
	'			   Mod: pDeserializeXml() deliverTo removed and uses tableNumber and deliverToTable values.
	'
	' Date......: 13/10/19
    ' Release...: 4
	' Overview..: Changes for X platform operation.
    ' Amendee...: D Morris.
    ' Details...:  Mod: "p-" and "l-" prefixes from all methods.
	'
	' Date......: 
    ' Release...: 
	' Overview..: Support for sessionId (Stripe Checkout operation).
    ' Amendee...: D Morris
    ' Details...: Added: sessionId with support code.
	'
	' Date......: 
	' Release...: 
	' Overview..: 
	' Amendee...: 
	' Details...: 
	'
#End Region  Documentation

#Region  Mandatory Subroutines & Data

Sub Class_Globals
	
	' Public variables
	Public customerNumber As String 	' The customer number.
	Public deliverToTable As Boolean 	' Indicates if order is to be delivered (otherwise for collection).
	Public itemList As List 			' List of clsCustomerOrderItemRec objects which store all the goods items in the order.
	Public orderId As Int 				' The order identifier.
	Public orderMessage As String 		' The message attached to the order.
	Public orderStarted As String 		' The order's timestamp. When deserialising, a date & time is provided but only the time is stored.
	Public paid As Boolean 				' Indicates if the order has been paid.
	Public sessionId As String			' The Session ID.
	Public tableNumber As Int			' Table number for order 	
End Sub

#End Region  Mandatory Subroutines & Data


#Region  Public Subroutines

' Initializes the object.
Public Sub Initialize
	itemList.Initialize
End Sub

' Returns a class object of this type containing the data contained in the specified XML string.
' If the deserialisation fails then a version of the class with empty fields will be returned.
Public Sub XmlDeserialize(xmlString As String) As clsEposOrderInfo
	' Parse the XML into a map containing all the class data
	Dim rtnLocalObject As clsEposOrderInfo : rtnLocalObject.Initialize ' Local working copy of object
	Dim xm As Xml2Map : xm.Initialize ' Initialise the XML parser
	Dim parsedData As Map = xm.Parse(xmlString) ' Parse the XML
	Log(xmlString) ' Log the XML string once the parsing is complete
	Dim mapOrderInfo As Map = parsedData.Get("clsEposOrderInfo") ' Get the map of the overall class
	
	' Populate the item list
	If mapOrderInfo.Get("orderList") Is Map Then ' Ensure the list object exists
		Dim orderItemsMap As Map = mapOrderInfo.Get("orderList")
		Dim orderItemsObj As Object = orderItemsMap.Get("clsCustomerOrderItemRec")
		If orderItemsObj Is List Then ' The returned object contains multiple items
			Dim itemList As List = orderItemsObj
			For Each item As Map In itemList
				rtnLocalObject.itemList.Add(GetOrderItem(item))
			Next
		Else If orderItemsObj Is Map Then ' The returned object contains only one item
			Dim itemMap As Map = orderItemsObj
			rtnLocalObject.itemList.Add(GetOrderItem(itemMap))
		End If
	End If
	
	' Populate the other fields
	rtnLocalObject.customerNumber = mapOrderInfo.Get("customerNumber")
	rtnLocalObject.tableNumber = mapOrderInfo.Get("tableNumber")
	rtnLocalObject.orderId = mapOrderInfo.Get("orderId")
	rtnLocalObject.orderMessage = mapOrderInfo.Get("orderMessage")
	Dim tempString As String = mapOrderInfo.Get("deliverToTable")
	rtnLocalObject.deliverToTable = modConvert.ConvertStringToBoolean(tempString)
	Dim dateTimeStr As String = mapOrderInfo.Get("orderStarted")
	Dim timeStr As String = dateTimeStr.SubString(dateTimeStr.IndexOf("T") + 1)
	If timeStr.Contains(".") Then timeStr = timeStr.SubString2(0, timeStr.IndexOf("."))
	rtnLocalObject.orderStarted = timeStr
	rtnLocalObject.paid = mapOrderInfo.Get("paid")
	rtnLocalObject.sessionId = mapOrderInfo.GetDefault("sessionId", "")
	Return rtnLocalObject
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Returns a clsCustomerOrderItemRec object containing the data within the specified map.
Private Sub GetOrderItem(itemMap As Map) As clsCustomerOrderItemRec
	Dim rtnOrderItem As clsCustomerOrderItemRec : rtnOrderItem.Initialize
	rtnOrderItem.priceId = itemMap.Get("priceId")
	rtnOrderItem.qty = itemMap.Get("qty")
	Return rtnOrderItem
End Sub

#End Region  Local Subroutines
