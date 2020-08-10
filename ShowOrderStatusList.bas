B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=7.8
@EndOfDesignText@
'
' This activity is used to display all open orders for a customer.
'

#Region  Documentation
	'
	' Name......: ShowOrderStatusList
	' Release...: 13
	' Date......: 18/10/19
	'
	' History
	'	Versions v1 - v9 see ShowOrderStatusList_v9.
	'
	' Date......: 05/04/18
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
	'
	'
	' Date......: 07/08/19
	' Release...: 10
	' Overview..: Improved status reports and support for myData.
	' Amendee...: D Morris
	' Details...:   Mod: lAddOrderEntryToListview() forDelivery parameter supported.
	'				Mod: support for myData lvwOrderSummary_ItemClick(), pSendRequestForOrderStatusList(), pUpdateOrderStatus().
	'
	' Date......: 14/08/19
	' Release...: 11
	' Overview..: Uses latest modEposApp.
	' Amendee...: D Morris
	' Details...:  Mod: pFormatCurrency to FormatCurrency.
	'
	' Date......: 13/10/19
	' Release...: 12
	' Overview..: Support for sub name changes.
	' Amendee...: D Morris
	' Details...:  Mod: clsEposOrderStatusList.pXmlDeserialize() renamed to XmlDeserialize().
		'
	' Date......: 19/10/19
	' Release...: 13
	' Overview..: Support for X-platform.
	' Amendee...: D Morris
	' Details...: Mod: Rename subs.
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
	#IncludeTitle: False
#End Region  Activity Attributes

#Region  Mandatory Subroutines & Data

Sub Process_Globals
	' Currently none
End Sub

Sub Globals
	
	' Local variables
	Private mPressedOrderStatus As clsEposOrderStatus ' Stores the data of the order that was most recently-clicked in the listview
	
	' Activity view declarations
	Private btnClose As Button ' The button which closes the form.
	Private lvwOrderSummary As ListView ' The listview which displays all the customer's orders.
	
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("frmShowOrderStatusList")
	
	' DH: The HACK below ensures the listview always displays black text
	lvwOrderSummary.SingleLineLayout.Label.TextColor = Colors.Black
	lvwOrderSummary.TwoLinesLayout.Label.TextColor = Colors.Black
	lvwOrderSummary.TwoLinesLayout.SecondLabel.TextColor = Colors.Black
	' End HACK
	
	Activity.Title = "Show Order Status"
End Sub

Sub Activity_Resume
	' Currently nothing
End Sub

Sub Activity_Pause(UserClosed As Boolean)
	If Starter.DisconnectedCloseActivities Then Activity.Finish
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Handles the Click event of the Close button.
Private Sub btnClose_Click
	StartActivity(aTaskSelect)
End Sub

' Handles the ItemClick event of the Order Summary listview.
Private Sub lvwOrderSummary_ItemClick(Position As Int, Value As Object)
	If Value <> 0 Then ' Only proceed if the order is valid (the return value is set to 0 for items which display error messages)
		Dim statusObj As clsEposOrderStatus = Value
		mPressedOrderStatus = statusObj
		ProgressDialogShow("Getting the order details, please wait...")
		Dim infoToSend As String =  "," & Starter.myData.customer.customerIdStr & "," & statusObj.orderId
		CallSub2(Starter, "pSendMessage", modEposApp.EPOS_ORDER_QUERY & infoToSend)
	End If
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' Displays the details of the specified order using a message box.
Public Sub pHandleOrderInfo(orderInfoStr As String)
	' Deserialise the XML string
	ProgressDialogHide
	Dim xmlStr As String = orderInfoStr.SubString(modEposApp.EPOS_ORDER_QUERY.Length) ' TODO - check if the XML string is valid?
	Dim orderInfoObj As clsEposOrderInfo : orderInfoObj.Initialize
	orderInfoObj = orderInfoObj.XmlDeserialize(xmlStr)
	
	' Assemble the message
	Dim msg As String = "Error reading order details. Please try again."
	Dim title As String = "Order Details Error"
	If orderInfoObj.orderId = mPressedOrderStatus.orderId Then ' Only proceed if the recieved info is for the correct order
		If orderInfoObj.itemList.Size <> 0 Then ' XML string was deserialised OK
			title = "Order " & orderInfoObj.orderId & " Details"
			Dim timestampStr As String = "Order started at " & orderInfoObj.orderStarted
			If orderInfoObj.orderStarted = "00:00:00" Then timestampStr = "Not started (payment required)"
			Dim queueStr As String = " (" & modConvert.ConvertNumberToOrdinalString(mPressedOrderStatus.queuePosition) & ")"
			If mPressedOrderStatus.queuePosition < 1 Then queueStr = ""
			Dim deliveryTypeStr As String = "Will be delivered to table " & orderInfoObj.tableNumber & "."
			If orderInfoObj.deliverToTable = False Then deliveryTypeStr = "To be collected when ready."
			msg = timestampStr & "." & CRLF & "Status: " & _ 
					modConvert.ConvertStatusToUserString(mPressedOrderStatus.status, mPressedOrderStatus.deliverToTable) & _
					queueStr & "." & CRLF & deliveryTypeStr & CRLF & CRLF & "Items in this order:"
			
			Dim totalCost As Float = 0
			For Each item As clsCustomerOrderItemRec In orderInfoObj.itemList
				Dim sizePriceObj As clsSizePriceTableRec = Starter.DataBase.GetSizePriceRec(item.priceId)
				Dim itemName As String = Starter.DataBase.GetGroupAndDescriptionName(sizePriceObj.goodsId)
				Dim itemPrice As Float = Starter.DataBase.GetPriceForSize(sizePriceObj.goodsId, sizePriceObj.size)
				Dim itemPriceStr As String = modEposApp.FormatCurrency(itemPrice)
				msg = msg & CRLF & item.qty & "x " & itemName & " @ £" & itemPriceStr & " each"
				totalCost = totalCost + (itemPrice * item.qty)
			Next
			
			Dim orderPaidStr As String = "This order is currently unpaid."
			If orderInfoObj.paid Then orderPaidStr = "This order has been paid for."
			Dim orderMessage As String = CRLF & CRLF & "Your order message: " & orderInfoObj.orderMessage
			If orderInfoObj.orderMessage.Trim = "" Then orderMessage = ""
			msg = msg & CRLF & CRLF & "Order total: £" & modEposApp.FormatCurrency(totalCost) & CRLF & orderPaidStr & orderMessage
		End If		
	End If
	
	' Display the message
	MsgboxAsync(msg, title)
