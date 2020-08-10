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
	' Release...: 1
	' Date......: 22/10/19
	'
	' History
	' Date......: 22/10/19
	' Release...: 1
	' Created by: D Morris (started 20/10/19)
	' Details...: Based on ShowOrder_v27 and IOS frmMakeOrder_v5.
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
		
	' Local constants
	Private const TABLE_NUMBER_MAX_LEN As Int = 3 ' The table number text field's contents can be up to this maximum length.
	Private Const DIALOG_BTN_PROCEED As String = "Proceed" ' The text displyed on the Proceed button of the Confirm Order dialog.

	' Activity view declarations
	Private btnCancel As B4XView ' The button which cancels the order and closes the activity.
	Private btnClear As B4XView ' The button which clears all items from the order list.
	Private btnMessage As B4XView ' The button which allows the user to add/edit the order message.
	Private btnOrder As B4XView ' The button which submits the order to the Server.
	Private lblCollectOnly As B4XView ' The caption which explains that collecting their order is the only delivery option.
	Private lblOrderTotal As B4XView ' The label which displays the total price of the order.
#if B4A
	Private lvwOrderItems As ListView ' The listview which contains all the items current on the order.
#else ' B4I
	Private lvwOrderItems As usrListView ' The listview which contains all the items current on the order.
	Private swcCollectDeliver As Switch ' The swtich used to control whether the order will be collected or delivered.
	Private lblCollectCaption As Label ' The label used as a caption for the 'Collect from counter' delivery option.
	Private lblDeliverCaption As Label ' The label used as a caption for the 'Deliver to table' delivery option.
#End If
	Private optCollect As B4XView ' The radiobutton which signifies the order should be collected by the customer when ready.
	Private optTable As B4XView ' The radiobutton which signifies the order will be delivered to the customer's table when ready.

'	Private txtTableNumber As B4XView ' The text field used to enter the customer's table number.
	Private txtTableNumber As TextView
#if B4I
	Private txtMessage As TextView ' The multiline text view displayed on the text input dialog, used for the orderr message.
#End If
	
	' Misc objects
	Private progressbox As clsProgressDialog	' Progress box
	
	' Local variables
	Private mLocalOrderTotal As Float ' The total price of the order.
	Private mClosingActivity As Boolean ' Whether the activity should be closed the next time it is paused.
	
	Private mClosingForm As Boolean ' Whether the form should be closed the next time it is paused.
	Private mConfirmationObject As clsEposCustomerOrderResponse ' Object which stores the Server's response to the Send Order command.
	
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (parent As B4XView)
	parent.LoadLayout("frmPlaceOrder")
	InitializeLocals
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Handles the Click event of the Cancel Order button.
Private Sub btnCancel_Click
	lClearOrder ' Clear the database's order information
#if B4A
	' Activity.Finish ' Will return to the Task Select activity
	StartActivity(aTaskSelect)
#else ' B4I
	mClosingForm = True
	xTaskSelect.show
#End If

End Sub

' Handles the Click event of the Clear Items button.
Private Sub btnClear_Click
	lClearOrder ' Clear the database's order information
#if B4I
	lShowOrderList
	lHandleMessageButton
#End If
End Sub

#if B4I
' Added to support done button on numerical keyboard.
'  see https://www.b4x.com/android/forum/threads/input-accessory-views.51000/#content
Sub btnHideKeyboard_Click
' This needs to be moved to the activity code.
'	mPage.ResignFocus
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
		Starter.customerOrderInfo.orderMessage = textInputDialog.Input.Trim
	End If
#else ' B4I
	' The custom dialog is taken from here: https://www.b4x.com/android/forum/threads/custom-dialogs-with-icustomdialog-library.83526/
	Dim dialogPanel As Panel : dialogPanel.Initialize("pnlTextEntryDialog")
'	dialogPanel.SetLayoutAnimated(0, 1, 0, 0, mPage.RootPanel.Width - 50dip, 150dip)
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
	If Result = dialog.RESULT_POSITIVE Then	Starter.CustomerOrderInfo.orderMessage = txtMessage.Text.Trim
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
		If errorMsg <> "" Then errorMsg = errorMsg & " and "
		errorMsg = errorMsg & "no table number has been entered"
	End If
	
	' Send the order command, or display error message, as appropriate
	If errorMsg = "" Then ' Order details are OK, no errors detected
		Starter.customerOrderInfo.customerNumber = Starter.myData.customer.customerIdStr
		Starter.customerOrderInfo.tableNumber = txtTableNumber.Text.Trim ' Belt-and-braces
		Dim xmlOrder As String = Starter.customerOrderInfo.XmlSerialize
#if B4A
		Starter.latestOrderTotal = mLocalOrderTotal
		ProgressShow("Verifying the details of your order, please wait...")
#else ' B4I
		Main.latestOrderTotal = mLocalOrderTotal
		ProgressShow("Verifying your order...")
#End If
#if B4A
		CallSub2(Starter, "pSendMessageAndCheckReconnect", modEposApp.EPOS_ORDER_SEND & xmlOrder)
#else ' B4I
		Main.SendMessageAndCheckReconnect(modEposApp.EPOS_ORDER_SEND & xmlOrder)
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

' Handles the Click event of the dynamically-created Done numerical keyboard accessory button.
Private Sub btnNumPadDone_Click
	txtTableNumber.ResignFocus ' Hide the keyboard
End Sub
#End If

' Handles the ItemClick event of the Order Items listview.
#if B4A
Private Sub lvwOrderItems_ItemClick(position As Int, value As Object)
#else ' B4I
Private Sub lvwOrderItems_ItemClick(Value As Object, position As Int)
#End If
	Dim itemSelect As Int = position + 1
#if B4A
	If itemSelect < lvwOrderItems.Size Then	' Edit Items?
		CallSubDelayed2(aSelectItem, "pEditItem", position) ' Edit item in order table
	Else ' Add new item
		CallSubDelayed(aSelectItem, "pStartSelectItem")
	End If
#else ' B4I
	xSelectItem.Show
	If itemSelect < lvwOrderItems.Count Then
		xSelectItem.EditItem(position) ' Edit item in order table
	Else ' Selected item is the last in the list - the 'add an item' placeholder
		xSelectItem.StartSelectItem ' Select a new item
	End If
#End If
End Sub

#if B4I
' Asynchronously handles a button being pressed on the 'Order Verified message box invoked in HandleOrderResponse()
Private Sub orderSuccessMsg_Click(ButtonText As String)
	If ButtonText = DIALOG_BTN_PROCEED Then
		Dim localOrderObj As clsOrderTableRec : localOrderObj.Initialize
		localOrderObj.customerId = mConfirmationObject.customerId
		localOrderObj.orderId = mConfirmationObject.orderId
		Dim xmlOrder As String = localOrderObj.XmlSerialize(localOrderObj)
		Log(xmlOrder)
		Main.SendMessage(modEposApp.EPOS_ORDER_ACKN & xmlOrder)
		' DM 27/5/18 & 19/09/18 - This is not ideal as the order may not be accepted by the server - need to investigate.
		svcPhoneTotal.AdjustPhoneTotal(Main.LatestOrderTotal)
		lClearOrder ' Important to do this as it updates the Main's database
		mClosingForm = True ' Kill the activity when the message box closes due to the below instruction
		ProgressShow("Submitting your order...")
		xTaskSelect.Show
	End If
End Sub
#End If

#if B4A
' Handles the CheckedChanged event of the Table radiobutton.
' NOTE: This event appears not to trigger when the radiobutton is unchecked?
Private Sub optCollect_CheckedChange(Checked As Boolean)
	Starter.customerOrderInfo.deliverToTable = False
End Sub
#else ' B4I
' Handles the ValueChanged event of the Collect or Deliver switch.
Private Sub swcCollectDeliver_ValueChanged(Value As Boolean)
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

' Handles the EnterPressed event of the Table Number edittext view.
Private Sub txtTableNumber_EnterPressed
	Dim enteredTableNo As String = txtTableNumber.Text.Trim
	If enteredTableNo <> "" And enteredTableNo <> 0 Then
		Starter.customerOrderInfo.tableNumber = enteredTableNo
#if B4I
	' XUI don't appear to support .ResignFocus.
	'	txtTableNumber.ResignFocus ' For some reason, it appears necessary to manually tell the keyboard to hide
