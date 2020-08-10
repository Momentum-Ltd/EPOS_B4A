B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=8.28
@EndOfDesignText@
'
' clsEposCustomerBillByItem class
'
#Region  Documentation
	'
	' Name......: clsEPosCustomerBillByItem
	' Release...: 4
	' Date......: 01/12/19
	'
	' History
	' Date......: 03/06/18
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
	'
	' Date......: 13/10/19
    ' Release...: 2
	' Overview..: Changes for X platform operation.
    ' Amendee...: D Morris.
    ' Details...:  Mod: "p-" and "l-" prefixes from all methods.
	'
	' Date......: 11/11/19
	' Release...: 3
	' Overview..: Supports customers amount outstanding.  
	' Amendee...: D Morris.
	' Details...:  Added: amountOutstanding element.
	'				 Mod: XmlDeserialize().
		'
	' Date......: 01/12/19
	' Release...: 4
    ' Overview..: Supports centreId.
    ' Amendee...: D Morris
    ' Details...: Added: centreId - definitions and XmlDeserialize().
	'
	' Date......: 
	' Release...: 
	' Overview..:
	' Amendee...: 
	' Details...: 
	'
#End Region

#Region  Mandatory Subroutines & Data
Sub Class_Globals
	Public centreId As Int				' Centre ID.
	Public customerId As Int			' Customer ID
	Public amountOutstanding As Float	' Amount outstanding for this customer
	Public itemList As List 			' list of clsCustomerOrderItemRec
End Sub
#end region


#Region  Public Subroutines
'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	itemList.Initialize
End Sub

' Deserialize  an itemized bill message.
Public Sub XmlDeserialize(xmlString As String) As clsEposCustomerBillByItem
	Dim parsedData As Map
	Dim localRetObject As clsEposCustomerBillByItem ' Local working copy of object
	localRetObject.Initialize
	Dim xm As Xml2Map
	xm.Initialize
	parsedData = xm.Parse(xmlString)
	Log(xmlString)
	Dim customerBillbyItem As Map = parsedData.Get("clsEposCustomerBillByItem")	
	localRetObject.amountOutstanding = customerBillbyItem.GetDefault("amountOutstanding", 0)
	If customerBillbyItem.Get("itemList") Is Map Then
		Dim billByItem As Map = customerBillbyItem.Get("itemList")
		' TODO Should .GetDefault() be used instead of .Get()
		If billByItem.Get("clsCustomerOrderItemRec") Is List Then ' List of orders
			Dim billByItemList As List = billByItem.Get("clsCustomerOrderItemRec")
			For Each item As Map In billByItemList
				localRetObject.itemList.Add(GetOrderSummary(item))
			Next
		Else if billByItem.Get("clsCustomerOrderItemRec") Is Map Then ' Single order
			Dim billByItemMap As Map = billByItem.Get("clsCustomerOrderItemRec")
			localRetObject.itemList.Add(GetOrderSummary(billByItemMap))
		End If
	End If
	localRetObject.centreId = customerBillbyItem.GetDefault("centreId", 0)
	localRetObject.customerId = customerBillbyItem.Get("customerId")
	Return localRetObject
End Sub
#end region

#Region Local Subroutines

' Converts map containing priceId and qty into a clsCustomerOrderItemRec.
Private Sub GetOrderSummary(orderSummaryEntry As Map) As clsCustomerOrderItemRec
	Dim tempOrderSummaryEntry As clsCustomerOrderItemRec: tempOrderSummaryEntry.Initialize
	tempOrderSummaryEntry.priceId = orderSummaryEntry.Get("priceId")
	tempOrderSummaryEntry.qty = orderSummaryEntry.Get("qty")
	Return tempOrderSummaryEntry
End Sub

#End Region