B4A=true
Group=HelperClasses
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
'
' This is a help class for template
'
#Region  Documentation
	'
	' Name......: hSelectItem
	' Release...: 12-
	' Date......: 25/11/20
	'
	' History
	' Date......: 22/10/19
	' Release...: 1
	' Created by: D Morris (started 3/8/19)
	' Details...: Based on SelectItem_v12 and B4I frmSelectItem_v1.
	'
	' Version 2 - 7 see v8.
	'				
	' Date......: 28/03/20
	' Release...: 8
	' Overview..: Bugfix: #0332 - Back button problem.
	' Amendee...: D Morris
	' Details...:  Mod: ExitToPlaceOrder().
	'
	' Date......: 02/04/20
	' Release...: 9
	' Overview..: Issue: #0371 - Notification whilst showing screen.
	' Amendee...: D Morris
	' Details...: Added: notification class.
	'			  Added: ShowMessageNotificationMsgBox() and ShowStatusNotificationMsgBox().
	'			    Mod: InitializeLocals(),
	'
	' Date......: 06/04/20
	' Release...: 10
	' Overview..: Issue: #0338 Item size dropdown problem.
	' Amendee...: D Morris
	' Details...: Mod: frmSelectItem.bal - lblItemSize overlays spnItemSize on only one selection available.
	'		      Mod: lPopulateListview() and pEditItem() will now display spinner for multiple items or label for single items.
	'
	' Date......: 11/05/20
	' Release...: 11
	' Overview..: Bugfix: #0406 - Code added to ensure timers are disabled when Activity is paused. 
	' Amendee...: D Morris.
	' Details...:  Added: OnClose().
	'				 Mod: Old commented code removed.
	'
	' Date......: 17/07/20
	' Release...: 12
	' Overview..: Start on new UI theme (First phase changing buttons to Orange with rounded corners.. 
	' Amendee...: D Morris.
	' Details...: Mod: Buttons changed to swiftbuttons.
	'
	' Date......: 
	' Release...: 
	' Overview..: Changed to new style UI.
	' Amendee...: D Morris
	' Details...: Mod: lblTitle removed.
	'             Mod: ICloseActivity() renamed to ExitToPlaceOrder().
	'			  Mod: replace lvwItemSize ursListView with customListView.
	'			  Mod: GetSizeName() now used version of clsDataBaseTables.
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
	Private Const BTNTEXT_UPDATE As String = "Update Item" 	' Text displayed on btnAddUpdateItem when updating an existing order item.
	Private Const BTNTEXT_ADD As String = "Add to Order" 	' Text displayed on btnAddUpdateItem when adding a new order item.
	Private Const LEVEL_MAINCAT As Int = 1 					' Indicates that the Select Main Category selection level is shown (defined as the top level).
	Private Const LEVEL_SUBCAT As Int = 2 					' Indicates that the Select Subcategory selection level is shown.
	Private Const LEVEL_GROUPCAT As Int = 3 				' Indicates that the Select Group Gategory selection level is shown.
	Private Const LEVEL_GOODSDESC As Int = 4 				' Indicates that the Select Goods Description selection level is shown.
	Private Const LEVEL_SIZEPRICE As Int = 5 				' Indicates that the Select Size/Price selection level is shown (defined as the bottom/lowest level).
	Private const NO_ITEMS_TEXT As String = "No items available." ' The text displayed in a listview item when there's no items in the selected category.
	
	' Local variables
	Private mEditingOrderItem As Int 			' The index of the item which is currently being edited in the order list.
'	Private mEndOnPause As Boolean = False 		' Stores whether the activity should be closed the next time it is Paused.
	Private mItemSizePriceTable As List 		' The list of sizePriceTableRec objects available for the currently selected goods item.
	Private mSelectedMainCatKey As Int = -1 	' The database key of the currently selected Main Category.
	Private mSelectedSubCatKey As Int = -1 		' The database key of the currently selected Subcategory.
	Private mSelectedGroupCatKey As Int = -1 	' The database key of the currently selected Group Category.
	Private mSelectedGoodsDescKey As Int = -1 	' The database key of the currently selected Goods Description.
	Private mSelectedSizePriceKey As Int = -1 	' The database key of the currently selected Size/Price.
	Private mSelectionLevel As Int 				' The currrently displayed Selection Level (see the LEVEL_* constants above).
	
	' View declarations
	Private btnAddUpdateItem As SwiftButton		' The button which adds/updates the selected item on the order's item list.
	Private btnDecQty As B4XView 				' The button which decrements the item quantity.
	Private btnDelete As SwiftButton			' The button which deletes the currently-editing item from the order.
	Private btnIncQty As B4XView 				' The button which increments the item quantity.
#if B4I
	Private btnItemSize As Button 				' The button which invokes the lvwItemSize listview palette to be displayed.
	Private btnMoreSizes As SwiftButton				' The button to show more sizes options list.
#End If
	Private btnTopLevel As SwiftButton 			' The button which returns the user to the top (Main Category) level of the selection tree.
	Private btnUpOneLevel As SwiftButton		' The button which returns the user to the previous selection level.
	Private imgSuperorder As B4XView 			' SuperOrder header icon.
	Private lblQty As B4XView 					' The label which displays the currently selected item quantity.
	Private lblSelection As B4XView 			' The label which displays the current selection and its 'path' (parent categories).
'#if B4A
'	Private lblTitle As B4XView 				' The label which displays whether the activity will currently add or update an item.
'#end if
	Private lblTotal As B4XView 				' The label which displays the item subtotal (item's individual cost * quantity).
	Private lvwSelectItem As CustomListView		' The listview used to display the selection choices available at the current level.
#if B4A
'	Private lvwSelectItem As CustomListView		' The listview used to display the selection choices available at the current level.
#else
	Private lvwItemSize As CustomListView 		' The listview which can be shown to allow the user to select the desired item size option.
'	Private lvwSelectItem As CustomListView 	' The listview used to display the selection choices available at the current level.
	Private pnlSizeMask As Panel 				' The full-screen-size panel, used to block controls beneath the Size listview from being clicked.
#End If
	Private pnlHeader As B4XView				' Page header panel.
	Private pnlItemDetails As B4XView 			' The panel which holds the views used to change the selected item's size option or quantity.
#if B4A
	'TODO Need a B4X version of spinner?
	Private spnItemSize As Spinner 				' The spinner which allows the user to select the desired item size option.
	Private lblItemSize As B4XView				' Displayed as item size on only one selection available.
#else ' B4I
	' TODO need a spinner for B4I.
#End If
	
	' Misc objects	
	Private notification As clsNotifications	' Handles notifications
End Sub

' Cancel the Select Item process.
Public Sub CancelSelectItem
	ExitToPlaceOrder
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (parent As B4XView)
	parent.LoadLayout("frmSelectItem")
	InitializeLocals
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

 ' Handles the Click event of the Add/Update Item button.
Private Sub btnAddUpdateItem_Click
	Dim duplicateItemFound As Boolean
	
	If btnAddUpdateItem.xLBL.Text = BTNTEXT_ADD Then ' The user is adding a new item to the order
		If Starter.customerOrderInfo.IsItemFound(mSelectedSizePriceKey) = False Then
			Starter.customerOrderInfo.AddItem(mSelectedSizePriceKey, lblQty.Text)
		Else ' Item already exists in the order
			duplicateItemFound = True
		End If
	Else If btnAddUpdateItem.xLBl.Text = BTNTEXT_UPDATE Then ' The user is updating an existing item in the order
		Dim itemInfo As clsCustomerOrderItemRec : itemInfo.Initialize
		itemInfo.priceId = mSelectedSizePriceKey
		itemInfo.qty =  lblQty.Text
		Dim prevItemInfo As clsCustomerOrderItemRec = Starter.customerOrderInfo.orderList.get(mEditingOrderItem)
		If itemInfo.priceId = prevItemInfo.priceId Then ' Item is unchanged - just update
			Starter.customerOrderInfo.orderList.Set(mEditingOrderItem, itemInfo)
		Else ' Item changed - check for duplication
			If Starter.customerOrderInfo.IsItemFound(mSelectedSizePriceKey) = False Then
				Starter.customerOrderInfo.orderList.Set(mEditingOrderItem, itemInfo)
			Else ' An item with the same goods ID already exists in the order
				duplicateItemFound = True
			End If
		End If
	End If
	
	If duplicateItemFound Then
		' TODO - should this instead update the existing item's quantity (and notify the customer)?
		Dim itemDuplicatedMsg As String = "An identical item already exists in the order." & CRLF & "The item will not " & _
												"be added – please edit the previous entry and increase its quantity instead."
