B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=7.8
@EndOfDesignText@
'
' This class handles message records
'
#Region  Documentation
	'
	' Name......: clsEposMessageRec
	' Release...: 5
	' Date......: 13/05/20
	'
	' History
	' Date......: 21/01/18
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
	'
	' Date......: 25/05/18
	' Release...: 2
	' Amendee...: D Morris
	' Details...: Mod: rename from clsMessageRec to clsEposMessageRec	
	'
	'
	' Date......: 13/10/19
    ' Release...: 3
	' Overview..: Changes for X platform operation.
    ' Amendee...: D Morris.
    ' Details...:  Mod: Code taken from iOSEpos.clsEposMessageRec_v1.
	'						 Removed: unnecessary "p-" and "l-" prefixes from all methods.
	'						     Mod: XmlSerialize() to remove the iOS-unsupported XML properties and close the XML document.
	'
	' Date......: 01/12/19
	' Release...: 4
    ' Overview..: Supports centreId.
    ' Amendee...: D Morris
    ' Details...: Added: centreId and customerId  - definitions, XmlDeserialize() and XmlSerialize().
	'
	' Date......: 13/05/20
	' Release...: 5
	' Overview..: Bugfix: #0404 - no response to Message or Update Epos commands.
	' Amendee...: D Morris.
	' Details...: Added:  messageId and messageStatus.
	'			    Mod: XmlDeserialize() and XmlSerialize() supports messageId and messageStatus.
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
	
	''' <summary>The centre identifier</summary>
	Public centreId As Int

	''' <summary>The customer identifier.</summary>
	Public customerId As Int
	
	''' <summary>The message heading top line.</summary>
	Public headingTop As String

	''' <summary>The message heading bottom line.</summary>
	Public headingBottom As String

	''' <summary>The message contents.</summary>
	Public message As String
	
	''' <summary>The Message identifier.</summary>
	Public messageId As Int

	''' <summary>The message status.</summary>
	Public messageStatus As Int' enuMessageStatus
	
End Sub
#end region


#Region  Public Subroutines
'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize

End Sub

' Returns an instance of this object containing the data contained in the specified XML string.
Public Sub XmlDeserialize(xmlString As String) As clsEposMessageRec
	Dim parsedData As Map
	Dim localRetObject As clsEposMessageRec ' Local working copy of object
	localRetObject.Initialize
	Dim xm As Xml2Map
	xm.Initialize
	parsedData = xm.Parse(xmlString)
	
	Dim msgObjResult As Map = parsedData.Get("clsEposMessageRec")
	localRetObject.centreId = msgObjResult.GetDefault("centreId", 0)
	localRetObject.customerId = msgObjResult.GetDefault("customerId", 0)
	localRetObject.headingTop =  msgObjResult.GetDefault("headingTop", "")
	localRetObject.headingBottom = msgObjResult.GetDefault("headingBottom", "")
	localRetObject.message = msgObjResult.GetDefault("message", "")
	localRetObject.messageId = msgObjResult.GetDefault("messageId", 0)
	localRetObject.messageStatus = modConvert.ConvertMessageStatusToInt(msgObjResult.GetDefault("messageStatus", "unknown"))  
	Return localRetObject
End Sub

' Returns an XML string containing the data contained in the order status information.
' (Taken from https://www.b4x.com/android/forum/threads/anyone-using-xmlbuilder-with-b4a.16277/ )
Public Sub XmlSerialize(messageInfo As clsEposMessageRec) As String
	Dim x As XMLBuilder
	x = x.create("clsEposMessageRec") _
		.attribute("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") _
		.attribute("xmlns:xsd", "http://www.w3.org/2001/XMLSchema")
	x = x.element("centreId").text(messageInfo.centreId).up()
	x = x.element("customerId").text(messageInfo.customerId).up()
	x = x.element("headingTop").text(messageInfo.headingTop).up()
	x = x.element("headingBottom").text(messageInfo.headingBottom).up()
	x = x.element("message").text(messageInfo.message).up()
	x = x.element("messageId").text(messageInfo.messageId).up()
	x = x.element("messageStatus").text(modConvert.ConvertMessageStatusIntToString(messageInfo.messageStatus)).up()
#if B4A
	Dim props As Map	' TODO Not sure using 'Map' is necessary - needs investigation
	props.Initialize
	props.Put("{http://xml.apache.org/xslt}indent-amount", "4")
	props.Put("indent", "yes")
	Return x.asString2(props)
#else ' B4I
	' NOTE: The following line ensures the class's closing tag is included - strangely, it's not appended by the serializer
	Dim xmlString As String = x.AsString & CRLF & "</clsEposMessageRec>"
	Return xmlString
#end if
End Sub

#end region

#Region Local Subroutines

#End Region
