B4A=true
Group=HelperClasses
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@

'
' This is a help class for Place Order
'
#Region  Documentation
	'
	' Name......: hPlaceOrder
	' Release...: 34-
	' Date......: 06/04/21
	'
	' History
	' Date......: 22/10/19
	' Release...: 1
	' Created by: D Morris (started 20/10/19)
	' Details...: Based on ShowOrder_v27 and IOS frmMakeOrder_v5.
	'
	' Version 2 - 8 see v9.
	'         10 - 16 see v16.
	'         17 - 25 see v25.
	'		  26 - 31 see v32.
	' 			  
	' Date......: 28/01/21
	' Release...: 32
	' Overview..: Bugfix: #0587 - Not return to Home screen after paying order in cash. 
	' Amendee...: D Morris
	' Details...:  Mod: HandleOrderAcknResponse() - code fixed.
	' 			  
	' Date......: 06/02/21
	' Release...: 33
	' Overview..: Maintenance fix.
	' Amendee...: D Morris
	' Details...: Mod: Old commented code removed.
	'             		
	' Date......: 10/02/21
	' Release...: 34
	' Overview..: Maintenance fix.
	' Amendee...: D Morris
	' Details...: Mod: 'p' dropped from call to Starter.SendMessage().
	' 			  
	' Date......: 
	' Release...: 
	' Overview..: Support for Stripe Checkout (session ID)
	' Amendee...: D Morris
	' Details...: Mod: HandleOrderAcknResponse() - saves session to clsOrderPaymentRec.
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
				
	' Local constants
	Private const MAX_TABLE_NUMBER As Int = 999	' Maximum table number value.
	Private const MIN_TABLE_NUMBER As Int = 1	' Minimum table number value.

	' Activity view declarations
	Private btnMessage As SwiftButton	 		' Button which allows the user to add/edit the order message.
	Private btnOrder As SwiftButton		 		' Button which submits the order to the Server.
	Private imgSuperorder As B4XView 			' SuperOrder header icon.	
	Private lblBackButton As B4XView			' Back button.
	Private lblCollectCaption As B4XView		' Label used as a caption for the 'Collect from counter' delivery option.
	Private lblCollectionOnly As B4XView		' Label indicating Centre only allows collection.	
	Private lblDeliverCaption As B4XView		' Label used as a caption for the 'Deliver to table' delivery option.		
	Private lblOrderTotal As B4XView 			' Label which displays the total price of the order.
	Private lvwOrderItems As CustomListView		' listview which contains all the items current on the order.	
	Private pnlHeader As B4XView				' Header panel.
	Private pnlHideOrder As B4XView				' Panel to hide order details.
	Private swcCollectDeliver As B4XSwitch 		' Swtich used to control whether the order will be collected or delivered.
	Private txtTableNumber As B4XFloatTextField ' Text field used to enter the customer's table number.
#if B4I
	Private txtMessage As TextView 				' The multiline text view displayed on the text input dialog, used for the order message.	
#End If

	' Misc objects
	Private kbHelper As clsKeyboardHelper		' Keyboard handler
	Private notification As clsNotifications	' Handles notifications.
	Private payment As clsPayment				' Handles payments.	
	Private progressbox As clsProgressDialog	' Progress box.

	' Local variables
	Private mLocalOrderTotal As Float 			' The total price of the order.
#if B4I
	Private mConfirmationObject As clsEposCustomerOrderResponse ' Object which stores the Server's response to the Send Order command.
#end if

End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (parent As B4XView)
	parent.LoadLayout("frmPlaceOrder")
	InitializeLocals
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Handles the Click event of the Order Message button.
Private Sub btnMessage_Click
	'TODO There is a X-Platform version of this see https://www.b4x.com/android/forum/threads/b4x-xui-views-cross-platform-views-and-dialogs.100836/#content
#if B4A
	Dim textInputDialog As InputDialog
	textInputDialog.Input = Starter.customerOrderInfo.orderMessage
	Dim asyncDialog As Object = textInputDialog.ShowAsync("", "Enter your message here:", "Accept", "", "Cancel", Null, True)
	Wait For (asyncDialog) Dialog_Result(result As Int)
	If result = DialogResponse.POSITIVE Then 
		Starter.customerOrderInfo.orderMessage = modEposWeb.FilterStringInput(textInputDialog.Input.Trim)
	End If
#else ' B4I
	' The custom dialog is taken from here: https://www.b4x.com/android/forum/threads/custom-dialogs-with-icustomdialog-library.83526/
	Dim dialogPanel As Panel : dialogPanel.Initialize("pnlTextEntryDialog")
	dialogPanel.SetLayoutAnimated(0, 1, 0, 0, xPlaceOrder.GetRootPanelWidth() - 50dip, 150dip)
	txtMessage.Initialize("txtTextEntryDialog")
	txtMessage.Text = Starter.CustomerOrderInfo.orderMessage
	txtMessage.SetBorder(1, Colors.Black, 3)
	txtMessage.KeyboardAppearance = txtMessage.APPEARANCE_DARK

	AddDoneButtonToKeyboard(txtMessage)

	dialogPanel.AddView(txtMessage, 0, 0, dialogPanel.Width, dialogPanel.Height)
	Dim dialog As CustomLayoutDialog
	dialog.Initialize(dialogPanel)
	dialog.style = dialog.STYLE_EDIT ' Style only seems to affect the icon on the dialog - this one has a writing symbol
	Dim dialogObj As Object = dialog.ShowAsync("Enter your message here:", "OK", "Cancel", "", False)
	Wait For (dialogObj) Dialog_Result (Result As Int)
	If Result = dialog.RESULT_POSITIVE Then	
		Starter.CustomerOrderInfo.orderMessage = modEposWeb.FilterStringInput(txtMessage.Text.Trim)
	End If
#End If
	HandleMessageButton
End Sub

' Handles the Click event of the Submit Order button.
Private Sub btnOrder_Click
	Starter.customerOrderInfo.tableNumber = modEposApp.Val( txtTableNumber.Text.Trim) 
	Dim errorMsg As String = ""
	If Starter.customerorderInfo.orderList.Size < 1 Then
		errorMsg = errorMsg & "there are no items in your order"
	End If
	If Starter.myData.centre.allowDeliverToTable Then ' Centre allows delivery?
		If Starter.CustomerOrderInfo.deliverToTable And Starter.CustomerOrderInfo.tableNumber = 0 Then ' Table number ok
			If errorMsg <> "" Then 
				errorMsg = errorMsg & " and "
			End If
			errorMsg = errorMsg & "no table number has been entered"
		End If
	Else ' Centre not allowing delivery
		Starter.customerOrderInfo.deliverToTable = False	' Ensure delivery is OFF.
	End If
	If errorMsg = "" Then ' Order details are OK, no errors detected
		Starter.customerOrderInfo.customerNumber = Starter.myData.customer.customerId
		Starter.customerOrderInfo.centreId = Starter.myData.centre.centreId
		Dim xmlOrder As String = Starter.customerOrderInfo.XmlSerialize
#if B4A
		Starter.latestOrderTotal = mLocalOrderTotal
		ProgressShow("Verifying the details of your order, please wait...")
#else ' B4I
		Main.latestOrderTotal = mLocalOrderTotal
		ProgressShow("Verifying your order...")
#End If
		Dim msg As String = modEposApp.EPOS_ORDER_SEND & xmlOrder
#if B4A
		CallSub2(Starter, "SendMessageAndCheckReconnect", msg )
#else ' B4I
		'Main.comms.SendMessageAndCheckReconnect(msg)
		Main.SendMessageAndCheckReconnect(msg)
#End If
	Else ' Errors have been detected with the entered order details
		xui.MsgboxAsync("Unable to submit your order because " & errorMsg & ".", "Invalid Order")
	End If
End Sub

