B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=8.3
@EndOfDesignText@
'
' This is a class to handle EPOS customer information 
'

#Region  Documentation
	'
	' Name......: clsEposCustomerInfo
	' Release...: 9
	' Date......: 13/05/20
	'
	' History
	' StartDate.: 14/07/18
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
	'
	' Version 2 - 8 see v8.
	'
	' Date......: 13/05/20
	' Release...: 9
	' Overview..: Bugfix: #0404 - no response to Message or Update Epos commands.
	'			   Added: #0232 - Support EPOS_GET_LOCATION. 
	' Amendee...: D Morris.
	' Details...: Added:  XmlSerialize().
	'		      
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
	
	' Local constants
	Private Const MAPKEY_ADDRESS As String = "address" 			' Map key to be used for the Customer address value.
	Private Const MAPKEY_CUSTOMERID As String = "customerIdStr" ' Map key to be used for the Customer ID value.
	Private Const MAPKEY_EMAIL As String = "email" 				' Map key to be used for the Customer email value.
	Private Const MAPKEY_NAME As String = "name"		 		' Map key to be used for the Customer Forename value.
	Private Const MAPKEY_NICKNAME As String = "nickName" 		' Map key to be used for the Customer Surname value.
	Private Const MAPKEY_HOUSENUMBER As String = "houseNumber" 	' Map key to be used for the Customer House Number value.
	Private Const MAPKEY_POSTCODE As String = "postCode" 		' Map key to be used for the Customer Postcode value.
	Private const MAPKEY_PHONENUMBER As String ="phoneNumber" 	' Map key to be used for the Customer Phone Number value.
	Private Const CUSTOMERINFO_FILENAME As String = "CustomerInfoFile.map" ' Name of the file in which this class is stored.
	
	' Public variables
	Public address As String 		' The customer's address
	Public customerIdStr As String 	' The customer's unique ID number (in string form).
	Public email As String 			' The customer's emmail address.
	Public name As String 			' The customer's name.
	Public houseNumber As String 	' The customer's house number.
	Public phoneNumber As String 	' The customer's phone number.
	Public postCode As String 		' The customer's postcode.
	Public nickName As String 		' The customer's nick name.
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	' Currently nothing
End Sub

' Clears customer information
Public Sub ClearCustomerInfo
	address = ""
	customerIdStr = ""
	email = ""
	nickName =""
	name = ""
	houseNumber = ""
	postCode = ""
	phoneNumber = ""
End Sub

' Returns a string containing all the customer's stored details, separated by colons.
' The information is in the order: forename, surname, house number, postcode, phone number.
Public Sub  BuildUniqueCustomerInfoString() As String
	Dim uniqueCustomerInfo As String
	uniqueCustomerInfo = nickName & ":" & name  & ":" & houseNumber & ":" & postCode & ":" & phoneNumber
	Return uniqueCustomerInfo
End Sub

' Deletes the file in which the customer info is stored.
public Sub DeleteCustomerInfo 
#if B4A 
	If File.Exists(File.DirInternal, CUSTOMERINFO_FILENAME) Then
		File.Delete(File.DirInternal, CUSTOMERINFO_FILENAME)
	End If
#else
	If File.Exists(File.DirLibrary, CUSTOMERINFO_FILENAME) Then
		File.Delete(File.DirLibrary, CUSTOMERINFO_FILENAME)
	End If	
#End If
	

End Sub

' Attempts to load the customer info from the file in which it is stored, and returns whether the file exists.
Public Sub LoadCustomerInfo As Boolean
	Dim fileExists As Boolean = False
#if B4A
	If File.Exists(File.DirInternal, CUSTOMERINFO_FILENAME) Then
		Dim mapCustomerInfo As Map = File.ReadMap(File.DirInternal, CUSTOMERINFO_FILENAME)
#else
	If File.Exists(File.DirLibrary, CUSTOMERINFO_FILENAME) Then
		Dim mapCustomerInfo As Map = File.ReadMap(File.DirLibrary, CUSTOMERINFO_FILENAME)
#End If
		CvtFromMap(mapCustomerInfo)
		fileExists = True
	End If
	
	Return fileExists
End Sub

