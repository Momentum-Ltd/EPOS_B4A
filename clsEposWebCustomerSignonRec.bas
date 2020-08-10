B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=9.01
@EndOfDesignText@
'
' Class for handling Epos Web Customer Signon information
'

#Region  Documentation
	'
	' Name......: clsEposWebCustomerSignOnRec
	' Release...: -
	' Date......: 24/06/19
	'
	' History
	' Date......: 24/06/19
	' Release...: -
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
	''' <summary>
	''' Set when customer is authorised
	''' </summary>
	Public authorised As Boolean

	''' <summary>
	''' The device type
	''' </summary>
	Public deviceType As Int

	''' <summary>
	''' The email
	''' </summary>
	Public email As String

	''' <summary>
	''' The FCM token
	''' </summary>
	Public fcmToken As String

	''' <summary>
	''' The customer identifier
	''' </summary>
	Public ID As Int

	''' <summary>
	''' The customer's name
	''' </summary>
	Public name As String

	''' <summary>
	''' The customer's postcode
	''' </summary>
	Public postCode As String

End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines
' Returns the contents of this class as a JSON-formatted string.
Public Sub GetJson As String
	Dim mapObj As Map = CreateMap("address":address, "altTelephone":altTelephone, "authDate":authDate, "authorised":authorised, _
									"deleted":deleted, "deviceType":deviceType, "email":email, "fcmToken":fcmToken, "hash":hash, _
									"ID":ID, "name":name, "postCode":postCode, "signedOnCentreId":signedOnCentreId, "telephone":telephone)
	Dim json As JSONGenerator
	json.Initialize(mapObj)
	Return json.ToString
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize

End Sub



#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines