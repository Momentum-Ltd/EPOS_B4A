B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=7.8
@EndOfDesignText@
'
' Handles Epos Order status (with queue position)
'

#Region  Documentation
	'
	' Name......: clsEposOrderStatus
    ' Release...: 7-
    ' Date......: 05/04/21
    '
    ' History
	' Date......: 27/02/17
    ' Release...: 1
    ' Created by: D Morris
    ' Details...: First release to support version tracking (based on clsEposOrderStatus (v3) new element
	'					queuePosition added.)
	'
	' Date......: 20/09/18
    ' Release...: 2
	' Overview..: Added new members, to distinguish collection/delivery from table number.
    ' Amendee...: D Hathway
    ' Details...: Added: New public variables deliverToTable and tableNumber and associated code
	'			  Added: New public method pConvertFromMap() to make deserialisation easier (for e.g. clsEposOrderStatusList)
	'		        Mod: Changes to pXmlSerialize() to remove its parameter (uses data from its own instance)
	'
	' Date......: 22/10/18
    ' Release...: 3
	' Overview..: Removed obsolete 'deliverTo' field, and improved protection when deserialising.
    ' Amendee...: D Hathway
    ' Details...: Mod: Removed 'deliverTo' field, and its references in pConvertFromMap() and pXmlSerialize(), as part of #0054
	'			  Mod: Changes to pConvertFromMap() to replace each map.Get() call with safer map.GetDefault()
	'
	' Date......: 06/03/19
    ' Release...: 4
	' Overview..: Changes for #0107 - make an order's status text more relevant when it requires a refund
    ' Amendee...: D Hathway
    ' Details...: Added: New public variable "amount", with associated changes in pConvertFromMap() and pXmlSerialize()
		'
	' Date......: 13/10/19
    ' Release...: 5
	' Overview..: Changes for X platform operation.
    ' Amendee...: D Morris.
    ' Details...:  Mod: Code taken from iOSEpos.clsEposWebCommsMessageRec_v1.
	'						 Removed: unnecessary "p-" and "l-" prefixes from all methods.
	'						     Mod: XmlSerialize() to remove the iOS-unsupported XML properties and close the XML document.
	'
	' Date......: 01/12/19
    ' Release...: 6
    ' Overview..: Supports centreId.
    ' Amendee...: D Morris
    ' Details...: Added: centreId, customerId - definitions, ConvertFromMap() and XmlSerialize().
		'
	' Date......: 13/05/20
	' Release...: 7
	' Overview..: Bugfix: #0404 - no response to Message or Update Epos commands.
	' Amendee...: D Morris.
	' Details...: Added:  messageId.
	'			    Mod: XmlDeserialize() and XmlSerialize() supports messageId.
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
	Public amount As Float 			' The cash value owed on the order (can be negative to indicate a refund required).
	Public centreId As Int			' Centre identifier.
	Public customerId As Int		' Customer identifier.
	Public deliverToTable As Boolean ' Whether the order should be delivered (false = to be collected).
	Public messageId As Int			' The message ID (= 0 if no response required).
	Public orderId As Int 			' The order's ID number.
	Public queuePosition As Int 	' The position in the queue of the order. 0 is unknown and -1 is not in queue.
	Public sessionId As String		' The session ID.
	Public status As Int 			' The status of the order (as a ModConvert.status*** int value)
	Public tableNumber As Int 		' The customer's table number.	
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines
' Returns an instance of this object containing the data contained in the specified map.
Public Sub ConvertFromMap(mapInput As Map) As clsEposOrderStatus
	Dim rtnObj As clsEposOrderStatus : rtnObj.Initialize
	
	' TODO - check if the following default values are OK
	rtnObj.amount = mapInput.Getdefault("amount", 0)
	rtnObj.centreId = mapInput.GetDefault("centreId", 0)
	rtnObj.customerId = mapInput.GetDefault("customerId", 0)
	rtnObj.deliverToTable = mapInput.GetDefault("deliverToTable", False)
	rtnObj.messageId = mapInput.GetDefault("messageId", 0)
	rtnObj.orderId = mapInput.GetDefault("orderId", 0)
	rtnObj.queuePosition = mapInput.GetDefault("queuePosition", 0)
	rtnObj.sessionId = mapInput.GetDefault("sessionId", "")
	rtnObj.status = modConvert.ConvertStringToStatus(mapInput.GetDefault("status", "unknown"))
	rtnObj.tableNumber = mapInput.GetDefault("tableNumber", 0)
	Return rtnObj
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	' Currently nothing
End Sub

' Returns an instance of this object containing the data contained in the specified XML string.
' The status value will be set to ModConvert.statusUnknown if unable to deserialize message.
Public Sub XmlDeserialize(xmlString As String) As clsEposOrderStatus
	Dim localRetObject As clsEposOrderStatus : localRetObject.Initialize ' Local working copy of object
	Dim xm As Xml2Map : xm.Initialize
	Dim parsedData As Map = xm.Parse(xmlString)
	Dim orderStatusResult As Map = parsedData.Get("clsEposOrderStatus")
	If orderStatusResult.IsInitialized Then	
		localRetObject = ConvertFromMap(orderStatusResult)
	End If
	Return localRetObject
End Sub

' Returns an XML string containing the data contained in this class.
' (Taken from https://www.b4x.com/android/forum/threads/anyone-using-xmlbuilder-with-b4a.16277/ )
Public Sub XmlSerialize() As String
	Dim x As XMLBuilder
	
	x = x.create("clsEposOrderStatus").attribute("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") _
			.attribute("xmlns:xsd", "http://www.w3.org/2001/XMLSchema")
	x = x.element("amount").text(amount).up
	x = x.element("centreId").text(centreId).up
	x = x.element("customerId").text(customerId).up
	x = x.element("deliverToTable").text(deliverToTable).up
	x = x.element("messageId").text(messageId).up
	x = x.element("orderId").text(orderId).up
	x = x.element("queuePosition").text(queuePosition).up
	x = x.element("sessionId").text(sessionId).up
	x = x.element("status").text(modConvert.ConvertStatusToString(status)).up
	x = x.element("tableNumber").text(tableNumber).up
#if B4A	
	Dim props As Map : props.Initialize ' TODO Not sure using 'Map' is necessary - investigate
	props.Put("{http://xml.apache.org/xslt}indent-amount", "4")
	props.Put("indent", "yes")
	Return x.asString2(props)
#else 'B4I
	' NOTE: The following line ensures the class's closing tag is included - strangely, it's not appended by the serializer
	Dim xmlString As String = x.AsString & CRLF & "</clsEposOrderStatus>"
	Return xmlString
#end if
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Currently none

#End Region  Local Subroutines