#End If
	Else
		xui.MsgboxAsync("You must enter a table number.", "Table Number Required")
		txtTableNumber.RequestFocus ' Re-select the textbox
	End If
End Sub

' Handles the TextChanged event of the Table Number edittext view.
' Uses https://www.b4x.com/android/forum/threads/edittext-max-characters-limit.23409/ to limit the length of input
Private Sub txtTableNumber_TextChanged(strOld As String, strNew As String)
	If strNew.Length > TABLE_NUMBER_MAX_LEN Then
		txtTableNumber.Text = strOld
'TODO This statement is not supported by B4XView.
'		txtTableNumber.SelectionStart = txtTableNumber.Text.Length
	Else If IsNumber(strNew) And strNew <> "" And strNew <> "0" Then
		Starter.customerOrderInfo.tableNumber = strNew
	End If
End Sub
#End Region  Event Handlers

#Region  Public Subroutines
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
			xui.Msgbox2Async("Your order has been successfully verified. Please press 'Proceed' to confirm your order.", _
							"Order Verified", "Proceed", "Cancel", "", Null)
			Wait For MsgBox_Result(Result As Int)
			If Result = xui.DialogResponse_Positive Then
#if B4A
				Dim localOrderObj As clsOrderTableRec : localOrderObj.Initialize
				localOrderObj.customerId = responseObj.customerId
				localOrderObj.orderId = responseObj.orderId
				Dim xmlOrder As String = localOrderObj.XmlSerialize(localOrderObj)
				Log(xmlOrder)
				CallSub2(Starter, "pSendMessage", modEposApp.EPOS_ORDER_ACKN & xmlOrder)
				' DM 27/5/18 & 19/09/18 - This is not ideal as the order may not be accepted by the server - need to investigate.
				CallSub2(srvPhoneTotal, "pAdjustPhoneTotal", Starter.latestOrderTotal)
				lClearOrder ' Important to do this as it updates the Starter service's database
				mClosingActivity = True ' Kill the activity when it closes due to the below instruction
				CallSubDelayed2(aTaskSelect, "pProgressDialogShow", "Submitting your order, please wait...")
#else ' B4I
				showErrorMsg = False
				' TODO - does the user really need to manually acknowledge this? Instead it could be sent automatically
				Msgbox2("orderSuccessMsg", "Your order has been successfully verified. Please press 'Proceed' to confirm your order.", _
						"Order Verified", Array(DIALOG_BTN_PROCEED, "Cancel"))
				' See the orderSuccessMsg_Click() handler for continuation, as the user's response is required
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
			End If
		End If
	End If
	If showErrorMsg Then 
		xui.Msgbox2Async(msgStr, "Unable to Submit Order", "OK", "", "", Null)
	End If
End Sub

' Performs the resume operation.
public Sub ResumeOp
	lSetupViews
	lShowOrderList
	lHandleMessageButton
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
'	pnlButton.AddView(btnTextboxNext, (mPage.RootPanel.Width - 80), 0, 80, pnlButton.Height)
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
	' Ensure the listview always displays black text, at the correct size
	lvwOrderItems.SingleLineLayout.Label.Width = 999999dip ' Set this to be absurdly wide, as a HACK to prevent text wraparound
	lvwOrderItems.TwoLinesLayout.Label.Width = 999999dip ' See above
	lvwOrderItems.TwoLinesLayout.SecondLabel.Width = 999999dip ' See above
	lvwOrderItems.SingleLineLayout.Label.TextColor = Colors.Black
	lvwOrderItems.TwoLinesLayout.Label.TextColor = Colors.Black
	lvwOrderItems.TwoLinesLayout.SecondLabel.TextColor = Colors.Black
	lvwOrderItems.SingleLineLayout.Label.TextSize = lvwOrderItems.TwoLinesLayout.Label.TextSize
	
	lSetupViews
#else ' B4I


	mClosingForm = False

'	' Code to implement DONE button on numerical keyboard. see
''	https://www.b4x.com/android/forum/threads/input-accessory-views.51000/#content
''	tf.Initialize("tf")
''	mPage.RootPanel.AddView(tf, 0, 0, 200, 100)

	Dim btnHideKeyboard As Button
	btnHideKeyboard.Initialize("btnHideKeyboard", btnHideKeyboard.STYLE_SYSTEM)
	btnHideKeyboard.Text = "V Hide keyboard V"
	btnHideKeyboard.Width = 100
	btnHideKeyboard.Height = 50
	btnHideKeyboard.SetBorder(2, Colors.Blue, 3)
	btnHideKeyboard.SizeToFit
