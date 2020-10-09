B4A=true
Group=HelperClasses
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
'
' This is a helper class for CardEntry activity. 
'
#Region  Documentation
	'
	' Name......: hCardEntry
	' Release...: 16
	' Date......: 09/10/20
	'
	' History
	' Date......: 13/10/19
	' Release...: 1
	' Created by: D Morris (started 12/10/19).
	' Details...: First release to support version tracking.
	'
	' Versions 2 - 6 see v7
	'   	   7 - 14 see v15.
	'
	' Date......: 08/08/20
	' Release...: 15
	' Overview..: Support for new UI. 
	' Amendee...: D Morris
	' Details...: Mod: Changes to now exit to Centre Home page.
	'
	' Date......: 09/10/20
	' Release...: 16
	' Overview..: Bugfix: #0515 - Exception thrown if invalid card information entered.
	' Amendee...: D Morris.
	' Details...: Mod: SubmitCard() code fixed.
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
	Private xui As XUI							'ignore (to remove warning).
	
	' Misc objects
	Private progressbox As clsProgressDialog	' Progress box.
	Private cardInfo As clsStripeTokenRec		' Strip relating objects.

	' View declarations
	' Card Entry Panel
	Private btnSubmit As SwiftButton			' Submit card details button.
	Private btnTestData As SwiftButton			' Load test card data.
	Private chkSaveCard As B4XView				' Save card option.
	Private pnlCardEntry As B4XView				' The Card entry panel enclosing these views.
	Private txtCvc As B4XFloatTextField			' Card CVC.
	Private txtLine1 As B4XFloatTextField		' First line of billing address.
	Private txtName As B4XFloatTextField		' Name on card.
	Private txtPostCode As B4XFloatTextField	' Billing address postcode.
	Private txtCardNumber As B4XFloatTextField	' Long card number
	Private txtExpiryDate As B4XFloatTextField 	' Expiry date.

	' Default card entry panel
	Private pnlDefaultCard As B4XView 			' The default card panel.
	
	' Local variables
	Private stripe As clsStripe					' Used communication with the Stripe server.	
	Private total As Float 						' Amount to charge (if register card and take payment at the same time).
	Private mOrderId As Int						' The order to pay (if n.a. then = 0)

End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (parent As B4XView)
	parent.LoadLayout("frmCardEntry")
	InitializeLocals
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Handle the submit button.
Private Sub btnSubmit_Click
	SubmitCard
End Sub

' Load test data.
Private Sub btnTestData_Click
	LoadTestData
End Sub

' Progress dialog has timed out
Sub progressbox_Timeout()
	xui.Msgbox2Async("Payment request failed.", "Timeout Error", "OK", "", "", Null)
	Wait for msgbox_result (Result As Int)
	ExitToCentreHomePage
End Sub

' Handle card  token received from Stripe Server.
Private Sub stripe_CardToken(success As Boolean, cardToken As String)
	ProgressHide
	HandleStripeResponse(success, cardToken)
	If success = True Then
		ClearCard
	End If
End Sub

' Tab to next field
' Code taken from https://www.b4x.com/android/forum/threads/tab-order-of-textedit-views.19489/
Private Sub txtCardNumber_EnterPressed
	' TabToNext(Sender)
End Sub

' Handle Card number changes.
Private Sub txtCardNumber_TextChanged (old As String, new As String)
#if B4i	' See https://www.b4x.com/android/forum/threads/strange-text_changed-behaviour.107128/
	Sleep(0)	' Ensure the new value is ok
#end if
	' So cursor can be positioned correctly.
	' Adapted from https://www.b4x.com/android/forum/threads/b4xfloattextfield-filter-characters-allowed.114681/
#if B4A
	Dim et As EditText = txtCardNumber.TextField
#else ' B4i
	Dim et As TextField = txtCardNumber.TextField
#end if
'	Dim eos As Int = (new.Length + 1)
	If old.Length > new.Length Then
		If new.Length = 4 Or new.Length = 9 Or new.Length = 14 Then ' backspace over space?
			Dim x As String = FormatCardNumber(new)			
			x = x.SubString2(0, new.Length - 1)
			If x <> new Then
				txtCardNumber.Text = x		
				If x.Length > 0 Then
					et.SetSelection(x.Length, 0)
				End If							
			End If	
		End If
	else If new.Length = 4 Or new.Length = 9 Or new.Length = 14 Then ' Insert space?
		txtCardNumber.Text = new & " "
		et.SetSelection(new.Length + 1, 0)
	else if new.Length > 19 Then
		Dim x As String = new
		txtCardNumber.Text = x.SubString2(0, 19)
		et.SetSelection(19, 0)
	End If
End Sub

' Tab To next field
Private Sub txtCvc_EnterPressed
	'TabToNext(Sender)
End Sub

' Handle card CVC code
Private Sub txtCvc_TextChanged(old As String, new As String)
#if B4i	' See https://www.b4x.com/android/forum/threads/strange-text_changed-behaviour.107128/
	Sleep(0)	' Ensure the new value is ok
#end if
	' So cursor can be positioned correctly.
	' Adapted from https://www.b4x.com/android/forum/threads/b4xfloattextfield-filter-characters-allowed.114681/
#if B4A
	Dim et As EditText = txtCvc.TextField
#else ' B4i
	Dim et As TextField = txtCvc.TextField
#end if
	If new.Length > 3 Then
		txtCvc.Text = new.SubString2(0, 3)
		et.SetSelection(3,0)
	End If
End Sub

' Tab to next field
private Sub txtExpiryDate_EnterPressed
	'TabToNext(Sender)
End Sub

' Handle expiry date changes.
private Sub txtExpiryDate_TextChanged (Old As String, New As String)
#if B4i	' See https://www.b4x.com/android/forum/threads/strange-text_changed-behaviour.107128/
	Sleep(0)	' Ensure the new value is ok
#end if
 ' So cursor can be positioned correctly see https://www.b4x.com/android/forum/threads/b4xfloattextfield-filter-characters-allowed.114681/
#if B4A
	Dim et As EditText = txtExpiryDate.TextField
#else ' B4i
	Dim et As TextField = txtExpiryDate.TextField
#end if
	If Old.Length > New.Length Then
		Dim x As String = FormatExpiryDate(New)
		If New.Length = 4 Then ' backspace over "/20"?
			x = x.SubString2(0, New.Length - 3)
			If x <> New Then
				txtExpiryDate.Text = x
				If x.Length > 0 Then
					et.SetSelection(x.Length, 0)
				End If				
			End If
		End If
	else If New.Length = 2 Then ' Insert "/20"?
		Dim x As String = FormatExpiryDate(New)
		txtExpiryDate.Text = New & "/20"	
		et.SetSelection(5, 0)
	else if New.Length > 7 Then
		txtExpiryDate.Text = New.SubString2(0, 7)
		et.SetSelection(7, 0)
	else if New.Length = 1 Then
		If New.CompareTo("1") > 0 Then 'Do we need to reformat?
			txtExpiryDate.Text = FormatExpiryDate(New)
			et.SetSelection(5,0)
		End If
	End If
End Sub

' Tab to next field
private Sub txtLine1_EnterPressed
	'TabToNext(Sender)	
End Sub

' Tab to next field
private Sub txtName_EnterPressed
	'TabToNext(Sender)
End Sub

' Tab to next field
Private Sub txtPostCode_EnterPressed
'	TabToNext(Sender)
End Sub

#End Region  Event Handlers


#Region  Public Subroutines

'' Entry point to request card information and invoke a charge on the card.
'public Sub CardEntryAndCharge(amount As Float)
'	ClearCard
'	total = amount
'End Sub

' Make a card payment against an order.
' orderPayment information about amount and order to pay.
' defaultCard - set if use the default card.
Public Sub CardEntryAndOrderPayment(orderPayment As clsOrderPaymentRec, defaultCard As Boolean)As ResumableSub
	ClearCard
	total = orderPayment.amount	' Save for later.
	mOrderId = orderPayment.orderId
	If defaultCard = True And Starter.myData.customer.cardAccountEnabled = True Then ' Protect if default and not card details.
		pnlDefaultCard.Visible = True
		pnlCardEntry.Visible = False
		SendOrderPayment(orderPayment.orderId, orderPayment.amount)
	Else
		pnlDefaultCard.Visible = False
		pnlCardEntry.Visible = True
		Wait for btnSubmit_Click()	' Wait for card information to be entered.
		SubmitCard
	End If
	Return True
End Sub

' Entry point for request card with payment.
' charge - amount to charge card.
' defaultCard - set if use the default card.
Public Sub CardEntryAndPayment(amount As Float, defaultCard As Boolean) As ResumableSub
	ClearCard
	total = amount
	mOrderId = 0 ' Order is n.a.
	If defaultCard = True And Starter.myData.customer.cardAccountEnabled = True Then ' Protect if default and not card details.
		pnlDefaultCard.Visible = True
		pnlCardEntry.Visible = False
		SendPayment(amount)
	Else 
		pnlDefaultCard.Visible = False
		pnlCardEntry.Visible = True
		Wait for btnSubmit_Click()	' Wait for card information to be entered.
		SubmitCard
	End If
	Return True
End Sub

' Will perform any cleanup operation when the form is closed (disappears).
public Sub OnClose
	If progressbox.IsInitialized = True Then	' Ensures the progress timer is stopped.
		progressbox.Hide
	End If
End Sub

' Handles activity resume operation.
Public Sub ResumeOp
	btnTestData.mBase.Visible = Starter.settings.testMode ' Short cut for setting Test Card button.
	cardInfo.Initialize
End Sub

' Reports the result of a card transaction.
Public Sub ReportPaymentStatus(paymentInfo As clsEposCustomerPayment)
	ClearCard
	Log("Payment status:" & modConvert.ConvertPaymentStatusIntToString(paymentInfo.status))
	Dim cardAccepted As Boolean  = False
	Dim confirmMsg As String
	ProgressHide
	Select paymentInfo.status
		Case modConvert.payStatusCreateCardAccProblem
			confirmMsg = "Card not accepted"
		Case modConvert.payStatusSaveCard
			cardAccepted = True
			confirmMsg = "Card saved"
		Case modConvert.payStatusSucceeded
			cardAccepted = True
			confirmMsg = "Payment accepted"
		Case modConvert.payrequestRetry
			confirmMsg = " Operation failed - please retry"
		Case modConvert.payStatusPending
			cardAccepted = True
			confirmMsg = "Payment pending"
		Case modConvert.payStatusFailed
			confirmMsg = "Payment failed"
		Case Else
			confirmMsg = "Failed"
	End Select
	If cardAccepted = True Then
		xui.MsgboxAsync(confirmMsg,"Card transaction report")
		wait for MsgBox_result(tempResult As Int)
		ExitToCentreHomePage
	Else ' Card rejected give the customer some options
#if B4A
		xui.Msgbox2Async(confirmMsg,"Card declined", "Another" & CRLF & "  Card", "Cancel", "Cash" , Null)
#else ' B4i - CRLF removed!
		xui.Msgbox2Async(confirmMsg,"Card declined", "Another Card", "Cancel", "Cash" , Null)
#end if
		wait for Msgbox_Result(tempResult As Int)
		If tempResult = xui.DialogResponse_Positive Then ' Another card?
#if B4A
			' CallSubDelayed2(aCardEntry, "CardEntryAndCharge", paymentInfo.total)
			CallSubDelayed3(aCardEntry, "CardEntryAndPayment", paymentInfo.total, False) 
#else 'B4I
			' xCardEntry.CardEntryAndCharge(paymentInfo.total)
			xCardEntry.CardEntryAndPayment(paymentInfo.total, false)
#end if	
		else if tempResult = xui.DialogResponse_Negative Then ' Cash?
			Dim msg As String = "Please go to the counter to pay."
			xui.Msgbox2Async(msg, "Payment Instruction", "OK", "", "", Null)
			Wait For MsgBox_Result(Result As Int)
			ExitToCentreHomePage
		Else ' Cancel
			Dim msg As String = "Payment is required before your order can be processed."
			xui.Msgbox2Async(msg, "Operation Cancelled", "OK", "", "", Null)
			Wait For MsgBox_Result(Result As Int)
			ExitToCentreHomePage
		End If
	End If
End Sub


#End Region  Public Subroutines

#Region  Local Subroutines

' Clear card information from screen.
Private Sub ClearCard
	txtCardNumber.Text = ""
	txtCvc.Text = ""
	txtExpiryDate.text = ""
	txtName.Text = ""
	txtLine1.Text = ""
End Sub

' Handles exit to Centre Home page.
Private Sub ExitToCentreHomePage()
#if B4A
	StartActivity(aHome)
#else ' B4I
	xHome.Show
#End If	
End Sub

' Formats a card number string into #### #### #### #### format.
Private Sub FormatCardNumber(cardText As String) As String
	Dim tempCardText As String = cardText.trim.Replace(" ", "")	' First remove any previous spaces.
	Dim processedText As String = ""	
	If tempCardText.Length > 0 Then
		If tempCardText.Length > 16 Then ' Limit maximum size.
			tempCardText = tempCardText.SubString2(0, 15)
		End If
		Dim indexEnd As Int = tempCardText.Length - 1
		For charIndex = 0 To indexEnd ' Loop to insert spaces between blocks of numbers.
			If charIndex = 4 Or charIndex = 8 Or charIndex = 12 Then
				processedText = processedText & " "
			End If
			processedText = processedText & tempCardText.SubString2(charIndex, charIndex + 1)
		Next		
	End If
	Return processedText
End Sub

' Formats a Expiry Data string into MM/YY.
Private Sub FormatExpiryDate(expiryDate As String) As String
	Dim tempDate As String = expiryDate.Trim.Replace( "/20", "")
	Dim processeedText As String = ""
	If tempDate.Length > 0 Then
		If tempDate.Length > 4 Then
			tempDate = tempDate.SubString2(0, 3)
		End If
		If tempDate.Length = 1 Then
			If tempDate.CompareTo("1") > 0 Then 'Month less than 10?
				processeedText = "0" & tempDate & "/20" ' Skip to year.
			Else
				processeedText = tempDate
			End If
		Else
			Dim indexEnd As Int = tempDate.Length - 1
			For charIndex = 0 To indexEnd
				If charIndex = 2 Then 
					processeedText = processeedText & "/20"
				End If
				processeedText = processeedText & tempDate.SubString2(charIndex, charIndex + 1)
			Next
		End If
	End If
	Return processeedText
End Sub

' Handles Stripe response to request a token
private Sub HandleStripeResponse(success As Boolean, cardToken As String)
 	If success Then ' Card ok?
		Starter.myData.customer.cardAccountEnabled = True ' Set flag to indicated card account is open.
		SendCardTokenToServer(cardToken, total)	
	Else
		xui.MsgboxAsync(cardToken, "Card not accepted")
		wait for msgbox_result(tempResult As Int)	
	End If	
End Sub
	
' Initialize the locals etc.
private Sub InitializeLocals
	progressbox.Initialize(Me, "progressbox", modEposApp.DFT_PROGRESS_TIMEOUT)
	cardInfo.Initialize
	stripe.Initialize(Me, "sk_test_4eC39HqLyjWDarjtT1zdp7dc","Stripe")
	btnTestData.mBase.Visible = Starter.settings.testMode ' Short cut for setting Test Card button.
	SetupTabOrder
End Sub

' Load test data.
private Sub LoadTestData
	txtCardNumber.Text = "4242 4242 4242 4242"
	txtCvc.Text = "123"
	txtExpiryDate.Text = "01/2021"
End Sub

' Show the process box
Private Sub ProgressHide
	progressbox.Hide
End Sub

' Hide The process box.
Private Sub ProgressShow(message As String)
	progressbox.Show(message)
End Sub