#if B4A
		xui.Msgbox2Async(itemDuplicatedMsg, "Duplicate Item", "OK", "", "", Null) ' Don't allow the user to cancel the message
		Wait For Msgbox_Result (Result As Int) ' Only proceed when the user has acknowledged the message
#else ' B4I 
		Msgbox2("duplicateMsg", itemDuplicatedMsg, "Duplicate Item", Array("OK"))
		 ' See the duplicateMsg_Click() handler for continuation, as it should only proceed when the user has dismissed the message
#End If
	End If
	ExitToPlaceOrder
End Sub

' Handles the Click event of the Decrement Quantity button.
Private Sub btnDecQty_Click
	Dim currentNumber As Int = lblQty.Text
	If currentNumber > 1 Then
		lblQty.Text = currentNumber - 1
		lUpdateSubtotalLabel
	End If
End Sub

' Handles the Click event of the Delete Item button.
Private Sub btnDelete_Click
	' TODO - Should there be a confirmation request at this point?
	Starter.customerOrderInfo.orderList.RemoveAt(mEditingOrderItem)
	ExitToPlaceOrder
End Sub

' Handles the Click event of the Increment Quantity button.
Private Sub btnIncQty_Click
	Dim currentNumber As Int = lblQty.Text
	lblQty.Text = currentNumber + 1
	lUpdateSubtotalLabel
End Sub

#if B4I
' Handles the Click event of the Item Size button.
Private Sub btnItemSize_Click
	If mItemSizePriceTable.Size > 1 Then ' Multi sizes available?
		lPopulateSizeDropdown		
	End If
End Sub

' IPhone press on more size button.
Sub btnMoreSizes_Click
	lPopulateSizeDropdown
End Sub
#End If


' Handles the Click event of the Top Level button.
Private Sub btnTopLevel_Click
	lShowTopLevelOnListView
End Sub

' Handles the Click event of the Up One Level button.
Private Sub btnUpOneLevel_Click
	lGoUpALevel
End Sub

' Asynchronously handles a button being pressed on the "duplicate item" message box invoked in btnAddUpdateItem_Click()
Private Sub duplicateMsg_Click(ButtonText As String)
	ExitToPlaceOrder ' Message has been read, just close the form
End Sub


' Handle back button
private Sub lblBackButton_Click
'	If enableViews = True Then
	ExitToPlaceOrder
'	End If
End Sub

#if B4I
' Handles the ItemClick event of the Item Size listview.
Private Sub lvwItemSize_ItemClick(index As Int, value As Object)     ' (Value As Object, Index As Int)
	mSelectedSizePriceKey = value
	btnItemSize.Text = GetSizeName(mSelectedSizePriceKey)
	lUpdateSubtotalLabel
	pnlSizeMask.Visible = False
End Sub
#End If

' Handles the ItemClick event of the Select Item listview.
Private Sub lvwSelectItem_ItemClick(Position As Int, Value As Object)
	If Value <> NO_ITEMS_TEXT Then ' Only take action if the selection is not the generic 'no items' option
		Select Case mSelectionLevel
			Case LEVEL_MAINCAT
				mSelectedMainCatKey = Value
			Case LEVEL_SUBCAT
				mSelectedSubCatKey = Value
			Case LEVEL_GROUPCAT
				mSelectedGroupCatKey = Value
			Case LEVEL_GOODSDESC
				mSelectedGoodsDescKey = Value
		End Select

		PopulateListView
	End If
End Sub

' Handles the ItemClick event of the Item Size spinner.
Private Sub spnItemSize_ItemClick(position As Int, value As Object)
	Dim sizePriceRec As sizePriceTableRec = mItemSizePriceTable.Get(position)
	mSelectedSizePriceKey = sizePriceRec.sizePriceKey
	lUpdateSubtotalLabel
End Sub
#End Region  Event Handlers

#Region  Public Subroutines
' Sets up the form to modify the specified item which currently exists in teh order's item list.
Public Sub pEditItem(orderIndex As Int)
	' Set up the form's views as required
	mEditingOrderItem = orderIndex
'#if B4A
'	lblTitle.Text = "Editing Item"
'#end if
	btnDelete.mBase.Visible = True
	btnAddUpdateItem.xLBL.Text = BTNTEXT_UPDATE
	btnAddUpdateItem.mBase.Visible = True
	
	' Get the specified order item's info and display the relevant selection level
	Dim customerOrderObj As clsCustomerOrderItemRec = Starter.customerOrderInfo.orderList.Get(orderIndex)
	Dim sizePriceObj As clsSizePriceTableRec = Starter.DataBase.GetSizePriceRec(customerOrderObj.priceId)
	Dim goodsTableObj As clsGoodsTableRec = Starter.DataBase.GetGoodsTableRec(sizePriceObj.goodsId)
	mSelectedMainCatKey = goodsTableObj.mainCategory
	mSelectedSubCatKey = goodsTableObj.subCategory
	mSelectedGroupCatKey = goodsTableObj.groupCategory
	mSelectedGoodsDescKey = goodsTableObj.key
	lPopulateListview(LEVEL_SIZEPRICE)
	mSelectedSizePriceKey = sizePriceObj.key ' Must occur after lPopulateListview as it sets this member to default
#if B4A
	' Get and select the relevant item in the Size spinner
	mItemSizePriceTable = Starter.DataBase.SortSizePrice(mSelectedGoodsDescKey)
	spnItemSize.Visible = False
	lblItemSize.Visible = False
	' Populate spinner or label with size(s).
	If mItemSizePriceTable.Size > 1 Then ' Multiple sizes populate the spinner
		Dim sizeTextValue As String		
		For Each item As sizePriceTableRec In mItemSizePriceTable
			If item.sizeOptKey = sizePriceObj.size Then 
				sizeTextValue = item.sizePrice
			End If
		Next
		Dim indexToSet As Int = 0
		For itemIndex = 0 To (spnItemSize.size - 1)
			If spnItemSize.GetItem(itemIndex) = sizeTextValue Then 
				indexToSet = itemIndex
			End If
		Next
		spnItemSize.SelectedIndex = indexToSet
		spnItemSize.Visible = True
	Else ' Only single size available for that item. 
		Dim item As sizePriceTableRec: item.initialize
		item = mItemSizePriceTable.Get(0)
		lblItemSize.Text =item.sizePrice
		lblItemSize.Visible = True
	End If
#else ' B4I
	btnMoreSizes.mBase.Visible = False
	btnItemSize.Text = GetSizeName(mSelectedSizePriceKey) ' Show the relevant size name on the Size selection button
	If mItemSizePriceTable.Size > 1 Then ' Multiple sizes show the drop down button.
		btnMoreSizes.mBase.Visible = True
	End If
#End If
	
	' Update the quantity and total labels as required
	Dim qtyInt As Int = customerOrderObj.qty ' Declare as Int to prevent Float .qty field displaying with a decimal digit
	lblQty.Text = qtyInt
	lUpdateSubtotalLabel
