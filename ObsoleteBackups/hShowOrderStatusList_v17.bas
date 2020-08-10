B4A=true
Group=HelperClasses
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
'
' This is a helper class for Show order status list activity.
'
#Region  Documentation
	'
	' Name......: hShowOrderStatusList
	' Release...: 17
	' Date......: 11/06/20
	'
	' History
	' Date......: 22/10/19
	' Release...: 1
	' Created by: D Morris (started 3/8/19)
	' Details...: based on ShowOrderStatusList_v13.
	'
	' Versions  2 - 7 see v8.
	'			8 - 15 see v15.
	'
	'
	' Date......: 31/05/20
	' Release...: 16
	' Overview..: Bugfix: #0421 - Placing new orders when previous orders cancelled.
	' Amendee...: D Morris
	' Details...:  Added: QueryPayment().
	'				 Mod: pHandleOrderInfo().
	'
	' Date......: 11/06/20
	' Release...: 17
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
	Private xui As XUI							'ignore
	
	Private notification As clsNotifications	' Handles notifications
	
	' Local variables
	Private mPressedOrderStatus As clsEposOrderStatus ' Stores the data of the order that was most recently-clicked in the listview
	
	' Activity view declarations
'	Private btnClose As  B4XView			' The button which closes the form.
#if B4A
	Private lvwOrderSummary As ListView 	' The listview which displays all the customer's orders.
#else ' B4I
	Private lvwOrderSummary As usrListView 
#End If
	
	' Misc objects
	Private progressbox As clsProgressDialog	' Progress box
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (parent As B4XView)
	parent.LoadLayout("frmShowOrderStatusList")
	InitializeLocals
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Handles the Click event of the Close button.
'Private Sub btnClose_Click
''#if B4A
''	StartActivity(aTaskSelect)
''#else ' B4I
''	xTaskSelect.show
'''TODO - the line below is necessary it needs to be added to the form module.
'''	mPage = Null ' Kill the page (as belt-and-braces to prevent it being shown by the 'Back' action)
''#End If
'End Sub

' Handles the ItemClick event of the Order Summary listview.
#if B4A
Private Sub lvwOrderSummary_ItemClick(Position As Int, Value As Object)
#else ' B4I
Private Sub lvwOrderSummary_ItemClick(Value As Object, Index As Int)
#End If
	If Value <> 0 Then ' Only proceed if the order is valid (the return value is set to 0 for items which display error messages)
		Dim statusObj As clsEposOrderStatus = Value
		mPressedOrderStatus = statusObj
		ProgressShow("Getting the order details, please wait...")
		Dim msg As String = modEposApp.EPOS_ORDER_QUERY & _
									"," & modEposWeb.ConvertToString(Starter.myData.customer.customerId) & _
									"," & modEposWeb.ConvertToString(statusObj.orderId)
#if B4A
		CallSub2(Starter, "pSendMessage", msg)
#else ' B4I
		Main.SendMessage(msg)
#End If
	End If
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

' Close the order status list
Public Sub CloseOrderStatusList
#if B4A
	StartActivity(aTaskSelect)
#else ' B4I
	xTaskSelect.show
#End If	
End Sub

' Displays the details of the specified order using a message box.
Public Sub pHandleOrderInfo(orderInfoStr As String)
	Dim totalCost As Float = 0
	' Deserialise the XML string
	ProgressHide
#if B4A
	Dim xmlStr As String = orderInfoStr.SubString(modEposApp.EPOS_ORDER_QUERY.Length) ' TODO - check if the XML string is valid?
#else ' B4I
	Dim xmlStr As String = Main.TrimToXmlOnly(orderInfoStr) ' TODO - check if the XML string is valid?
#End If
	Dim orderInfoObj As clsEposOrderInfo : orderInfoObj.Initialize
	orderInfoObj = orderInfoObj.XmlDeserialize(xmlStr)
	' Assemble the message
	Dim msg As String = "Error reading order details. Please try again."
	Dim title As String = "Order Details Error"
	If orderInfoObj.orderId = mPressedOrderStatus.orderId Then ' Only proceed if the recieved info is for the correct order
		If orderInfoObj.itemList.Size <> 0 Then ' XML string was deserialised OK
			title = "Order " & orderInfoObj.orderId & " Details"
			Dim timestampStr As String = "Order started at " & orderInfoObj.orderStarted
			If orderInfoObj.orderStarted = "00:00:00" Then 
				timestampStr = "Not started (payment required)"
			End If
			Dim queueStr As String = " (" & modConvert.ConvertNumberToOrdinalString(mPressedOrderStatus.queuePosition) & ")"
			If mPressedOrderStatus.queuePosition < 1 Then 
				queueStr = ""
			End If
			Dim deliveryTypeStr As String = "Will be delivered to table " & orderInfoObj.tableNumber & "."
			If orderInfoObj.deliverToTable = False Then deliveryTypeStr = "To be collected when ready."
			msg = timestampStr & "." & CRLF & "Status: " & _
					modConvert.ConvertStatusToUserString(mPressedOrderStatus.status, mPressedOrderStatus.deliverToTable) & _
					queueStr & "." & CRLF & deliveryTypeStr & CRLF & CRLF & "Items in this order:"
			
			For Each item As clsCustomerOrderItemRec In orderInfoObj.itemList
				Dim sizePriceObj As clsSizePriceTableRec = Starter.DataBase.GetSizePriceRec(item.priceId)
				Dim itemName As String = Starter.DataBase.GetGroupAndDescriptionName(sizePriceObj.goodsId)
				Dim itemPrice As Float = Starter.DataBase.GetPriceForSize(sizePriceObj.goodsId, sizePriceObj.size)
				Dim itemPriceStr As String = modEposApp.FormatCurrency(itemPrice)
				msg = msg & CRLF & item.qty & "x " & itemName & " @ £" & itemPriceStr & " each"
				totalCost = totalCost + (itemPrice * item.qty)
			Next
			
			Dim orderPaidStr As String = "This order is currently unpaid."
			If orderInfoObj.paid Then 
				orderPaidStr = "This order has been paid for."
			End If
			Dim orderMessage As String = CRLF & CRLF & "Your order message: " & orderInfoObj.orderMessage
			If orderInfoObj.orderMessage.Trim = "" Then 
				orderMessage = ""
			End If
			msg = msg & CRLF & CRLF & "Order total: £" & modEposApp.FormatCurrency(totalCost) & CRLF & orderPaidStr & orderMessage
		End If
	End If
	Dim payPrompt As String = "" ' Decide if payment option should be offered.
	If orderInfoObj.paid = False Then
		payPrompt = "Pay order"
	End If
	xui.Msgbox2Async(msg, title, "OK", payPrompt, "", Null )
	Wait For MsgBox_Result(Result As Int)
	If Result = xui.DialogResponse_Cancel Then
		Dim orderPayment As clsOrderPaymentRec: orderPayment.initialize
		orderPayment.amount = totalCost
		orderPayment.orderId = orderInfoObj.orderId
		QueryPayment(orderPayment)
'#if B4A
'		CallSubDelayed2(aPlaceOrder, "QueryPaymentandReturn", totalCost)
'#else 
'		xPlaceOrder.QueryPaymentandReturn(totalCost)
'#end if 
	End If
' Warning using restart activity here appear to switch up operation after an attempt to 
'  pay for an order with caseh?	
'	RestartThisActivity ' appears necessary otherwise it goes back to TaskSelect.
	' new method of restart see https://www.b4x.com/android/forum/threads/restarting-an-activity.106576/
	
'	Log("hShowOrderStatusList.pHandleOrderInfo Call to RestartMe")
'	CallSub(aShowOrderStatusList, "RestartMe")
End Sub

' Populates the listview with each of the orders and their status in the specified XML string.
Public Sub pHandleOrderStatusList(orderStatusStr As String)
	ProgressHide
	' Deserialise the XML string
#if B4A
	Dim xmlStr As String = orderStatusStr.SubString(modEposApp.EPOS_ORDERSTATUSLIST.Length) ' TODO - check if the XML string is valid?
#else ' B4I
	Dim xmlStr As String = Main.TrimToXmlOnly(orderStatusStr) ' TODO - check if the XML string is valid?
#End If
	Dim orderListObj As clsEposOrderStatusList : orderListObj.Initialize
	orderListObj = orderListObj.XmlDeserialize(xmlStr) ' TODO - need to get the deserializer working?
	
	' Add the orders in the list to the listview
	lvwOrderSummary.Clear
	If orderListObj.customerId <> 0 Then ' XML string was deserialised OK
		If orderListObj.order.Size > 0 Then ' List contains orders
			For Each order As clsEposOrderStatus In orderListObj.order
				lAddOrderEntryToListview(order)
			Next
			If orderListObj.overflowFlag Then ' Order list overflowed?
#if B4A
				lvwOrderSummary.AddSingleLine2("More orders....", 0)
#else ' B4I
				lvwOrderSummary.AddItem("More orders....", "", 0)
#End If
			End If
		Else ' No orders found in order list
#if B4A
			lvwOrderSummary.AddSingleLine2("No active orders found", 0)
#else ' B4I
			lvwOrderSummary.AddItem("No active orders found", "", 0)
#End If
		End If
	Else ' XML failed to deserialise properly
#if B4A
		lvwOrderSummary.AddTwoLines2("Error reading order list", "Please retry", 0)
#else ' B4I
		lvwOrderSummary.AddItem("Error reading order list", "Please retry", 0)
#End If
	End If
End Sub

' Performs any clean up activities when activity closes
Public Sub OnClose
	If progressbox.IsInitialized = True Then	' Ensures the progress timer is stopped.
		progressbox.Hide
	End If
End Sub

'' Refresh displayed order status list.
'Public Sub RefreshList
'	pSendRequestForOrderStatusList
'End Sub

' Sends to the Server the message which requests the customer's order status list.
public Sub pSendRequestForOrderStatusList
'	Log("hShowOrderStatusList.pSendRequestForOrderStatusList")
	lvwOrderSummary.Clear ' Clear down previous displayed information.
	ProgressShow("Getting your order status, please wait...")
	Dim msg As String = modEposApp.EPOS_ORDERSTATUSLIST & modEposWeb.ConvertToString(Starter.myData.customer.customerId)
#if B4A
	CallSub2(Starter, "pSendMessageAndCheckReconnect", msg)
#else ' B4I
	Main.SendMessageAndCheckReconnect(msg)
#End If
End Sub

' Causes the listview to be repopulated so that the specified order's information is updated.
Public Sub pUpdateOrderStatus(statusObj As clsEposOrderStatus)
	Dim currentItems As List : currentItems.Initialize
	Dim needsToRefresh As Boolean = False
	Dim prevWaitingOrderFound As Boolean
	
	' Assemble a list containing all of the items' info, and detect if the whole list needs to be refreshed
#if B4A
	For itemIndex = 0 To (lvwOrderSummary.Size - 1)
#else ' B4I
	For itemIndex = 0 To (lvwOrderSummary.Count - 1)
#End If
		' Detect multiple orders in the list which have the 'waiting' status.
#if B4A
		Dim listviewStatus As  clsEposOrderStatus = lvwOrderSummary.GetItem(itemIndex)
#else ' B4I
		Dim listviewStatus As clsEposOrderStatus = lvwOrderSummary.GetItemAtIndex(itemIndex)
#End If
		If listviewStatus.status = modConvert.statusWaiting Then
			If prevWaitingOrderFound Or Not(listviewStatus.orderId = statusObj.orderId) Then
				needsToRefresh = True
				Exit
			End If
			prevWaitingOrderFound = True
		End If
		
		' Update and add the item to the list as necessary
		If listviewStatus.orderId = statusObj.orderId Then listviewStatus = statusObj
		If listviewStatus.status <> modConvert.statusCollected Then ' Don't add to the list if completed
			currentItems.Add(listviewStatus)
		End If
	Next
	If currentItems.IndexOf(statusObj) = -1 And statusObj.status <> modConvert.statusCollected Then
		currentItems.Add(statusObj)
	End If
	
	' Either send the request for more information or repopulate the listview with modified data, as necessary
	If needsToRefresh Then ' The list needs more data (i.e. queue positions) - send the command
		ProgressShow("Updating the order list, please wait...")
		Dim msg As String = modEposApp.EPOS_ORDERSTATUSLIST & modEposWeb.ConvertToString(Starter.myData.customer.customerId)
#if B4A
		CallSub2(Starter, "pSendMessage", msg)
#else ' B4I
		Main.SendMessage(msg)
#End If
	Else ' Don't need to refresh the whole list - repopulate using existing data
		lvwOrderSummary.Clear
		If currentItems.Size > 0 Then
			For Each listStatus As clsEposOrderStatus In currentItems
				lAddOrderEntryToListview(listStatus )
			Next
		Else ' No orders left in order list
#if B4A
			lvwOrderSummary.AddSingleLine2("No active orders found", 0)
#else ' B4I
			lvwOrderSummary.AddItem("No active orders found", "", 0)
#End If
		End If
	End If
End Sub

' Displays a messagebox containing the most recent Message To Customer text, and makes the notification sound/vibration if specified.
Public Sub ShowMessageNotificationMsgBox(soundAndVibrate As Boolean)
	pSendRequestForOrderStatusList ' Update displayed status list - just in case it changes.
	notification.ShowMessageNotificationMsgBox(soundAndVibrate)
End Sub

' Displays a messagebox containing the most recent Order Status text, and makes the notification sound/vibration if specified.
Public Sub ShowStatusNotificationMsgBox(soundAndVibrate As Boolean)
	pSendRequestForOrderStatusList ' Update displayed status list - just in case it changes.
	notification.ShowStatusNotificationMsgBox(soundAndVibrate)
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines
' Initialize the locals etc.
private Sub InitializeLocals
	progressbox.Initialize(Me, "progressbox", modEposApp.DFT_PROGRESS_TIMEOUT)	
#if B4A
	' DH: The HACK below ensures the listview always displays black text
	lvwOrderSummary.SingleLineLayout.Label.TextColor = Colors.Black
	lvwOrderSummary.TwoLinesLayout.Label.TextColor = Colors.Black
	lvwOrderSummary.TwoLinesLayout.SecondLabel.TextColor = Colors.Black
	' End HACK	
#End If
	notification.Initialize
End Sub

' Adds a two-line item to the listview containing the specified order information. The listview item will be set up so that the
' specified order status object is returned as the Value in e.g. lvwOrderSummary.GetItem() or lvwOrderSummary_ItemClick().
Private Sub lAddOrderEntryToListview(statusObj As clsEposOrderStatus)
	Dim topStr As String = "Order #" & statusObj.orderId
	Dim statusStr As String = modConvert.ConvertStatusToUserString(statusObj.status, statusObj.deliverToTable)
	If statusObj.amount < 0 Then 
		statusStr = "Awaiting Refund"
	End If
	Dim queueStr As String = " (" & modConvert.ConvertNumberToOrdinalString(statusObj.queuePosition) & ")"
	If statusObj.queuePosition < 1 Then 
		queueStr = ""
	End If
	Dim bottomStr As String = "Status: " & statusStr & queueStr
#if B4A
	lvwOrderSummary.AddTwoLines2(topStr, bottomStr, statusObj)
#else ' B4I
	lvwOrderSummary.AddItem(topStr, bottomStr, statusObj)
#End If
End Sub

' Show the process box
Private Sub ProgressHide
	progressbox.Hide
End Sub

' Hide The process box.
Private Sub ProgressShow(message As String)
	progressbox.Show(message)
End Sub

' Query and implement payment operation
' *** Very similar to code in hPlaceOrder.QueryPayment().
Private Sub QueryPayment(orderPayment As clsOrderPaymentRec)As ResumableSub
	Dim msg As String 
'	pnlHideOrder.Visible = True
'	btnOrder.Visible = False 	'TODO Not sure why these buttons show thro panel?
'	btnMessage.Visible = False
	Dim exitToTaskSelect As Boolean = False 'HACK to deal with problem with blank form.
	If Starter.myData.centre.acceptCards Then ' Cards accepted
		msg = "Payment is required before your order can be processed." & CRLF & "How do you want to pay?"
	#if B4A
		xui.Msgbox2Async(msg, "Payment Options", "Default" & CRLF & " Card", "Cash", "Another" & CRLF & " Card", Null)
	#else ' B4i - don't support CRLF in button text.
		xui.Msgbox2Async(msg, "Payment Options", "Default Card", "Cash", "Another Card", Null)
	#end if
		Wait For MsgBox_Result(Result As Int)
		If Result = xui.DialogResponse_Positive Then ' Default Card?
#if B4A
'			CallSubDelayed3(aCardEntry, "CardEntryAndPayment", amount, True)
			CallSubDelayed3(aCardEntry, "CardEntryAndOrderPayment", orderPayment, True)
#else ' b4i
'			xCardEntry.CardEntryAndPayment(amount, True)
			xCardEntry.CardEntryAndOrderPayment(orderPayment, True)
#end if
		else if Result = xui.DialogResponse_Cancel Then ' Cash?
			msg = "Please go to the counter to pay."
			xui.Msgbox2Async(msg, "Cash Payment", "OK", "", "", Null)
			Wait For MsgBox_Result(Result2 As Int)
			exitToTaskSelect = True 'HACK to deal with problem with blank form.
		Else ' Another Card?
#if B4A
'			CallSubDelayed3(aCardEntry, "CardEntryAndPayment", amount, False)
			CallSubDelayed3(aCardEntry, "CardEntryAndOrderPayment", orderPayment, False)
#else ' B4i
'			xCardEntry.CardEntryAndPayment(amount, False)
			xCardEntry.CardEntryAndOrderPayment(orderPayment, False)
#end if
		End If
	Else ' Cards not accepted - must go to the counter
		msg = "Payment is required before your order can be processed." & CRLF & "Please go to the counter."
		xui.Msgbox2Async(msg, "Order Status", "OK", "", "", Null)
		Wait For MsgBox_Result(Result3 As Int)
	End If

'	pnlHideOrder.Visible = False
'	btnOrder.Visible = True 	'TODO Not sure why these buttons show thro panel?
'	btnMessage.Visible = True
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

'' Restarts this acvtivity.
'' See https://www.b4x.com/android/forum/threads/programmatically-restarting-an-app.27544/
'Private Sub RestartThisActivity
'#if B4A
''	OnClose
'	CallSub(aShowOrderStatusList,"RecreateActivity")
'#else ' B4I
'	' xShowOrderStatusList	'TODO need a iOS version.
'#End If
'
'End Sub


#End Region  Local Subroutines