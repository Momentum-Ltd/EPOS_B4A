B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=7.8
@EndOfDesignText@
'
' Class which contains a list of the info objects for a customer's orders.
'

#Region  Documentation
	'
	' Name......: clsEposOrderStatusList
	' Release...: 5
	' Date......: 22/05/20
	'
	' History
	' Date......: 06/04/18
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
	'
	' Date......: 20/09/18
	' Release...: 2
	' Amendee...: D Hathway
	' Details...: 
	'		Mod: Change in pXmlDeserialize() and removed lGetOrderStatus(), to unify the
	'				code that deserialises clsEposOrderStatus within that class.
	'
	' Date......: 13/10/19
    ' Release...: 3
	' Overview..: Changes for X platform operation.
    ' Amendee...: D Morris.
    ' Details...:  Mod: unnecessary "p-" and "l-" prefixes from all methods.
    '
    ' Date......: 01/12/19
    ' Release...: 4
    ' Overview..: Supports centreId.
    ' Amendee...: D Morris
    ' Details...: Added: centreId - definitions and XmlDeserialize().
	'
	' Date......: 22/05/20
	' Release...: 5
	' Overview..: Bugfix: #0405 Unable to handle long FCM messages (short-term fix).
	' Amendee...: D Morris
	' Details...:  Mod: overflowFlag element added.
	'			   Mod: XmlDeserialize() handkes overflowFlag.
	
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
	Public centreId As Int			' Centre identifier.
	Public customerId As Int		' Customer identifier.
	Public order As List 			' list of clsOrderStatusRec
	Public overflowFlag As Boolean	' Indicates the order List has overflowed (more available).
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

'Initializes the object.
Public Sub Initialize
	order.Initialize
End Sub

' Returns an instance of this object containing the data contained in the specified XML string.
Public Sub XmlDeserialize(xmlString As String) As clsEposOrderStatusList
	Dim parsedData As Map
	Dim localRetObject As clsEposOrderStatusList ' Local working copy of object
	localRetObject.Initialize
	Dim xm As Xml2Map
	xm.Initialize
	parsedData = xm.Parse(xmlString)
	Log(xmlString)
	Dim eposOrderStatusList As Map = parsedData.Get("clsEposOrderStatusList")
	
	If eposOrderStatusList.Get("order") Is Map Then
		Dim orderStatusList As Map = eposOrderStatusList.Get("order")
		Dim orderStatusObj As clsEposOrderStatus : orderStatusObj.Initialize
		If orderStatusList.Get("clsEposOrderStatus") Is List Then ' List of orders
			Dim orderStatus As List = orderStatusList.Get("clsEposOrderStatus")
			For Each item As Map In orderStatus
				localRetObject.order.Add(orderStatusObj.ConvertFromMap(item))
			Next
		Else if orderStatusList.Get("clsEposOrderStatus") Is Map Then ' Single order
			Dim orderStatusMap As Map = orderStatusList.Get("clsEposOrderStatus")
			localRetObject.order.Add(orderStatusObj.ConvertFromMap(orderStatusMap))
		End If
	End If
	localRetObject.centreId = eposOrderStatusList.Get("centreId")
	localRetObject.customerId = eposOrderStatusList.Get("customerId")
'	localRetObject.overflowFlag = eposOrderStatusList.GetDefault("overflowFlag", False)
	localRetObject.overflowFlag = modConvert.ConvertStringToBoolean( eposOrderStatusList.GetDefault("overflowFlag", False))
	Return localRetObject
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Currently none

#End Region  Local Subroutines