' Sends the card token to Centre server 
Private Sub SendCardTokenToServer(cardToken As String, pTotal As Float)
	Dim cardTokenObj As clsEposCustomerPayment : cardTokenObj.initialize
	
	cardTokenObj.centreId = Starter.myData.centre.centreId
	cardTokenObj.customerId = Starter.myData.customer.customerId
	If chkSaveCard.Checked Then
		cardTokenObj.status = modConvert.payStatusSaveCard
	Else
		cardTokenObj.status = modConvert.statusUnknown
	End If
	cardTokenObj.token = cardToken
	cardTokenObj.total = pTotal
	cardTokenObj.orderId = mOrderId
	Dim msg As String =  modEposApp.EPOS_PAYMENT & cardTokenObj.XmlSerialize
	ProgressShow("Making Payment")
#if B4A
	CallSub2(Starter, "pSendMessage", msg)
#else ' B4A
	Main.SendMessage(msg)
#end if
End Sub

' Send a payment message for a specified order.
Private Sub SendOrderPayment(orderId As Int, amount As Float)
	Dim payment As clsEposCustomerPayment : payment.initialize
	payment.centreId = Starter.myData.centre.centreId
	payment.customerId = Starter.myData.customer.customerId
	payment.orderId = orderId
	payment.total = amount
	Dim msg As String  = modEposApp.EPOS_PAYMENT & payment.XmlSerialize()
	ProgressShow("Processing payment, please wait...")
	#if B4A
	CallSub2(Starter, "pSendMessage",  msg)
#else ' B4I
	Main.SendMessage(msg)
#End If
End Sub

' Send a payment message
Private Sub SendPayment(amount As Float)
	Dim payment As clsEposCustomerPayment : payment.initialize
	payment.centreId = Starter.myData.centre.centreId
	payment.customerId = Starter.myData.customer.customerId
	payment.total = amount
	Dim msg As String  = modEposApp.EPOS_PAYMENT & payment.XmlSerialize()
	ProgressShow("Processing payment, please wait...")
#if B4A
	CallSub2(Starter, "pSendMessage",  msg)
#else ' B4I
	Main.SendMessage(msg)
#End If
End Sub

' Setup the tab order (adjust as necessary).
' Code taken from https://www.b4x.com/android/forum/threads/tab-order-of-textedit-views.19489/
Private Sub SetupTabOrder
	txtCardNumber.Tag = txtExpiryDate
	txtExpiryDate.Tag = txtCvc
	txtCvc.Tag = txtName
	txtName.Tag = txtLine1
	txtLine1.Tag = txtPostCode
	txtPostCode.Tag = txtCardNumber
End Sub

' Submit card information to Strip.
Private Sub SubmitCard
	Dim tempExpiry As String = FormatExpiryDate(txtExpiryDate.Text)
	cardInfo.card.address_line1 = txtLine1.Text.Trim
	cardInfo.card.address_zip = txtPostCode.Text.trim
	cardInfo.card.cvc = txtCvc.Text.trim
	If tempExpiry.Length >= 4 Then
		cardInfo.card.exp_month = tempExpiry.SubString2(0, 2)
		cardInfo.card.exp_year = tempExpiry.SubString(3)		
	End If
	cardInfo.card.name = txtName.Text.trim
	cardInfo.card.number = FormatCardNumber(txtCardNumber.Text).Replace(" ", "")
	ProgressShow("Checking your card...")
	stripe.GetCardToken(Me, cardInfo)
End Sub

'' Tab to next field (Removed as it cause problems with operation.
' Android need a method to hide keyboard.
' iOS - the focus don't appear to work.
'' Code taken from https://www.b4x.com/android/forum/threads/tab-order-of-textedit-views.19489/
'private Sub TabToNext(pSender As B4XFloatTextField)
'	Dim currentView, nextView As B4XFloatTextField 
'	currentView = pSender
'	nextView = currentView.Tag
'#if B4A
'	nextView.RequestFocusAndShowKeyboard
'#else 
'	nextView.Focused = True
'#End If
'End Sub

#End Region  Local Subroutines