End Sub

' Will perform any cleanup operation when the form is closed (disappears).
public Sub OnClose
	' Nothing to do!
End Sub

' Displays a messagebox containing the most recent Message To Customer text, and makes the notification sound/vibration if specified.
Public Sub ShowMessageNotificationMsgBox(soundAndVibrate As Boolean)
	notification.ShowMessageNotificationMsgBox(soundAndVibrate)
End Sub

' Displays a messagebox containing the most recent Order Status text, and makes the notification sound/vibration if specified.
Public Sub ShowStatusNotificationMsgBox(soundAndVibrate As Boolean)
	notification.ShowStatusNotificationMsgBox(soundAndVibrate)
End Sub

' Start select item
Public Sub pStartSelectItem
	lShowTopLevelOnListView
#if B4I
	pnlSizeMask.Visible = False
#end if
	btnDelete.mBase.Visible = False
	btnAddUpdateItem.xLBL.Text = BTNTEXT_ADD
End Sub
#End Region  Public Subroutines

#Region  Local Subroutines

' Fully closes this activity, and returns to the Place order activity.
Private Sub ExitToPlaceOrder
#if B4A
	StartActivity(aPlaceOrder)
#else ' B4I
'	xSelectItem.ClrPageTitle' fixes page title operation.
	xPlaceOrder.Show
#End If
End Sub

#if B4I
' Returns the name text value of the specified goods item size.
Private Sub GetSizeName(sizePriceKey As Int) As String
'	Dim rtnName As String = "Unknown"
'	Dim sizePriceObj As clsSizePriceTableRec = Starter.DataBase.GetSizePriceRec(sizePriceKey)
'	For Each sizePrice As sizePriceTableRec In mItemSizePriceTable
'		If sizePrice.sizeOptKey = sizePriceObj.size Then
'			rtnName = sizePrice.sizePrice
'			Exit
'		End If
'	Next
'	Return rtnName
	Return Starter.DataBase.GetSizeTextForSizePriceValue(sizePriceKey)
End Sub
#End If

' Returns the user to the selection level above the currently displayed one.
' E.g. if the current level displays Subcategories, the user will be returned to the Main level.
Private Sub lGoUpALevel
	Select Case mSelectionLevel
		Case LEVEL_SUBCAT
			mSelectedMainCatKey = -1
			lPopulateListview(LEVEL_MAINCAT)
		Case LEVEL_GROUPCAT
			mSelectedSubCatKey = -1
			lPopulateListview(LEVEL_SUBCAT)
		Case LEVEL_GOODSDESC
			mSelectedGroupCatKey = -1
			lPopulateListview(LEVEL_GROUPCAT)
		Case LEVEL_SIZEPRICE
			mSelectedGoodsDescKey = -1
			lPopulateListview(LEVEL_GOODSDESC)
	End Select
End Sub

' Initialize the locals etc.
private Sub InitializeLocals
'	progressbox.Initialize(Me, "progressbox", modEposApp.DFT_PROGRESS_TIMEOUT)
#if B4A
#else ' B4I
	pnlSizeMask.Visible = False ' Just in case
#End If
	pStartSelectItem
	notification.Initialize
	Dim bt As Bitmap = imgSuperorder.GetBitmap
	imgSuperorder.SetBitmap(bt.Resize(imgSuperorder.Width, imgSuperorder.Height, True))
	imgSuperorder.Top = (pnlHeader.Height - imgSuperorder.Height) / 2   ' Centre SuperOrder vertically.
End Sub

#if B4I
' Populates the size droppdown option.
private Sub lPopulateSizeDropdown
	lvwItemSize.Clear
	For Each sizeRec As sizePriceTableRec In mItemSizePriceTable
	'	lvwItemSize.AddItem(sizeRec.sizePrice, "", sizeRec.sizePriceKey)
		lvwItemSize.AddTextItem(sizeRec.sizePrice & CRLF, sizeRec.sizePriceKey)
	Next
	pnlSizeMask.Visible = True
