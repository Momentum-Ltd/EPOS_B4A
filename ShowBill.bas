B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=7.3
@EndOfDesignText@
'
' This activity is used to display the customer's current bill.
'
#Region  Documentation
	'
	' Name......: ShowBill
	' Release...: 19
	' Date......: 22/10/19
	'
	' History
	' Date......: 23/12/17
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
	'
	' History
	'  Version v1 - 13 see ShowBill_v13
	'
	'
	' Date......: 07/08/19
	' Release...: 14
	' Overview..: Support for myData.
	' Amendee...: D Morris 
	' Details...: Mods: Support for myData pSendRequestForBill().
	'
	' Date......: 14/08/19
	' Release...: 15
	' Overview..: Uses latest modEposApp
	' Amendee...: D Morris
	' Details...: Mod: Renamed pBuildCustomerName to BuildCustomerName.
	'			  Mod: pFormatCurrency to FormatCurrency.
		'
	' Date......: 03/09/19
	' Release...: 16
	' Overview..: Support for card payments.
	' Amendee...: D Morris
	' Details...:  Added: ReportPaymentStatus().
	'		       Added: Payment button and handling.
	'			  Bugfix: pSendRequestForBill() now defined correctly public (was private but still got called).
	'			     Mod: btnPay re=enabled.
	'
	' Date......: 05/09/19
	' Release...: 17
	' Overview..: Returns to Task Select after reporting about payment, and improved payment reporting.
	' Amendee...: D Morris.
	' Details...: Mod: ReportPaymentStatus() code changed.
		'
	' Date......: 13/10/19
	' Release...: 18
	' Overview..: Support for X-platform.
	' Amendee...: D Morris
	' Details...: Mod: Rename subs.
	'
	' Date......: 22/10/19
	' Release...: 19
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

	' Activity view declarations
	Private btnRefreshBill As Button
	Private btnClose As Button
	Private lvwOrderSummary As ListView
	Private lblTotal As Label
	Private lblName As Label
	Private btnPay As Button
	
	' locals
	Private totalCost As Float' Total cost of bill
	Private cardProcessor As clsCardPayment
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("frmShowBill")
	cardProcessor.Initialize
	lSetupListview
End Sub

Sub Activity_Resume
	lblName.Text = "Bill for " & modEposApp.BuildCustomerName
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	If Starter.DisconnectedCloseActivities Then Activity.Finish
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Handles the Click event of the Refresh Bill button.
Sub btnClose_Click
	Activity.Finish
End Sub

Sub btnPay_Click
	cardProcessor.PayByCard(totalCost)
End Sub


' Handles the Click event of the Refresh Bill button.
Sub btnRefreshBill_Click
	pSendRequestForBill
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' Handles the response received from the Server to the request for an itemised bill.
Public Sub pHandleGetBillByItemResponse(customerBillByItemStr As String)
	ProgressDialogHide
	Dim xmlStr As String = customerBillByItemStr.SubString(modEposApp.EPOS_ITEMIZED_BILL.Length) ' TODO - detect if XML string is valid
	Dim responseObj As clsEposCustomerBillByItem
	responseObj.Initialize
	responseObj = responseObj.XmlDeserialize(xmlStr) ' TODO - need to determine if the deserialisation was successful
	lvwOrderSummary.Clear
	totalCost  = 0

	If responseObj.itemList.Size > 0 Then
		For Each itemEntry As clsCustomerOrderItemRec In responseObj.itemList
			Dim sizeInfo As clsSizePriceTableRec = Starter.DataBase.GetSizePriceRec(itemEntry.priceId)
			Dim itemSubTotal As Float = sizeInfo.unitPrice * itemEntry.qty
			totalCost = totalCost + itemSubTotal
			Dim itemLine1 As String = Starter.DataBase.GetGroupAndDescriptionName(sizeInfo.goodsId) & ", " & _
										Starter.DataBase.GetSizeOptName(sizeInfo.size)
			Dim itemLine2 As String = "Each: £" & modEposApp.FormatCurrency(sizeInfo.unitPrice) & " | Qty: " & itemEntry.qty & _
										" | Total: £" & modEposApp.FormatCurrency(itemSubTotal)
			lvwOrderSummary.AddTwoLines(itemLine1, itemLine2)
		Next
	Else
		lvwOrderSummary.AddTwoLines("Nothing to pay", "No bills outstanding!")
	End If

	lblTotal.Text = "Total: £" & modEposApp.FormatCurrency(totalCost)
	If totalCost > 0.30 Then	' There is a minimum card payment.
		btnPay.Enabled = Starter.myData.centre.acceptCards	
	Else
		btnPay.Enabled = False
	End If
End Sub

' Handles the response received from the Server to the request for an order-based bill.
' Note: The EPOS_BILL command is now considered obsolete; this handler for it is retained for backwards-compatibility.
Public Sub pHandleGetBillResponse(customerBillStr As String)
	ProgressDialogHide
	Dim xmlStr As String = customerBillStr.SubString(modEposApp.EPOS_BILL.Length) ' TODO - Need to detect if the XML string is valid
	Dim responseObj As clsCustomerBill
	
	responseObj.Initialize
	responseObj = responseObj.XmlDeserialize(xmlStr) ' TODO - need to determine if the deserialisation was successful
	lvwOrderSummary.Clear
	totalCost  = 0
	If responseObj.order.Size > 0 Then
		For Each order As clsOrderSummaryRec In responseObj.order
			Dim lineStrg As String
			lineStrg = "Order:" & order.orderId & "  Cost: £" & modEposApp.FormatCurrency(order.cost)
			totalCost = totalCost + order.cost
			lvwOrderSummary.AddSingleLine(lineStrg)
		Next
	Else
		lvwOrderSummary.AddTwoLines("Nothing to pay", "No bills outstanding!")
	End If
	
	btnPay.Enabled = Starter.myData.centre.acceptCards 
	
	lblTotal.Text = "Total: £" & modEposApp.FormatCurrency(totalCost)
End Sub

' Reports the result of a card transaction.
Public Sub ReportPaymentStatus(paymentInfo As clsEposCustomerPayment)
	Dim msgTitle As String = "Card transaction report"
	Dim msgBody As String = "Failed"
	
	Select paymentInfo.status
		Case modConvert.payStatusCreateCardAccProblem
			msgBody = "Card not accepted"
		Case modConvert.payStatusSaveCard
			msgBody = "Card saved"
		Case modConvert.payStatusSucceeded
			msgBody =  "Payment accepted"
		Case modConvert.payrequestRetry
			msgBody = "Operation failed - please retry"
		Case modConvert.payStatusPending
			msgBody = "Payment pending"
		Case modConvert.payStatusFailed
			msgBody = "Payment failed"
	End Select
	MsgboxAsync(msgBody, msgTitle)
	wait for MsgBox_result()
'	Activity.Finish ' this shows caller activity.
	StartActivity(aTaskSelect)
End Sub

' Sends to the Server the message which requests the customer's bill information.
Public Sub pSendRequestForBill
	Dim xmlOrder As String = CallSub(Starter, "BuildEposCustomerDetailsXml")
	ProgressDialogShow("Getting your bill, please wait...")
'	' Restore the following line to send the (now obsolete) request for an order-based bill instead
'	CallSub2(Starter, "pSendMessage", ModEposApp.EPOS_BILL & xmlOrder)
	CallSub2(Starter, "pSendMessageAndCheckReconnect", modEposApp.EPOS_ITEMIZED_BILL & xmlOrder) ' Requests an itemised bill
End Sub


#End Region  Public Subroutines

#Region  Local Subroutines

' Adjusts the properties of the lvwOrderSummary listview so that it will always display its contents properly.
Private Sub lSetupListview
	Dim strUtils As StringUtils
	Dim tempLabel As Label : tempLabel.Initialize("")
	tempLabel.Width = lvwOrderSummary.Width
	tempLabel.TextSize = lvwOrderSummary.TwoLinesLayout.Label.TextSize
	Dim topTextHeight As Float = strUtils.MeasureMultilineTextHeight(tempLabel, "Test1" & CRLF & "Test2")
	tempLabel.TextSize = lvwOrderSummary.TwoLinesLayout.SecondLabel.TextSize
	Dim bottomTextHeight As Float = strUtils.MeasureMultilineTextHeight(tempLabel, "Test1")
	lvwOrderSummary.TwoLinesLayout.Label.Height = topTextHeight
	lvwOrderSummary.TwoLinesLayout.Label.Gravity = Gravity.CENTER_VERTICAL
	lvwOrderSummary.TwoLinesLayout.SecondLabel.Top = topTextHeight
	lvwOrderSummary.TwoLinesLayout.SecondLabel.Height = bottomTextHeight
	lvwOrderSummary.TwoLinesLayout.SecondLabel.Gravity = Gravity.CENTER_VERTICAL
	lvwOrderSummary.TwoLinesLayout.ItemHeight = topTextHeight + bottomTextHeight
	
	' The following is a workaround which ensures the listview always displays black text
	lvwOrderSummary.SingleLineLayout.Label.TextColor = Colors.Black
	lvwOrderSummary.TwoLinesLayout.Label.TextColor = Colors.Black
	lvwOrderSummary.TwoLinesLayout.SecondLabel.TextColor = Colors.Black
	
	' Handle pay button
	
End Sub

#End Region  Local Subroutines