#if B4I
' Handles done button (used for submitting customer messages).
Private Sub btnTextboxDone_Click
	txtMessage.ResignFocus ' Hide the keyboard
End Sub
#End If

#if B4i
Private Sub kbHelper_HideKeyboard
	HideKeyboard
End Sub
#End If

' Handle back button
Private Sub lblBackButton_Click
	CancelOrder
End Sub

' Handles click off txtTableNumber view to hide the keyboard.
Private Sub lblCollectCaption_Click
	QueryDisplayKeyboardAndButtons
End Sub

' Handles click off txtTableNumber view to hide the keyboard.
Private Sub lblCollectOnly_Click
	QueryDisplayKeyboardAndButtons
End Sub

' Handles click off txtTableNumber view to hide the keyboard.
private Sub lblDeliverCaption_Click
	QueryDisplayKeyboardAndButtons
End Sub

' Handles click off txtTableNumber view to hide the keyboard.
private Sub lblOrderTotal_Click
	QueryDisplayKeyboardAndButtons
End Sub

' Handles click off txtTableNumber view to hide the keyboard.
Private Sub lblCollectionOnly_Click
	QueryDisplayKeyboardAndButtons
End Sub

' Handles the ItemClick event of the Order Items listview.
Private Sub lvwOrderItems_ItemClick(Value As Object, position As Int)
	If isTableNumberValid Then ' Check if table number is OK!
		Dim itemSelect As Int = position
#if B4A
		If itemSelect < lvwOrderItems.Size Then	' Edit Items?
			CallSubDelayed2(aSelectItem, "EditItem", itemSelect - 1) ' Edit item in order table
		Else ' Add new item
			CallSubDelayed(aSelectItem, "StartSelectItem")
		End If
#else ' B4I
'		xPlaceOrder.ClrPageTitle()	' fixes page title operation.
		xSelectItem.Show
		If itemSelect < lvwOrderItems.Size Then
			xSelectItem.EditItem(itemSelect - 1) ' Edit item in order table
		Else ' Selected item is the last in the list - the 'add an item' placeholder
			xSelectItem.StartSelectItem ' Select a new item
		End If	
#End If		
	Else 
		xui.MsgboxAsync("You must enter a table number.", "Table Number Required")
	End If
End Sub

' Handle Collect/Deliver switch.
Private Sub swcCollectDeliver_ValueChanged(deliver As Boolean)
	Starter.CustomerOrderInfo.deliverToTable = deliver
	QueryDisplayKeyboard
	SetupCollectDeliverViews
	HandleMessageButton
	HandleOrderButton	
	ShowOrderList	' This ensure correct text is shown at end of list.
End Sub

' Progress dialog has timed out
Private Sub progressbox_Timeout
	xui.MsgboxAsync("No response", "Checking Account")
	Wait for msgbox_result (result As Int)
	ExitToCentreHomePage
End Sub

' Handles the EnterPressed event of the Table Number edittext view.
Private Sub txtTableNumber_EnterPressed
	ProcessTableNumer(txtTableNumber.Text.Trim) 
End Sub

' Handles the TextChanged event of the Table Number edittext view.
' Uses https://www.b4x.com/android/forum/threads/edittext-max-characters-limit.23409/ to limit the length of input
Private Sub txtTableNumber_TextChanged(strOld As String, strNew As String)
#if B4i	' See https://www.b4x.com/android/forum/threads/strange-text_changed-behaviour.107128/
	Sleep(0)	' Ensure the new value is ok
#end if
	Dim tableNumber As Int = modEposApp.CheckNumberRange(strNew.Trim, MAX_TABLE_NUMBER, MIN_TABLE_NUMBER, 0)
	Starter.CustomerOrderInfo.tableNumber = tableNumber	
	If strNew <> strOld Then
		If tableNumber <> 0 Then
			txtTableNumber.Text = tableNumber				
		Else
			txtTableNumber.Text = "" ' Table number = 0 displayed as blank.
		End If
		' Adapted from https://www.b4x.com/android/forum/threads/b4xfloattextfield-filter-characters-allowed.114681/
#if B4A
		Dim et As EditText = txtTableNumber.TextField		' So cursor can be positioned correctly (appears only necessary for Android).
#else ' B4i
		Dim et As TextField = txtTableNumber.TextField
#end if
		If txtTableNumber.Text.Length > 0 Then
			et.SetSelection(txtTableNumber.Text.Length, 0)
		End If
	End If
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' Handles the Cancel Order operation (i.e. back button).
Public Sub CancelOrder
	If lvwOrderItems.Size > 1 Then ' Items in order - check if OK to clear the order.
		xui.Msgbox2Async("This will clear your order - do you want to continue?", "Back button operation", "Yes", "No", "" , Null)
		Wait For Msgbox_Result (result As Int)
		If result = xui.DialogResponse_Positive Then
			ClearOrder ' Clear order information
			ExitToCentreHomePage
		End If
	Else ' No items in order - just exit
		ClearOrder ' Clear order information
		ExitToCentreHomePage
	End If
End Sub

' Handles the Order Acknowledgement response from the Server and takes appropriate action.
Public Sub HandleOrderAcknResponse(orderAcknResponseStr As String)
	ProgressHide ' Always hide the progress dialog
#if B4A
	Dim xmlStr As String = orderAcknResponseStr.SubString(modEposApp.EPOS_ORDER_ACKN.Length)
#else ' B4I
	Dim xmlStr As String = Main.TrimToXmlOnly(orderAcknResponseStr)
#End If
	Dim responseObj As clsEposOrderStatus : responseObj.Initialize
	responseObj = responseObj.XmlDeserialize(xmlStr)
'	Dim msg As String = "Your order is " & _
'			 modConvert.ConvertStatusToUserString(responseObj.status, responseObj.deliverToTable) ' Generic message, just in case
	If responseObj.status = modConvert.statusWaiting Then ' Order is progressing as normal
		Dim queueStr As String = " " & modConvert.ConvertNumberToOrdinalString(responseObj.queuePosition)
		If responseObj.queuePosition < 1 Then queueStr = ""
		Dim msg As String = "Your order is being processed, and is" & queueStr & " in the queue."
		xui.Msgbox2Async(msg, "Order Status", "OK", "", "", Null)
		Wait For MsgBox_Result(result As Int)
	Else If responseObj.status = modConvert.statusWaitingForPayment Then ' Payment required before order is processed
		Dim orderPayment As clsOrderPaymentRec: orderPayment.initialize (responseObj.orderId, responseObj.amount, responseObj.sessionId )
#if B4A
		CallSubDelayed2(aHome, "QueryAndMakePayment", orderPayment)
#else ' B41
		xHome.QueryAndMakePayment(orderPayment)
#End If
	End If
	ExitToCentreHomePage
End Sub

' Handles the response from the Server to the Order message.
Public Sub HandleOrderResponse(orderResponseStr As String)
	ProgressHide ' Always hide the progress dialog at this point
#if B4A
	Dim xmlStr As String = orderResponseStr.SubString(modEposApp.EPOS_ORDER_SEND.Length)
#else ' B4I
	Dim xmlStr As String = Main.TrimToXmlOnly(orderResponseStr)
	mConfirmationObject.Initialize ' Reset the stored response object
	mConfirmationObject.DeserialiseXml(xmlStr)
#End If
	Dim responseObj As clsEposCustomerOrderResponse : responseObj.Initialize
	responseObj.DeserialiseXml(xmlStr)
	
	Dim showErrorMsg As Boolean = True
	Dim msgStr As String = "An error occurred while trying to verify your order. Please try again."
	If responseObj.customerId > 0 Then ' Validate that the deserialisation was successful
		If responseObj.accept Then
			showErrorMsg = False
			' TODO - does the user really need to manually acknowledge this? Instead it could be sent automatically
			Dim msg As String = "Your order with" & CRLF & _
								"Centre:" & Starter.myData.centre.name & CRLF & _
								"Has been successfully verified." & CRLF & _
								 "Please press 'Proceed' to confirm your order."	
			xui.Msgbox2Async(msg, "Order Verified", "Proceed", "Cancel", "", Null)
			Wait For MsgBox_Result(Result As Int)
			If Result = xui.DialogResponse_Positive Then ' Proceed with order?
				ProgressShow("Processing your selection...")
				Dim localOrderObj As clsOrderTableRec : localOrderObj.Initialize
				localOrderObj.customerId = responseObj.customerId
				localOrderObj.orderId = responseObj.orderId			
				Dim msg As String = modEposApp.EPOS_ORDER_ACKN & localOrderObj.XmlSerialize(localOrderObj)
				Log(msg)
#if B4A
				CallSub2(Starter, "SendMessage",  msg)
				' DM 27/5/18 & 19/09/18 - This is not ideal as the order may not be accepted by the server - need to investigate.
				CallSub2(srvPhoneTotal, "AdjustPhoneTotal", Starter.latestOrderTotal)
#Else ' B4I
				' Main.comms.SendMessage( msg)
				Main.SendMessage(msg)
				' DM 27/5/18 & 19/09/18 - This is not ideal as the order may not be accepted by the server - need to investigate.
				svcPhoneTotal.AdjustPhoneTotal(Main.LatestOrderTotal)
#End If
				ClearOrder ' Important to do this as it updates the Starter service's database
			End If
		Else ' Order was not accepted
			If responseObj.itemList.Size > 0 Then ' Items in the order are out of stock
				msgStr = "The following items in your order have run out of stock:" & CRLF
				For Each item As clsCustomerOrderItemRec In responseObj.itemList
					Dim sizePriceRec As clsSizePriceTableRec = Starter.DataBase.GetSizePriceRec(item.priceId)
					msgStr = msgStr & Starter.DataBase.GetGroupAndDescriptionName(sizePriceRec.goodsId) & _
								", " & Starter.DataBase.GetSizeOptName(sizePriceRec.size) & CRLF
				Next
				msgStr = msgStr & CRLF & "Please remove them from your order or replace them with alternatives, and then try again."
			Else ' Some other problem than items being out of stock
				msgStr = "There is a problem with your order: " & responseObj.message
				xui.Msgbox2Async(msgStr, "Unable to Submit Order", "OK", "", "", Null)
				Wait For MsgBox_Result(Result1 As Int)
				ExitToCentreHomePage	
			End If
		End If
	End If
	If showErrorMsg Then 
		xui.Msgbox2Async(msgStr, "Unable to Submit Order", "OK", "", "", Null)
	End If
End Sub

#if B4i
' This method moves a text entry field so it does not get covered by the keyboard.
' B4XFloatTextField is taken from here: https://www.b4x.com/android/forum/threads/b4xfloattextfield-keyboard-hiding-views.118242/#post-740784
Public Sub MoveUpEnterDetailsPanel(height As Float)
	kbHelper.MoveUpEnterDetailsPanel(height)
End Sub
#End If

' Will perform any cleanup operation when the form is closed (disappears).
public Sub OnClose
	' Warning don't be tempted to call ClearOrder() closed to call SelectItem.
	Starter.CustomerOrderInfo.tableNumber = modEposApp.Val( txtTableNumber.Text.trim) ' Ensures last entered table number is stored.
	If progressbox.IsInitialized = True Then	' Ensures the progress timer is stopped.
		progressbox.Hide
	End If
End Sub

' Performs the resume operation.
public Sub ResumeOp
	HandleMessageButton
	HandleOrderButton	
	ShowOrderList	
	SetupCollectDeliverViews
	QueryDisplayKeyboard
End Sub

#if B4i
' Handle resize event
Public Sub Resize
	kbHelper.Resize
End Sub
#End If

' Displays a messagebox containing the most recent Message To Customer text, and makes the notification sound/vibration if specified.
Public Sub ShowMessageNotificationMsgBox(soundAndVibrate As Boolean)
	notification.ShowMessageNotificationMsgBox(soundAndVibrate)
End Sub

' Displays a messagebox containing the most recent Order Status text, and makes the notification sound/vibration if specified.
Public Sub ShowStatusNotificationMsgBox(soundAndVibrate As Boolean)
	notification.ShowStatusNotificationMsgBox(soundAndVibrate)
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines
#If B4I
'' Add to support a done button on numerical keyboard.
'' see https://www.b4x.com/android/forum/threads/input-accessory-views.51000/#content
'Sub AddViewToKeyboard(TextField1 As TextField, View1 As View)
'	Dim no As NativeObject = TextField1
'	no.SetField("inputAccessoryView", View1)
'End Sub

' Sets up a small 'Done' buttons to appear above the keyboard shown when the specified textbox is entered.
Private Sub AddDoneButtonToKeyboard(attachedTextBox As TextView)
	' This sub contains code taken from https://www.b4x.com/android/forum/threads/input-accessory-views.51000/
	' as well as https://www.b4x.com/android/forum/threads/icon-to-hide-keyboard.69102/
	Dim orangeColour As Int = Colors.RGB(230, 100, 15)
	Dim greyColour As Int = Colors.RGB(169, 169, 169)
	
	' Create transparent panel (or otherwise the buttons will fill the whole width of the screen)
	Dim pnlButton As Panel : pnlButton.Initialize("")
	pnlButton.Color = Colors.Transparent
	pnlButton.Height = 35
	
	' Create the Done button and add it to the panel
	Dim btnTextboxNext As Button : btnTextboxNext.InitializeCustom("btnTextboxDone", Colors.Black, orangeColour)
	btnTextboxNext.Color = greyColour
	btnTextboxNext.SetBorder(0, greyColour, 3) ' To make the corners rounded
	btnTextboxNext.Text = "Done"
	pnlButton.AddView(btnTextboxNext, (xPlaceOrder.GetRootPanelWidth() - 80), 0, 80, pnlButton.Height)
	
	' Attach the panel bearing the buttons to the specified textbox's keyboard
	Dim textboxNativeObj As NativeObject = attachedTextBox
	textboxNativeObj.SetField("inputAccessoryView", pnlButton)
End Sub
#End If

' Clears all items and data from the current order (including in the database).
Private Sub ClearOrder
	Starter.customerOrderInfo.orderList.Clear
	Starter.customerOrderInfo.orderMessage = ""
	ShowOrderList
	HandleMessageButton
	HandleOrderButton
End Sub

' Handles exit to Centre Home page.
Private Sub ExitToCentreHomePage()
#if B4A
	StartActivity(aHome)
#else ' B4I
'	xPlaceOrder.ClrPageTitle()	' fixes page title operation.
	xHome.Show
#End If	
End Sub

' Displays the relevant text on the Message button and enables/disables the button accordingly.
Private Sub HandleMessageButton
	If Starter.customerOrderInfo.orderMessage <> "" Then
		btnMessage.xLBL.text = "Edit your message"
	Else ' No message currently saved
		btnMessage.xLBL.text = "Add a message" & CRLF & "to your order"
	End If
	If isTableNumberValid Then
		btnMessage.Enabled = True
	Else
		btnMessage.Enabled = False
	End If
End Sub

' Enable/disable Order button accordingly.
Private Sub HandleOrderButton
	If isTableNumberValid Then
		btnOrder.Enabled = True
	Else
		btnOrder.Enabled = False
	End If
End Sub

' Hide the keyboard
Private Sub HideKeyboard
#if B4i
	xPlaceOrder.HideKeyboard
#End If
End Sub

' Initialize the locals etc.
private Sub InitializeLocals
	progressbox.Initialize(Me, "progressbox", modEposApp.DFT_PROGRESS_TIMEOUT)
	payment.Initialize(progressbox)
	notification.Initialize
	Dim bt As Bitmap = imgSuperorder.GetBitmap
	imgSuperorder.SetBitmap(bt.Resize(imgSuperorder.Width, imgSuperorder.Height, True))
	imgSuperorder.Top = (pnlHeader.Height - imgSuperorder.Height) / 2   ' Centre SuperOrder vertically.
	kbHelper.Initialize(Me, "kbHelper", pnlHeader)
#if B4i	
	kbHelper.AddViewToKeyboard(txtTableNumber)
#End If	
	kbHelper.SetupBackcolourAndBorder(txtTableNumber)	
End Sub

' Checks if a table number is valid
' Returns true if table number not required or valid table number entered.
Private Sub isTableNumberValid() As Boolean
	Dim tableNumberValid As Boolean = False
	If Not(Starter.myData.centre.allowDeliverToTable) Or _ 
			Starter.CustomerOrderInfo.tableNumber <> 0 Or Not(Starter.CustomerOrderInfo.deliverToTable) Then
		tableNumberValid = True
	End If
	Return tableNumberValid
End Sub

' Show the process box
Private Sub ProgressHide
	progressbox.Hide
End Sub

' Hide The process box.
Private Sub ProgressShow(message As String)
	progressbox.Show(message)
End Sub

' Process the Table number enter and check if valid t - then take appropriate action.
Private Sub ProcessTableNumer(enteredTableNo As String)
	Dim tableNumber As Int = modEposApp.CheckNumberRange(enteredTableNo, MAX_TABLE_NUMBER, MIN_TABLE_NUMBER, 0) ' = 0 if invalid table string.
	If (tableNumber > 0) Or Not(Starter.CustomerOrderInfo.deliverToTable) Then
		Starter.customerOrderInfo.tableNumber = tableNumber
		ResumeOp
	Else
		xui.MsgboxAsync("You must enter a table number.", "Table Number Required")
		ShowKeyboard
	End If
End Sub

' Query displaying of keyboard.
Private Sub QueryDisplayKeyboard
	If Starter.myData.centre.allowDeliverToTable And _ 
		Starter.customerOrderInfo.tableNumber = 0 And _
		 Starter.CustomerOrderInfo.deliverToTable Then	' Table number required?
#if B4I
		Sleep(1000)	' Gives nice keyboard operation (would be to be quicker).
#End If
		ShowKeyboard
	Else
		HideKeyboard
	End If
End Sub

' Query displaying keyboard and handles the message/order buttons.
Private Sub QueryDisplayKeyboardAndButtons
	QueryDisplayKeyboard
	HandleMessageButton
	HandleOrderButton
End Sub

' Updates views for Collect/Deliver operation.
Private Sub SetupCollectDeliverViews
	Dim allowDeliver As Boolean = Starter.myData.centre.allowDeliverToTable		
	If allowDeliver Then
		lblCollectionOnly.Visible = False	
		lblCollectCaption.Visible = True	' Display the delivery options.
		swcCollectDeliver.mBase.Visible = True
		lblDeliverCaption.Visible = True
		' Set the table number as necessary
		Dim tableNumber As String = Starter.customerOrderInfo.tableNumber
		If tableNumber = "0" Then 
			tableNumber = ""
		End If
		txtTableNumber.Text = tableNumber
		' Display the collect/deliver radiobuttons (or the collection-only caption), and set them as necessary
		swcCollectDeliver.mBase.Visible = allowDeliver
		swcCollectDeliver.Value = Starter.CustomerOrderInfo.deliverToTable
		If swcCollectDeliver.Value = True Then ' Deliver?
			txtTableNumber.mBase.Visible = True
			lblCollectCaption.TextColor = Colors.LightGray
			lblCollectCaption.Font = xui.CreateDefaultFont(lblCollectCaption.Font.Size)
			lblDeliverCaption.Text = "Deliver to"
			lblDeliverCaption.TextColor = Colors.White
			lblDeliverCaption.Font = xui.CreateDefaultBoldFont(lblDeliverCaption.Font.Size)
		Else ' Collect
			txtTableNumber.mBase.Visible = False
			lblCollectCaption.TextColor = Colors.White
			lblCollectCaption.Font = xui.CreateDefaultBoldFont(lblCollectCaption.Font.Size)
			lblDeliverCaption.Text = "Deliver"
			lblDeliverCaption.TextColor = Colors.LightGray
			lblDeliverCaption.Font = xui.CreateDefaultFont(lblDeliverCaption.Font.Size)
		End If
	Else ' Display Collection only message.
		lblCollectionOnly.Visible = True 
		lblCollectCaption.Visible = False	' Display the delivery options.
		swcCollectDeliver.mBase.Visible = False
		lblDeliverCaption.Visible = False
		txtTableNumber.mBase.Visible = False
	End If
	' Update the message button as necessary
	btnMessage.mBase.Visible = Not(Starter.myData.centre.disableCustomMessage)
End Sub

' Show the keyboard
Private Sub ShowKeyboard
#if B4A 
	Sleep(0) ' Necessary for the B4A otherwise the keyboard don't appear automatically!
#End If
	txtTableNumber.RequestFocusAndShowKeyboard
	txtTableNumber.mBase.RequestFocus ' Necessary for the B4A otherwise the keyboard don't appear automatically!
#if B4A 
	Sleep(0) ' Necessary for the B4A otherwise the keyboard don't appear automatically!
#End If	
End Sub

' Shows the current list of order items in the Order Items listview.
Private Sub ShowOrderList
	Dim i As Int = 1
	Dim topLine As String
	Dim bottomLine As String
	Dim orderTotal As Float = 0.0

	lvwOrderItems.Clear
	For Each item As clsCustomerOrderItemRec In Starter.customerOrderInfo.orderList
		Dim mSizePriceRec As clsSizePriceTableRec : mSizePriceRec.initialize
		mSizePriceRec = Starter.DataBase.GetSizePriceRec(item.priceId)
		Dim fullDescription As String = Starter.DataBase.GetGroupAndDescriptionName(mSizePriceRec.goodsId)
		topLine = "#" & i & ": " & fullDescription
		Dim unitPrice As Float = mSizePriceRec.unitPrice
		Dim lineTotal As Float = unitPrice * item.qty
		bottomLine = Starter.DataBase.GetSizeOptName(mSizePriceRec.size)
		bottomLine = bottomLine & " x" & item.qty & " @ £" & modEposApp.FormatCurrency(unitPrice)
		bottomLine = bottomLine &  "/ea = £" & modEposApp.FormatCurrency(lineTotal)
		lvwOrderItems.AddTextItem(topLine & CRLF & bottomLine, i)
		orderTotal = orderTotal + lineTotal
		i = i + 1
	Next
	If isTableNumberValid Then
		lvwOrderItems.AddTextItem("+ Press here to add an item" & CRLF , i) ' Note: The CRLF is necessary for list to scroll when required. 	
	Else
		lvwOrderItems.AddTextItem("+ Enter table number" & CRLF, i)	
	End If
#if B4A
	' https://www.b4x.com/android/forum/threads/customlistview-scrolltoitem-problem.90996/
	Sleep(0)	' Suggested by Erel.
	lvwOrderItems.ScrollToItem(i - 1)
#else
	Sleep(0)	' (for iOS this fixes the problem of vanishing "+ Press here to add an item" when anchors used.
	Dim bottomItem As Int = lvwOrderItems.LastVisibleIndex
	If bottomItem < (i - 1) Then ' Make iOS list view operate as Android (See not about CRLF above) 
		lvwOrderItems.ScrollToItem(i - 1)
	End If
#end if
	lblOrderTotal.Text = "Order Total: £" & modEposApp.FormatCurrency(orderTotal)
	mLocalOrderTotal = orderTotal
End Sub

#End Region  Local Subroutines
