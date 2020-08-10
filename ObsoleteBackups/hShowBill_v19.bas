B4A=true
Group=HelperClasses
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
'
' This is a helper classes for Showbill activity.
'
#Region  Documentation
	'
	' Name......: hShowBill
	' Release...: 19
	' Date......: 11/06/20
	'
	' History
	' Date......: 22/10/19
	' Release...: 1
	' Created by: D Morris
	' Details...: based on ShowBill_v19.
	'
	' Versions 2 - 9 see v9.
	'
	' Date......: 21/03/20
	' Release...: 10
	' Overview..: #315 Issue removed B4A compiler warnings. 
	' Amendee...: D Morris
	' Details...:  Mod: btnPay_Click() msg now declared as string.
	'			   Mod: ReportPaymentStatus() code corrected in log report.
	'
	' Date......: 02/04/20
	' Release...: 11
	' Overview..: Issue: #0371 - Notification whilst showing screen.
	' Amendee...: D Morris
	' Details...: Added: notification class.
	'			  Added: ShowMessageNotificationMsgBox() and ShowStatusNotificationMsgBox().
	'			    Mod: InitializeLocals(), 
	'
	' Date......: 26/04/20
	' Release...: 12
	' Overview..: Bug #0186: Problem moving accounts support for new customerId (with embedded rev). 
	' Amendee...: D Morris
	' Details...: Mod: SendPayment() handles customerId correctly.
	'			  Mod: pSendRequestForBill(), SendPayment()
	'
	' Date......: 29/04/20
	' Release...: 13
	' Overview..: Bugfix: #0260, #0261 - card problems if declined or change card. 
	' Amendee...: D Morris
	' Details...:  Mod: Removed old commented out code.
	'			   Mod: ReportPaymentStatus() - If card declined option to enter another card.
	'			   Mod: btnPay_Click() - handles default and another card, also cancel.
		'
	' Date......: 05/05/20
	' Release...: 14
	' Overview..: Bugfix: #0392 No progress dialog when new card information entered.
	' Amendee...: D Morris
	' Details...:   Mod: Remove ReportPaymentStatus() and SendPayment().
	'
	' Date......: 06/05/20
	' Release...: 15
	' Overview..: Now uses the CardEntry to make payment.
	' Amendee...: D Morris
	' Details...:  Mod: btnPay_Click().
	'
	' Date......: 09/05/20
	' Release...: 16
	' Overview..: Bugfix: 0401 - No progress dialog order between order ackn message and displaying payment options. 
	' Amendee...: D Morris.
	' Details...:  Mod: ResumeOpt() modified.
	'
	' Date......: 11/05/20
	' Release...: 17
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Added: OnClose().
	'
	' Date......: 31/05/20
	' Release...: 18
	' Overview..: References to obsolete code removed.
	' Amendee...: D Morris
	' Details...:  Mod: references to clsCardPayment removed changes to InitializeLocals() and Class_Globals.
	'
	' Date......: 11/06/20
	' Release...: 19
	' Overview..: bugfix: #420 Order status update problem.
	' Amendee...: D Morris.
	' Details...:  Mod: ShowMessageNotificationMsgBox() and ShowStatusNotificationMsgBox() now
	'					 updates the status list.
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
	Private xui As XUI							'ignore (to remove warning) -  Required for X platform operation.

	Private notification As clsNotifications	' Handles notifications
#if B4A
	Private lvwOrderSummary As ListView 		'TODO Check is it was ListView
#else ' B4I
	Private lvwOrderSummary As usrListView ' Listview which displays the breakdown of the customer's bill.
#End If
	Private lblTotal As B4XView					' Bill total.
	Private lblName As B4XView					' Title.
	Private btnPay As B4XView					' Pay bill button.

	' Misc objects
	Private progressbox As clsProgressDialog	' Progress box

	' locals
	Private amountDue As Float 					' Total amound due to pay for bill
'	Private cardProcessor As clsCardPayment		' For card payments.
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (Parent As B4XView)
	Parent.LoadLayout("frmShowBill")
	lblName.Text = "Your Bill"
	InitializeLocals
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Handles the pay button.
Sub btnPay_Click
#if B4A
	CallSubDelayed2(aPlaceOrder, "QueryPaymentandReturn", amountDue)
#else
	xPlaceOrder.QueryPaymentandReturn(amountDue)
#End If
'	End If
End Sub

' Progress dialog has timed out
Private Sub progressbox_Timeout()
	Dim tempLocationRec As clsEposWebCentreLocationRec
	tempLocationRec.Initialize
	tempLocationRec.centreName = Starter.myData.centre.name
	tempLocationRec.centreOpen = True
	tempLocationRec.id = Starter.myData.centre.centreId
#if B4A
	CallSubDelayed2(ValidateCentreSelection, "ValidateSelection", tempLocationRec)
#else ' B4I
	frmXValidateCentreSelection.Show(tempLocationRec)
#end if

End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' Close the Show bill form.
Public Sub CloseShowBill
	#if B4A
	StartActivity(aTaskSelect)
#else ' B4I
	xTaskSelect.Show
#End If
End Sub

' Handles the response received from the Server to the request for an itemised bill.
Public Sub pHandleGetBillByItemResponse(customerBillByItemStr As String)
	ProgressHide
#if B4A
	Dim xmlStr As String = customerBillByItemStr.SubString(modEposApp.EPOS_ITEMIZED_BILL.Length) ' TODO - detect if XML string is valid
#else ' B4I
	Dim xmlStr As String = Main.TrimToXmlOnly(customerBillByItemStr) ' TODO - detect if XML string is valid
#End If
	Dim responseObj As clsEposCustomerBillByItem
	responseObj.Initialize
	responseObj = responseObj.XmlDeserialize(xmlStr) ' TODO - need to determine if the deserialisation was successful
	lvwOrderSummary.Clear
	amountDue = responseObj.amountOutstanding
	If responseObj.itemList.Size > 0 Then
		For Each itemEntry As clsCustomerOrderItemRec In responseObj.itemList
			Dim sizeInfo As clsSizePriceTableRec = Starter.DataBase.GetSizePriceRec(itemEntry.priceId)
			Dim itemSubTotal As Float = sizeInfo.unitPrice * itemEntry.qty
			Dim itemLine1 As String = Starter.DataBase.GetGroupAndDescriptionName(sizeInfo.goodsId) & ", " & _
										Starter.DataBase.GetSizeOptName(sizeInfo.size)
			Dim itemLine2 As String = "Each: £" & modEposApp.FormatCurrency(sizeInfo.unitPrice) & " | Qty: " & itemEntry.qty & _
										" | Total: £" & modEposApp.FormatCurrency(itemSubTotal)
#if B4A
			lvwOrderSummary.AddTwoLines(itemLine1, itemLine2)
#else ' B4I
			lvwOrderSummary.AddItem(itemLine1, itemLine2, Null)
#end if
		Next
	Else
#if B4A
		lvwOrderSummary.AddTwoLines("Nothing to pay", "No bills outstanding!")
#else ' B4I
		lvwOrderSummary.AddItem("Nothing to pay", "No bills outstanding!", Null)
#End If
	End If
	lblTotal.Text = "Due: £" & modEposApp.FormatCurrency(amountDue)
	If amountDue > 0 Then	' There is a minimum card payment.
		btnPay.Enabled = True ' or Starter.myData.centre.acceptCards
	Else
		btnPay.Enabled = False
	End If
End Sub

' Will perform any cleanup operation when the form is closed (disappears).
public Sub OnClose
	If progressbox.IsInitialized = True Then	' Ensures the progress timer is stopped.
		progressbox.Hide
	End If
End Sub

' Refresh displayed bill list.
Public Sub RefreshList
	pSendRequestForBill
End Sub

'' Reports the result of a card transaction.
'Public Sub ReportPaymentStatus(paymentInfo As clsEposCustomerPayment)
'	Log("Payment status:" & modConvert.ConvertPaymentStatusIntToString(paymentInfo.status))
'	Dim cardAccepted As Boolean  = False
'	Dim confirmMsg As String
'	ProgressHide
'	Select paymentInfo.status
'		Case modConvert.payStatusCreateCardAccProblem	
'			confirmMsg = "Card not accepted"	
'		Case modConvert.payStatusSaveCard
'			cardAccepted = True
'			confirmMsg = "Card saved"
'		Case modConvert.payStatusSucceeded
'			cardAccepted = True
'			confirmMsg = "Payment accepted"
'		Case modConvert.payrequestRetry
'			confirmMsg = " Operation failed - please retry"
'		Case modConvert.payStatusPending
'			cardAccepted = True
'			confirmMsg = "Payment pending"
'		Case modConvert.payStatusFailed
'			confirmMsg = "Payment failed"
'		Case Else
'			confirmMsg = "Failed"
'	End Select
'	If cardAccepted = True Then
'		xui.MsgboxAsync(confirmMsg,"Card transaction report")
'		wait for MsgBox_result(tempResult As Int)		
'#if B4A
'		StartActivity(aTaskSelect)
'#else ' B4I
'		xTaskSelect.Show
'#End If		
'	Else ' Card rejected give the customer some options
'#if B4A
'		xui.Msgbox2Async(confirmMsg,"Card declined", "Another" & CRLF & "  Card", "Cancel", "Cash" , Null)
'#else ' B4i - CRLF removed!
'		xui.Msgbox2Async(confirmMsg,"Card declined", "Another Card", "Cancel", "Cash" , Null)
'#end if
'		wait for Msgbox_Result(tempResult As Int)
'		If tempResult = xui.DialogResponse_Positive Then ' Another card?
'#if B4A
'			CallSubDelayed2(aCardEntry, "CardEntryAndCharge", paymentInfo.total)
'#else 'B4I
'			xCardEntry.CardEntryAndCharge(paymentInfo.total)
'#end if	
'		else if tempResult = xui.DialogResponse_Negative Then ' Cash?
'			Dim msg As String = "Please go to the counter to pay."
'			xui.Msgbox2Async(msg, "Payment Instruction", "OK", "", "", Null)
'			Wait For MsgBox_Result(Result As Int)
'#if B4A
'			StartActivity(aTaskSelect)
'#else ' B4I
'			xTaskSelect.Show
'#End If	
'		Else ' Cancel
'			Dim msg As String = "Payment is required before your order can be processed."
'			xui.Msgbox2Async(msg, "Operation Cancelled", "OK", "", "", Null)
'			Wait For MsgBox_Result(Result As Int)
'#if B4A
'			StartActivity(aTaskSelect)
'#else ' B4I
'			xTaskSelect.Show
'#End If	
'		End If			
'	End If
'End Sub

