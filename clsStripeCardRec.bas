B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=9.3
@EndOfDesignText@
'
' Class for storaging a Stripe Card Object
'
#Region  Documentation
	'
	' Name......: clsStripeCardRec
	' Release...: 2
	' Date......: 05/09/19
	'
	' History
	' Date......: 03/09/19
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
		'
	' Date......: 05/09/19 
	' Release...: 2
	' Overview..: More customer information supported.
	' Amendee...: D Morris
	' Details...: Added:  name, address_line1 and address_zip.
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
	' Only fields currently used by the system are included.
	Public address_line1 As String		' Address line 1.
	Public address_zip As String		' Post code.	
	Public cvc As String				' CVC code	
	Public exp_month As String			' Expire month.
	Public exp_year As String			' Expire year.
	Public name As String				' Name on card	
	Public number As String 			' Card number.
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize

End Sub

#End Region  Public Subroutines

' Returns json string representing this record.
public Sub GetJson As String
	Dim mapObj As Map = GetMap
	Dim json As JSONGenerator
	json.Initialize(mapObj)
	Return json.ToPrettyString(2)
End Sub

' Returns a map object of this record (TODO support all elments).
Public Sub GetMap As Map
	Dim mapObj As Map = CreateMap("number":number, "exp_month": exp_month, "exp_year":exp_year, "cvc":cvc)
	Return mapObj
End Sub

#Region  Local Subroutines

#End Region  Local Subroutines