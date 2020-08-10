B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=9.01
@EndOfDesignText@
'
' This class is used to store the customer info and transmit it to the Web API.
' Its contents are copied directly from the CustomerDetailsTest project (class of the same name).
'

#Region  Documentation
	'
	' Name......: clsEposWebCustomerRec
	' Release...: 3
	' Date......: 26/04/20
	'
	' History
	' Date......: 11/06/19
	' Release...: 1
	' Created by: D Hathway
	' Details...: First release to support version tracking
	'
	' Date......: 01/07/19
	' Release...: 2
	' Overview..: Json deserializer support and signedOnCentreId element added.
	' Amendee...: D Morris
	' Details...: Added: pJsonDeserialize()
	'			  Added: signedOnCentreId element
	'				Mod: GetJson() supports signedOnCentreId.
	'
	' Date......: 26/04/20
	' Release...: 3
	' Overview..: Bug #0186: Problem moving accounts support for new customerId (with embedded rev).
	' Amendee...: D Morris
	' Details...: Added: Added rev
	'			    Mod: pJsonDeserialize() and GetJson() - support new rev element.
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
	
	''' <summary>The customer's address.</summary>
	Public address As String

	''' <summary>The customer's alternative telephone number.</summary>
	Public altTelephone As String

	''' <summary>The date the customer's account was authenticated.</summary>
	Public authDate As String

	''' <summary>Flag to indicate if customer's account is authorised</summary>
	Public authorised As Boolean

	''' <summary>Set to true when customer's account is deleted</summary>
	Public deleted As Boolean
	
	''' <summary>The device type</summary>
	Public deviceType As Int
	
	''' <summary>The customer's email address.</summary>
	Public email As String

	''' <summary>The FCM token</summary>
	Public fcmToken As String

	''' <summary>The hash access code.</summary>
	Public hash As String

	''' <summary>The Customer's identifier.</summary>
	''' <remarks>When inserting new data into the database , this is a "don't care" value (as it will automatically
	''' generate a new ID value). However, when reading, this element contains a valid value.</remarks>
	Public ID As Int

	''' <summary>The customer's name.</summary>
	Public name As String

	''' <summary>The customer's post code.</summary>
	Public postCode As String
	
	'''<summary>The revision number.</summary?
	Public rev As Int
	
	''' <summary>Signed on to centreId.</summary>
	Public signedOnCentreId As String

	''' <summary>The customer's telephone number.</summary>
	Public telephone As String
	
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

' Returns the contents of this class as a JSON-formatted string.
Public Sub GetJson As String
	Dim mapObj As Map = CreateMap("address":address, "altTelephone":altTelephone, "authDate":authDate, "authorised":authorised, _
									"deleted":deleted, "deviceType":deviceType, "email":email, "fcmToken":fcmToken, "hash":hash, _
									"ID":ID, "name":name, "postCode":postCode, "rev":rev, "signedOnCentreId":signedOnCentreId, "telephone":telephone)
	Dim json As JSONGenerator
	json.Initialize(mapObj)
	Return json.ToString
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	' Currently nothing
End Sub

' Deserialize a Json string.
public Sub pJsonDeserialize(jsonCustomerInfoRec As String)
	Dim json As JSONParser
	Dim map1 As Map
	json.Initialize(jsonCustomerInfoRec)
	map1 = json.NextObject
	address = map1.Get("address")
	altTelephone = map1.Get("altTelephone")
	authDate = map1.Get("authDate")
	authorised = map1.Get("authorised")
	deleted = map1.Get("deleted")
	deviceType = map1.Get("deviceType")
	email = map1.Get("email")
	fcmToken = map1.Get("fcmToken")
	hash = map1.Get("hash")
	ID = map1.Get("ID")
	name = map1.Get("name")
	postCode = map1.Get("postCode")
	rev = map1.Get("rev")
	signedOnCentreId = map1.Get("signedOnCentreId")
	telephone = map1.Get("telephone")
End Sub
#End Region  Public Subroutines

#Region  Local Subroutines

' Currently none

#End Region  Local Subroutines