End Sub

' Sends to the Server the message which requests the customer's order status list.
Public Sub pSendRequestForOrderStatusList
	ProgressDialogShow("Getting your order status, please wait...")
	CallSub2(Starter, "pSendMessageAndCheckReconnect", modEposApp.EPOS_ORDERSTATUSLIST & Starter.myData.customer.customerIdStr)
End Sub

' Populates the listview with each of the orders and their statuses in the specified XML string.
Public Sub pHandleOrderStatusList(orderStatusStr As String)
	ProgressDialogHide
	
	' Deserialise the XML string
	Dim xmlStr As String = orderStatusStr.SubString(modEposApp.EPOS_ORDERSTATUSLIST.Length) ' TODO - check if the XML string is valid?
	Dim orderListObj As clsEposOrderStatusList : orderListObj.Initialize
	orderListObj = orderListObj.XmlDeserialize(xmlStr) ' TODO - need to get the deserializer working?
	
	' Add the orders in the list to the listview
	lvwOrderSummary.Clear
	If orderListObj.customerId <> 0 Then ' XML string was deserialised OK
		If orderListObj.order.Size > 0 Then ' List contains orders
			For Each order As clsEposOrderStatus In orderListObj.order
				lAddOrderEntryToListview(order)
			Next
		Else ' No orders found in order list
			lvwOrderSummary.AddSingleLine2("No active orders found", 0)
		End If		
	Else ' XML failed to deserialise properly
		lvwOrderSummary.AddTwoLines2("Error reading order list", "Please retry", 0)
	End If
End Sub

' Causes the listview to be repopulated so that the specified order's information is updated.
Public Sub pUpdateOrderStatus(statusObj As clsEposOrderStatus)
	Dim currentItems As List : currentItems.Initialize
	Dim needsToRefresh As Boolean = False
	Dim prevWaitingOrderFound As Boolean
	
	' Assemble a list containing all of the items' info, and detect if the whole list needs to be refreshed
	For itemIndex = 0 To (lvwOrderSummary.Size - 1)
		' Detect multiple orders in the list which have the 'waiting' status.
		Dim listviewStatus As  clsEposOrderStatus = lvwOrderSummary.GetItem(itemIndex)
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
		ProgressDialogShow("Updating the order list, please wait...")
		CallSub2(Starter, "pSendMessage", modEposApp.EPOS_ORDERSTATUSLIST & Starter.myData.customer.customerIdStr)
	Else ' Don't need to refresh the whole list - repopulate using existing data
		lvwOrderSummary.Clear
		For Each listStatus As clsEposOrderStatus In currentItems
			lAddOrderEntryToListview(listStatus )
		Next
	End If
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Adds a two-line item to the listview containing the specified order information. The listview item will be set up so that the
' specified order status object is returned as the Value in e.g. lvwOrderSummary.GetItem() or lvwOrderSummary_ItemClick().
Private Sub lAddOrderEntryToListview(statusObj As clsEposOrderStatus)
	Dim topStr As String = "Order #" & statusObj.orderId
	Dim statusStr As String = modConvert.ConvertStatusToUserString(statusObj.status, statusObj.deliverToTable)
	If statusObj.amount < 0 Then statusStr = "Awaiting Refund"
	Dim queueStr As String = " (" & modConvert.ConvertNumberToOrdinalString(statusObj.queuePosition) & ")"
	If statusObj.queuePosition < 1 Then queueStr = ""
	Dim bottomStr As String = "Status: " & statusStr & queueStr
	lvwOrderSummary.AddTwoLines2(topStr, bottomStr, statusObj)
End Sub

#End Region  Local Subroutines
