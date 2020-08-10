B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=7.3
@EndOfDesignText@
'
' Class to order table record
'

#Region  Documentation
	'
	' Name......: clsOrderTableRec
    ' Release...: 4
    ' Date......: 01/12/19   
    '
    ' History
	' Date......: 23/12/17
    ' Release...: 1
    ' Created by: D Morris
    ' Details...: First release to support version tracking.
	'
	' Date......: 01/01/19
    ' Release...: 2
	' Overview..: Bugfix problem with deliverTo (#0056).
    ' Amendee...: D Morris
    ' Details...: Mod: Code references to deliverTo removed.
		'
	' Date......: 13/10/19
    ' Release...: 3
	' Overview..: Changes for X platform operation.
    ' Amendee...: D Morris
    ' Details...: Code taken from iOSEpos.clsOrderTableRec_v1.
	'					Removed: unnecessary "p-" and "l-" prefixes from all methods.
	'					    Mod: XmlSerialize() modified to support B4I oepration.
	'
	' Date......: 01/12/19
    ' Release...: 4
    ' Overview..: Supports centreId.
    ' Amendee...: D Morris
    ' Details...: Added: centreId. - definitions, XmlDeserialize() and XmlSerialize()
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
	Public centreId As Int			' Centre identifier.
	Public customerId As Int		' Customer identifier.
	Public orderId As Int			' Order indentitier.
End Sub
#End Region

#Region Public Subroutines

' Deep copy of this class.	
public Sub DeepCopy(dstOrderTableRec As clsOrderTableRec, srcOrderTableRec As clsOrderTableRec)
	dstOrderTableRec.customerId = srcOrderTableRec.customerId
	dstOrderTableRec.orderId = srcOrderTableRec.orderId
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize

End Sub

' Returns an instance of this object containing the data contained in the specified XML string.
Public Sub XmlDeserialize(xmlString As String) As clsOrderTableRec
	Dim parsedData As Map
	Dim localRetObject As clsOrderTableRec ' Local working copy of object
	localRetObject.Initialize
	Dim xm As Xml2Map
	xm.Initialize
	parsedData = xm.Parse(xmlString)
	Dim customerDetailsResult As Map = parsedData.Get("clsOrderTableRec")
	localRetObject.orderId = customerDetailsResult.Get("orderId")
	localRetObject.centreId = customerDetailsResult.Get("centreId")
	localRetObject.customerId = customerDetailsResult.Get("customerId")
	Return localRetObject
End Sub

' Returns an XML string containing the data contained in the order information.
' (Taken from https://www.b4x.com/android/forum/threads/anyone-using-xmlbuilder-with-b4a.16277/ )
Public Sub XmlSerialize(orderInfo As clsOrderTableRec) As String
	Dim x As XMLBuilder
	x = x.create("clsOrderTableRec") _
		.attribute("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") _
		.attribute("xmlns:xsd", "http://www.w3.org/2001/XMLSchema")
	x = x.element("customerId").text(orderInfo.customerId).up()
	x = x.element("centreId").text(orderInfo.centreId).up()
	x = x.element("orderId").text(orderInfo.orderId).up()

#if B4A
	Dim props As Map	' TODO Not sure using 'Map' is necessary - needs investigation
	props.Initialize
	props.Put("{http://xml.apache.org/xslt}indent-amount", "4")
	props.Put("indent", "yes")
	Return x.asString2(props)
#else ' B4I
	' NOTE: The following line ensures the class's closing tag is included - strangely, it's not appended by the serializer
	Dim xmlString As String = x.AsString & CRLF & "</clsOrderTableRec>"
	Return xmlString
#end if
End Sub
#End Region


#Region Local Subroutines

#End Region
