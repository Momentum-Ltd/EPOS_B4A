B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=9.8
@EndOfDesignText@
'
' class for storing Epos Location Record
'
#Region  Documentation
	'
	' Name......: clsEposLocationRec
	' Release...: 1
	' Date......: 13/05/20
	'
	' History
	' Date......: 13/05/20
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
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
	''' <summary>The device identifier.</summary>
	Public ID As Int

	''' <summary>The location coordinates.</summary>
	Public location As clsEposWebLocationCoordinates
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize


End Sub

' Returns an XML string containing the location data contained in this class.
' (Taken from https://www.b4x.com/android/forum/threads/anyone-using-xmlbuilder-with-b4a.16277/ )
Public Sub XmlSerialize As String
	Dim x As XMLBuilder
	
	x = x.create("clsEposLocationRec").attribute("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") _
			.attribute("xmlns:xsd", "http://www.w3.org/2001/XMLSchema")
	x = x.element("ID").text(ID).up
	
	x = x.element("location")
'	x = x.element("clsEposWebLocationCoordinates").element("latitude").text(location.latitude).up _
'				.element("longitude").text(location.longitude).up.up
	x = x.element("latitude").text(location.latitude).up _
				.element("longitude").text(location.longitude).up.up
#if B4A	
	Dim props As Map : props.Initialize ' TODO Not sure using 'Map' is necessary - investigate
	props.Put("{http://xml.apache.org/xslt}indent-amount", "4")
	props.Put("indent", "yes")
	Return x.asString2(props)
	#else ' B4I
	' NOTE: The following line ensures the list and class's closing tags are included - strangely, they're not appended by the serializer
	Dim xmlString As String = x.AsString & CRLF & "</clsEposLocationRec>"
	Return xmlString
#end if
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines