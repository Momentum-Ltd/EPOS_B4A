B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=7.3
@EndOfDesignText@
'
' This form allows a client to select and item from the database.
'

#Region  Documentation
	'
	' Name......: SelectItem
	' Release...: 12
	' Date......: 14/08/19
	'
	' History
	' Date......: 23/12/17
	' Release...: 1
	' Created by: D Morris
	' Details...: Based on AndroidRemote.PlayerNames (v3)
	'
	' Versions 2 - 11 see SelectItem_v11
	'
	' Date......: 14/08/19
	' Release...: 12
	' Overview..: Uses latest modEposApp.
	' Amendee...: D Morris
	' Details...:  Mod: pFormatCurrency to FormatCurrency.
	'
	' Date......: 
	' Release...: 
	' Overview..: 
	' Amendee...: 
	' Details...: 
	'
#End Region ' Documentation

#Region  Activity Attributes
	#FullScreen: False
	#IncludeTitle: False
#End Region  Activity Attributes

#Region  Mandatory Subroutines & Data

Sub Process_Globals
	
' Currently none

End Sub

Sub Globals
	
	' Local constants
	Private Const BTNTEXT_UPDATE As String = "Update Item" ' Text displayed on btnAddUpdateItem when updating an existing order item.
	Private Const BTNTEXT_ADD As String = "Add to Order" ' Text displayed on btnAddUpdateItem when adding a new order item.
	Private Const LEVEL_MAINCAT As Int = 1 ' Indicates that the Select Main Category selection level is shown.
	Private Const LEVEL_SUBCAT As Int = 2 ' Indicates that the Select Subcategory selection level is shown.
	Private Const LEVEL_GROUPCAT As Int = 3 ' Indicates that the Select Group Gategory selection level is shown.
	Private Const LEVEL_GOODSDESC As Int = 4 ' Indicates that the Select Goods Description selection level is shown.
	Private Const LEVEL_SIZEPRICE As Int = 5 ' Indicates that the Select Size/Price selection level is shown.
	Private const NO_ITEMS_TEXT As String = "No items available." ' The text displayed in a listview item when there's no items in the selected category.
	
	' Local variables
	Private mEditingOrderItem As Int ' The index of the item which is currently being edited in the order list.
	Private mEndOnPause As Boolean = False ' Stores whether the activity should be closed the next time it is Paused.
	Private mItemSizePriceTable As List ' The list of sizePriceTableRec objects available for the currently selected goods item.
	Private mSelectedMainCatKey As Int = -1 ' The database key of the currently selected Main Category.
	Private mSelectedSubCatKey As Int = -1 ' The database key of the currently selected Subcategory.
	Private mSelectedGroupCatKey As Int = -1 ' The database key of the currently selected Group Category.
	Private mSelectedGoodsDescKey As Int = -1 ' The database key of the currently selected Goods Description.
	Private mSelectedSizePriceKey As Int = -1 ' The database key of the currently selected Size/Price.
	Private mSelectionLevel As Int ' The currrently displayed Selection Level (see the LEVEL_* constants above).
	
	' View declarations
	Private btnAddUpdateItem As Button ' The button which adds/updates the selected item on the order's item list.
	Private btnCancel As Button ' The button which cancels the item selection/update and returns to the ShowOrder activity.
	Private btnDecQty As Button ' The button which decrements the item quantity.
	Private btnDelete As Button ' The button which deletes the currently-editing item from the order.
	Private btnIncQty As Button ' The button which increments the item quantity.
	Private btnTopLevel As Button ' The button which returns the user to the top (Main Category) level of the selection tree.
	Private btnUpOneLevel As Button ' The button which returns the user to the previous selection level.
	Private lblQty As Label ' The label which displays the currently selected item quantity.
	Private lblSelection As Label ' The label which displays the current selection and its 'path' (parent categories).
	Private lblTitle As Label ' The label which displays whether the activity will currently add or update an item.
	Private lblTotal As Label ' The label which displays the item subtotal (item's individual cost * quantity).
	Private lvwSelectItem As ListView ' The listview used to display the selection choices available at the current level.
	Private pnlItemDetails As Panel ' The panel which holds the views used to change the selected item's size option or quantity.
	Private spnItemSize As Spinner ' The spinner which allows the user to select the desired item size option.
	
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("frmSelectItem")
	
	' Ensure the listview always displays black text
	lvwSelectItem.SingleLineLayout.Label.Width = 999999dip ' Set this to be absurdly wide, as a HACK to prevent text wraparound
	lvwSelectItem.TwoLinesLayout.Label.Width = 999999dip ' See above (two-line layout is currently unused - but just in case)
	lvwSelectItem.TwoLinesLayout.SecondLabel.Width = 999999dip ' See above (two-line layout is currently unused - but just in case)
	lvwSelectItem.SingleLineLayout.Label.TextColor = Colors.Black
	lvwSelectItem.TwoLinesLayout.Label.TextColor = Colors.Black ' Two-line layout isn't currently used on this form - but just in case
	lvwSelectItem.TwoLinesLayout.SecondLabel.TextColor = Colors.Black ' Two-line layout isn't currently used on this form - but just in case
	
	pStartSelectItem
End Sub

Sub Activity_Resume
	' Currently nothing
End Sub

Sub Activity_Pause(UserClosed As Boolean)
	If mEndOnPause Or Starter.DisconnectedCloseActivities Then Activity.Finish
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

 ' Handles the Click event of the Add/Update Item button.
Private Sub btnAddUpdateItem_Click
	Dim duplicateItemFound As Boolean
	
	If btnAddUpdateItem.Text = BTNTEXT_ADD Then ' The user is adding a new item to the order
		If Starter.customerOrderInfo.pIsItemFound(mSelectedSizePriceKey) = False Then
			Starter.customerOrderInfo.pAddItem(mSelectedSizePriceKey, lblQty.Text)
		Else ' Item already exists in the order
			duplicateItemFound = True
		End If
	Else If btnAddUpdateItem.Text = BTNTEXT_UPDATE Then ' The user is updating an existing item in the order
		Dim itemInfo As clsCustomerOrderItemRec : itemInfo.Initialize
		itemInfo.priceId = mSelectedSizePriceKey
		itemInfo.qty =  lblQty.Text
		Dim prevItemInfo As clsCustomerOrderItemRec = Starter.customerOrderInfo.orderList.get(mEditingOrderItem)
		If itemInfo.priceId = prevItemInfo.priceId Then ' Item is unchanged - just update
			Starter.customerOrderInfo.orderList.Set(mEditingOrderItem, itemInfo)
		Else ' Item changed - check for duplication
			If Starter.customerOrderInfo.pIsItemFound(mSelectedSizePriceKey) = False Then
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
		Msgbox2Async(itemDuplicatedMsg, "Duplicate Item", "OK", "", "", Null, False) ' Don't allow the user to cancel the message
		Wait For Msgbox_Result (Result As Int) ' Only proceed when the user has acknowledged the message
	End If
	
	lCloseActivity
End Sub

' Handles the Click event of the Cancel button.
Private Sub btnCancel_Click
	lCloseActivity
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
	lCloseActivity
End Sub

' Handles the Click event of the Increment Quantity button.
Private Sub btnIncQty_Click
	Dim currentNumber As Int = lblQty.Text
	lblQty.Text = currentNumber + 1
	lUpdateSubtotalLabel
End Sub

' Handles the Click event of the Top Level button.
Private Sub btnTopLevel_Click
	lShowTopLevelOnListView
End Sub

' Handles the Click event of the Up One Level button.
Private Sub btnUpOneLevel_Click
	lGoUpALevel
End Sub

' Handles the ItemClick event of the Select Item listview.
Private Sub lvwSelectItem_ItemClick(Position As Int, Value As Object)
	If Value <> NO_ITEMS_TEXT Then ' Only take action if the selection is not the generic 'no items' option
		Select Case mSelectionLevel
			Case LEVEL_MAINCAT
				mSelectedMainCatKey = Value
				lPopulateListview(LEVEL_SUBCAT)
			Case LEVEL_SUBCAT
				mSelectedSubCatKey = Value
				lPopulateListview(LEVEL_GROUPCAT)
			Case LEVEL_GROUPCAT
				mSelectedGroupCatKey = Value
				lPopulateListview(LEVEL_GOODSDESC)
			Case LEVEL_GOODSDESC
				mSelectedGoodsDescKey = Value
				lPopulateListview(LEVEL_SIZEPRICE)
		End Select		
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
	lblTitle.Text = "Editing Item"
	btnDelete.Visible = True
	btnAddUpdateItem.Text = BTNTEXT_UPDATE
	
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
	
	' Get and select the relevant item in the Size spinner
	mItemSizePriceTable = Starter.DataBase.SortSizePrice(mSelectedGoodsDescKey)
	Dim sizeTextValue As String
	For Each item As sizePriceTableRec In mItemSizePriceTable
		If item.sizeOptKey = sizePriceObj.size Then sizeTextValue = item.sizePrice
	Next
	Dim indexToSet As Int = 0
	For itemIndex = 0 To (spnItemSize.size - 1)
		If spnItemSize.GetItem(itemIndex) = sizeTextValue Then indexToSet = itemIndex
	Next
	spnItemSize.SelectedIndex = indexToSet
	
	' Update the quantity and total labels as required
	Dim qtyInt As Int = customerOrderObj.qty ' Declare as Int to prevent Float .qty field displaying with a decimal digit
	lblQty.Text = qtyInt
	lUpdateSubtotalLabel
End Sub

Private Sub pStartSelectItem
	lShowTopLevelOnListView
	lblTitle.Text = "Item Selection"
	btnDelete.Visible = False
	btnAddUpdateItem.Text = BTNTEXT_ADD
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Fully closes this activity, and returns to the ShowOrder activity.
Private Sub lCloseActivity
	mEndOnPause = True
	StartActivity(ShowOrder)
End Sub

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
				lvwSelectItem.AddSingleLine2(subCat.value, subCat.key)
			Next
		Case LEVEL_GROUPCAT
			lUpdateSelectionLabel
			itemList = Starter.DataBase.SortGrpCat(mSelectedSubCatKey, mSelectedMainCatKey)
			For Each groupCat As clsGroupCategoryTableRec In itemList
				lvwSelectItem.AddSingleLine2(groupCat.value, groupCat.key)
			Next
		Case LEVEL_GOODSDESC
			lUpdateSelectionLabel
			itemList = Starter.DataBase.SortGoods(mSelectedGroupCatKey, mSelectedSubCatKey, mSelectedMainCatKey)
			For Each goodsDesc As descriptionAbridgedTableRec In itemList
				lvwSelectItem.AddSingleLine2(goodsDesc.value, goodsDesc.key)
			Next
			btnAddUpdateItem.Enabled = False
			pnlItemDetails.Visible = False
			lvwSelectItem.Visible = True
		Case LEVEL_SIZEPRICE
			lUpdateSelectionLabel
			mItemSizePriceTable = Starter.DataBase.SortSizePrice(mSelectedGoodsDescKey)
			spnItemSize.Clear
			Dim itemInStock As Boolean = False
			' TODO Does b4A have equivalent to .net list.find(Predicate<T>) type operation?
			For Each item As sizePriceTableRec In mItemSizePriceTable ' Loop to check if any item is in-stock 
				If item.inStock Then
					itemInStock = True 
					Exit 	' item found in stock exit the for loop! 
				End If
			Next
			If itemInStock Then ' At least one size is in-stock
				For Each item As sizePriceTableRec In mItemSizePriceTable ' add all items to spinner (inc out-of-stock)
					spnItemSize.Add(item.sizePrice) 
				Next
				spnItemSize.SelectedIndex = 0
				Dim sizePriceRec As sizePriceTableRec = mItemSizePriceTable.Get(0)
				mSelectedSizePriceKey = sizePriceRec.sizePriceKey
				lblQty.Text = "1"
				lUpdateSubtotalLabel
				btnAddUpdateItem.Enabled = True
				lvwSelectItem.Visible = False
				pnlItemDetails.Visible = True
			Else ' No available sizes are in-stock
				MsgboxAsync("This item is not currently available. Please select another.", "Item Unavailable")
				lGoUpALevel
			End If
	End Select
	
	If lvwSelectItem.Size = 0 Then
		lvwSelectItem.AddSingleLine2(NO_ITEMS_TEXT, NO_ITEMS_TEXT)
	End If
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
		lvwSelectItem.AddSingleLine2(entry.value, entry.key)
	Next
	btnAddUpdateItem.Enabled = False
	pnlItemDetails.Visible = False
	lvwSelectItem.Visible = True
End Sub

' Updates the Selection label to display the current selection and its 'path' (parent categories)
Private Sub lUpdateSelectionLabel
	Dim strLabel As String = "Select an item below..."
	If mSelectedMainCatKey <> -1  Then strLabel = "Selected: " & Starter.DataBase.GetMainCatName(mSelectedMainCatKey)
	If mSelectedSubCatKey <> -1 Then strLabel = strLabel & " > " & Starter.DataBase.GetSubCatName(mSelectedSubCatKey)
	If mSelectedGroupCatKey <> -1 Then strLabel = strLabel & " > " & Starter.DataBase.GetGroupCatName(mSelectedGroupCatKey)
	If mSelectedGoodsDescKey <> -1 Then
		Dim goodsObj As clsGoodsTableRec = Starter.DataBase.GetGoodsTableRec(mSelectedGoodsDescKey)
		strLabel = strLabel & " > " & goodsObj.description
	End If
	lblSelection.text = strLabel
End Sub

' Updates the Subtotal label to display the current subtotal price (item's individual cost * quantity).
Private Sub lUpdateSubtotalLabel
	Dim qty As Int  = lblQty.Text
	Dim priceTotal As Float = (Starter.DataBase.GetUnitPrice(mSelectedSizePriceKey)) * qty
	lblTotal.Text = "Item Subtotal: £" & modEposApp.FormatCurrency(priceTotal)
End Sub

#End Region  Local Subroutines
