B4A=true
Group=HelperClasses
ModulesStructureVersion=1
Type=Class
Version=10.7
@EndOfDesignText@

'
' This is a help class for the About activity.
'
#Region  Documentation
	'
	' Name......: hStripeCheckout
	' Release...: -
	' Date......: 08/04/21
	'
	' 8History
	' Date......: 
	' Release...: 
	' Created by: D Morris.
	' Details...: First release to support version tracking
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
	Private xui As XUI						'ignore
	
	' Local variables
	Private currentOrderId As Int			' Current order ID	
	Private currentSessionId As String		' Storage for current session ID.
	Private currentTotal As Float			' Current order total.

	' Misc 
	Private imeObj As IME
	
	' View declarations
	Private btnWebClose As SwiftButton		' close web view button.
	Private imgSuperorder As B4XView 		' SuperOrder header icon.	
	Private lblBackButton As B4XView		' Back button
	Private pnlHeader As B4XView			' Header panel.	
	Private pnlWeb As Panel					' Border for the Web view.
	Private web As WebView					' Web view for showing privacy policy.
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (parent As B4XView)
	parent.LoadLayout("frmCheckOut")

	imeObj.Initialize("imeObj")
	
	imeObj.AddHeightChangedEvent
	
	InitializeLocals
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Close web view.
Sub btnWebClose_Click
'	pnlWeb.Visible = False
	CallSubDelayed(Me, "SubmitButton_Pressed")
'	Dim showCurrentURL As String = web.Url
	ExitToCentreHomePage
End Sub

' Handle back button
private Sub lblBackButton_Click
	ExitToCentreHomePage
End Sub

' Reduce webview to show keyboard.
' Taken from https://www.b4x.com/android/forum/threads/virtual-keyboard-hides-input-fields-in-webview.114077/#content
Sub imeObj_HeightChanged (NewHeight As Int, OldHeight As Int)
'	web.Height = NewHeight
'	web.Height = 100
	pnlWeb.Height = NewHeight
	web.Height = NewHeight - 30
'	btnWebClose.mBase.Top = NewHeight - 100
End Sub

' Handles URL changed (used to detect success/fail card payment)
Sub web_OverrideUrl (url As String) As Boolean
	Dim exitWebView As Boolean = False
	Select url
		Case modEposWeb.URL_PAYMENT_SUCCESS
			SendPaymentToServer(currentSessionId, currentTotal, modConvert.payStatusSucceeded)
		Case modEposWeb.URL_PAYMENT_FAIL
			SendPaymentToServer(currentSessionId, currentTotal, modConvert.payStatusFailed)
		Case Else
			' No action!			
	End Select
	Return exitWebView
End Sub
#End Region  Event Handlers

#Region  Public Subroutines



' Make a card payment against an order.
' orderPayment information about amount and order to pay.
Public Sub CardEntryAndOrderPayment(orderPayment As clsOrderPaymentRec)As ResumableSub
	Dim htmlScript As String = BuildPaymentHtml(orderPayment.sessionId, Starter.myData.centre.publishedKey)
	currentSessionId = orderPayment.sessionId
	currentOrderId = orderPayment.orderId
	currentTotal = orderPayment.amount
	ShowPaymentPage(htmlScript)
	
	Wait for SubmitButton_Pressed ' Wait for card information to be entered - and the submit button presed.

	Return True
End Sub

' Will perform any cleanup operation when the form is closed (disappears).
public Sub OnClose
	currentOrderId = 0
	currentSessionId = ""
	currentTotal = 0
	web.LoadUrl("")	' Clear the last displayed HTML page information.
End Sub

' Handles activity resume operation.
Public Sub ResumeOp
'	cardInfo.Initialize
End Sub

' Handle operation when user presses backbutton.
Public Sub UserPressesBackButton()
	ExitToCentreHomePage
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Builds the Payment HTML page
Private Sub BuildPaymentHtml(sessionId As String, publishedApiKey As String) As String
	Dim htmlScript As String
	htmlScript =  $"
    <html>
    <head>
    <title> Payment For purchase</title>
    <script src = "https://js.stripe.com/v3/" ></script>
    </head>
    <body>
    <h2>Payment process<br />
	 Please wait...</h2>
        <script type = "text/javascript" >
        var stripe = Stripe("${publishedApiKey}");
        window.onload = stripe.redirectToCheckout({
          sessionId:  (Id = "${sessionId}"),
        })
        .then(function(result) {
          if(result.error) {
            alert(result.error.message);
          }
        })
        .catch(function(error) {
          console.error("Error: ", error);
        });
        </script>
    </body>
    </html>   "$
	Log("html:" & htmlScript)
	Return htmlScript
End Sub

' Exits to Home Page
private Sub ExitToCentreHomePage
'	ProgressHide
'	Starter.customerOrderInfo.tableNumber = 0
'	tmrConnectToCentreTimout.Enabled = False
#if B4A
	StartActivity(aHome)
#else
	xHome.Show
#End If
End Sub

'' Will show or hide privacy policy
'Private Sub HandlePrivacyPolicy(show As Boolean)
'	web.LoadUrl(modEposWeb.URL_PRIVACY_POLICY)
''	pnlWeb.Visible = show
''	web.Visible = show
'End Sub

' Initialize the locals etc.
private Sub InitializeLocals
'#if B4A
'	lblAppName.Text = "App name:" & Application.PackageName
'	lblVersion.Text = "Version:" & Application.VersionName
'#Else
'	lblAppName.Text = "App name: " & Main.GetAppName
'	lblVersion.Text = "Version: " & Main.GetAppVersion
'#End If
'	Private cs As CSBuilder
'	cs.Initialize.Underline.Color(Colors.White).Append("View Privacy Policy").PopAll
'	' See https://www.b4x.com/android/forum/threads/b4x-set-csbuilder-or-text-to-a-label.102118/
'	XUIViewsUtils.SetTextOrCSBuilderToLabel(lblPrivacyPolicy, cs)

	currentOrderId = 0
	currentSessionId = ""
	currentTotal = 0
	
	Dim bt As Bitmap = imgSuperorder.GetBitmap
	imgSuperorder.SetBitmap(bt.Resize(imgSuperorder.Width, imgSuperorder.Height, True))
	imgSuperorder.Top = (pnlHeader.Height - imgSuperorder.Height) / 2   ' Centre SuperOrder vertically.
End Sub

'' Is this form shown
'private Sub IsVisible As Boolean
'#if B4A
'	Return (CallSub(aAbout, "IsVisible"))
'#else ' B4i
'	Return xAbout.IsVisible
'#End If
'End Sub

' Shows the Checkout page to enter card.
Private Sub ShowPaymentPage(htmlScript As String)
	web.LoadHtml(htmlScript)
End Sub

' Sends the payment message to Centre server 
Private Sub SendPaymentToServer(sessionId As String, pTotal As Float, paymentStatus As Int)
	Dim paymentObj As clsEposCustomerPayment : paymentObj.initialize
	
	paymentObj.centreId = Starter.myData.centre.centreId
	paymentObj.customerId = Starter.myData.customer.customerId
	paymentObj.status = paymentStatus
	paymentObj.token = ""
	paymentObj.total = pTotal
	paymentObj.orderId = currentOrderId
	paymentObj.sessionId = sessionId
	Dim msg As String =  modEposApp.EPOS_PAYMENT & paymentObj.XmlSerialize
'	ProgressShow("Making Payment")
#if B4A
	CallSub2(Starter, "SendMessage", msg)
#else ' B4A
	'Main.comms.SendMessage(msg)
	Main.SendMessage(msg)
#end if
'	ClearCard
End Sub

#End Region  Local Subroutines
