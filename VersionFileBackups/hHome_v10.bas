B4A=true
Group=HelperClasses
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
'
' This is a helper class centre home activity.
'
#Region  Documentation
	'
	' Name......: hHome
	' Release...: 10
	' Date......: 26/11/20
	'
	' History
	' Date......: 08/08/20
	' Release...: 1
	' Created by: D Morris 
	' Details...: based on hShowOrderStatusList_v19 and hTaskSelect_v28.
	' 
	' Date......: 11/08/20
	' Release...: 2
	' Overview..: Revised how controls are inhibited.
	' Amendee...: D Morris.
	' Details...: Mod: controls now inhibited/enabled when Show/HideProgress() called.
	'
	' Date......: 28/09/20
	' Release...: 3
	' Overview..: Bugfix: #0498 - Problem with switching centres.
	' Amendee...: D Morris
	' Details...:  Added: RefreshPage() code moved from LocalInitailize().
	'		         Mod: LocalInitialize() code moved to RefreshPage().
	'		
	' Date......: 02/10/20
	' Release...: 4
	' Overview..: Bugfix: #0500 - Validate Centre screen not showing picture after communication timeout.
	' Amendee...: D Morris
	' Details...: Mod: progressbox_Timeout() support for Starter selectedCentreLocationRec.
	'			
	' Date......: 15/10/20
	' Release...: 5
	' Overview..: Bugfix: #0523 - Showing "Order #0" on manually entered orders.
	'			  Bugfix: #0525 - Crashing when "No Active Orders" clicked.
	' Amendee...: D Morris
	' Details...: Mod: pUpdateOrderStatus() code fixes (not sure why Android version worked!) 
	'			  Mod: pUpdateOrderStatus() code modified so it don't request the status list.
	'			  Bugfix: pHandleOrderStatusList() - invalidItem not initialized!	
	'			  Bugfix: pUpdateOrderStatus() - null object in "No active orders".	
	'
	' Date......: 02/11/20
	' Release...: 6
	' Overview..: Bugfix: (iOS) #0534 Order status list missing updates.
	' Amendee...: D Morris.
	' Details...: Mod: (for iOS) - timer to update the order status list periodically.
	'
	' Date......: 08/11/20
	' Release...: 7
	' Overview..:  Issue #0499 Fix progress circles truncation. 
	'			   Issue: #0544 Slow screen rebuild after refresh.
	' Amendee...: D Morris
	' Details...: Mod: 	pSendRequestForOrderStatusList() - Clear list command removed.
	'			  Issue #0521 Refresh icon touch area increased.
	'             Mod: pnlShowDialog rename to pnlLoadingTouch.
	'			
	' Date......: 16/11/20
	' Release...: 8
	' Overview..: ListViews changed to CustomListViews.
	'             Bugfix: #0535 Display order information - status and position incorrect.
	'			   Issue: #0553 Android Tablet Home screen order list too small.
	'			  Bugfix: #0535 Order information (Status and queue position incorrect). 
	' Overview..: ListViews changed to CustomListViews.
	' Amendee...: D Morris
	' Details...:  Mode: B4A ListView changed to CustomListView (and associated code).
	'				Mod: B4A Order list backgroud change to grey (as the iOS).
	'             Bugfix: (#0535) - pHandleOrderInfo() status and position removed. And report reworded.
	'		
	' Date......: 20/11/20
	' Release...: 9
	' Overview..: Issue: #0451 Replace "Default Card" with "Saved Card".
	' Amendee...: D Morris
	' Details...: Mod: QueryPayment() shown text fixed.
	'		
	' Date......: 26/11/20
	' Release...: 10
	' Overview..: Bugfix: #0466 Android phone restart after screen locked. 
	'			   Issue: #0561 Viewing website information.
	'			   Issue: #0564 Home screen flashing when drawing (fixed in Place order screen). 
	'             Bugfix: #0566 Home screen not displaying size in order information.
	' Amendee...: D Morris
	' Details...: Mod: btnLeaveCentre_Click() clears centreId from centre information. 
	'			  Mod: pHandleOrderInfo() - code fixed to include the size in order information.
	'			  
	'			
	' Date......: 
	' Release...: 
	' Overview..:
	' Amendee...: 
	' Details...: 
	'  	'			 
