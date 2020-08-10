B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=7.3
@EndOfDesignText@
'
' Handles Order status record
'
#Region  Documentation
	'
	' Name......: clsOrderStatusRec
    ' Release...: 5
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
    ' Amendee...: 17/02/18
    ' Details...:  Added: Serializer (pXmlSerializer)
		'
	' Date......: 27/02/18
    ' Release...: 3
	' Overview..: Bugfix
    ' Amendee...: D Morris
    ' Details...: Bugfix: IF asked to Deserialise wrong class - throws not initialized exception. 
	'						Code changed in pXmlDeserialize(). 
		'
	' Date......: 01/01/19
    ' Release...: 4
	' Overview..: Bugfix problem with devliverTo (#0056).
    ' Amendee...: D Morris
    ' Details...: Mod: Code referencing deliverTo removed.
	'
	' Date......: 13/10/19
    ' Release...: 5
	' Overview..: Changes for X platform operation.
    ' Amendee...: D Morris.
    ' Details...:  Mod: Code taken from iOSEpos.clsOrderStatusRec_v1.
	'					 Removed: unnecessary "p-" and "l-" prefixes from all methods.
	'						 Mod: XmlSerialize() to remove the iOS-unsupported XML properties and close the XML document
	'
	'             TODO: This module don't appear necessary, need to check. 
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
	Public status As Int
	Public orderId As Int
End Sub
#End Region

#Region Public Subroutines
'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize

End Sub

' Returns an instance of this object containing the data contained in the specified XML string.
'   status = ModConvert.statusUnknown returned if unable to deserialize message
Public Sub XmlDeserialize(xmlString As String) As clsOrderStatusRec
	Dim parsedData As Map
	Dim localRetObject As clsOrderStatusRec ' Local working copy of object
	localRetObject.Initialize
	Dim xm As Xml2Map
	xm.Initialize
	parsedData = xm.Parse(xmlString)
	Dim orderStatusResult As Map = parsedData.Get("clsOrderStatusRec")
	If orderStatusResult.IsInitialized Then ' Just in case the wrong class is used in the message.
		localRetObject.status =  modConvert.ConvertStringToStatus(orderStatusResult.Get("status"))
		localRetObject.orderId = orderStatusResult.Get("orderId")
	End If
	Return localRetObject
End Sub

' Returns an XML string containing the data contained in the order status information.
' (Taken from https://www.b4x.com/android/forum/threads/anyone-using-xmlbuilder-with-b4a.16277/ )
Public Sub XmlSerialize(statusInfo As clsOrderStatusRec) As String
	Dim x As XMLBuilder
	x = x.create("clsOrderStatusRec") _
		.attribute("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") _
		.attribute("xmlns:xsd", "http://www.w3.org/2001/XMLSchema")
	x = x.element("status").text( modConvert.ConvertStatusToString(statusInfo.status)).up()
	x = x.element("orderId").text(statusInfo.orderId).up()

#if B4A
	Dim props As Map	' TODO Not sure using 'Map' is necessary - needs investigation
	props.Initialize
	props.Put("{http://xml.apache.org/xslt}indent-amount", "4")
	props.Put("indent", "yes")
	Return x.asString2(props)
#else ' B4I
	' NOTE: The following line ensures the class's closing tag is included - strangely, it's not appended by the serializer
	Dim xmlString As String = x.AsString & CRLF & "</clsOrderStatusRec>"
	Return xmlString
#end if
End Sub

#End Region




#Region Local Subroutines

#End Region
