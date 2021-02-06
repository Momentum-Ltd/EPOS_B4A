B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=9.3
@EndOfDesignText@
'
' Credit Card Entry
'
#Region  Documentation
	'
	' Name......: aCardEntry
	' Release...: 10
	' Date......: 06/02/21   
	'
	' History
	' Date......: 13/10/19
	' Release...: 1
	' Created by: D Morris
	' Details...:  Work on X-platform (based on CardEntry_v2).
	'
	'  Versions:
	'		2 - 8 see v9
	'
	' Date......: 21/01/21
	' Release...: 9
	' Overview..: General maintenance.
	' Amendee...: D Morris
	' Details...:  Mod: CardEntryAndCharge() and ReportPaymentStatus() removed.
	'			   Mod: CardEntryAndOrderPayment() - defaultCard parameter removed.
	'
	' Date......: 06/02/21
	' Release...: 10
	' Overview..: General maintenance.
	' Amendee...: D Morris
	' Details...: Mod: Old commented code removed.
	'
	' Date......: 
	' Release...: 
	' Overview..: 
	' Amendee...: 
	' Details...: 
	'
#End Region  Documentation

#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: true
#End Region

#Region  Mandatory Subroutines & Data

Sub Process_Globals

End Sub

Sub Globals
	Private bar As StdActionBar		' New title bar 
	Private hc As hCardEntry 		' This activity's helper class.
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

'Back button pressed (in titlebar).
private Sub Activity_ActionBarHomeClick
#if B4A
	StartActivity(aHome)
#else ' B4I
	xHome.Show
#End If
End Sub

Private Sub Activity_Create(FirstTime As Boolean)
	modEposApp.InitializeStdActionBar(bar, "bar")
	hc.Initialize(Activity)
End Sub

Private Sub Activity_Pause (UserClosed As Boolean)
	hc.OnClose
End Sub

Private Sub Activity_Resume
	Activity.Title = "Enter card details" 'TODO could this be moved to the helper?
	hc.ResumeOp
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' Make a card payment against an order.
' The ensure the payment is only made against a specified order.
Public Sub CardEntryAndOrderPayment(paymentInfo As clsOrderPaymentRec)
	Wait For (hc.CardEntryAndOrderPayment(paymentInfo)) complete(a As Boolean)
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines


#End Region  Local Subroutines