#End Region  Documentation

#Region  Mandatory Subroutines & Data

Sub Class_Globals
	' X-platform related.
	Private xui As XUI									'ignore
	
	' Local variables
	Private displayUpdateInProgress As Boolean			' Indicates updating the displayed order status list is in-progress.
	Private mPressedOrderStatus As clsEposOrderStatus 	' Stores the data of the order that was most recently-clicked in the listview
	Private enableViews As Boolean						' When set views (controls) are enabled.
	
	' Local constants
	Private Const DEFAULT_TIME_STAMP As Int = 1
#if B4I
	Private DFT_UPDATE_ORDERSTATUS As Int = 20000		' Default for initialise the tmrUpdateOrderStatus (msecs).
#End If	
	' Activity view declarations
	Private btnLeaveCentre As SwiftButton				' Leave centre
	Private btnPlaceOrder As SwiftButton				' Place order button.
	Private imgCentrePicture As B4XView					' Holder for the center's picture
	Private imgSuperorder As B4XView 					' SuperOrder header icon.
	Private indLoading As B4XLoadingIndicator			' Loading indicator
	Private lblBackButton As B4XView					' Back button
	Private lblCentreName As B4XView					' Centre name	
	Private lblShowOrder As Label						' Instruction to show order information.
	Private pnlHeader As B4XView						' Header panel.
	Private lvwOrderSummary As CustomListView			' The listview which displays all the customer's orders.
	Private pnlLoadingTouch As B4XView					' Clickable show loading circle display progress dialog.
	
	' Misc objects
	Private notification As clsNotifications			' Handles notifications	
	Private progressbox As clsProgress					' Progress indicator and box
#if B4I
	Private tmrUpdateOrderStatus As Timer				' Timer to handle updating the order status.
#End If
	Private pnlRefreshTouch As B4XView
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (parent As B4XView)
	parent.LoadLayout("frmHome") ' Currently same form name for both B4A and B4i.
#if B4i
	Starter.lastPageShown = "xHome"	
#End If
	InitializeLocals
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Handles the Leave Centre button.
Private Sub btnLeaveCentre_Click
	If enableViews = True Then
		xui.Msgbox2Async("Are you sure?", "Leaving this centre", "Yes", "", "No", Null)
		Wait For msgbox_result(result As Int)
		If result = xui.DialogResponse_Positive Then
			ExitBackTSelectPlayCentre
'			Starter.myData.centre.signedOn = False ' log off centre.
'			Starter.myData.centre.centreId = 0 	' This clears the centre information to it is not used after returning from Background
'			Dim msg As String = modEposApp.EPOS_DISCONNECT & modEposWeb.ConvertToString(Starter.myData.customer.customerId)
'#if B4A
'			CallSubDelayed2(Starter, "pSendMessage", msg )
'			StartActivity(aSelectPlayCentre3)
'#else 'B4I
'			Main.SendMessage(msg)
'			frmXSelectPlayCentre3.Show				
'#end if		
		End If
	End If
End Sub

' Handles the Click event of the Place Order button.
Private Sub btnPlaceOrder_Click
	If enableViews = True Then
		' Clear old order data (in case e.g. the Make Order form's 'Back' nav-button was previously used, avoiding the order being cleared)
		Starter.customerOrderInfo.orderList.Clear
		Starter.customerOrderInfo.orderMessage = ""
		lStartPlaceOrder	
	End If
End Sub

' Handle back button
private Sub lblBackButton_Click
	If enableViews = True Then
		LeaveCentre		
	End If
End Sub

' Handles Show more order information i.e. clicking on an order summary list.
Private Sub lvwOrderSummary_ItemClick(Position As Int, Value As Object)
	If enableViews = True Then
		Dim statusObj As clsEposOrderStatus = Value
		If statusObj.status <> modConvert.statusUnknown And statusObj.orderId <> 0 Then			
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
	End If
End Sub

' Click on progress circles to show the dialog progress box.
' This is always enabled.
Private Sub pnlLoadingTouch_Click
	progressbox.ShowDialog
End Sub

' Touch area for the refesh operation
Private Sub pnlRefreshTouch_Click
	If enableViews = True Then
		pSendRequestForOrderStatusList
	End If
End Sub

' Progress dialog has timed out
Private Sub progressbox_Timeout()
	ViewControl(True)
#if B4A
	CallSubDelayed2(ValidateCentreSelection2, "ValidateSelection", Starter.selectedCentreLocationRec)
#else ' B4I
	frmXValidateCentreSelection2.Show(Starter.selectedCentreLocationRec)
#end if
End Sub

#if B4I
Private Sub tmrUpdateOrderStatus_Tick()
	tmrUpdateOrderStatus.Enabled = False
	If IsVisible Then
		pSendRequestForOrderStatusList		
	End If
End Sub
#End If

#End Region  Event Handlers

#Region  Public Subroutines

' Displays the details of the specified order using a message box.
Public Sub pHandleOrderInfo(orderInfoStr As String)
	Dim totalCost As Float = 0
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
			Dim timestampStr As String = "Order placed at " & orderInfoObj.orderStarted
			If orderInfoObj.orderStarted = "00:00:00" Then
				timestampStr = "Payment required!"
			End If
			Dim deliveryTypeStr As String = "Will be delivered to table " & orderInfoObj.tableNumber & "."
			If orderInfoObj.deliverToTable = False Then 
				deliveryTypeStr = "To be collected when ready."
			End If
			msg = timestampStr & CRLF & deliveryTypeStr & CRLF & CRLF & "Items in this order:"
			For Each item As clsCustomerOrderItemRec In orderInfoObj.itemList
				Dim sizePriceObj As clsSizePriceTableRec = Starter.DataBase.GetSizePriceRec(item.priceId)
				Dim itemName As String = Starter.DataBase.GetGroupAndDescriptionName(sizePriceObj.goodsId)
				Dim itemPrice As Float = Starter.DataBase.GetPriceForSize(sizePriceObj.goodsId, sizePriceObj.size)
				Dim itemPriceStr As String = modEposApp.FormatCurrency(itemPrice)
				Dim itemSize As String = Starter.DataBase.GetSizeTextForSizePriceValue(item.priceId)
				msg = msg & CRLF & item.qty & "x " & itemSize & ": " & itemName & " @ £" & itemPriceStr & " each"
				totalCost = totalCost + (itemPrice * item.qty)
			Next		
			Dim orderPaidStr As String = "This order is currently unpaid."
			If orderInfoObj.paid Then
				orderPaidStr = "This order has been paid for."
			End If
			Dim orderMessage As String = ""
			If orderInfoObj.orderMessage.Trim <> "" Then
				orderMessage =  CRLF & CRLF & "Your order message: " & orderInfoObj.orderMessage
			End If
			msg = msg & CRLF & CRLF & "Order total: £" & modEposApp.FormatCurrency(totalCost) & _ 
							CRLF & orderPaidStr & orderMessage
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
	End If
End Sub

' Handles the Order Start reponse from the Server by displaying a relevant messagebox and then starting the Show Order activity.
Public Sub HandleOrderStart(orderStartStr As String)
	ProgressHide ' Always hide the progress dialog
#if B4A
	Dim xmlStr As String = orderStartStr.SubString(modEposApp.EPOS_ORDER_START.Length) ' TODO - check if the XML string is valid?
#else ' B4I
	Dim xmlStr As String = Main.TrimToXmlOnly(orderStartStr) ' TODO - check if the XML string is valid?
#end if
	Dim responseObj As clsOrderStartResponse : responseObj.Initialize
	responseObj = responseObj.XmlDeserialize(xmlStr)' TODO - need to check if the deserialisation was successful?
	If responseObj.accept Then ' OK to go ahead with order - display any instruction message if required
		If responseObj.message <> "" Then
			xui.MsgboxAsync(responseObj.message, "Order instructions")
			Wait For MsgBox_Result(Result As Int)
		End If
		Starter.myData.centre.allowDeliverToTable = responseObj.allowDeliverToTable
		Starter.myData.centre.disableCustomMessage = responseObj.disableCustomMessage
#if B4A
		StartActivity(aPlaceOrder)
#else ' B4I
		xPlaceOrder.Show
#end if
	Else ' Not allowed to place an order - display the reason why
		xui.MsgboxAsync("Reason: " & responseObj.message, "Order cannot be placed")
		wait for MsgBox_Result(Result As Int)
	End If
End Sub

' Populates the listview with each of the orders and their status in the specified XML string.
Public Sub pHandleOrderStatusList(orderStatusStr As String)
#if B4A
	Dim xmlStr As String = orderStatusStr.SubString(modEposApp.EPOS_ORDERSTATUSLIST.Length) ' TODO - check if the XML string is valid?
#else ' B4I
	Dim xmlStr As String = Main.TrimToXmlOnly(orderStatusStr) ' TODO - check if the XML string is valid?
#End If
	Dim orderListObj As clsEposOrderStatusList : orderListObj.Initialize
	orderListObj = orderListObj.XmlDeserialize(xmlStr) ' TODO - need to get the deserializer working?
	If Not(displayUpdateInProgress) Then
		displayUpdateInProgress = True
		Dim invalidItem As clsEposOrderStatus : invalidItem.Initialize	' Used to mark end of list or invalid item.
		invalidItem.status = modConvert.statusUnknown

		lvwOrderSummary.Clear
		If orderListObj.customerId <> 0 Then ' XML string was deserialised OK
			If orderListObj.order.Size > 0 Then ' List contains orders
				For Each order As clsEposOrderStatus In orderListObj.order
					lAddOrderEntryToListview(order)
				Next
				If orderListObj.overflowFlag Then ' Order list overflowed?
					lvwOrderSummary.AddTextItem("More orders....", invalidItem)
				End If
			Else ' No orders found in order list
				lvwOrderSummary.AddTextItem("No active orders found", invalidItem)
			End If
		Else ' XML failed to deserialise properly
			lvwOrderSummary.AddTextItem("Error reading order list" & CRLF & "Please retry", invalidItem)
		End If
		displayUpdateInProgress = False
	End If
	ProgressHide
#if B4i
	tmrUpdateOrderStatus.Enabled = False
	tmrUpdateOrderStatus.Enabled = True 	' Restart the update timer.
#End If
End Sub

' Handles customer request to leave the Centre.
Public Sub LeaveCentre
	xui.Msgbox2Async("Are you sure?", "Leaving this centre", "Yes", "", "No", Null)
	Wait For msgbox_result(result As Int)
	If result = xui.DialogResponse_Positive Then
'		OnClose
'		Starter.myData.centre.signedOn = False ' log off centre.
'		Dim msg As String = modEposApp.EPOS_DISCONNECT & modEposWeb.ConvertToString(Starter.myData.customer.customerId)
'#if B4A
'		CallSubDelayed2(Starter, "pSendMessage", msg )
'		StartActivity(aSelectPlayCentre3)
'#else 'B4I
'		Main.SendMessage(msg)
'		frmXSelectPlayCentre3.Show				
'#end if
	ExitBackTSelectPlayCentre
	End If
End Sub

' Performs any clean up activities when activity closes
Public Sub OnClose
	If progressbox.IsInitialized = True Then	' Ensures the progress timer is stopped.
		progressbox.Hide
	End If
#if B4I
	tmrUpdateOrderStatus.Enabled = False
#End If
End Sub

' Refreshes the page with new centre information.
'  This method should be called each time a new centre is select.
' Note: When user clicks on Notification message (when the phone is locked) this sub is called
' 	via aHome.Activity_Resume() - it will check if valid centre information vailable and continue 
'  	or return to the select play centre as appropriate (See Bugfix #0466). 
Public Sub RefreshPage()
	If Starter.myData.centre.centreId <> 0 Then ' Valid centre information?
		Dim bt As Bitmap = Starter.myData.centre.pictureBitMap
		imgCentrePicture.SetBitmap(bt.Resize(imgCentrePicture.Width, imgCentrePicture.Height, True))
		lblCentreName.Text = Starter.myData.centre.name
		pSendRequestForOrderStatusList
	Else ' Not valid centre information.
		ExitBackTSelectPlayCentre	
	End If
End Sub

' Sends to the Server the message which requests the customer's order status list.
public Sub pSendRequestForOrderStatusList
	' lvwOrderSummary.Clear ' Clear down previous displayed information.
	ProgressShow("Getting your order status, please wait...")
	Dim msg As String = modEposApp.EPOS_ORDERSTATUSLIST & modEposWeb.ConvertToString(Starter.myData.customer.customerId)
#if B4A
	CallSub2(Starter, "pSendMessageAndCheckReconnect", msg)
#else ' B4I
	Main.SendMessageAndCheckReconnect(msg)
#End If
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

' Causes the listview to be repopulated so that the specified order's information is updated.
Public Sub pUpdateOrderStatus(statusObj As clsEposOrderStatus)
	Dim currentItems As List : currentItems.Initialize
	If Not(displayUpdateInProgress) Then
		displayUpdateInProgress = True
		' Assemble a list containing all of the items' info, and detect if the whole list needs to be refreshed
		For itemIndex = 0 To (lvwOrderSummary.Size - 1)
			' Detect multiple orders in the list which have the 'waiting' status.
			Dim listviewStatus As  clsEposOrderStatus = lvwOrderSummary.GetValue(itemIndex)
			' Update and add the item to the list as necessary
			If listviewStatus.orderId = statusObj.orderId Then
				listviewStatus = statusObj
			End If
			If listviewStatus.status <> modConvert.statusCollected _
			And listviewStatus.status <> modConvert.statusUnknown Then ' Don't add to the list if completed or unknown.
				currentItems.Add(listviewStatus)
			End If
		Next
		' If item not already added to list - add it!
		If currentItems.IndexOf(statusObj) = -1 And statusObj.status <> modConvert.statusCollected Then
			currentItems.Add(statusObj)
		End If
		lvwOrderSummary.Clear
		If currentItems.Size > 0 Then
			For Each listStatus As clsEposOrderStatus In currentItems
				lAddOrderEntryToListview(listStatus )
			Next
		Else ' No orders left in order list
			Dim invalidItem As clsEposOrderStatus : invalidItem.Initialize	' Used to mark end of list or invalid item.
			invalidItem.status = modConvert.statusUnknown
			lvwOrderSummary.AddTextItem("No active orders found", invalidItem)
		End If
		displayUpdateInProgress = False
	End If
#if B4i
	tmrUpdateOrderStatus.Enabled = False
	tmrUpdateOrderStatus.Enabled = True 	' Restart the update timer.
#End If
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Adds a order item to the listview.
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
	lvwOrderSummary.AddTextItem(topStr & CRLF & bottomStr, statusObj)
End Sub

' Checks if connected to centre.
' handleProgress - true handle progress otherwise no progress
private Sub CheckConnection(handleProgress As Boolean) As ResumableSub
	' Setup up variables, and ensure the relevant service is running
	Dim centreConnectedOk As Boolean = False
	If handleProgress = True Then
		ProgressShow("Checking connection...")		
	End If
	' Detect if any problems with the connection to the centre.
#if B4A
	Wait For (Starter.connect.IsInternetAvailable) complete (internetAvailable As Boolean)
#else ' B4I
	Wait For (Main.connect.IsInternetAvailable) complete (internetAvailable As Boolean)