' Saves the customer info to its file.
Public Sub SaveCustomerInfo
	Dim mapCustomerInfo As Map : mapCustomerInfo.Initialize
	mapCustomerInfo.Put(MAPKEY_ADDRESS, address)
	mapCustomerInfo.Put(MAPKEY_CUSTOMERID, customerIdStr)
	mapCustomerInfo.Put(MAPKEY_EMAIL, email)
	mapCustomerInfo.Put(MAPKEY_NAME, name)
	mapCustomerInfo.Put(MAPKEY_NICKNAME, nickName)
	mapCustomerInfo.Put(MAPKEY_HOUSENUMBER, houseNumber)
	mapCustomerInfo.Put(MAPKEY_POSTCODE, postCode)
	mapCustomerInfo.Put(MAPKEY_PHONENUMBER, phoneNumber)
#if B4A
	File.WriteMap(File.DirInternal, CUSTOMERINFO_FILENAME, mapCustomerInfo)
#else
	File.WriteMap(File.DirLibrary, CUSTOMERINFO_FILENAME, mapCustomerInfo)
#End If
End Sub

' Updates the fields of this class with the data contained in the specified XML string.
' If the wrong class has been passed as XML, no effect will be made on this class.
Public Sub XmlDeserialise(xmlString As String)
	Dim xm As Xml2Map : xm.Initialize
	Dim parsedData As Map = xm.Parse(xmlString)
	Dim customerDetailsResult As Map = parsedData.Get("clsEposCustomerInfo")
	If customerDetailsResult.IsInitialized Then ' Protection against receiving the wrong class
		CvtFromMap(customerDetailsResult)
	End If
End Sub

' Returns an XML string containing cusotmer information.
' (Taken from https://www.b4x.com/android/forum/threads/anyone-using-xmlbuilder-with-b4a.16277/ )
Public Sub XmlSerialize(customerInfoRec As clsEposCustomerInfo) As String
	Dim x As XMLBuilder
	x = x.create("clsEposCustomerInfo") _
		.attribute("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") _
		.attribute("xmlns:xsd", "http://www.w3.org/2001/XMLSchema")
	x = x.element("address").text(customerInfoRec.address).up()
	x = x.element("customerIdStr").text(customerInfoRec.customerIdStr).up()
	x = x.element("email").text(customerInfoRec.email).up()
	x = x.element("name").text(customerInfoRec.name).up()
	x = x.element("houseNumber").text(customerInfoRec.houseNumber).up()
	x = x.element("phoneNumber").text(customerInfoRec.phoneNumber).up()
	x = x.element("postCode").text(customerInfoRec.postCode).up()
	x = x.element("nickName").text(customerInfoRec.nickName).up()
#if B4A
	Dim props As Map	' TODO Not sure using 'Map' is necessary - needs investigation
	props.Initialize
	props.Put("{http://xml.apache.org/xslt}indent-amount", "4")
	props.Put("indent", "yes")
	Return x.asString2(props)
#else ' B4I
	' NOTE: The following line ensures the class's closing tag is included - strangely, it's not appended by the serializer
	Dim xmlString As String = x.AsString & CRLF & "</clsEposCustomerInfo>"
	Return xmlString
#end if
End Sub

' Populates the fields of this class with the corresponding values in the specified map object.
' If a value cannot be got from the map, that field will be assigned the default value (an empty string).
Public Sub CvtFromMap(mapInput As Map)
	address = mapInput.GetDefault(MAPKEY_ADDRESS, "")
	customerIdStr = mapInput.GetDefault(MAPKEY_CUSTOMERID, "")
	email = mapInput.GetDefault(MAPKEY_EMAIL, "")
	name = mapInput.GetDefault(MAPKEY_NAME, "")
	nickName = mapInput.GetDefault(MAPKEY_NICKNAME, "")
	houseNumber = mapInput.GetDefault(MAPKEY_HOUSENUMBER, "")
	postCode = mapInput.GetDefault(MAPKEY_POSTCODE, "")
	phoneNumber = mapInput.GetDefault(MAPKEY_PHONENUMBER, "")
End Sub

' Converts to a map
Public Sub CvtToMap As Map
	Dim mapCustomerInfo As Map : mapCustomerInfo.Initialize
	mapCustomerInfo.Put(MAPKEY_ADDRESS, address)
	mapCustomerInfo.Put(MAPKEY_CUSTOMERID, customerIdStr)
	mapCustomerInfo.Put(MAPKEY_EMAIL, email)
	mapCustomerInfo.Put(MAPKEY_NAME, name)
	mapCustomerInfo.Put(MAPKEY_NICKNAME, nickName)
	mapCustomerInfo.Put(MAPKEY_HOUSENUMBER, houseNumber)
	mapCustomerInfo.Put(MAPKEY_POSTCODE, postCode)
	mapCustomerInfo.Put(MAPKEY_PHONENUMBER, phoneNumber)
	Return mapCustomerInfo
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines
