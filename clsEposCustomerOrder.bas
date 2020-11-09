B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=7.3
@EndOfDesignText@
'
' Class holding information about a customer's order (EPOS communications with Server).
'

#Region  Documentation
	'
	' Name......: clsEposCustomerOrder
    ' Release...: 12
    ' Date......: 08/11/20
    '
    ' History
	' Date......: 23/12/17
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
	'
	' Version 2 - 9 see clsEposCustomerOrder_v10.
	'
	' Date......: 13/10/19
    ' Release...: 10
	' Overview..: Changes for X platform operation.
    ' Amendee...: D Morris.
    ' Details...:  Mod:  "p-" and "l-" prefixes from all methods.
	'		       Mod: XmlSerialize() to remove the iOS-unsupported XML properties and close the XML document.
	'
	' Date......: 01/12/19
    ' Release...: 11
    ' Overview..: Supports centreId.
    ' Amendee...: D Morris
    ' Details...: Added: centreId.
	'				Mod: XmlSerialize() supports centreId.
	'			    Mod: old definitions allowDeliverToTable and disableCustomerMessage removed.
	'
	' Date......: 08/11/20
	' Release...: 12
	' Overview..: Issue: 00542 Table number handling provided.
	' Amendee...: D Morris
	' Details...: Mod: Initialize() deliver to table now is the default.
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
'	Public allowDeliverToTable As Boolean 	' Indicates if customer can specify order deliver to table (otherwise collect only)
	Public centreId As Int				' Centre Identify
	Public customerNumber As String 	' The customer's Unique Customer Number.
	Public deliverToTable As Boolean 	' Whether the order should be delivered (false = to be collected).
'	Public disableCustomMessage As Boolean ' Whether the order's custom message input will be inhibited.
	Public orderList As List 			' (of clsCustomerOrderItemRec) - the items in the order.
	Public orderMessage As String 		' The message from the customer attached to the order.
	Public tableNumber As Int 			' The customer's table number.
	
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

' Adds the specified item to the order.
Public Sub AddItem(priceId As Int, qty As Int)
	Dim itemRec As clsCustomerOrderItemRec : itemRec.initialize

	itemRec.priceId = priceId
	itemRec.qty = qty
	orderList.Add(itemRec)
End Sub

' Returns whether the specified item currently exists in the order's item list.
Public Sub IsItemFound(priceId As Int) As Boolean
	Dim itemfound As Boolean = False
	
	For Each item As clsCustomerOrderItemRec In orderList
		If item.priceId = priceId Then
			itemfound = True
			Exit	' Exit for loop
		End If
	Next
	Return itemfound
End Sub

' Initializes the object.
Public Sub Initialize
	deliverToTable = True
	orderList.Initialize
End Sub

' Returns an XML string containing the order data contained in this class.
' (Taken from https://www.b4x.com/android/forum/threads/anyone-using-xmlbuilder-with-b4a.16277/ )
Public Sub XmlSerialize As String
	Dim x As XMLBuilder
	
	x = x.create("clsEposCustomerOrder").attribute("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") _
			.attribute("xmlns:xsd", "http://www.w3.org/2001/XMLSchema")
	x = x.element("centreId").text(centreId).up		
	x = x.element("customerNumber").text(customerNumber).up
	x = x.element("deliverToTable").text(deliverToTable).up
	x = x.element("orderMessage").text(orderMessage).up
	x = x.element("tableNumber").text(tableNumber).up	
	
	x = x.element("orderList")
	For Each item As clsCustomerOrderItemRec In orderList
		x = x.element("clsCustomerOrderItemRec").element("priceId").text(item.priceId).up _
				.element("qty").text(item.qty).up.up
	Next
#if B4A	
	Dim props As Map : props.Initialize ' TODO Not sure using 'Map' is necessary - investigate
	props.Put("{http://xml.apache.org/xslt}indent-amount", "4")
	props.Put("indent", "yes")
	Return x.asString2(props)
#else ' B4I
	' NOTE: The following line ensures the list and class's closing tags are included - strangely, they're not appended by the serializer
	Dim xmlString As String = x.AsString & CRLF & "</orderList>" & CRLF & "</clsEposCustomerOrder>"
	Return xmlString
#end if
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Currently none

#End Region  Local Subroutines