#End If
	If internetAvailable Then
		Wait For (IsCentreOpen(Starter.myData.centre.centreId)) complete(centreOpen As Boolean)
		If centreOpen Then
			centreConnectedOk = True
		Else
			xui.MsgboxAsync("This centre is closed or cannot take orders, ask a member of staff.", "Centre problem" )
			Wait For Msgbox_Result (Result As Int)
#if B4A 
			StartActivity(CheckAccountStatus)
#else ' B4I
			frmCheckAccountStatus.Show(True)
#End If						
		End If
	Else
		ReportNoInternet
	End If
	If handleProgress = True Then
		ProgressHide		
	End If
	Return centreConnectedOk
End Sub

' Exit back to Select Play Centre screen.
Private Sub ExitBackTSelectPlayCentre
	Starter.myData.centre.signedOn = False ' log off centre.
	Starter.myData.centre.centreId = 0 	' This clears the centre information to it is not used after returning from Background
	Dim msg As String = modEposApp.EPOS_DISCONNECT & modEposWeb.ConvertToString(Starter.myData.customer.customerId)
#if B4A
	CallSubDelayed2(Starter, "pSendMessage", msg )
	StartActivity(aSelectPlayCentre3)
#else 'B4I
	Main.SendMessage(msg)
	frmXSelectPlayCentre3.Show				
#end if
End Sub

' Initialize the locals etc.
private Sub InitializeLocals
	indLoading.mBase.Visible = False
	progressbox.Initialize(Me, "progressbox", modEposApp.DFT_PROGRESS_TIMEOUT, indLoading)
#if B4A
	' DH: The HACK below ensures the listview always displays black text
'	lvwOrderSummary.SingleLineLayout.Label.TextColor = Colors.Black
'	lvwOrderSummary.SingleLineLayout.Label.TextSize = 16
'	lvwOrderSummary.TwoLinesLayout.Label.TextColor = Colors.Black
'	lvwOrderSummary.TwoLinesLayout.Label.TextSize = 14
'	lvwOrderSummary.TwoLinesLayout.SecondLabel.TextColor = Colors.Black
'	lvwOrderSummary.TwoLinesLayout.SecondLabel.TextSize = 14
	' End HACK
#End If
	notification.Initialize
#if B4I
	tmrUpdateOrderStatus.Initialize("tmrUpdateOrderStatus", DFT_UPDATE_ORDERSTATUS)
	tmrUpdateOrderStatus.Enabled = True
#End If
	Dim bt As Bitmap = imgSuperorder.GetBitmap
	imgSuperorder.SetBitmap(bt.Resize(imgSuperorder.Width, imgSuperorder.Height, True))
	imgSuperorder.Top = (pnlHeader.Height - imgSuperorder.Height) / 2   ' Centre SuperOrder vertically.
End Sub

' Checks if a centre is open
private Sub IsCentreOpen(centreId As Int) As ResumableSub
	Dim centreOpen As Boolean = False
	Dim job As HttpJob : job.Initialize("CheckCentreAPI", Me)
	Dim apiString As String = Starter.server.URL_CENTRE_API & "/" & centreId & _
							 "?" & modEposWeb.API_QUERY & "=" & modEposWeb.API_OPEN_QUERY 'search=open"
	job.Download(apiString  )
	Wait For (job) JobDone(job As HttpJob)
	If job.Success And job.Response.StatusCode = 200 Then
		Dim rxMsg As String = job.GetString
		Log("Success received from the Web API – response: " & rxMsg)
		If IsNumber(rxMsg) Then
			Dim statusValue As Int = rxMsg
			If statusValue = 1 Then
				centreOpen = True
			End If
		End If
	End If
	job.Release ' Must always be called after the job is complete, to free its resources
	Return centreOpen
End Sub

' Is this form shown
private Sub IsVisible As Boolean
#if B4A
	Return (CallSub(aHome, "IsVisible"))
#else ' B4i
	Return xHome.IsVisible
#End If
End Sub

' Show the process box
Private Sub ProgressHide
	ViewControl(True)
	lblShowOrder.Visible = True
	progressbox.Hide
End Sub

' Hide The process box.
Private Sub ProgressShow(message As String)
	ViewControl(False)
	lblShowOrder.Visible = False
	progressbox.Show(message)
End Sub

' Query and implement payment operation
' *** Very similar to code in hPlaceOrder.QueryPayment().
Private Sub QueryPayment(orderPayment As clsOrderPaymentRec)As ResumableSub
	Dim msg As String
	If Starter.myData.centre.acceptCards Then ' Cards accepted
		msg = "Payment is required before your order can be processed." & CRLF & "How do you want to pay?"
	#if B4A
		xui.Msgbox2Async(msg, "Payment Options", "Saved" & CRLF & " Card", "Cash", "Another" & CRLF & " Card", Null)
	#else ' B4i - don't support CRLF in button text.
		xui.Msgbox2Async(msg, "Payment Options", "Saved Card", "Cash", "Another Card", Null)
	#end if
		Wait For MsgBox_Result(Result As Int)
		If Result = xui.DialogResponse_Positive Then ' Default Card?
#if B4A
			CallSubDelayed3(aCardEntry, "CardEntryAndOrderPayment", orderPayment, True)
#else ' b4i
			xCardEntry.CardEntryAndOrderPayment(orderPayment, True)
#end if
		else if Result = xui.DialogResponse_Cancel Then ' Cash?
			msg = "Please go to the counter to pay."
			xui.Msgbox2Async(msg, "Cash Payment", "OK", "", "", Null)
			Wait For MsgBox_Result(Result2 As Int)
		Else ' Another Card?
#if B4A
			CallSubDelayed3(aCardEntry, "CardEntryAndOrderPayment", orderPayment, False)
#else ' B4i
			xCardEntry.CardEntryAndOrderPayment(orderPayment, False)
#end if
		End If
	Else ' Cards not accepted - must go to the counter
		msg = "Payment is required before your order can be processed." & CRLF & "Please go to the counter."
		xui.Msgbox2Async(msg, "Order Status", "OK", "", "", Null)
		Wait For MsgBox_Result(Result3 As Int)
	End If
	Return True
End Sub

' Report no internet detected.
Private Sub ReportNoInternet
	xui.MsgboxAsync("Unable to continue without a working Internet connection.", "No Internet!" )
End Sub

' Starts the order placing procedure. .
Private Sub lStartPlaceOrder()
	ProgressShow("Starting your order, please wait...") 
	Wait For (CheckConnection(False)) complete(centreConnectionOk As Boolean)
	If centreConnectionOk Then
		Dim apiHelper As clsEposApiHelper
		apiHelper.Initialize
		Wait for (apiHelper.CheckMenuRevision) complete (menuOk As Boolean)
		If menuOk Then ' Menu ok
			Dim msgToSend As String = modEposApp.EPOS_ORDER_START & "," & Starter.myData.Customer.customerId & _
									"," & DEFAULT_TIME_STAMP & "," & Starter.customerOrderInfo.tableNumber	
			' Taken from https://www.b4x.com/android/forum/threads/solved-resumable-subs-and-callbacks.103775/
#if B4A
			Dim SendMsg As ResumableSub = CallSub2(Starter, "pSendMessageAndCheckReconnect", msgToSend)
#else ' B4I
			Dim SendMsg As ResumableSub = Main.SendMessageAndCheckReconnect(msgToSend)
#End If
			Wait For (SendMsg) Complete(statusCodeResult As Int)
		Else ' Menu error = resync data.
			xui.MsgboxAsync("Your will need to resync your menu with the Centre.", "Menu out of date!" )
			Wait For Msgbox_Result (Result As Int)
#if B4A
			CallSubDelayed(aSyncDatabase, "pSyncDataBase")
#Else
			xSyncDatabase.show
#End If			
		End If
	End If
End Sub

' Enable/disable views
' pEnableView = true view operation enabled.
Private Sub ViewControl( pEnableViews As Boolean)
	enableViews = pEnableViews
End Sub
#End Region  Local Subroutines
