B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=7.8
@EndOfDesignText@
'
' Class to handle EPOS balance check commands
'
#Region  Documentation
	'
	' Name......: clsEposBalanceCheckRec
	' Release...: 3
	' Date......: 01/12/19
	'
	' History
	' Date......: 31/05/18
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
			'
	' Date......: 13/10/19
    ' Release...: 2
	' Overview..: Changes for X platform operation.
    ' Amendee...: D Morris.
    ' Details...:  Mod:  "p-" and "l-" prefixes from all methods.
	'			   Mod: XmlSerialize() to remove the iOS-unsupported XML properties and close the XML document.
	'
	' Date......: 01/12/19
	' Release...: 3
    ' Overview..: Supports centreId.
    ' Amendee...: D Morris
    ' Details...: Added: centreId - definitions, XmlDeserialize() and XmlSerialize().
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
	Public centreId As Int
	Public customerId As Int
	Public zeroTotals As Boolean
	Public phoneTotal As Float
	Public serverTotal As Float
End Sub
#end region


#Region  Public Subroutines
'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize

End Sub

' Returns an instance of this object containing the data contained in the specified XML string.
'   status = ModConvert.statusUnknown returned if unable to deserialize message
Public Sub XmlDeserialize(xmlString As String) As clsEposBalanceCheckRec
	Dim parsedData As Map
	Dim localRetObject As clsEposBalanceCheckRec ' Local working copy of object
	localRetObject.Initialize
	Dim xm As Xml2Map
	xm.Initialize
	parsedData = xm.Parse(xmlString)
	Dim balanceCheckResult As Map = parsedData.Get("clsEposBalanceCheckRec")
	If balanceCheckResult.IsInitialized Then ' Just in case the wrong class is used in the message.
		localRetObject.centreId = balanceCheckResult.GetDefault("centerId", 0)
		' TODO Should .GetDefault() be used instead of .Get()
		localRetObject.customerId = balanceCheckResult.Get("customerId")
		Dim tempString As String	' not necessary be easier to debug
		tempString = balanceCheckResult.Get("zeroTotals")
		localRetObject.zeroTotals = modConvert.ConvertStringToBoolean(tempString)
		localRetObject.phoneTotal = balanceCheckResult.Get("phoneTotal")
		localRetObject.serverTotal = balanceCheckResult.Get("serverTotal")
	End If
	Return localRetObject
End Sub


' Returns an XML string containing the data contained in the order status information.
' (Taken from https://www.b4x.com/android/forum/threads/anyone-using-xmlbuilder-with-b4a.16277/ )
Public Sub XmlSerialize(balanceCheck As clsEposBalanceCheckRec) As String
	Dim x As XMLBuilder
	x = x.create("clsEposBalanceCheckRec") _
		.attribute("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") _
		.attribute("xmlns:xsd", "http://www.w3.org/2001/XMLSchema")
	x = x.element("centreId").text(balanceCheck.centreId).up()
	x = x.element("customerId").text(balanceCheck.customerId).up()
	x = x.element("zeroTotals").text(modConvert.ConvertBooleanToString(balanceCheck.zeroTotals)).up()
	x = x.element("phoneTotal").text(balanceCheck.phoneTotal).up()
	x = x.element("serverTotal").text(balanceCheck.serverTotal).up()
#if B4A
	Dim props As Map	' TODO Not sure using 'Map' is necessary - needs investigation
	props.Initialize
	props.Put("{http://xml.apache.org/xslt}indent-amount", "4")
	props.Put("indent", "yes")
	Return x.asString2(props)
#else
	' NOTE: The following line ensures the class's closing tag is included - strangely, it's not appended by the serializer
	Dim xmlString As String = x.AsString & CRLF & "</clsEposBalanceCheckRec>"
	Return xmlString
#end if
End Sub
#end region

#Region Local Subroutines

#End Region