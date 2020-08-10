B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=9.3
@EndOfDesignText@
'
' Class for storing a Stripe Token Object
'
#Region  Documentation
	'
	' Name......: clsStripeTokenRec
	' Release...: 2
	' Date......: 05/09/19
	'
	' History
	' Date......: 03/09/19
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking.
		'
	' Date......: 05/09/19
	' Release...: 2
	' Overview..: Now handles urlencode data.
	' Amendee...: D Morris
	' Details...: Added: 
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
	Public card As clsStripeCardRec	' Card information.
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	card.Initialize
End Sub

#End Region  Public Subroutines

' Return a Json string representing this object.
public Sub GetJson As String
	Dim mapCardObj As Map = card.GetMap
	'Dim mapObj As Map = CreateMap("id":id, "card": card)
	Dim mapObj As Map = CreateMap("card": mapCardObj)
	Dim json As JSONGenerator
	json.Initialize(mapObj)
	Return json.ToPrettyString(2)
End Sub

' Return map representing this object.
public Sub GetMap As Map
	Dim mapCardObj As Map = card.GetMap
	Dim mapObj As Map = CreateMap("card": mapCardObj)
	Return mapObj
End Sub

' Returns x-www-form-urlencoded;charset=utf-8 string.
Public Sub UrlEncoded As String
	
	'Dim ttt As String = "card[number]=4242424242424242&card[exp_month]=12&card[exp_year]=2020&card[cvc]=123"

	Dim urlEncodedString As String = "card[number]=" & card.number.Trim  & "&card[exp_month]=" & card.exp_month & _
				 "&card[exp_year]=" & card.exp_year & "&card[cvc]=" & card.cvc.trim & "&card[name]=" & card.name & _
				 "&card[address_line1]=" & card.address_line1 & "&card[address_zip]=" & card.address_zip
	Return urlEncodedString
End Sub
#Region  Local Subroutines

#End Region  Local Subroutines
