B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=9.3
@EndOfDesignText@
'
' This is a class to handle stoarge of this customer's information 
'

#Region  Documentation
	'
	' Name......: clsCustomerInfo
	' Release...: 10
	' Date......: 28/01/21
	'
	' History
	' StartDate.: 06/08/19
	' Release...: 1
	' Created by: D Morris (started 06/08/19)
	' Details...: Based on a conbination of clsEposCustomerInfo_v6 and clsEposCustomerDetails_v6.
	'
	' Date......: 03/09/19
	' Release...: 2
	' Overview..: Support for card payments and setup. 
	' Amendee...: D Morris
	' Details...: Added: cardAccountEnabled.
	'			    Mods: Clear(), Save(), CvtFromMap() and CvtToMap().
	'
	' Date......: 12/10/19
	' Release...: 3
	' Overview..: Changes to support B4i operation.
	' Amendee...: D Morris.
	' Details...:  Mod: Delete(). Load() and  Save() - code added to support B4I.
	'
	' Date......: 22/10/19
	' Release...: 4
	' Overview..: Bugfix: flxed for B4I reading/write booleans.
	' Amendee...: D Morris
	' Details...:  Mod: Save() now uses CvtToMap() to handle booleans.
	'				  : CvtFromMap() and CvtToMap() now converts booleans.
	'
	' Date......: 01/12/19
	' Release...: 5
	' Overview..: Bugfix: #0216 - restore default values if centre file corrupted.
	' Amendee...: D Morris
	' Details...: Mod: Load() - try/catch added.
	'
	' Date......: 02/12/19
	' Release...: 6
	' Overview..: Fix in v5 don't appear to work - another attempt
	' Amendee...: D Morris
	' Details...: Mod: Load() and CvtFromMap().
	'
	' Date......: 04/12/19
	' Release...: 7
	' Overview..: Code modified to handle B4I operation. 
	' Amendee...: D Morris
	' Details...: Mod: Load() calls main.ToastMessageShow().
	'
	' Date......: 26/04/20
	' Release...: 8
	' Overview..: Bug #0186: Problem moving accounts support for new customerId (with embedded rev). 
	'			  Bugfix: Always reporting corrupt files after installation.
	' Amendee...: D Morris
	' Details...: Added: customerId, apiCustomerId and rev.
	'			  Added: SaveDefault().
	'			    Mod: Clear(), CvtFromMap(). CvtToMap().
	'			  Bugfix: Load().
	'				Mod: Save() now returns a boolean.
		'
	' Date......: 16/05/20
	' Release...: 9
	' Overview..: Load() now will only returns true if valid customer information available.
	' Amendee...: D Morris
	' Details...: Mod: Load() - code modified.
	'
	' Date......: 28/01/21
	' Release...: 10
	' Overview..: Update feature added. 
	' Amendee...: D Morris
	' Details...: Added: UpdateStoredCustomerInfo().
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
	' X-platform related.
	Private xui As XUI						'Ignore
	
	' Local constants
	Private Const MAPKEY_ADDRESS As String = "address" 			' Map key to be used for the Customer address value.
	Private Const MAPKEY_API_CUSTOMERID As String = "apiCustomerId" ' Map key used for the api Customer ID
	Private Const MAPKEY_CARDACCOUNTENABLED As String = "cardAccountEnabled"	' Map key to b used for the cardAccountEnabled value. 
	Private Const MAPKEY_CUSTOMERIDSTR As String = "customerIdStr" 	' Map key to be used for the Customer ID value.
	Private Const MAPKEY_CUSTOMERID As String = "customerId"	' Map key to be used for the Customer ID
	Private Const MAPKEY_EMAIL As String = "email" 				' Map key to be used for the Customer email value.
	Private Const MAPKEY_NAME As String = "name" 				' Map key to be used for the Customer name value.
	Private Const MAPKEY_NICKNAME As String = "nickName" 		' Map key to be used for the Customer nisk name value.
	Private Const MAPKEY_POSTCODE As String = "postCode" 		' Map key to be used for the Customer Postcode value.
	Private const MAPKEY_PHONENUMBER As String ="phoneNumber" 	' Map key to be used for the Customer Phone Number value.
	Private const MAPKEY_REV As String = "rev"					' Map key to be used for the Customer revision number.
	
	Private Const CUSTOMER_FILENAME As String = "CustomerFile.map" ' Name of the file in which this class is stored.
		
	' Public variables - Customer information
	Public address As String 				' Address
	Public apiCustomerId As Int				' Api Customer Id (as integer)
	Public cardAccountEnabled As Boolean	' Allowed to use cards in this centre (saved as string).
	Public customerIdStr As String 			' apiCustomerId (in string form).
	Public customerId As Int				' Customer ID
	Public email As String 					' Email address.
	Public name As String 					' Customer Name.
	Public nickName As String 				' nickname.	
	Public postCode As String 				' postcode.
	Public phoneNumber As String			' phone number
	Public rev As Int						' customer ID revision number 
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	' Currently nothing
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines


' Returns a string containing all the customer's stored details, separated by colons.
' The information is in the order: name, nicName, postcode, phone number.
Public Sub  BuildUniqueCustomerInfoString() As String
	Dim uniqueCustomerInfo As String
	uniqueCustomerInfo = name & ":" & nickName  & ":" & ":" & postCode & ":" & phoneNumber
	Return uniqueCustomerInfo
End Sub

' Clears customer information
Public Sub Clear
	address = ""
	cardAccountEnabled = False
	customerIdStr = "0"
	customerId = 0
	email = ""
	name =""
	nickName = ""
	postCode = ""
	phoneNumber = ""
	rev = 0
End Sub

' Deletes the file in which the customer info is stored.
public Sub Delete
#if B4A
	If File.Exists(File.DirInternal, CUSTOMER_FILENAME) Then
		File.Delete(File.DirInternal, CUSTOMER_FILENAME)
	End If
#else
	If File.Exists(File.DirLibrary, CUSTOMER_FILENAME) Then
		File.Delete(File.DirLibrary, CUSTOMER_FILENAME)
	End If
#end if
End Sub

' Load the customer information from file.
' If true if valid customer information available otherwise false.
'  False is returned if the customer defaults are loaded or file have been corrupted.
Public Sub Load As Boolean
	Dim loadOk As Boolean = False
#if B4A
	If File.Exists(File.DirInternal, CUSTOMER_FILENAME) Then
		Dim mapCustomerInfo As Map = File.ReadMap(File.DirInternal, CUSTOMER_FILENAME)
#else 'B4i
	If File.Exists(File.DirLibrary, CUSTOMER_FILENAME) Then
		Dim mapCustomerInfo As Map = File.ReadMap(File.DirLibrary, CUSTOMER_FILENAME)		
#end if			
		If CvtFromMap(mapCustomerInfo) = True Then
			If customerId <> 0 And customerIdStr <> "0" And customerIdStr <> "" Then
				loadOk = True
			End If
		Else ' Can't read the map.
			SaveDefault
#if B4A
			ToastMessageShow("Customer account information corrupted  corrupted.", True)
#else ' B4I
			Main.ToastMessageShow("Customer settings file corrupted, default loaded.", True)
#end if		
#if B4A
			CallSubDelayed3(Starter, "LogReport", modEposApp.ERROR_LIST_FILENAME, "Problem with Customer information file:" & CRLF & CUSTOMER_FILENAME & CRLF & LastException)
#else ' B4I
		' 	Starter.LogReport(Starter, "LogReport", modEposApp.ERROR_LIST_FILENAME, "Problem with Customer Information file:" & CRLF & CENTREINFO_FILENAME & CRLF & LastException )
#end if	
		End If
	Else ' File does not exist - create a new one!
		SaveDefault
	End If
	Return loadOk
End Sub

' Saves the customer info to its file.
Public Sub Save As Boolean
	Dim mapCustomerInfo As Map : mapCustomerInfo.Initialize
	mapCustomerInfo = CvtToMap	
#if B4A
	File.WriteMap(File.DirInternal, CUSTOMER_FILENAME, mapCustomerInfo)
#else
	File.WriteMap(File.DirLibrary, CUSTOMER_FILENAME, mapCustomerInfo)
#end if
	Return True 'TODO Needs to check if Save operation worked and return the correct value
End Sub

