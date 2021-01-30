B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@

'
' Helper class for handling payments.
'
#Region  Documentation
	'
	' Name......: clsPayment
	' Release...: 3
	' Date......: 30/01/21
	'
	' History
	' Date......: 24/01/21
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
	'
	' Date......: 27/01/21
	' Release...: 2
	' Overview..: Maintenance - removed some warnings.
	' Amendee...: D Morris
	' Details...:  Mod: QueryPaymentAfterFailure(), PayWithSavedCard() now private
	'				Removed: PayWithAnotherCard() and SendOrderPayment().
	'
	' Date......: 30/01/21
	' Release...: 3
	' Overview..: Bugfix: #0588 - Experimemnt stop problem.
	' Amendee...: D Morris
	' Details...: Mod (Bugfix): QueryPaymentMethod() - iOS code "Wait for" inserted.
	'								QueryPaymentAfterFailure() also updated with "Wait for".
	'			  Mod: Old commented code removed.
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
	Private xui As XUI							'ignore
	
	' Progress box object
	Private mProgressDialog As clsProgressDialog 	' Reference to the caller's progress dialog object.
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(progressDialog As clsProgressDialog)	
	mProgressDialog = progressDialog
End Sub

' Query method and invoke payment (Saved card | Another card | Cash).
Public Sub QueryPaymentMethod(orderPayment As clsOrderPaymentRec) As ResumableSub 
	Dim msg As String
	Dim queryResult As Boolean = False
	If Starter.myData.centre.acceptCards Then ' Cards accepted
		msg = "Payment is required before your order can be processed." & CRLF & "How do you want to pay?"
		If Starter.myData.customer.cardAccountEnabled Then ' Included Saved Card as an option?
#if B4A
			xui.Msgbox2Async(msg, "Payment Options", "Saved" & CRLF & " Card", "Cash", "Another" & CRLF & " Card", Null)
#else ' B4i - don't support CRLF in button text.
			xui.Msgbox2Async(msg, "Payment Options", "Saved Card", "Cash", "Another Card", Null)
#end if
		Else ' ELSE no saved card available.
#if B4A
			xui.Msgbox2Async(msg, "Payment Options", "", "Cash", "Another" & CRLF & " Card", Null)
#else ' B4i - don't support CRLF in button text.
			xui.Msgbox2Async(msg, "Payment Options", "", "Cash", "Another Card", Null)
#end if						
		End If
		Wait For MsgBox_Result(Result As Int)
		If Result = xui.DialogResponse_Positive Then ' Saved (Default) Card?
			PayWithSavedCard(orderPayment)
		else if Result = xui.DialogResponse_Cancel Then ' Cash?
			msg = "Please go to the counter to pay."
			xui.Msgbox2Async(msg, "Cash Payment", "OK", "", "", Null)
			Wait For MsgBox_Result(Result2 As Int)
		Else ' Another Card?
#if B4A
			CallSubDelayed2(aCardEntry, "CardEntryAndOrderPayment", orderPayment) ' No need wait for as it is in another activity
#else ' B4i
			Wait for (xCardEntry.CardEntryAndOrderPayment(orderPayment, False)) complete (a As Boolean) ' Wait for needed for iOS operation (see bug #0588)
#end if
		End If
	Else ' Cards not accepted - must go to the counter
		msg = "Payment is required before your order can be processed." & CRLF & "Please go to the counter."
		xui.Msgbox2Async(msg, "Order Status", "OK", "", "", Null)
		Wait For MsgBox_Result(Result3 As Int)
	End If
	queryResult = True
	Return queryResult
End Sub

