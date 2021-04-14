B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=9.8
@EndOfDesignText@
'
' class for holding basic order payment information.
'
#Region  Documentation
	'
	' Name......: clsOrderPaymentRec
	' Release...: 2-
	' Date......: 06/03/21
	'
	' History
	' Date......: 31/05/20
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking.
	'
	' Date......: 24/01/21
	' Release...: 2
	' Overview..: Maintenance modifications.
	' Amendee...: D Morris
	' Details...: Mod: Initialize() - has parameters.
	'
	' Date......: 
	' Release...: 
	' Overview..: Support for sessionId (Stripe Checkout)
	' Amendee...: D Morris
	' Details...: Add: sessionId.
	'		      Mod: Initialize() now includes sessionId.
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
	
	' Amount to pay for order.
	Public amount As Float	
	
	' Order ID
	Public orderId As Int
	
	' Session ID 
	Public sessionId As String
	
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(pOrderId As Int, pAmount As Float, pSessionId As String)
	amount = pAmount
	orderId = pOrderId
	sessionId = pSessionId
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines