B4A=true
Group=HelperClasses
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@

'
' This is a help class for Make Order
'
#Region  Documentation
	'
	' Name......: hMakeOrder
	' Release...: -
	' Date......: 20/10/19
	'
	' History
	' Date......: 20/10/19
	' Release...: -
	' Created by: D Morris (started 20/10/19)
	' Details...: Based on ShowOrder_v27
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
	
	' Activity view declarations

	' Activity view declarations
	Private btnCancel As B4XView ' The button which cancels the order and closes the activity.
	Private btnClear As B4XView ' The button which clears all items from the order list.
	Private btnMessage As B4XView ' The button which allows the user to add/edit the order message.
	Private btnOrder As B4XView ' The button which submits the order to the Server.
	Private lblCollectOnly As B4XView ' The caption which explains that collecting their order is the only delivery option.
	Private lblOrderTotal As B4XView ' The label which displays the total price of the order.
	Private lvwOrderItems As ListView ' The listview which contains all the items current on the order.
	Private optCollect As B4XView ' The radiobutton which signifies the order should be collected by the customer when ready.
	Private optTable As B4XView ' The radiobutton which signifies the order will be delivered to the customer's table when ready.
	Private txtTableNumber As B4XView ' The text field used to enter the customer's table number.
	
	' Misc objects
	Private progressbox As clsProgressDialog	' Progress box
	
	' Local variables
	Private mLocalOrderTotal As Float ' The total price of the order.
	Private mClosingActivity As Boolean ' Whether the activity should be closed the next time it is paused.
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (parent As B4XView)
	parent.LoadLayout("frmShowOrder")
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
	xTaskSelect.show
#End If

End Sub

' Handles the Click event of the Clear Items button.
Private Sub btnClear_Click
	lClearOrder ' Clear the database's order information
End Sub

' Handles the Click event of the Order Message button.
Private Sub btnMessage_Click
	Dim textInputDialog As InputDialog
	textInputDialog.Input = Starter.customerOrderInfo.orderMessage
	Dim asyncDialog As Object = textInputDialog.ShowAsync("", "Enter your message here:", "Accept", "", "Cancel", Null, True)
	Wait For (asyncDialog) Dialog_Result(result As Int)
	If result = DialogResponse.POSITIVE Then 
		Starter.customerOrderInfo.orderMessage = textInputDialog.Input.Trim
	End If
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
		Starter.latestOrderTotal = mLocalOrderTotal
		ProgressDialogShow("Verifying the details of your order, please wait...")
		CallSub2(Starter, "pSendMessageAndCheckReconnect", modEposApp.EPOS_ORDER_SEND & xmlOrder)
	Else ' Errors have been detected with the entered order details
		MsgboxAsync("Unable to submit your order because " & errorMsg & ".", "Invalid Order")
	End If
End Sub

' Handles the ItemClick event of the Order Items listview.
Private Sub lvwOrderItems_ItemClick(position As Int, value As Object)
	Dim itemSelect As Int = position + 1
	If itemSelect < lvwOrderItems.Size Then	' Edit Items?
		CallSubDelayed2(SelectItem, "pEditItem", position) ' Edit item in order table
	Else ' Add new item
		CallSubDelayed(SelectItem, "pStartSelectItem")
	End If
End Sub

' Handles the CheckedChanged event of the Table radiobutton.
' NOTE: This event appears not to trigger when the radiobutton is unchecked?
Private Sub optCollect_CheckedChange(Checked As Boolean)
	Starter.customerOrderInfo.deliverToTable = False
End Sub

' Handles the CheckedChanged event of the Table radiobutton.
' NOTE: This event appears not to trigger when the radiobutton is unchecked?
Private Sub optTable_CheckedChange(Checked As Boolean)
	Starter.customerOrderInfo.deliverToTable = True
End Sub

' Handles the EnterPressed event of the Table Number edittext view.
Private Sub txtTableNumber_EnterPressed
	Dim enteredTableNo As String = txtTableNumber.Text.Trim
	If enteredTableNo <> "" And enteredTableNo <> 0 Then
		Starter.customerOrderInfo.tableNumber = enteredTableNo
	Else
		MsgboxAsync("You must enter a table number.", "Table Number Required")
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
	ProgressDialogHide ' Always hide the progress dialog at this point
	Dim xmlStr As String = orderResponseStr.SubString(modEposApp.EPOS_ORDER_SEND.Length)
	Dim responseObj As clsEposCustomerOrderResponse : responseObj.Initialize
	responseObj.DeserialiseXml(xmlStr)
	
	Dim showErrorMsg As Boolean = True
	Dim msgStr As String = "An error occurred while trying to verify your order. Please try again."
	If responseObj.customerId > 0 Then ' Validate that the deserialisation was successful
		If responseObj.accept Then
			showErrorMsg = False
			' TODO - does the user really need to manually acknowledge this? Instead it could be sent automatically
			Msgbox2Async("Your order has been successfully verified. Please press 'Proceed' to confirm your order.", _
							"Order Verified", "Proceed", "Cancel", "", Null, False)
			Wait For MsgBox_Result(Result As Int)
			If Result = DialogResponse.POSITIVE Then
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
	
	If showErrorMsg Then Msgbox2Async(msgStr, "Unable to Submit Order", "OK", "", "", Null, False)
End Sub
' Performs the resume operation.
public Sub ResumeOp
	lSetupViews
	lShowOrderList
	lHandleMessageButton
End Sub
#End Region  Public Subroutines

#Region  Local Subroutines

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
		
	' Ensure the listview always displays black text, at the correct size
	lvwOrderItems.SingleLineLayout.Label.Width = 999999dip ' Set this to be absurdly wide, as a HACK to prevent text wraparound
	lvwOrderItems.TwoLinesLayout.Label.Width = 999999dip ' See above
	lvwOrderItems.TwoLinesLayout.SecondLabel.Width = 999999dip ' See above
	lvwOrderItems.SingleLineLayout.Label.TextColor = Colors.Black
	lvwOrderItems.TwoLinesLayout.Label.TextColor = Colors.Black
	lvwOrderItems.TwoLinesLayout.SecondLabel.TextColor = Colors.Black
	lvwOrderItems.SingleLineLayout.Label.TextSize = lvwOrderItems.TwoLinesLayout.Label.TextSize
	
	lSetupViews
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
	Dim allowDeliver As Boolean = Starter.customerOrderInfo.allowDeliverToTable
	lblCollectOnly.Visible = Not(allowDeliver)
	optCollect.Visible = allowDeliver
	optTable.Visible = allowDeliver
	Dim checkedRadioButton As RadioButton = optCollect
	If Starter.customerOrderInfo.deliverToTable Then checkedRadioButton = optTable ' Get the previous selection
	checkedRadioButton.Checked = True ' Make the appropriate radiobutton checked (will un-check the other)
	If Not(allowDeliver) Then optCollect.Checked = True ' Belt-and-braces
	
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
		lvwOrderItems.AddTwoLines(topLine, bottomLine)
		orderTotal = orderTotal + lineTotal
		i = i + 1
	Next
	
	lvwOrderItems.AddSingleLine("+ Press here to add an item")
	lblOrderTotal.Text = "Order Total: £" & modEposApp.FormatCurrency(orderTotal)
	mLocalOrderTotal = orderTotal
End Sub


#End Region  Local Subroutines