' Report a payment result
Public Sub ReportPaymentResult(paymentInfo As clsEposCustomerPayment) As ResumableSub
	Dim cardAccepted As Boolean  
	Dim confirmMsg As String = GetPaymentConfirmMsg(paymentInfo.status)	
	mProgressDialog.Hide
	If IsPaymentAccepted(paymentInfo.status) Then
		xui.MsgboxAsync(confirmMsg,"Card transaction report")
		wait for MsgBox_result(tempResult As Int)
		cardAccepted = True
	Else
		wait for (QueryPaymentAfterFailure(paymentInfo)) complete(tempResult As Int) ' Wait for added just in-case, see Bug #0588.
	End If
	Return cardAccepted
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' check if payment is accepted.
private Sub IsPaymentAccepted(paymentInfo_status As Int) As Boolean
	Dim paymentAccepted As Boolean = False
	If paymentInfo_status = modConvert.payStatusSucceeded Then
		paymentAccepted = True
	End If
	Return paymentAccepted
End Sub

' Gets the payment confirm msg corresponding to the clsEposCustomerPayment.status value
Private Sub GetPaymentConfirmMsg(paymentInfo_status As Int) As String
	Dim confirmMsg As String
	Select paymentInfo_status
		Case modConvert.payStatusCreateCardAccProblem
			confirmMsg = "Card not accepted"
		Case modConvert.payStatusSaveCard
			confirmMsg = "Card saved"
		Case modConvert.payStatusSucceeded
			confirmMsg = "Payment accepted"
		Case modConvert.payrequestRetry
			confirmMsg = " Operation failed - please retry"
		Case modConvert.payStatusPending
			confirmMsg = "Payment pending"
		Case modConvert.payStatusFailed
			confirmMsg = "Payment failed"
		Case Else
			confirmMsg = "Failed"
	End Select
	Return confirmMsg
End Sub

' Pay with Save Card.
Private Sub PayWithSavedCard(orderPayment As clsOrderPaymentRec)
	Dim paymentObj As clsEposCustomerPayment : paymentObj.initialize
	paymentObj.billPayment = False
	paymentObj.centreId = Starter.myData.centre.centreId
	paymentObj.customerId = Starter.myData.customer.customerId
	paymentObj.orderId = orderPayment.orderId
	paymentObj.total = orderPayment.amount
	Dim msg As String  = modEposApp.EPOS_PAYMENT & paymentObj.XmlSerialize()
	mProgressDialog.Show("Processing payment, please wait...")
#if B4A
	CallSub2(Starter, "pSendMessage",  msg)
#else ' B4I
	Main.SendMessage(msg)
#End If	
End Sub

' Query and inovke payment method after a fail (Another card | Cash | Cancel)
Private Sub QueryPaymentAfterFailure(paymentInfo As clsEposCustomerPayment) As ResumableSub
	Dim confirmMsg As String = GetPaymentConfirmMsg(paymentInfo.status)
#if B4A
	xui.Msgbox2Async(confirmMsg,"Card declined", "Another" & CRLF & "  Card", "Cancel", "Cash" , Null)
#else ' B4i - CRLF removed!
	xui.Msgbox2Async(confirmMsg,"Card declined", "Another Card", "Cancel", "Cash" , Null)
#end if
	wait for Msgbox_Result(tempResult As Int)
	If tempResult = xui.DialogResponse_Positive Then ' Another card?
		Dim orderPayment As clsOrderPaymentRec: orderPayment.initialize(paymentInfo.orderId, paymentInfo.total)
#if B4A
		CallSubDelayed2(aCardEntry, "CardEntryAndOrderPayment", orderPayment)
#else 'B4I
'		xCardEntry.CardEntryAndOrderPayment(orderPayment, False)
		Wait for (xCardEntry.CardEntryAndOrderPayment(orderPayment, False)) complete (a As Boolean)
#end if	
	else if tempResult = xui.DialogResponse_Negative Then ' Cash?
		Dim msg As String = "Please go to the counter to pay."
		xui.Msgbox2Async(msg, "Payment Instruction", "OK", "", "", Null)
		Wait For MsgBox_Result(Result As Int)
	Else ' Cancel
		Dim msg As String = "Payment is required before your order can be processed."
		xui.Msgbox2Async(msg, "Operation Cancelled", "OK", "", "", Null)
		Wait For MsgBox_Result(Result As Int)
	End If
	Return tempResult
End Sub

#End Region  Local Subroutines