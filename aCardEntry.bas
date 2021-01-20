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
	' Release...: 8-
	' Date......: 10/01/21   
	'
	' History
	' Date......: 13/10/19
	' Release...: 1
	' Created by: D Morris
	' Details...:  Work on X-platform (based on CardEntry_v2).
	'
	' Date......: 05/05/20
	' Release...: 2
	' Overview..: Bugfix: #0392 No progress dialog when new card information entered.
	' Amendee...: D Morris.
	' Details...:  Added: ReportPaymentStatus().
	'
	' Date......: 09/05/20
	' Release...: 3
	' Overview..: Bugfix: 0401 - No progress dialog order between order ackn message and displaying payment options. 
	'			     Mod: CallSub replaced with CallSubDelayed.
	' Amendee...: D Morris.
	' Details...:  Mod: CardEntryAndPayment now resummable.
	'
	' Date......: 11/05/20
	' Release...: 4
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Mods: Activity_Pause().
		'
	' Date......: 16/05/20
	' Release...: 5
	' Overview..: Issue #0390 - no back arrow in title bar for Settings and Enter card activitues.
	' Amendee...: D Morris
	' Details...: Mod: Another attempt at using back but (found using  	Activity.Finish works).
		'
	' Date......: 26/05/20
	' Release...: 6
	' Overview..: Mod: Card Entry form improved.
	' Amendee...: D Morris.
	' Details...:  Mods: Title added to screen.
	'
	' Date......: 31/05/20
	' Release...: 7
	' Overview..: Bugfix: #0421 - Placing new orders when previous orders cancelled.
	' Amendee...: D Morris
	' Details...:  Added: Public CardEntryAndOrderPayment(). 
	'			 Removed: CardEntryAndCharge() removed.
	'
	' Date......: 08/08/20
	' Release...: 8
	' Overview..: Support for new UI.
	' Amendee...: D Morris
	' Details...:  Mod: Activity_ActionBarHomeClick()
	'
	' Date......: 
	' Release...: 
	' Overview..: General maintenance.
	' Amendee...: D Morris
	' Details...:  Mod: CardEntryAndCharge() removed.
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
'	StartActivity(aTaskSelect)
	StartActivity(aHome)
#else ' B4I
'	xTaskSelect.Show
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
'
'' Entry point to request card information and invoke a charge on the card.
'public Sub CardEntryAndCharge(charge As Float)
'	hc.CardEntryAndCharge(charge)
'End Sub

' Make a card payment against an order.
' The ensure the payment is only made against a specified order.
Public Sub CardEntryAndOrderPayment(paymentInfo As clsOrderPaymentRec, defaultCard As Boolean)
	Wait For (hc.CardEntryAndOrderPayment(paymentInfo, defaultCard)) complete(a As Boolean)
End Sub

''  Make a card payment for a specified amount.
'' Can be used to settle Bill or multiple orders.
'Public Sub CardEntryAndPayment(amount As Float, defaultCard As Boolean)
'	wait for (hc.CardEntryAndPayment(amount, defaultCard)) complete(a As Boolean)
'End Sub

' Reports the result of a card transaction.
Public Sub ReportPaymentStatus(paymentInfo As clsEposCustomerPayment)
	hc.ReportPaymentStatus(paymentInfo)
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines


#End Region  Local Subroutines





