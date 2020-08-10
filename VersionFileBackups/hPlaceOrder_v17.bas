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
	' Release...: 17
	' Date......: 11/06/20
	'
	' History
	' Date......: 22/10/19
	' Release...: 1
	' Created by: D Morris (started 20/10/19)
	' Details...: Based on ShowOrder_v27 and IOS frmMakeOrder_v5.
	'
	' Version 2 - 8 see v9
	'
	' Date......: 21/03/20
	' Release...: 9
	' Overview..: #315 Issue removed B4A compiler warnings. 
	' Amendee...: D Morris
	' Details...:  Mod: pHandleOrderResponse() call to pProgressDialogShow removed - replaced by StartActivity(aTaskSelect).
	'			   Mod: DIALOG_BTN_PROCEED commented out.
	'			   Mod: btnCancel(), mClosingActivity and mClosingForm commented out.
	'			   Mod: mConfirmationObject commented out.
	'			   Mod: pHandleOrderResponse() mClosingActivity commented out.
	'			   Mod: InitializeLocals() orangeColour commented out.
	'				
	' Date......: 28/03/20
	' Release...: 10
	' Overview..: Bugfix: #0332 - Back button problem.
	' Amendee...: D Morris
	' Details...:  Mod: lvwOrderItems_ItemClick(). orderSuccessMsg_Click(), CancelOrder(). 
	'
	' Date......: 02/04/20
	' Release...: 11
	' Overview..: Issue: #0371 - Notification whilst showing screens.
	'			  
	' Amendee...: D Morris
	' Details...: Added: notification class.
	'			  Added: ShowMessageNotificationMsgBox() and ShowStatusNotificationMsgBox().
	'			    Mod: InitializeLocals(), 
	'
	' Date......: 06/04/20
	' Release...: 12
	' Overview..: Issue: iOS phones asking twice to confirm order.
	'			  Issue: #0353 Centre name now included in order confirmation.		
	'			  Issue: #0315 (ongoing) compiler warnings removed. 	
	' Amendee...: D Morris 
	' Details...: Mod: pHandleOrderResponse() B4i code calls confirm order twice - plus B4i code.
	'			  Mod: pHandleOrderResponse() Includes centre name in order confirmation message.
	'			  Mod: DIALOG_BTN_PROCEED commented out.
	'
	' Date......: 26/04/20
	' Release...: 13
	' Overview..: Bug #0186: Problem moving accounts support for new customerId (with embedded rev). 
	' Amendee...: D Morris
	' Details...: Mod: btnOrder_Click() handles customerId correctly.	
	'			  Mod: pHandleOrderResponse().
	'
	' Date......: 09/05/20
	' Release...: 14
	' Overview..: Bugfix: 0401 - No progress dialog order between order ackn message and displaying payment options. 
	' Amendee...: D Morris.
	' Details...:  Added: HandleOrderAcknResponse() and QueryPayment() moved from hTaskSelect.
	'				 Mod: pHandleOrderResponse() - starts progress dialog.
	'			   Added: pnlHideOrder support to hide order details.
	'
	' Date......: 11/05/20
	' Release...: 15
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Added: OnClose().
	'				 Mod: Old commented code removed.
	' 
	' Date......: 20/05/20
	' Release...: 16
	' Overview..: Bugfix: #0414 - Order payment rejected, no returning to Task Select.    		   
	' Amendee...: D Morris
	' Details...:  Mod: pHandleOrderResponse() code fixed.
	'
	' Date......: 11/06/20
	' Release...: 17
	' Overview..: Bugfix: #0423 On timeout when Server sending response to payment message.
	' Amendee...: D Morris.
	' Details...: Added: progressbox_Timeout() - to handle timeout event.
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
	Private xui As XUI			'ignore
		
	Private notification As clsNotifications	' Handles notifications
		
	' Local constants
	Private const TABLE_NUMBER_MAX_LEN As Int = 3 ' The table number text field's contents can be up to this maximum length.

	' Activity view declarations
	Private btnMessage As B4XView ' The button which allows the user to add/edit the order message.
	Private btnOrder As B4XView ' The button which submits the order to the Server.
	Private lblOrderTotal As B4XView ' The label which displays the total price of the order.
	
#if B4A
	Private lvwOrderItems As CustomListView' The listview which contains all the items current on the order.
