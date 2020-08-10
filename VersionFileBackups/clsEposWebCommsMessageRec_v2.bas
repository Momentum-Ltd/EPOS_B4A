B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=9.01
@EndOfDesignText@
'
' Class to handle Epos Web Communications messages.
'
#Region  Documentation
	'
	' Name......: clsEposWebCommsMessageRec
	' Release...: 2
	' Date......: 13/10/19
	'
	' History
	' Date......: 04/06/19
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
	'
	' Date......: 13/10/19
    ' Release...: 2
	' Overview..: Changes for X platform operation.
    ' Amendee...: D Morris.
    ' Details...:  Mod: Code taken from iOSEpos.clsEposWebCommsMessageRec_v1.
	'						 Removed: unnecessary "p-" and "l-" prefixes from all methods.
	'						     Mod: XmlSerialize() to remove the iOS-unsupported XML properties and close the XML document.
	'						-Removed: xmltojson() method as it's not used anywhere and (according to D Hathway) there's no way 
	'																								to easily convert it to B4i
	'
	' Date......: 
	' Release...: 
	' Overview..:
	' Amendee...: 
	' Details...: 
	'
#End Region  Documentation

#Region Data
Sub Class_Globals
	''' <summary>The centre identifier.</summary>
	Public centreId As Int
	
	''' <summary>The customer identifier.</summary>
	Public customerId As Int
	
	''' <summary>The message string.</summary>
	Public message As String
End Sub

#End Region  Data


#Region  Public Subroutines

' Returns the contents of this class as a JSON-formatted string.
Public Sub pGetJson As String
	Dim mapObj As Map = CreateMap("centreId":centreId, "customerId": customerId, "message":message)
	Dim json As JSONGenerator
	json.Initialize(mapObj)
	Return json.ToString
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize

End Sub


' Returns an XML string containing the data contained in the passed clsEposWebCommsMessageRec.
' (Taken from https://www.b4x.com/android/forum/threads/anyone-using-xmlbuilder-with-b4a.16277/ )
Public Sub pXmlSerialize(commsMessageRec As clsEposWebCommsMessageRec) As String
	Dim x As XMLBuilder
	x = x.create("clsEposWebCommsMessageRec") _
		.attribute("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") _
		.attribute("xmlns:xsd", "http://www.w3.org/2001/XMLSchema")
	x = x.element("centreId").text(commsMessageRec.centreId).up()
	x = x.element("customerId").text(commsMessageRec.customerId).up()
	x = x.element("message").text(commsMessageRec.message).up()
#if B4A 
	Dim props As Map	' TODO Not sure using 'Map' is necessary - needs investigation
	props.Initialize
	props.Put("{http://xml.apache.org/xslt}indent-amount", "4")
	props.Put("indent", "yes")
	Return x.asString2(props)
#else ' B4I
	' NOTE: The following line ensures the class's closing tag is included - strangely, it's not appended by the serializer
	Dim xmlString As String = x.AsString & CRLF & "</clsEposWebCommsMessageRec>"
	Return xmlString
#end if
End Sub
#End Region  Public Subroutines

#Region  Local Subroutines

'' Convert XML to JSON format.
'' Code taken from https://www.b4x.com/android/forum/threads/json-to-xml-and-xml-to-json.41830/
'Sub xmltojson(xml As String) As String
'	'nothing to do in this sub it just works
'	Dim jo As JavaObject
'	Dim JSON As JSONParser
'	Dim jg1 As JSONGenerator
'
'	jo.InitializeNewInstance("org.json.XML", Null)
'	Dim jml As String = jo.RunMethod("toJSONObject", Array(xml))
'
'	Dim Map1 As Map
'	JSON.Initialize(jml)
'	Map1 = JSON.NextObject
'
'	jg1.Initialize(Map1)
'	Return jg1.ToPrettyString(4)
'End Sub

#End Region  Local Subroutines