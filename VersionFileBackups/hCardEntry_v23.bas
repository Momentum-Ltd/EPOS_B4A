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
	' Release...: 23
	' Date......: 06/02/21
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
	' Date......: 20/11/20
	' Release...: 17
	' Overview..: Issue: #0437 Enter card details difficult. 
	'			  Issue: #0453 Expiry date format.
	' Amendee...: D Morris
	' Details...: Mod: SetupTabOrder() now will just show a accept button and not tab to next field.
	'			  Added: (for Android) clicking on background hides keyboard. 
	'			  Mod: uses clsMMYYhandler to process date string.
	'
	' Date......: 03/01/21
	' Release...: 18
	' Overview..: Bugfix: iOS unable to accept card.
	'			  Issue: Test data expiry date replaced with later date. 
	' Amendee...: D Morris
	' Details...: Mod: InitializeLocals() - Problem with iOS initialization of clsStripe case changed.
	'			  Mod: LoadTestData() - Expiry date changed.
	'             Mod: clsStripe - now uses latest parameters InitializeLocals() and SubmitCard().			  
	'		
	' Date......: 20/01/21
	' Release...: 19
	' Overview..: Bugfix: #0464 - Save card option now works correctly.
	'			  Bugfix: #0578 - Payment message orderId is now included in the message.
	' Amendee...: D Morris.
	' Details...: Mod: chkSaveCard replaced with swSaveCard.
	'			  Mod: SendCardTokenToServer() znc ReportPaymentStatus().
	'			  Removed: CardEntryAndPayment(), SendPayment().
	'			  Mod: ClearCard() now includes the swSaveCard set to false.
	'		
	' Date......: 24/01/21
	' Release...: 20
	' Overview..: Bugfix: #0562 - Payment with Saved card shows Enter card as background fixed. 
	' Amendee...: D Morris
	' Details...: Mod: General changes to use clsPayment class for card payment.
	'			  Mod: CardEntryAndOrderPayment() defaultCard parameter removed.
	'
	' Date......: 27/01/21
	' Release...: 21
	' Overview..: New uses clsKeyboardHelper for keyboard handling.
	' Amendee...: D Morris
	' Details...: Mod: General changes to support clsKeyboardHelper.
	'			  Removed: kk as IME removed no longer necessary.
	'
	' Date......: 30/01/21
	' Release...: 22
	' Overview..: Maintenance fix.
	'             Issue (iOS)  - Strange submit button operation.
	' Amendee...: D Morris
	' Details...: Mod: Old commented code removed.
	'			  Mod: InitializeLocals() - New call to clsKeyboardHelper.SetupTextAndKeyboard().
	'			  Mod: btnSubmit_Click() - now generates an internal event.
	'
	' Date......: 06/02/21
	' Release...: 23
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

#Region  Mandatory Subroutines & Data

Sub Class_Globals
	' X-platform related.
	Private xui As XUI							'ignore (to remove warning).
	
	' Misc objects
	Private processedDate As clsDatehandler		' Handles processing date.
	Private progressbox As clsProgressDialog	' Progress box.
	Private cardInfo As clsStripeTokenRec		' Strip relating objects.
	Private payment As clsPayment				' Class to handle payments.
	
	' View declarations
	' Card Entry Panel
	Private btnSubmit As SwiftButton			' Submit card details button.
	Private btnTestData As SwiftButton			' Load test card data.
	Private pnlCardEntry As B4XView				' The Card entry panel enclosing these views.
	Private swSaveCard As B4XSwitch				' Save Card 
	Private txtCvc As B4XFloatTextField			' Card CVC.
	Private txtLine1 As B4XFloatTextField		' First line of billing address.
	Private txtName As B4XFloatTextField		' Name on card.
	Private txtPostCode As B4XFloatTextField	' Billing address postcode.
	Private txtCardNumber As B4XFloatTextField	' Long card number
	Private txtExpiryDate As B4XFloatTextField 	' Expiry date.
	
	' Local variables
	Private kbHelper As clsKeyboardHelper		' Keyboard handler
	Private mOrderId As Int						' The order to pay (if n.a. then = 0)	
	Private stripe As clsStripe					' Used for Stripe payments.	
	Private total As Float 						' Amount to charge (if register card and take payment at the same time).

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
	CallSubDelayed(Me, "SubmitButton_Pressed")
End Sub

' Load test data.
Private Sub btnTestData_Click
	LoadTestData
End Sub

' Handle hide keyboard required from keyboard helper class.
Private Sub kbHelper_HideKeyboard
	HideKeyboard
End Sub

' Hide keyboard (click outside the text fields).
Private Sub pnlCardEntry_Click
	HideKeyboard
End Sub

' Progress dialog has timed out
Private Sub progressbox_Timeout()
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

' Handle Card number changes.
Private Sub txtCardNumber_TextChanged (old As String, new As String)
#if B4i	' See https://www.b4x.com/android/forum/threads/strange-text_changed-behaviour.107128/
	Sleep(0)	' Ensure the new value is ok
#end if
	' Adapted from https://www.b4x.com/android/forum/threads/b4xfloattextfield-filter-characters-allowed.114681/
