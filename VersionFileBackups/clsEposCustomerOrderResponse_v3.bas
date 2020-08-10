B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=8.28
@EndOfDesignText@
'
' Class received from the Server, sent in response to an order being submitted.
'

#Region  Documentation
	'
	' Name......: clsEposCustomerOrderResponse
	' Release...: 3
	' Date......: 01/12/19
	'
	' History
	' Date......: 10/09/18
	' Release...: 1
	' Created by: D Hathway
	' Details...: First release to support version tracking
			'
	' Date......: 13/10/19
    ' Release...: 2
	' Overview..: Changes for X platform operation.
    ' Amendee...: D Morris.
    ' Details...:  Mod: "p-" and "l-" prefixes from all methods.
		'
	' Date......: 01/12/19
    ' Release...: 3
    ' Overview..: Supports centreId.
    ' Amendee...: D Morris
    ' Details...: Added: centreId - definition and DeserialiseXml().
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
	Public accept As Boolean
	Public centreId As Int			' Centre identifier.
	Public customerId As Int		' Customer identifier.
	Public itemList As List
	Public message As String
	Public orderId As Int
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

' Populates the fields of this class with the the data contained in the specified XML string.
' If the deserialisation fails then the fields of this class will be unchanged from their previous values.
Public Sub DeserialiseXml(xmlString As String)
	' Attempt to parse the XML into a map containing all the class data
	Dim xm As Xml2Map : xm.Initialize ' Initialise the XML parser
	Dim orderResponseMap As Map : orderResponseMap.Initialize
	Try
		Dim parsedData As Map = xm.Parse(xmlString) ' Parse the XML
		orderResponseMap = parsedData.Get("clsEposCustomerOrderResponse") ' Get the map of the overall class
	Catch
		Log(LastException)
	End Try
	Log(xmlString) ' Log the XML string once the parsing is complete, for test purposes
	
	' Populate the list and fields of this class using the deserialised data
	If orderResponseMap Is Map Then ' Check whether the data has been successfully deserialised
		itemList.Initialize
		If orderResponseMap.Get("itemList") Is Map Then ' Check if the list object contains any entries
			Dim itemListMap As Map = orderResponseMap.Get("itemList")
			Dim itemListObj As Object = itemListMap.Get("clsCustomerOrderItemRec")
			If itemListObj Is List Then ' The returned object contains multiple items
				Dim localItemsList As List = itemListObj
				For Each item As Map In localItemsList
					itemList.Add(GetItem(item))
				Next
			Else If itemListObj Is Map Then ' The returned object contains only one item
				Dim localItemMap As Map = itemListObj
				itemList.Add(GetItem(localItemMap))
			End If
		End If

		accept = orderResponseMap.GetDefault("accept", False)
		centreId = orderResponseMap.GetDefault("centreId", 0)
		customerId = orderResponseMap.GetDefault("customerId", 0)
		message = orderResponseMap.GetDefault("message", "")
		orderId = orderResponseMap.GetDefault("orderId", 0)
	End If
End Sub

' Initializes the object.
Public Sub Initialize
	itemList.Initialize
End Sub


#End Region  Public Subroutines

#Region  Local Subroutines

' Returns a clsCustomerOrderItemRec object containing the data within the specified map.
Private Sub GetItem(itemMap As Map) As clsCustomerOrderItemRec
	Dim rtnItem As clsCustomerOrderItemRec : rtnItem.Initialize
	rtnItem.priceId = itemMap.Get("priceId")
	rtnItem.qty = itemMap.Get("qty")
	Return rtnItem
End Sub

#End Region  Local Subroutines