' Handles resume operation.
public Sub ResumeOp
	RefreshList
End Sub

'' Send a payment message
'Public Sub SendPayment(amount As Float)
'	Dim payment As clsEposCustomerPayment : payment.initialize
'	payment.centreId = Starter.myData.centre.centreId
'	payment.customerId = Starter.myData.customer.customerId
'	payment.total = amount
'	Dim msg As String  = modEposApp.EPOS_PAYMENT & payment.XmlSerialize()
'#if B4A
'	ProgressShow("Processing payment, please wait...")
'	CallSub2(Starter, "pSendMessage",  msg)
'#else ' B4I
'	ProgressShow("Processing payment, please wait...")
'	Main.SendMessage(msg)
'#End If
'End Sub

' Sends to the Server the message which requests the customer's bill information.
Public Sub pSendRequestForBill
	Dim xmlOrder As String = CallSub(Starter, "BuildEposCustomerDetailsXml")
	lvwOrderSummary.Clear ' Clear down previous displayed information.
#if B4A
	ProgressShow("Getting your bill, please wait...")
#else ' B4I
	ProgressShow("Getting your bill...")
#end if
	Dim msg As String = modEposApp.EPOS_ITEMIZED_BILL & xmlOrder
#if B4A
	CallSub2(Starter, "pSendMessageAndCheckReconnect", msg) ' Requests an itemised bill
#else ' B4I
	Main.SendMessageAndCheckReconnect(msg) ' Requests an itemised bill
#end if
End Sub

' Displays a messagebox containing the most recent Message To Customer text, and makes the notification sound/vibration if specified.
Public Sub ShowMessageNotificationMsgBox(soundAndVibrate As Boolean)
	pSendRequestForBill ' Update bill list just in-case it has changed.
	notification.ShowMessageNotificationMsgBox(soundAndVibrate)
End Sub

' Displays a messagebox containing the most recent Order Status text, and makes the notification sound/vibration if specified.
Public Sub ShowStatusNotificationMsgBox(soundAndVibrate As Boolean)
	pSendRequestForBill ' Update bill list just in-case it has changed.
	notification.ShowStatusNotificationMsgBox(soundAndVibrate)
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Initialize the locals etc.
private Sub InitializeLocals
	progressbox.Initialize(Me, "progressbox", modEposApp.DFT_PROGRESS_TIMEOUT)
'	cardProcessor.Initialize
	lSetupListview
	notification.Initialize
End Sub

' Adjusts the properties of the lvwOrderSummary listview so that it will always display its contents properly.
Private Sub lSetupListview
#if B4A
	Dim strUtils As StringUtils
	Dim tempLabel As Label : tempLabel.Initialize("")
	tempLabel.Width = lvwOrderSummary.Width
	tempLabel.TextSize = lvwOrderSummary.TwoLinesLayout.Label.TextSize
	Dim topTextHeight As Float = strUtils.MeasureMultilineTextHeight(tempLabel, "Test1" & CRLF & "Test2")
	tempLabel.TextSize = lvwOrderSummary.TwoLinesLayout.SecondLabel.TextSize
	Dim bottomTextHeight As Float = strUtils.MeasureMultilineTextHeight(tempLabel, "Test1")
	lvwOrderSummary.TwoLinesLayout.Label.Height = topTextHeight
	lvwOrderSummary.TwoLinesLayout.Label.Gravity = Gravity.CENTER_VERTICAL
	lvwOrderSummary.TwoLinesLayout.SecondLabel.Top = topTextHeight
	lvwOrderSummary.TwoLinesLayout.SecondLabel.Height = bottomTextHeight
	lvwOrderSummary.TwoLinesLayout.SecondLabel.Gravity = Gravity.CENTER_VERTICAL
	lvwOrderSummary.TwoLinesLayout.ItemHeight = topTextHeight + bottomTextHeight
	
	' The following is a workaround which ensures the listview always displays black text
	lvwOrderSummary.SingleLineLayout.Label.TextColor = Colors.Black
	lvwOrderSummary.TwoLinesLayout.Label.TextColor = Colors.Black
	lvwOrderSummary.TwoLinesLayout.SecondLabel.TextColor = Colors.Black

#else ' B4I
	'TODO - Is some code required for B4I?
#end if	
End Sub

' Show the process box
Private Sub ProgressHide
	progressbox.Hide
End Sub

' Hide The process box.
Private Sub ProgressShow(message As String)
	progressbox.Show(message)
End Sub

#End Region  Local Subroutines