End Sub
#end if 

' Populates the Item Selection listview with the relevant choices at the specified selection level. If the specified
' level is LEVEL_SIZEPRICE then the listview will be hidden and the Item Details panel will be populated instead.
Private Sub lPopulateListview(selectLevel As Int)
	Dim itemList As List : itemList.Initialize
	lvwSelectItem.Clear
	mSelectionLevel = selectLevel
	
	Select Case selectLevel
		Case LEVEL_MAINCAT
			lShowTopLevelOnListView
		Case LEVEL_SUBCAT
			lUpdateSelectionLabel
			itemList = Starter.DataBase.SortSubCat(mSelectedMainCatKey)
			For Each subCat As clsSubCategoryTableRec In itemList
'#if B4A
'				lvwSelectItem.AddTextItem(subCat.value, subCat.key)
'#else ' B4I
				lvwSelectItem.AddTextItem(subCat.value, subCat.key)
'#End If
			Next
		Case LEVEL_GROUPCAT
			lUpdateSelectionLabel
			itemList = Starter.DataBase.SortGrpCat(mSelectedSubCatKey, mSelectedMainCatKey)
			For Each groupCat As clsGroupCategoryTableRec In itemList
'#if B4A
'				lvwSelectItem.AddTextItem(groupCat.value, groupCat.key)
'#else ' B4I
				lvwSelectItem.AddTextItem(groupCat.value, groupCat.key)
'#End If
			Next
		Case LEVEL_GOODSDESC
			lUpdateSelectionLabel
			itemList = Starter.DataBase.SortGoods(mSelectedGroupCatKey, mSelectedSubCatKey, mSelectedMainCatKey)
			For Each goodsDesc As descriptionAbridgedTableRec In itemList
				lvwSelectItem.AddTextItem(goodsDesc.value, goodsDesc.key)
			Next
			btnAddUpdateItem.mBase.Visible = False
			pnlItemDetails.Visible = False
			'https://www.b4x.com/android/forum/threads/customlistview-visibility-problem.81651/
			lvwSelectItem.AsView.Visible = True
		Case LEVEL_SIZEPRICE
			lUpdateSelectionLabel
			mItemSizePriceTable = Starter.DataBase.SortSizePrice(mSelectedGoodsDescKey)
#if B4A
			spnItemSize.Clear
#End If
			Dim itemInStock As Boolean = False	
			' TODO Does b4A have equivalent to .net list.find(Predicate<T>) type operation?
			For Each item As sizePriceTableRec In mItemSizePriceTable ' Loop to check if any item is in-stock
				If item.inStock Then
					itemInStock = True
					Exit 	' item found in stock exit the for loop!
				End If
			Next	
			If itemInStock Then ' At least one size is in-stock
#if B4A
				spnItemSize.Visible = False
				lblItemSize.Visible = False
				' Populate spinner or label with size(s).
				If mItemSizePriceTable.Size > 1 Then ' Multiple sizes populate the spinner
					For Each item As sizePriceTableRec In mItemSizePriceTable ' add all items to spinner (inc out-of-stock)
						spnItemSize.Add(item.sizePrice)
					Next
					spnItemSize.SelectedIndex = 0
					spnItemSize.Visible = True
				Else ' Only single size available for that item.
					Dim item As sizePriceTableRec: item.initialize
					item = mItemSizePriceTable.Get(0)
					lblItemSize.Text =item.sizePrice
					lblItemSize.Visible = True				
				End If
#else ' B4I
				btnMoreSizes.mBase.Visible = False
				Dim tempItem As sizePriceTableRec = mItemSizePriceTable.Get(0)
				btnItemSize.Text = tempItem.sizePrice
				If mItemSizePriceTable.Size > 1 Then
					btnMoreSizes.mBase.Visible = True
				End If
#End If
				
				Dim sizePriceRec As sizePriceTableRec = mItemSizePriceTable.Get(0)
				mSelectedSizePriceKey = sizePriceRec.sizePriceKey
				lblQty.Text = "1"
				lUpdateSubtotalLabel
				btnAddUpdateItem.mBase.Visible = True
				'https://www.b4x.com/android/forum/threads/customlistview-visibility-problem.81651/
				lvwSelectItem.AsView.Visible = False	
				pnlItemDetails.Visible = True
			Else ' No available sizes are in-stock
				xui.MsgboxAsync("This item is not currently available. Please select another.", "Item Unavailable")
				lGoUpALevel
			End If
	End Select
'#if B4A
'	If lvwSelectItem.Size = 0 Then
'		lvwSelectItem.AddTextItem( NO_ITEMS_TEXT & NO_ITEMS_TEXT, 0)	' TODO Check this line is ok.
'	End If
'#else ' B4I
	If lvwSelectItem.Size = 0 Then
		lvwSelectItem.AddTextItem( NO_ITEMS_TEXT & NO_ITEMS_TEXT, 0)	' TODO Check this line is ok.
	End If
'#End If
End Sub

' Changes the selection level to the top (Main) level, clearing out all lower levels' data.
Private Sub lShowTopLevelOnListView
	mSelectionLevel = LEVEL_MAINCAT
	mSelectedMainCatKey = -1
	mSelectedSubCatKey = -1
	mSelectedGroupCatKey = -1
	mSelectedGoodsDescKey = -1
	mSelectedSizePriceKey = -1
	lUpdateSelectionLabel
	lvwSelectItem.Clear
	Dim itemList As List = Starter.DataBase.mainCatTable
	For Each entry As clsMainCategoryTableRec In itemList
'#if B4A
'		lvwSelectItem.AddTextItem(entry.value, entry.key)
'#else ' B4I
		lvwSelectItem.AddTextItem(entry.value, entry.key)
'#End If
	Next
	btnAddUpdateItem.mBase.Visible = False
	pnlItemDetails.Visible = False

	'https://www.b4x.com/android/forum/threads/customlistview-visibility-problem.81651/
	lvwSelectItem.AsView.Visible = True 
End Sub

' Updates the Selection label to display the current selection and its 'path' (parent categories)
Private Sub lUpdateSelectionLabel
	Dim strLabel As String = "Select an item below..."
	If mSelectedMainCatKey <> -1  Then 
		strLabel = "Selected: " & Starter.DataBase.GetMainCatName(mSelectedMainCatKey)
	End If
	If mSelectedSubCatKey <> -1 Then 
		strLabel = strLabel & " > " & Starter.DataBase.GetSubCatName(mSelectedSubCatKey)
	End If
	If mSelectedGroupCatKey <> -1 Then 
		strLabel = strLabel & " > " & Starter.DataBase.GetGroupCatName(mSelectedGroupCatKey)
	End If
	If mSelectedGoodsDescKey <> -1 Then
		Dim goodsObj As clsGoodsTableRec = Starter.DataBase.GetGoodsTableRec(mSelectedGoodsDescKey)
		strLabel = strLabel & " > " & Starter.DataBase.GetDescription(goodsObj.descId)
	End If
	lblSelection.text = strLabel
End Sub

' Updates the Subtotal label to display the current subtotal price (item's individual cost * quantity).
Private Sub lUpdateSubtotalLabel
	Dim qty As Int  = lblQty.Text
	Dim priceTotal As Float = (Starter.DataBase.GetUnitPrice(mSelectedSizePriceKey)) * qty
	lblTotal.Text = "Item Subtotal: £" & modEposApp.FormatCurrency(priceTotal)
End Sub

