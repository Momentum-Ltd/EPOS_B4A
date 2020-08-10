B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=7.3
@EndOfDesignText@
'
' clsCustomerBill class
' Note: This class is used for socket messages.
'
#Region Documentation
	'
	' Name......: clsCustomerBill
	' Release...: 3
	' Date......: 13/10/19
	'
	' History
	' Date......: 23/12/17
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
		'
	' Date......: 17/02/18
	' Release...: 2
	' Amendee...: D Morris
	' Details...:  Mod: Header text changed (no code changed).
		'
	' Date......: 13/10/19
    ' Release...: 3
	' Overview..: Changes for X platform operation.
    ' Amendee...: D Morris.
    ' Details...:  Mod: "p-" and "l-" prefixes from all methods.
	'
	' Date......: 
	' Release...: 
	' Overview..: 
	' Amendee...: 
	' Details...: 
	'
#End Region ' Documentation

#Region  Mandatory Subroutines & Data
Sub Class_Globals
	Public customerId As Int	' The unique number of the customer associated with the bill.
	Public Order As List 		' (of clsOrderSummaryRec) - The list of orders related to the bill.
End Sub
#End Region

#Region  Public Subroutines
'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	Order.Initialize
End Sub

' Deserialize customer bill xml string
Public Sub XmlDeserialize(xmlString As String) As clsCustomerBill
	Dim parsedData As Map
	Dim localRetObject As clsCustomerBill ' Local working copy of object
	localRetObject.Initialize
	Dim xm As Xml2Map
	xm.Initialize
	parsedData = xm.Parse(xmlString)
	Log(xmlString)
	Dim customerBill As Map = parsedData.Get("clsCustomerBill")
	
	If customerBill.Get("order") Is Map Then
		Dim orderSummary As Map = customerBill.Get("order")
		If orderSummary.Get("clsOrderSummaryRec") Is List Then ' List of orders
			Dim orderSummaryList As List = orderSummary.Get("clsOrderSummaryRec")
			For Each item As Map In orderSummaryList
				localRetObject.order.Add(GetOrderSummary(item))
			Next
		Else if orderSummary.Get("clsOrderSummaryRec") Is Map Then ' Single order
			Dim orderSummaryMap As Map = orderSummary.Get("clsOrderSummaryRec")
			localRetObject.order.Add(GetOrderSummary(orderSummaryMap))
		End If
	End If
	localRetObject.customerId = customerBill.Get("customerId")
	
	Return localRetObject
End Sub
#End Region


#Region Local Subroutines

' Get Order summary from a map.
Private Sub GetOrderSummary(orderSummaryEntry As Map) As clsOrderSummaryRec
	Dim tempOrderSummaryEntry As clsOrderSummaryRec: tempOrderSummaryEntry.Initialize
	tempOrderSummaryEntry.orderId = orderSummaryEntry.Get("orderId")
	tempOrderSummaryEntry.cost = orderSummaryEntry.Get("cost")
	Return tempOrderSummaryEntry
End Sub
#end Region





	
	