' Update the customer info and save it to file.
Public Sub Update(pApiCustomerId As Int, customerInfoRec As clsEposWebCustomerRec) As Boolean
'	Starter.myData.customer.apiCustomerId = apiCustomerId
'	Starter.myData.customer.address = customerInfoRec.address
'	Starter.myData.customer.customerId = customerInfoRec.ID
'	Starter.myData.customer.customerIdStr = modEposWeb.ConvertToString(apiCustomerId)
'	Starter.myData.customer.email = customerInfoRec.email
'	Starter.myData.customer.name = customerInfoRec.name
'	Starter.myData.customer.phoneNumber = customerInfoRec.telephone
'	Starter.myData.customer.postCode = customerInfoRec.postCode
'	Starter.myData.customer.rev = customerInfoRec.rev
'	Starter.myData.Save
'	Starter.customerInfoAvailable = True ' necessary to signal valid information available.
	
	apiCustomerId = pApiCustomerId
	address = customerInfoRec.address
	customerId = customerInfoRec.ID
	customerIdStr = modEposWeb.ConvertToString(pApiCustomerId)
	email = customerInfoRec.email
	name = customerInfoRec.name
	phoneNumber = customerInfoRec.telephone
	postCode = customerInfoRec.postCode
	rev = customerInfoRec.rev
	Return Save
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Converts from a map object into this class object (boolean values converted from strings).
' values not available are returned as null or false as applicable.
Private Sub CvtFromMap(mapInput As Map) As Boolean
	Dim convertOk As Boolean = False
	Try
		address = mapInput.GetDefault(MAPKEY_ADDRESS, "")
		apiCustomerId = mapInput.GetDefault(MAPKEY_API_CUSTOMERID, 0)
		cardAccountEnabled = modConvert.ConvertStringToBoolean(mapInput.GetDefault(MAPKEY_CARDACCOUNTENABLED, "false"))
		customerIdStr = mapInput.GetDefault(MAPKEY_CUSTOMERIDSTR, "0")
		customerId = mapInput.GetDefault(MAPKEY_CUSTOMERID, 0)
		email = mapInput.GetDefault(MAPKEY_EMAIL, "")
		name = mapInput.GetDefault(MAPKEY_NAME, "")
		nickName = mapInput.GetDefault(MAPKEY_NICKNAME, "")
		postCode = mapInput.GetDefault(MAPKEY_POSTCODE, "")
		phoneNumber = mapInput.GetDefault(MAPKEY_PHONENUMBER, "")	
		rev = mapInput.GetDefault(MAPKEY_REV, 0)
		If customerId = 0 Then	' Code to fix older versions of map (without customerId and rev)
			If customerIdStr <> "" Then
				apiCustomerId = customerIdStr
			Else
				apiCustomerId = 0
			End If			
			customerId = modEposWeb.ConvertApiIdToCustomerId(customerIdStr)
			rev = modEposWeb.ConvertApiIdtoRev(customerIdStr)
		End If
		convertOk = True	
	Catch
		Log(LastException)
	End Try
	Return convertOk
End Sub

' Converts this class to a map (boolean values are converted to a string)  
'  Boolean fields are converted to strings within the map.
Private Sub CvtToMap As Map
	Dim mapCustomerInfo As Map : mapCustomerInfo.Initialize
	mapCustomerInfo.Put(MAPKEY_ADDRESS, address)
	mapCustomerInfo.Put(MAPKEY_API_CUSTOMERID, apiCustomerId)
	mapCustomerInfo.Put(MAPKEY_CARDACCOUNTENABLED, modConvert.ConvertBooleanToString(cardAccountEnabled))
	mapCustomerInfo.Put(MAPKEY_CUSTOMERIDSTR, customerIdStr)
	mapCustomerInfo.Put(MAPKEY_CUSTOMERID, customerId)
	mapCustomerInfo.Put(MAPKEY_EMAIL, email)
	mapCustomerInfo.Put(MAPKEY_NAME, name)
	mapCustomerInfo.Put(MAPKEY_NICKNAME, nickName)
	mapCustomerInfo.Put(MAPKEY_POSTCODE, postCode)
	mapCustomerInfo.Put(MAPKEY_PHONENUMBER, phoneNumber)
	mapCustomerInfo.Put(MAPKEY_REV, rev)
	Return mapCustomerInfo
End Sub

' Saves default customer information to file
private Sub SaveDefault As Boolean
	Clear
	Return Save
End Sub

#End Region  Local Subroutines