#else ' B4I
	Private btnHideKeyboard As Button	' Button to used to Submit the table number.
	Private lvwOrderItems As CustomListView ' The listview which contains all the items current on the order.
	Private swcCollectDeliver As Switch ' The swtich used to control whether the order will be collected or delivered.
	Private lblCollectCaption As Label ' The label used as a caption for the 'Collect from counter' delivery option.
	Private lblDeliverCaption As Label ' The label used as a caption for the 'Deliver to table' delivery option.
	Private lblTableNumberCaption As Label ' label used as a caption for table number entry.
#End If
#if B4A
	Private optCollect As B4XView ' The radiobutton which signifies the order should be collected by the customer when ready.
	Private optTable As B4XView ' The radiobutton which signifies the order will be delivered to the customer's table when ready.
#end if

	Private pnlHideOrder As B4XView	' Panel to hide order details.
	Private txtTableNumber As B4XView ' The text field used to enter the customer's table number.
#if B4I
	Private txtMessage As TextView ' The multiline text view displayed on the text input dialog, used for the orderr message.
#End If
	
	' Misc objects
	Private progressbox As clsProgressDialog	' Progress box
	
	' Local variables
	Private mLocalOrderTotal As Float ' The total price of the order.
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


#if B4I
' Added to support done button on numerical keyboard.
'  see https://www.b4x.com/android/forum/threads/input-accessory-views.51000/#content
Sub btnHideKeyboard_Click
	xPlaceOrder.HideKeyboard
End Sub
#end if

' Handles the Click event of the Order Message button.
Private Sub btnMessage_Click
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
	lHandleMessageButton
End Sub

' Handles the Click event of the Submit Order button.
Private Sub btnOrder_Click
	' Check if the entered order details are OK
	Dim errorMsg As String = ""
	If Starter.customerorderInfo.orderList.Size < 1 Then
		errorMsg = errorMsg & "there are no items in your order"
	End If
	If txtTableNumber.Text.Trim = "" Then
		If errorMsg <> "" Then 
			errorMsg = errorMsg & " and "
		End If
		errorMsg = errorMsg & "no table number has been entered"
	End If
	
	' Send the order command, or display error message, as appropriate
	If errorMsg = "" Then ' Order details are OK, no errors detected
		Starter.customerOrderInfo.customerNumber = Starter.myData.customer.customerId
		Starter.customerOrderInfo.tableNumber = txtTableNumber.Text.Trim ' Belt-and-braces
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
		CallSub2(Starter, "pSendMessageAndCheckReconnect", msg )
#else ' B4I
		Main.SendMessageAndCheckReconnect(msg)
#End If
	Else ' Errors have been detected with the entered order details
		xui.MsgboxAsync("Unable to submit your order because " & errorMsg & ".", "Invalid Order")
	End If
End Sub

#if B4I
' Handles the Click event of the dynamically-created Done keyboard accessory button.
Private Sub btnTextboxDone_Click
	txtMessage.ResignFocus ' Hide the keyboard
End Sub
#End If

#if B4I
' Clicks on screen off keyboard so hide the keyboard.
Sub lblCollectCaption_Click
	xPlaceOrder.HideKeyboard
End Sub

'' Clicks on screen off keyboard so hide the keyboard.
'Sub lblCollectOnly_Click
'	xPlaceOrder.HideKeyboard
'End Sub

' Clicks on screen off keyboard so hide the keyboard.
Sub lblDeliverCaption_Click
	xPlaceOrder.HideKeyboard
End Sub

' Clicks on screen off keyboard so hide the keyboard.
Private Sub lblTableNumberCaption_Click
	xPlaceOrder.HideKeyboard
End Sub
#End If

' Handles the ItemClick event of the Order Items listview.
Private Sub lvwOrderItems_ItemClick(Value As Object, position As Int)
	Dim itemSelect As Int = position
#if B4A
	If itemSelect < lvwOrderItems.Size Then	' Edit Items?
	'	CallSubDelayed2(aSelectItem, "pEditItem", position) ' Edit item in order table
		CallSubDelayed2(aSelectItem, "pEditItem", itemSelect - 1) ' Edit item in order table
	Else ' Add new item
		CallSubDelayed(aSelectItem, "pStartSelectItem")
	End If
#else ' B4I
	xPlaceOrder.HideKeyboard
	xPlaceOrder.ClrPageTitle()	' fixes page title operation.
	xSelectItem.Show
	If itemSelect < lvwOrderItems.Size Then
		xSelectItem.EditItem(itemSelect - 1) ' Edit item in order table
	Else ' Selected item is the last in the list - the 'add an item' placeholder
		xSelectItem.StartSelectItem ' Select a new item
	End If
#End If
End Sub

#if B4A
' Handles the CheckedChanged event of the Table radiobutton.
' NOTE: This event appears not to trigger when the radiobutton is unchecked?
Private Sub optCollect_CheckedChange(Checked As Boolean)
	Starter.customerOrderInfo.deliverToTable = False
End Sub
#else ' B4I
' Handles the ValueChanged event of the Collect or Deliver switch.
Private Sub swcCollectDeliver_ValueChanged(Value As Boolean)
	xPlaceOrder.HideKeyboard
	Starter.CustomerOrderInfo.deliverToTable = Value
End Sub
#End If

#if B4A
' Handles the CheckedChanged event of the Table radiobutton.
' NOTE: This event appears not to trigger when the radiobutton is unchecked?
Private Sub optTable_CheckedChange(Checked As Boolean)
	Starter.customerOrderInfo.deliverToTable = True
End Sub
#End If

' Progress dialog has timed out
Private Sub progressbox_Timeout
	'TODO need some code to deail with this problem!
	xui.MsgboxAsync("No response", "Checking Account")
	Wait for msgbox_result (result As Int)
#if B4A
	StartActivity(aTaskSelect)
#else 'B4i
	xPlaceOrder.ClrPageTitle()	' fixes page title operation.
	xTaskSelect.Show
#End If
End Sub

' Handles the EnterPressed event of the Table Number edittext view.
Private Sub txtTableNumber_EnterPressed
	Dim enteredTableNo As String = txtTableNumber.Text.Trim
	If enteredTableNo <> "" And enteredTableNo <> 0 Then
		Starter.customerOrderInfo.tableNumber = enteredTableNo
	Else
		xui.MsgboxAsync("You must enter a table number.", "Table Number Required")
		txtTableNumber.RequestFocus ' Re-select the textbox
	End If
End Sub

' Handles the TextChanged event of the Table Number edittext view.
' Uses https://www.b4x.com/android/forum/threads/edittext-max-characters-limit.23409/ to limit the length of input
Private Sub txtTableNumber_TextChanged(strOld As String, strNew As String)
	If strNew.Length > TABLE_NUMBER_MAX_LEN Then
		txtTableNumber.Text = strNew.substring2(0, (TABLE_NUMBER_MAX_LEN ) ) ' This code don't work correctly 
		' looks like some problem with buffering - Community suggests using
	Else If IsNumber(strNew) And strNew <> "" And strNew <> "0" Then
#if B4I
		btnHideKeyboard.text = "Submit"
#end if		
		Starter.customerOrderInfo.tableNumber = strNew
	Else
#if B4I
		btnHideKeyboard.text =  "Enter table number"
#end if
	End If
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' Handles the Cancel Order operation (i.e. back button).
Public Sub CancelOrder
	lClearOrder ' Clear the database's order information
#if B4A
	StartActivity(aTaskSelect)
#else ' B4I
'	mClosingForm = True
	xPlaceOrder.ClrPageTitle()	' fixes page title operation.
	xTaskSelect.show
#End If
End Sub

' Handles the Order Acknowledgement response from the Server by displaying a messagebox with relevant text.
Public Sub HandleOrderAcknResponse(orderAcknResponseStr As String)
	ProgressHide ' Always hide the progress dialog
#if B4A
	Dim xmlStr As String = orderAcknResponseStr.SubString(modEposApp.EPOS_ORDER_ACKN.Length)
#else ' B4I
	Dim xmlStr As String = Main.TrimToXmlOnly(orderAcknResponseStr)
#End If
	Dim responseObj As clsEposOrderStatus : responseObj.Initialize
	responseObj = responseObj.XmlDeserialize(xmlStr)
	
	Dim msg As String = "Your order is " & _
			 modConvert.ConvertStatusToUserString(responseObj.status, responseObj.deliverToTable) ' Generic message, just in case
	If responseObj.status = modConvert.statusWaiting Then ' Order is progressing as normal
		Dim queueStr As String = " " & modConvert.ConvertNumberToOrdinalString(responseObj.queuePosition)
		If responseObj.queuePosition < 1 Then queueStr = ""
		msg = "Your order is being processed, and is" & queueStr & " in the queue."
		xui.Msgbox2Async(msg, "Order Status", "OK", "", "", Null)
		Wait For MsgBox_Result(Result As Int)
#if B4A
		StartActivity(aTaskSelect)	
#else 'B4i
		xPlaceOrder.ClrPageTitle()	' fixes page title operation.
		xTaskSelect.Show
#End If
	Else If responseObj.status = modConvert.statusWaitingForPayment Then ' Payment required before order is processed
		wait for (QueryPayment(responseObj.amount)) complete(Result1 As Boolean)
	End If
#if B4A
'	StartActivity(aTaskSelect)	'WARNING Causes problems with paying for an order.
#else 'B4i
	xPlaceOrder.ClrPageTitle()	' fixes page title operation.
'	xTaskSelect.Show
#End If
End Sub

' Handles the response from the Server to the Order message.
Public Sub pHandleOrderResponse(orderResponseStr As String)
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
			If Result = xui.DialogResponse_Positive Then
				ProgressShow("Processing your selection...")
				Dim localOrderObj As clsOrderTableRec : localOrderObj.Initialize
				localOrderObj.customerId = responseObj.customerId
				localOrderObj.orderId = responseObj.orderId			
				Dim msg As String = modEposApp.EPOS_ORDER_ACKN & localOrderObj.XmlSerialize(localOrderObj)
				Log(msg)
#if B4A
				CallSub2(Starter, "pSendMessage",  msg)
				' DM 27/5/18 & 19/09/18 - This is not ideal as the order may not be accepted by the server - need to investigate.
				CallSub2(srvPhoneTotal, "pAdjustPhoneTotal", Starter.latestOrderTotal)
#Else ' B4I
				Main.SendMessage( msg)
				' DM 27/5/18 & 19/09/18 - This is not ideal as the order may not be accepted by the server - need to investigate.
				svcPhoneTotal.AdjustPhoneTotal(Main.LatestOrderTotal)
#End If
				lClearOrder ' Important to do this as it updates the Starter service's database
#if B4A
	'			StartActivity(aTaskSelect)
#else 'B4i
		'		ProgressShow("Submitting your order...") ' Ok code - may still be necessary for slow connections.
				xPlaceOrder.ClrPageTitle()	' fixes page title operation.
	'			xTaskSelect.Show
#End If
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
#if B4A
				StartActivity(aTaskSelect)
#else 'B4i
				xPlaceOrder.ClrPageTitle()	' fixes page title operation.
				xTaskSelect.Show
#End If				
			End If
		End If
	End If
	If showErrorMsg Then 
		xui.Msgbox2Async(msgStr, "Unable to Submit Order", "OK", "", "", Null)
	End If
End Sub

' Will perform any cleanup operation when the form is closed (disappears).
public Sub OnClose
	If progressbox.IsInitialized = True Then	' Ensures the progress timer is stopped.
		progressbox.Hide
	End If
End Sub

' Query and implement payment operation
Public Sub QueryPayment(amount As Float)As ResumableSub
	Dim msg As String = "Payment is required before your order can be processed." & CRLF & "How do you want to pay?"
	pnlHideOrder.Visible = True
	btnOrder.Visible = False 	'TODO Not sure why these buttons show thro panel?
	btnMessage.Visible = False
	Dim exitToTaskSelect As Boolean = False 'HACK to deal with problem with blank form.
		If Starter.myData.centre.acceptCards Then ' Cards accepted
	#if B4A
		xui.Msgbox2Async(msg, "Payment Options", "Default" & CRLF & " Card", "Cash", "Another" & CRLF & " Card", Null)
	#else ' B4i - don't support CRLF in button text.
		xui.Msgbox2Async(msg, "Payment Options", "Default Card", "Cash", "Another Card", Null)
	#end if
		Wait For MsgBox_Result(Result As Int)
		If Result = xui.DialogResponse_Positive Then ' Default Card?
#if B4A
			CallSubDelayed3(aCardEntry, "CardEntryAndPayment", amount, True)
#else ' b4i
			xCardEntry.CardEntryAndPayment(amount, True)
#end if
		else if Result = xui.DialogResponse_Cancel Then ' Cash?
			msg = "Please go to the counter to pay."
			xui.Msgbox2Async(msg, "Cash Payment", "OK", "", "", Null)
			Wait For MsgBox_Result(Result2 As Int)
			exitToTaskSelect = True 'HACK to deal with problem with blank form.
		Else ' Another Card?
#if B4A
			CallSubDelayed3(aCardEntry, "CardEntryAndPayment", amount, False)
#else ' B4i
			xCardEntry.CardEntryAndPayment(amount, False)
#end if
		End If
	Else ' Cards not accepted - must go to the counter
		msg = "Payment is required before your order can be processed." & CRLF & "Please go to the counter."
		xui.Msgbox2Async(msg, "Order Status", "OK", "", "", Null)
		Wait For MsgBox_Result(Result3 As Int)
	End If

	pnlHideOrder.Visible = False
	btnOrder.Visible = True 	'TODO Not sure why these buttons show thro panel?
	btnMessage.Visible = True
	If exitToTaskSelect Then 'HACK to deal with problem with blank form.
#if B4A
		StartActivity(aTaskSelect)
#else 'B4i
		xPlaceOrder.ClrPageTitle()	' fixes page title operation.
		xTaskSelect.Show
#End If		
	End If
	Return True
End Sub

' Performs the resume operation.
public Sub ResumeOp
	lSetupViews
	lShowOrderList
	lHandleMessageButton
End Sub

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
' Add to support a done button on numerical keyboard.
' see https://www.b4x.com/android/forum/threads/input-accessory-views.51000/#content
Sub AddViewToKeyboard(TextField1 As TextField, View1 As View)
	Dim no As NativeObject = TextField1
	no.SetField("inputAccessoryView", View1)
End Sub

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
Private Sub lClearOrder
	Starter.customerOrderInfo.orderList.Clear
	Starter.customerOrderInfo.orderMessage = ""
	lShowOrderList
	lHandleMessageButton
End Sub

' Initialize the locals etc.
private Sub InitializeLocals
	progressbox.Initialize(Me, "progressbox", modEposApp.DFT_PROGRESS_TIMEOUT)
#if B4A
	lSetupViews
#else ' B4I
	Dim greyColour As Int = Colors.RGB(169, 169, 169)
	btnHideKeyboard.Initialize("btnHideKeyboard", btnHideKeyboard.STYLE_SYSTEM)
	btnHideKeyboard.CustomLabel.Font = Font.CreateNew(25)
	btnHideKeyboard.Text = "Enter table number"
	btnHideKeyboard.Width = 100
	btnHideKeyboard.Height = 50
	btnHideKeyboard.Color = greyColour
	btnHideKeyboard.SetBorder(1, Colors.Black, 3)
	AddViewToKeyboard(txtTableNumber, btnHideKeyboard)
#End If
	notification.Initialize
	
End Sub

' Displays the relevant text on the Message button.
Private Sub lHandleMessageButton
	If Starter.customerOrderInfo.orderMessage <> "" Then
		btnMessage.Text = "Edit your message"
	Else ' No message currently saved
		btnMessage.Text = "Add a message" & CRLF & "to your order"
	End If
End Sub

' Show the process box
Private Sub ProgressHide
	progressbox.Hide
End Sub

' Hide The process box.
Private Sub ProgressShow(message As String)
	progressbox.Show(message)
End Sub

' Updates the radiobuttons and table number textbox based on the Starter service's table number database value.
Private Sub lSetupViews
	' Set the table number as necessary
	Dim tableNumber As String = Starter.customerOrderInfo.tableNumber
	If tableNumber = "0" Then 
		tableNumber = ""
	End If
	txtTableNumber.Text = tableNumber
	' Display the collect/deliver radiobuttons (or the collection-only caption), and set them as necessary
	Dim allowDeliver As Boolean = Starter.myData.centre.allowDeliverToTable	
#if B4A
	optTable.Enabled = allowDeliver
	If Starter.customerOrderInfo.deliverToTable Then ' Get the previous selection
		optTable.Checked = True
	Else
		optCollect.Checked = True
	End If
#else ' B4I
	swcCollectDeliver.Visible = allowDeliver
	swcCollectDeliver.Value = False
	If allowDeliver Then
		swcCollectDeliver.Value = Starter.CustomerOrderInfo.deliverToTable
	End If
#End If
	' Display the custom message button as necessary
	btnMessage.Visible = Not(Starter.myData.centre.disableCustomMessage)
End Sub

' Shows the current list of order items in the Order Items listview.
Private Sub lShowOrderList
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
	lvwOrderItems.AddTextItem("+ Press here to add an item", i)
#if B4A
	' https://www.b4x.com/android/forum/threads/customlistview-scrolltoitem-problem.90996/
	Sleep(0)	' Suggested by Erel.
	lvwOrderItems.ScrollToItem(i - 1)
#else
	Sleep(0)	' (for iOS this fixs the problme of vanishing "+ Press here to add an item" when anchors used.
	If i > 1 Then ' Don't work like B4A it does help to improve (need to ask the Community). 
		lvwOrderItems.ScrollToItem(i - 1)	' TODO B4I promblems don't work like the B4A version.
	End If
#end if

'#End If
	lblOrderTotal.Text = "Order Total: £" & modEposApp.FormatCurrency(orderTotal)
	mLocalOrderTotal = orderTotal
End Sub

#End Region  Local Subroutines