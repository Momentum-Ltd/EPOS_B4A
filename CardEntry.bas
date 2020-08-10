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
	' Name......: CardEntry
	' Release...: 2-
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
	' Overview..: Option to save card information added and improved card number entry.
	' Amendee...: D Morris.
	' Details...: Added: Save Card checkbox - with associated code.
	'			    Mod: Card number entry and associated code.
		'
	' Date......: 
	' Release...: 
	' Overview..: Work on X-platform.
	' Amendee...: D Morris
	' Details...: Mod: Command moved to hCardEntry
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

	Private cardInfo As clsStripeTokenRec

End Sub

Sub Globals
	
	' View declarations
	Private btnSubmit As Button
	Private chkSaveCard As CheckBox
	Private txtCard1 As EditText
	Private txtCard2 As EditText
	Private txtCard3 As EditText
	Private txtCard4 As EditText
	Private txtCvc As EditText	
	Private txtExpireMonth As EditText
	Private txtExpireYear As EditText
	Private txtLine1 As EditText	
	Private txtName As EditText
	Private txtLine1 As EditText
	Private txtPostCode As EditText
	
	' Local variables
	Private total As Float 	' Amount to charge (if register card and take amount at same time)
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("frmCardEntry")
End Sub

Sub Activity_Resume
	ClearScreen
	PrefillScreen
	LoadTestData
	
	cardInfo.Initialize
End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Handle the submit button.
Sub btnSubmit_Click
	cardInfo.card.address_line1 = txtLine1.Text.Trim
	cardInfo.card.address_zip = txtPostCode.Text.trim	
	cardInfo.card.cvc = txtCvc.Text.trim
	cardInfo.card.exp_month = txtExpireMonth.Text.Trim
	cardInfo.card.exp_year = "20" & txtExpireYear.Text.Trim
	cardInfo.card.name = txtName.Text.trim
'	cardInfo.card.number = txtCardNumber.text.trim
	cardInfo.card.number = txtCard1.Text.Trim & txtCard2.Text.Trim & txtCard3.Text.Trim & txtCard4.Text.trim
	Starter.stripe.GetCardToken(Me, cardInfo)	
End Sub
'
'' Consume the stripe Charges event.
'Sub stripe_Charges(success As Boolean, result As String)
'	Dim a As Int
'	a = 1
'End Sub

' Handle card  token received from Stripe Server.
Sub stripe_CardToken(success As Boolean, cardToken As String)
	Starter.myData.customer.cardAccountEnabled = True ' Set flag to indicated card account is open.
	SendCardTokenToServer(cardToken, total)
End Sub

' Handle card  substring #1
Sub txtCard1_TextChanged (Old As String, New As String)
	EditSubString(txtCard1, txtCard2, New)
End Sub

' Handle card  substring #2
Sub txtCard2_TextChanged (Old As String, New As String)
	EditSubString(txtCard2, txtCard3, New)
End Sub

' Handle card  substring #3
Sub txtCard3_TextChanged (Old As String, New As String)
	EditSubString(txtCard3, txtCard4, New)
End Sub

' Handle card  substring #4 (inhibit tab to next field).
Sub txtCard4_TextChanged (Old As String, New As String)
	EditLastSubstring(txtCard4, New)
End Sub

' Handle card  CVC code
Sub txtCvc_TextChanged(old As String, new As String)
	LimitEditText(txtCvc, 3)
End Sub

' Handle card  Expiry month
Sub txtExpireMonth_TextChanged (Old As String, New As String)
	LimitEditText(txtExpireMonth, 2)
End Sub

' Handle card expiry year.
Sub txtExpireYear_TextChanged(old As String, new As String)
	LimitEditText(txtExpireYear, 2)
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' Entry point to request card information and invoke a charge on the card.
public Sub CardEntryAndCharge(charge As Float)
	total = charge	
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines
' Clear screen
Private Sub ClearScreen
	txtCard1.Text = ""
	txtCard2.Text = ""
	txtCard3.Text = ""
	txtCard4.Text = ""
	txtCvc.Text = ""
	txtExpireMonth.text = ""
	txtExpireYear.text = ""
	txtLine1.text = ""
	txtName.Text  = ""
	chkSaveCard.Checked = True
End Sub

' Edit last substring handle (special case for the last substring).
Sub EditLastSubstring(box As EditText, new As String)
	If new.Length > 4 Then
		Dim selVal As Int = box.SelectionStart
		If selVal <= 4 Then
			box.Text = box.Text.SubString2(0, selVal) & new.SubString2(selVal+ 1, 5)
			If selVal <> 4 Then
				box.SelectionStart = selVal
			End If
		End If
	End If
End Sub

' Edit sub string handler (tabs to next box and handle overwrite operation).
private Sub EditSubString(box1 As EditText, box2 As EditText, new As String)
	If new.Length > 4 Then
		Dim selVal As Int = box1.SelectionStart
		If box1.SelectionStart > 4 Then ' Move to next sub string?
			box2.Text = new.SubString2(4,5) & box2.text
			box2.RequestFocus
			box2.SelectionStart = 1
			box1.Text = box1.Text.SubString2(0, 4)
		Else ' Overwrite this sub string.
			box1.Text = box1.Text.SubString2(0, selVal) & new.SubString2(selVal+ 1, 5)
			If selVal <> 4 Then
				box1.SelectionStart = selVal
			Else
				box2.RequestFocus
				box2.SelectionStart = 0
			End If	
		End If
	End If
End Sub

' Limits a edittext view to maximum characters
private Sub LimitEditText(box As EditText, maxCharacters As Int)
	If box.Text.Length > maxCharacters Then
		box.Text = box.Text.SubString2(0, maxCharacters)	
	End If
End Sub

' Load test data.
private Sub LoadTestData
	'txtCardNumber.Text = "4242424242424242"
	txtCard1.Text = "4242"
	txtCard2.Text = "4242"
	txtCard3.Text = "4242"
	txtCard4.Text = "4242"
	txtCvc.Text = "123"
	txtExpireMonth.Text = "01"
	txtExpireYear.Text = "21"
End Sub

'Prefill Screen with address, name and postcode.
Private Sub PrefillScreen
	txtLine1.text = Starter.myData.customer.address
	txtName.Text = Starter.myData.customer.name
	txtPostCode.Text = Starter.myData.customer.postCode
	txtLine1.Text = Starter.myData.customer.address
	txtPostCode.Text = Starter.myData.customer.postCode
	chkSaveCard.Checked = True
End Sub

' Sends the card token to Centre server 
Private Sub SendCardTokenToServer(cardToken As String, pTotal As Float)
	Dim cardTokenObj As clsEposCustomerPayment : cardTokenObj.initialize
	
	cardTokenObj.customerId = Starter.myData.customer.customerIdStr
	If chkSaveCard.Checked Then
		cardTokenObj.status = modConvert.payStatusSaveCard
	Else
		cardTokenObj.status = modConvert.statusUnknown	
	End If
	cardTokenObj.token = cardToken
	cardTokenObj.total = pTotal
	Dim xmlString As String =  cardTokenObj.XmlSerialize
	CallSub2(Starter, "pSendMessage", modEposApp.EPOS_PAYMENT & xmlString)
End Sub



#End Region  Local Subroutines