#if B4A
	Dim et As EditText = txtCardNumber.TextField	' So cursor can be positioned correctly.
#else ' B4i
	Dim et As TextField = txtCardNumber.TextField
#end if
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

' Handle card CVC code
Private Sub txtCvc_TextChanged(old As String, new As String)
#if B4i	' See https://www.b4x.com/android/forum/threads/strange-text_changed-behaviour.107128/
	Sleep(0)	' Ensure the new value is ok
#end if
	' Adapted from https://www.b4x.com/android/forum/threads/b4xfloattextfield-filter-characters-allowed.114681/
#if B4A
	Dim et As EditText = txtCvc.TextField	' So cursor can be positioned correctly.
#else ' B4i
	Dim et As TextField = txtCvc.TextField
#end if
	If new.Length > 3 Then
		txtCvc.Text = new.SubString2(0, 3)
		et.SetSelection(3,0)
	End If
End Sub

' Handle expiry date changes.
private Sub txtExpiryDate_TextChanged (Old As String, New As String)
	processedDate.Handler_TextChanged_MMYY(txtExpiryDate, Old, New)
End Sub

#End Region  Event Handlers


#Region  Public Subroutines

' Make a card payment against an order.
' orderPayment information about amount and order to pay.
Public Sub CardEntryAndOrderPayment(orderPayment As clsOrderPaymentRec)As ResumableSub
	ClearCard
	total = orderPayment.amount	' Save for later.
	mOrderId = orderPayment.orderId
	pnlCardEntry.Visible = True
	Wait for SubmitButton_Pressed ' Wait for card information to be entered - and the submit button presed.
	Return True
End Sub

#if B4i
' Moves up the panel when necessary.
Public Sub MoveUpEnterPanel(oskHeight As Float)
	kbHelper.MoveUpEnterDetailsPanel(oskHeight)
End Sub
#End If

' Will perform any cleanup operation when the form is closed (disappears).
public Sub OnClose
	If progressbox.IsInitialized = True Then	' Ensures the progress timer is stopped.
		progressbox.Hide
	End If
End Sub

#if B4i
' Handle resize event
Public Sub Resize
	kbHelper.Resize
End Sub
#End If

' Handles activity resume operation.
Public Sub ResumeOp
	cardInfo.Initialize
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
	swSaveCard.Value = False
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
	Return processedDate.FormatDateMMYY(expiryDate)
End Sub

' Gets the Public card information
Private Sub GetPublicCardInfo() As clsEposPublicCardInfo
	Dim publicCardInfo As clsEposPublicCardInfo : publicCardInfo.initialize
	publicCardInfo.expiryDate = cardInfo.card.exp_month & "/" & cardInfo.card.exp_year
	publicCardInfo.last4Digits =   cardInfo.card.number.SubString(12) ' Last 4 digits of card number - TODO Support other than 16 digit card numbers.
	Return publicCardInfo
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

' Hide Keyboard
Private Sub HideKeyboard
#If B4i
	xCardEntry.HideKeyboard
#End If
End Sub
	
' Initialize the locals etc.
private Sub InitializeLocals
	processedDate.Initialize
	progressbox.Initialize(Me, "progressbox", modEposApp.DFT_PROGRESS_TIMEOUT)
	payment.Initialize(progressbox)
	cardInfo.Initialize
	stripe.Initialize(Me, "stripe") ' 
	btnTestData.mBase.Visible = Starter.settings.testMode ' Short cut for setting Test Card button.
	SetupTabOrder
	kbHelper.Initialize(Me, "kbHelper", pnlCardEntry)
	Dim enterPanelTextField() As B4XFloatTextField = Array As B4XFloatTextField(txtCardNumber, txtExpiryDate, txtCvc, txtName, txtLine1, txtPostCode)
	kbHelper.SetupTextAndKeyboard(enterPanelTextField)
End Sub

' Load test data.
private Sub LoadTestData
	txtCardNumber.Text = "4242 4242 4242 4242"
	txtCvc.Text = "123"
	txtExpiryDate.Text = "01/23" ' Set to a date in the future.
	swSaveCard.Value = True
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
	If swSaveCard.Value  Then
		cardTokenObj.status = modConvert.payStatusSaveCard
		cardTokenObj.publicCardInfo = GetPublicCardInfo	' Get Card information.
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
	ClearCard
End Sub

' Setup the tab order (adjust as necessary - currently no tab operation and keyboard will hide when enter pressed).
' IMPORTANT - Don't remove otherwise it will autotab to the next field and not hide the keyboard when Enter is pressed!
Private Sub SetupTabOrder
	txtCardNumber.NextField = txtCardNumber ' This setting shows the accept button and stops the tab to next field (found thro' experimentation).
	txtExpiryDate.NextField = txtExpiryDate
	txtCvc.NextField = txtCvc
	txtName.NextField = txtName
	txtLine1.NextField = txtLine1
	txtPostCode.NextField = txtPostCode
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
	stripe.GetCardToken(cardInfo)
End Sub

#End Region  Local Subroutines