'	AddViewToKeyboard(tf, b)
	AddViewToKeyboard(txtTableNumber, btnHideKeyboard)
	
'	Dim orangeColour As Int = Colors.RGB(230, 100, 15)
'	Dim greyColour As Int = Colors.RGB(169, 169, 169)
'
'	'Create transparent panel (Or otherwise the buttons will fill the whole width of the screen)
'	Dim pnlButton As Panel : pnlButton.Initialize("")
'	pnlButton.Color = Colors.Transparent
'	pnlButton.Height = 35
'	
'	'Create the Done button And add it To the panel
'	Dim btnTextboxNext As Button : btnTextboxNext.InitializeCustom("btnNumPadDone", Colors.Black, orangeColour)
'	btnTextboxNext.Width = 100
'	btnTextboxNext.Height = 50
'	btnTextboxNext.Color = greyColour
'	btnTextboxNext.SetBorder(0, greyColour, 3) ' To make the corners rounded
'	btnTextboxNext.Text = "Done"
'''	pnlButton.AddView(btnTextboxNext, (mPage.RootPanel.Width - 80), 0, 80, pnlButton.Height)
'	pnlButton.AddView(btnTextboxNext, (xPlaceOrder.GetRootPanelWidth() - 80), 0, 80, pnlButton.Height)
'	AddViewToKeyboard(txtTableNumber, btnTextboxNext)
'	' Attach the panel bearing the buttons to the specified textbox's keyboard
'	'Dim textboxNativeObj As NativeObject = attachedTextBox
'	Dim textboxNativeObj As NativeObject = txtTableNumber
'	textboxNativeObj.SetField("inputAccessoryView", pnlButton)
#End If

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
	If tableNumber = "0" Then tableNumber = ""
	txtTableNumber.Text = tableNumber
	
	' Display the collect/deliver radiobuttons (or the collection-only caption), and set them as necessary
#if B4A
	Dim allowDeliver As Boolean = Starter.customerOrderInfo.allowDeliverToTable
	lblCollectOnly.Visible = Not(allowDeliver)
	optCollect.Visible = allowDeliver
	optTable.Visible = allowDeliver
	Dim checkedRadioButton As RadioButton = optCollect
	If Starter.customerOrderInfo.deliverToTable Then checkedRadioButton = optTable ' Get the previous selection
	checkedRadioButton.Checked = True ' Make the appropriate radiobutton checked (will un-check the other)
	If Not(allowDeliver) Then 
		optCollect.Checked = True ' Belt-and-braces
	End If
#else ' B4I
	' Display the collect/deliver radiobuttons (or the collection-only caption), and set them as necessary
	Dim deliverAllowed As Boolean = Starter.CustomerOrderInfo.allowDeliverToTable
	lblCollectCaption.Visible = deliverAllowed
	lblCollectOnly.Visible = Not(deliverAllowed)
	lblDeliverCaption.Visible = deliverAllowed
	swcCollectDeliver.Visible = deliverAllowed
	swcCollectDeliver.Value = False
	If deliverAllowed Then swcCollectDeliver.Value = Starter.CustomerOrderInfo.deliverToTable
#End If
	' Display the custom message button as necessary
	btnMessage.Visible = Not(Starter.customerOrderInfo.disableCustomMessage)
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
#if B4A
		lvwOrderItems.AddTwoLines(topLine, bottomLine)
#Else ' B4I
		lvwOrderItems.AddItem(topLine, bottomLine, Null)
#End If
		orderTotal = orderTotal + lineTotal
		i = i + 1
	Next
#if B4A
	lvwOrderItems.AddSingleLine("+ Press here to add an item")
#else ' B4I
	lvwOrderItems.AddItem("+ Press here to add an item", "", Null)
#End If
	lblOrderTotal.Text = "Order Total: £" & modEposApp.FormatCurrency(orderTotal)
	mLocalOrderTotal = orderTotal
End Sub


#End Region  Local Subroutines