' Get a list of items available at the specified level.
' Return list of item objects (the type is dependant on the level).
private Sub GetItemList(level As Int) As List 
	Dim itemList As List : itemList.Initialize
	Select Case (level)
		Case LEVEL_MAINCAT
			itemList  = Starter.DataBase.mainCatTable
		Case LEVEL_SUBCAT
			itemList = Starter.DataBase.SortSubCat(mSelectedMainCatKey)
		Case LEVEL_GROUPCAT
			itemList = Starter.DataBase.SortGrpCat(mSelectedSubCatKey, mSelectedMainCatKey)
		Case LEVEL_GOODSDESC
			itemList = Starter.DataBase.SortGoods(mSelectedGroupCatKey, mSelectedSubCatKey, mSelectedMainCatKey)
		Case Else 'LEVEL_SIZEPRICE
			Starter.DataBase.SortSizePrice(mSelectedGoodsDescKey)
	End Select
	Return itemList
End Sub


' Get next lower level
' Returns the next lower level (returns lowest level if already at that level).
private Sub GetNextLowerLevel(currentLevel As Int) As Int
	Dim newlevel As Int = LEVEL_SIZEPRICE
	Select Case (currentLevel)
		Case LEVEL_MAINCAT
			newlevel = LEVEL_SUBCAT
		Case LEVEL_SUBCAT
			newlevel = LEVEL_GROUPCAT
		Case LEVEL_GROUPCAT
			newlevel = LEVEL_GOODSDESC
		Case LEVEL_GOODSDESC
			newlevel = LEVEL_SIZEPRICE
		Case Else
			newlevel = LEVEL_SIZEPRICE
	End Select
	Return newlevel
End Sub

' Get the next viewable item list.
' Return list of item objects (the type is dependant on the level).
private Sub GetNextViewableItemList(level As Int) As List
	Dim itemList As List 
	Dim nextLevel As Int = level
	Do While (True) ' See code below to exit
		nextLevel = GetNextLowerLevel(nextLevel)		
		itemList = GetItemList(nextLevel)
		If itemList.Size > 0 Or nextLevel = LEVEL_SIZEPRICE Then ' Items available in this category?
			If nextLevel = LEVEL_SIZEPRICE Or itemList.Size >= 2 Then
				mSelectionLevel = nextLevel
				Exit ' Exit the loop!
			End If
			UpdateSelectedCatKey(nextLevel, itemList)
		Else ' No items in this category.
			itemList = GetItemList(level) 	' Retun the current item list.
			xui.MsgboxAsync("There are NO items available in this category. Please select category.", "No items available")
			Exit ' Exit loop!
		End If
	Loop
	Return itemList
End Sub

' Populate the list view.
' This will automatically move to the next level if only one option is available at the current level (except the bottom level).
private Sub PopulateListView()
	GetNextViewableItemList(mSelectionLevel)
	lPopulateListview(mSelectionLevel)		
End Sub

' Updates the Selected Category key for the specified level
'   The associated database key of the currently selected Category is updated.
Private Sub UpdateSelectedCatKey(level As Int, itemList As List)
	Select Case (level)
		Case LEVEL_MAINCAT
			Dim mainCatRec As clsMainCategoryTableRec = itemList.Get(0) ' used to cast types
			mSelectedMainCatKey = mainCatRec.key
		Case LEVEL_SUBCAT
			Dim subCatRec As clsSubCategoryTableRec = itemList.Get(0) ' used to cast types
			mSelectedSubCatKey = subCatRec.key
		Case LEVEL_GROUPCAT
			Dim groupCatRec As clsGroupCategoryTableRec = itemList.Get(0) ' used to cast types
			mSelectedGroupCatKey = groupCatRec.key
		Case LEVEL_GOODSDESC
			Dim goodsCatRec As descriptionAbridgedTableRec = itemList.Get(0) ' used to cast types
			mSelectedGoodsDescKey = goodsCatRec.key
		Case Else ' LEVEL_SIZEPRICE
			Dim sizePriceCatRec As clsSizePriceTableRec = itemList.Get(0) ' used to cast types
			mSelectedSizePriceKey = sizePriceCatRec.key
	End Select
End Sub

#End Region  Local Subroutines
