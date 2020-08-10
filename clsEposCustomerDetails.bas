B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=7.3
@EndOfDesignText@
'
' This class is used to store the customer details received from the Server.
'

#Region  Documentation
	'
	' Name......: clsEposCustomerDetails
	' Release...: 12
	' Date......: 26/04/20   
	'
	' History
	' Date......: 23/12/17
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
	' 
	' History 
	'   versions 2 - 9 see clsEposCustomerDetails_v10.
	'		
	' Date......: 22/10/19
	' Release...: 10
	' Overview..: Bugfix: Not deserialising message correctly (i.e. booleans) 
	' Amendee...: D Morris
	' Details...:  Mod: Now uses modConvert methods to convert string to correct value.
	'		
	' Date......: 27/11/19 
	' Release...: 11
	' Overview..: Header size reduced (no code changed).
	' Amendee...: D Morris
	' Details...:  Mod: Header text removed.
	'			
	' Date......: 26/04/20
	' Release...: 12
	' Overview..: Bug #0186: Problem moving accounts support for new customerId (with embedded rev).
	' Amendee...: D Morris.
	' Details...: Added: rev.
	'			    Mod: XmlDeserialize(), XmlSerialize().
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
	''' <summary>The flag indicates if centre accepts cards.</summary>
	Public acceptCards As Boolean
	''' <summary>The customer's address.</summary>
	Public address As String
	''' <summary>Whether the customer is authorized to place orders.</summary>
	Public authorized As Boolean
	''' <summary>The customer has a card account enabled with this centre.</summary>
	Public cardAccountEnabled As Boolean
	''' <summary>The centre's identifier number.</summary>
	Public centreId As Int
	''' <summary>The customer's Unique Customer Number (ID).</summary>
	Public customerId As Long
	''' <summary>The customer's email address.</summary>
	Public email As String
	''' <summary>The customer's name.</summary>
	Public name As String
	''' <summary>The customer's nickname.</summary>
	Public nickName As String
	''' <summary>The Stripe's published key.</summary>
	Public publishedKey As String
	''' <summary>The customer's revision number </summary>
	Public rev As Int
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

'Initializes the object.
Public Sub Initialize
	' Currently nothing
End Sub

' Returns an instance of this object containing the data contained in the specified XML string.
Public Sub XmlDeserialize(xmlString As String) As clsEposCustomerDetails
	Dim localRetObject As clsEposCustomerDetails : localRetObject.Initialize ' Local working copy of object
	Dim xm As Xml2Map : xm.Initialize
	Dim parsedData As Map = xm.Parse(xmlString)
	Dim customerDetailsResult As Map = parsedData.Get("clsEposCustomerDetails")
	If customerDetailsResult.IsInitialized Then ' Protection against receiving the wrong class
		localRetObject.acceptCards = modConvert.ConvertStringToBoolean( customerDetailsResult.GetDefault("acceptCards","false"))
		localRetObject.address = customerDetailsResult.GetDefault("address", "")
		localRetObject.authorized = modConvert.ConvertStringToBoolean(customerDetailsResult.GetDefault("authorized", "false"))
		localRetObject.cardAccountEnabled = modConvert.ConvertStringToBoolean(customerDetailsResult.GetDefault("cardAccountEnabled", "false"))
		localRetObject.centreId = customerDetailsResult.GetDefault("centreId", 0)
		localRetObject.customerId = customerDetailsResult.GetDefault("customerId", 0)
		localRetObject.email = customerDetailsResult.GetDefault("email", "")
		localRetObject.name = customerDetailsResult.GetDefault("name", "")
		localRetObject.nickName = customerDetailsResult.GetDefault("nickName", "")
		localRetObject.publishedKey = customerDetailsResult.GetDefault("publishedKey", "")
		localRetObject.rev = customerDetailsResult.GetDefault("rev", 0)
	End If
	Return localRetObject
End Sub

' Returns an XML string containing the data contained in this class.
Public Sub XmlSerialize() As String
	Dim x As XMLBuilder
	
	x = x.create("clsEposCustomerDetails").attribute("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") _
			.attribute("xmlns:xsd", "http://www.w3.org/2001/XMLSchema")
	x = x.element("acceptCards").text(acceptCards).up
	x = x.element("address").text(address).up		
	x = x.element("authorized").text(authorized).up
	x = x.element("cardAccountEnabled").text(cardAccountEnabled).up
	x = x.element("centreId").text(centreId).up
	x = x.element("customerId").text(customerId).up
	x = x.element("email").text(email).up
	x = x.element("name").text(name).up
	x = x.element("nickName").text(nickName).up
	x = x.element("publishedKey").text(publishedKey).up
	x = x.element("rev").text(rev).up
#if B4A	'TODO need to investigate why different code required for B4A and B4I  
	Dim props As Map : props.Initialize ' TODO Not sure using 'Map' is necessary - investigate
	props.Put("{http://xml.apache.org/xslt}indent-amount", "4")
	props.Put("indent", "yes")
	Return x.asString2(props)
#else ' B4I code taken from original version for B4I
	' DH - NOTE: The following line ensures the class's closing tag is included - strangely, it's not appended by the serializer
	Dim xmlString As String = x.AsString & CRLF & "</clsEposCustomerDetails>"
	Return xmlString
#End If

End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Currently nothing

#End Region  Local Subroutines
