B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=7.8
@EndOfDesignText@
'
' Class to handle Order Start Response
'

#Region  Documentation
	'
	' Name......: clsOrderStartResponse
	' Release...: 5
	' Date......: 01/12/19
	'
	' History
	' Date......: 10/01/18
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
	'
	' Date......: 31/12/18
	' Release...: 2
	' Overview..: Support for option to Deliver to table.
	' Amendee...: D Morris
	' Details...: Mod: pXmlDeserialize() support for allowDeliverToTable also changed get() to more
	'					robust GetDefault().
	'
	' Date......: 06/03/19
	' Release...: 3
	' Overview..: Changes for #0127 - allow the Server to control whether the user can add a custom message to their order.
	' Amendee...: D Hathway
	' Details...: Added: #0127 - New public variable "disableCustomMessage", and associated changes in pXmlDeserialize()
		'
	' Date......: 13/10/19
    ' Release...: 4
	' Overview..: Changes for X platform operation.
    ' Amendee...: D Morris.
    ' Details...:  Mod: Code taken from iOSEpos.clsOrderStartResponse_v2.
	'					 Removed: unnecessary "p-" and "l-" prefixes from all methods.
	'
    ' Date......: 01/12/19
    ' Release...: 5
    ' Overview..: Supports centreId.
    ' Amendee...: D Morris
    ' Details...: Added: customerId and centreId.
	'			    Mod: XmlDeserialize() supports customerId and centreId.
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
	
	Public accept As Boolean 				' Indicates if order accepted/rejected
	Public centreId As Int					' Centre identifier.
	Public customerId As Int				' Customer identifier.
	Public allowDeliverToTable As Boolean 	' Indicates if option to delivery to table is available for this order.
	Public disableCustomMessage As Boolean 	' Indicates whether the order's custom message should be inhibited.
	Public message As String 				' Message issued by server relating to order
	
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

' Initializes the object.
Public Sub Initialize
	' Currently nothing
End Sub

' Returns an instance of this object containing the data contained in the specified XML string.
Public Sub XmlDeserialize(xmlString As String) As clsOrderStartResponse
	Dim parsedData As Map
	Dim localRetObject As clsOrderStartResponse ' Local working copy of object
	localRetObject.Initialize
	Dim xm As Xml2Map
	xm.Initialize
	parsedData = xm.Parse(xmlString)
	Dim orderStartMsg As Map = parsedData.Get("clsOrderStartResponse")
	localRetObject.accept =  modConvert.ConvertStringToBoolean(orderStartMsg.GetDefault("accept", "false"))
	localRetObject.allowDeliverToTable = modConvert.ConvertStringToBoolean(orderStartMsg.GetDefault("allowDeliverToTable", "false"))
	localRetObject.centreId = orderStartMsg.GetDefault("centreId", 0)
	localRetObject.customerId = orderStartMsg.GetDefault("customerId", 0)
	localRetObject.disableCustomMessage = modConvert.ConvertStringToBoolean(orderStartMsg.GetDefault("disableCustomMessage", "false"))
	localRetObject.message = orderStartMsg.GetDefault("message", "")
	Return localRetObject
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Currently none

#End Region  Local Subroutines
