B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=7.3
@EndOfDesignText@
'
' This class handles the Database Tables.
'

#Region  Documentation
	'
	' Name......: clsDataBaseTables
	' Release...: 10
	' Date......: 25/03/20   
	'
	' History
	' Date......: 23/12/17
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
	'
	' Versions
	'		2 - 8 	see v9
	'
	' Date......: 10/02/20
	' Release...: 9
	' Overview..: Fix: #0074 Changes to support the description table.
	' Amendee...: D Morris
	' Details...:  Mod: General changes to support description table.
	'
	' Date......: 25/03/20
	' Release...: 10
	' Overview..: Text changed - no code changed.
	' Amendee...: D Morris.
	' Details...:  Mod: No code changed.
	'
	' Date......: 
	' Release...: 
	' Overview..: 
	' Amendee...: 
	' Details...: 
	'
#End Region

#Region  Mandatory Subroutines & Data

Sub Class_Globals
	' Menu information.
	Public mainCatTable As List 	' List (Of clsMainCategoryTableRec)'TODO: Check if maps (instead of lists) give improve performance. 
	Public subCatTable As List 		' List (Of clsSubCategoryTableRec).
	Public sizeOptTable As List 	' List (Of clsSizeOptionTableRec).
	Public sizePriceTable As List 	' List (Of clsSizePriceTableRec).
	Public groupCatTable As List 	' List (Of clsGroupCategoryTableRec).
	Public goodsTable As List 		' List (Of clsGoodsTableRec).
	Public descriptionTable As List ' list (Of clsDescriptionTableRec).
	Public preparationTable As List ' list (Of clsPreparationTableRec).
	
	Type tempClsSubCategoryTableRec(key As Int, value As String)
	Type tempClsGroupCategoryTableRec(key As Int, value As String)
	Type tempClsSizePriceTableRec(key As Int, value As String, price As Float, sizeOptKey As Int, inStock As Boolean)
	Type tempClsSizeOptionTableRec(key As Int, value As String, sizeOptKey As Int)
	
End Sub

#End Region

#Region Public Subroutines

' Get a description string for the specified descriptionId (as number).
Public Sub GetDescription(descriptionId As Int) As String
	Dim mDescription As String = "Description not found!"
	
	For Each item As clsDescriptionTableRec In descriptionTable
		If item.key = descriptionId Then
			mDescription = item.value
			Exit
		End If
	Next
	Return mDescription
End Sub

' Get a goodsTable record for the specified goodsId (as number)
Public Sub GetGoodsTableRec(goodsId As Int) As clsGoodsTableRec
	Dim mGoodsTableRec As clsGoodsTableRec : mGoodsTableRec.initialize
	
	For Each item As clsGoodsTableRec In goodsTable
		If item.key = goodsId Then
			mGoodsTableRec = item
			Exit
		End If
	Next
	Return mGoodsTableRec
End Sub

' Get the Group and description names for a specified goodsId (returns as a displayable string)
public Sub GetGroupAndDescriptionName(goodsId As Int) As String
	Dim mGroupAndDescription As String = "Goods Item not found!"
	
	For Each item As clsGoodsTableRec In goodsTable
		If (item.key = goodsId) Then
			mGroupAndDescription = GetGroupCatName(item.groupCategory) & " – " & GetDescription(item.descId)
			Exit
		End If
	Next
	Return mGroupAndDescription
End Sub

' Get the GroupCategory name corresponding to the specified groupCatType (as number)
Public Sub GetGroupCatName(groupCatType As Int) As String
	Dim groupCatName As String
	
	For Each item As clsGroupCategoryTableRec In groupCatTable
		If item.key = groupCatType Then
			groupCatName = item.value
			Exit ' Exit for loop
		End If
	Next
	Return groupCatName
End Sub

' Get the Main Category name corresponding to the specified mainCatType (as number)
Public Sub GetMainCatName(mainCatType As Int) As String
	Dim mainCatName As String
	
	For Each item As clsMainCategoryTableRec In mainCatTable
		If item.key = mainCatType Then
			mainCatName = item.value
			Exit
		End If
	Next
	Return mainCatName
End Sub

' Get the price for a goods item of a specified size
public Sub GetPriceForSize(goodsId As Int, sizeId As Int) As Float
	Dim price As Float
	
	For Each item As clsSizePriceTableRec In sizePriceTable
		If item.goodsId = goodsId And item.size = sizeId Then
			price = item.unitPrice
		End If
	Next
	Return price
End Sub


' Get the sizeOption name corresponding to the specified sizeOptType (as number)
Public Sub GetSizeOptName(sizeOptType As Int) As String
	Dim sizeOptionName As String
	
	For Each item As clsSizeOptionTableRec In sizeOptTable
		If item.key = sizeOptType Then
			sizeOptionName = item.value
			Exit 
		End If
	Next
	Return sizeOptionName
End Sub

' Get a record from the sizePrice table 
Public Sub GetSizePriceRec(sizePriceId As Int) As clsSizePriceTableRec
	Dim mSizePriceRec As clsSizePriceTableRec : mSizePriceRec.initialize
	
	For Each item As clsSizePriceTableRec In sizePriceTable
		If item.key = sizePriceId Then
			mSizePriceRec = item
		End If
	Next
	Return mSizePriceRec
End Sub

' Get the SubCategory name corresponding to the specified subCatType (as number)
'  Return name as string, null if not found
Public Sub GetSubCatName(subCatType As Int) As String
	Dim subCatName As String
	
	For Each item As clsSubCategoryTableRec In subCatTable
		If item.key = subCatType Then
			subCatName = item.value
			Exit ' Exit for loop
		End If
	Next
	Return subCatName
End Sub

' Get a unit price from the sizePrice table (using the priceKey)
Public Sub GetUnitPrice(sizePricekey As Int) As Float
	Dim retPrice As Float
	
	For Each item As clsSizePriceTableRec In sizePriceTable
		If item.key = sizePricekey Then
			retPrice = item.unitPrice
			Exit
		End If
	Next
	Return retPrice
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	mainCatTable.Initialize
	subCatTable.Initialize
	sizeOptTable.Initialize
	sizePriceTable.Initialize
	groupCatTable.Initialize
	goodsTable.Initialize
	descriptionTable.Initialize
	preparationTable.Initialize
End Sub


' Produces a table if goodsId's (sorted in ascending description order) that have 
'			the specified mainCategory, subCategory and groupCategory types.
' Returns list(of descriptionAbridgedTableRec).
public Sub SortGoods(groupCatType As Int, subCatType As Int, mainCatType As Int) As List
	Dim mSortedGoodsTable As List : mSortedGoodsTable.initialize
	Dim mSortedDescriptionTable As List : mSortedDescriptionTable.initialize
	
	' First fill mSortedDescriptionTable with clsDescriptionTableRec
	For Each item As clsGoodsTableRec In goodsTable
		If (item.groupCategory = groupCatType) And (item.subCategory = subCatType) And (item.mainCategory = mainCatType) Then
			Dim mDescriptionTableRec As descriptionAbridgedTableRec : mDescriptionTableRec.initialize
			mDescriptionTableRec.key = item.key

'			mDescriptionTableRec.value = item.description

			mDescriptionTableRec.value = GetDescription(item.descId)

			mSortedDescriptionTable.Add(mDescriptionTableRec)
		End If
	Next
	mSortedDescriptionTable.SortType("value", True)' Sort the description list
	Return mSortedDescriptionTable
End Sub

' Produces a sorted table of groupCategory's whose goods (in goodsTable) 
'	have the specified subCategory and mainCategory types.
' Returns list(of clsGroupCategoryTableRec)
Public Sub SortGrpCat(subCatType As Int, mainCatType As Int) As List
	Dim mSortedGrpCatTable As List : mSortedGrpCatTable.initialize
	Dim mAddedGrpCat As List : mAddedGrpCat.initialize ' This is necessary to check if item has already been added
	
	For Each item As clsGoodsTableRec In goodsTable
		If (item.subCategory = subCatType) And (item.mainCategory = mainCatType)Then
			Dim mGrpCatTableRec As tempClsGroupCategoryTableRec : mGrpCatTableRec.initialize
			mGrpCatTableRec.key = item.groupCategory
			If mAddedGrpCat.IndexOf(mGrpCatTableRec.key) = -1 Then ' Add to list if not already added (note list.IndexOf() on works for simple type it don't work of custom types
				' See https://www.b4x.com/android/forum/threads/list-indexof-problem.17093/ for details
				mGrpCatTableRec.value = GetGroupCatName(mGrpCatTableRec.key)
				mSortedGrpCatTable.Add(mGrpCatTableRec)
				mAddedGrpCat.Add(mGrpCatTableRec.key)
			End If
		End If
	Next
	mSortedGrpCatTable.SortType("value", True)
	' Convert the list of user types to list of clsSubCategoryTableRec
	Dim retSortedGroupCat As List : retSortedGroupCat.initialize
	For Each record As tempClsGroupCategoryTableRec In mSortedGrpCatTable
		Dim groupCatRec As clsGroupCategoryTableRec : groupCatRec.initialize
		groupCatRec.key = record.key
		groupCatRec.value = record.value
		retSortedGroupCat.Add(groupCatRec)
	Next
	Return retSortedGroupCat
End Sub

' Produces a table of goods ID with the specified mainCategory.
' Returns list(of clsGoodsTableRec).
' TODO Check if this sub is necessary
public Sub SortMainCat(mainCatType As Int) As List
	Dim mSortedMainCatTable As List : mSortedMainCatTable.initialize
	
	For Each item As clsGoodsTableRec In goodsTable
		If item.mainCategory = mainCatType Then
			mSortedMainCatTable.Add(item.key)
		End If
	Next
	Return mSortedMainCatTable
End Sub

' Sort the size options available for a particular goods item in the sizePrices Table.
' Returns list(of clsSizeOptionTableRec).
public Sub SortSizeOption(goodsId As Int) As List
	Dim mSortedSizeOptTable As List : mSortedSizeOptTable.initialize
	Dim mAddedSizeOpt As List : mAddedSizeOpt.initialize

	For Each item As clsSizePriceTableRec In sizePriceTable
		If item.goodsId = goodsId Then
			Dim mSizeOptionTableRec As tempClsSizeOptionTableRec : mSizeOptionTableRec.initialize
			mSizeOptionTableRec.key = item.key
			If mAddedSizeOpt.IndexOf(mSizeOptionTableRec.key) = -1 Then ' Add to list if not already added (note list.IndexOf() on works for simple type it don't work of custom types
			' See https://www.b4x.com/android/forum/threads/list-indexof-problem.17093/ for details
				mSizeOptionTableRec.value = GetSizeOptName(item.size)
				mSortedSizeOptTable.Add(mSizeOptionTableRec)
				mAddedSizeOpt.Add(mSizeOptionTableRec)
			End If
		End If
	Next
	mSortedSizeOptTable.SortType("value", True)
	' Convert the list of user types to list of clsSizeOptionTableRec
	Dim retSortedSizeOpt As List : retSortedSizeOpt.initialize
	For Each record As tempClsSizeOptionTableRec In mSortedSizeOptTable
		Dim sizeOptRec As clsSizeOptionTableRec : sizeOptRec.initialize
		sizeOptRec.key = record.key
		sizeOptRec.value = record.value
		retSortedSizeOpt.Add(sizeOptRec)
	Next
	Return retSortedSizeOpt
End Sub

' Sort the size/price values available for a particular goods item in the sizePrices table.
' Returns List (of sizePriceTableRec)
public Sub SortSizePrice(goodsId As Int) As List ' List (of sizePriceTableRec)
	Dim mSortedSizePriceTable As List : mSortedSizePriceTable.initialize
	Dim mAddedSizePrice As List : mAddedSizePrice.initialize
	
	For Each item As clsSizePriceTableRec In sizePriceTable
		If item.goodsId = goodsId Then
			Dim mSizePriceTableRec As tempClsSizePriceTableRec : mSizePriceTableRec.initialize
			mSizePriceTableRec.sizeOptKey = item.size
			If mAddedSizePrice.IndexOf(mSizePriceTableRec.sizeOptKey) = -1 Then
				Dim priceStr As String = " (£" & modEposApp.FormatCurrency(item.unitPrice) & ")"
				mSizePriceTableRec.value = GetSizeOptName(mSizePriceTableRec.sizeOptKey) & priceStr
				mSizePriceTableRec.key = item.key
				mSizePriceTableRec.inStock = item.inStock
				mSortedSizePriceTable.Add(mSizePriceTableRec)
				mAddedSizePrice.Add(mSizePriceTableRec)
			End If
		End If
	Next
	mSortedSizePriceTable.SortType("price", True)	
	Dim retSortedSizePrice As List : retSortedSizePrice.initialize
	For Each record As tempClsSizePriceTableRec In mSortedSizePriceTable
		Dim mSizePriceRec As sizePriceTableRec : mSizePriceRec.initialize
		mSizePriceRec.sizePriceKey = record.key
		mSizePriceRec.sizePrice = record.value
		mSizePriceRec.sizeOptKey = record.sizeOptKey
		mSizePriceRec.inStock = record.inStock
		retSortedSizePrice.Add(mSizePriceRec)
	Next
	Return retSortedSizePrice
End Sub

' Produces a sorted table of subCategory's whose goods (in goodsTable) have the specified mainCategory type.
' Returns List(of clsSubCategoryTableRec) 
Public Sub SortSubCat( mainCatType As Int) As List
	Dim mSortedSubCatTable As List : mSortedSubCatTable.initialize
	Dim mAddedSubCat As List : mAddedSubCat.initialize ' This is necessary to check if item has already been added
	
	For Each item As clsGoodsTableRec In goodsTable
		If item.mainCategory = mainCatType Then
			Dim mSubCatTableRec As tempClsSubCategoryTableRec : mSubCatTableRec.initialize
			mSubCatTableRec.key = item.subCategory
			If mAddedSubCat.IndexOf(mSubCatTableRec.key) = -1 Then ' Add to list if not already added (note list.IndexOf() on works for simple type it don't work of custom types
				' See https://www.b4x.com/android/forum/threads/list-indexof-problem.17093/ for details			
				mSubCatTableRec.value = GetSubCatName(mSubCatTableRec.key)
				mSortedSubCatTable.Add(mSubCatTableRec)
				mAddedSubCat.Add(mSubCatTableRec.key)
			End If
		End If
	Next
	mSortedSubCatTable.SortType("value", True)
	' Convert the list of user types to list of clsSubCategoryTableRec
	Dim retSortedSubCat As List : retSortedSubCat.initialize
	For Each record As tempClsSubCategoryTableRec In mSortedSubCatTable
		Dim SubCatRec As clsSubCategoryTableRec : SubCatRec.initialize
		SubCatRec.key = record.key
		SubCatRec.value = record.value
		retSortedSubCat.Add(SubCatRec)
	Next
	Return retSortedSubCat
End Sub

' Returns an instance of this object containing the data contained in the specified XML string.
Public Sub XmlDeserialize(xmlString As String) As clsDataBaseTables
	Dim parsedData As Map
	Dim localRetObject As clsDataBaseTables ' Local working copy of object
	localRetObject.Initialize
	Dim Xm As Xml2Map
	Xm.Initialize
	parsedData = Xm.Parse(xmlString)
'	Log(xmlString) ' Output log
	DateTime.DateFormat = "HH:mm:ss"
	Dim timeStamp As String = "Time:" & DateTime.Date(DateTime.Now)
	Log("XML Start parsing :" & timeStamp)	
	Dim dataBaseTables As Map = parsedData.Get("clsDbItemInfo") 
	
	' TODO - Look into using some common code to reduce the size of this Sub
	' Update Main Category table
	timeStamp = "Time:" & DateTime.Date(DateTime.Now)
	Log("Parsing XML complete:" & timeStamp )
	If dataBaseTables.Get("mainCatTable") Is Map Then	' Bit of protection - Check if main cat available
		Dim mainCatList As Map = dataBaseTables.Get("mainCatTable")
		' Fix to deal with single and no items - based on https://www.b4x.com/android/forum/threads/xml2map-error-while-parsing-rss.75274/#post-478013'
		If mainCatList.Get("clsMainCategoryTableRec") Is List Then ' List of main category records?
			Dim localMainCatList As List = mainCatList.Get("clsMainCategoryTableRec")
			For Each item As Map In localMainCatList
				localRetObject.mainCatTable.Add(lGetMainCategoryRec(item))
			Next
		Else if mainCatList.Get("clsMainCategoryTableRec") Is Map Then ' Single main category?
			Dim mainCatListMap As Map = mainCatList.Get("clsMainCategoryTableRec")
			localRetObject.mainCatTable.Add(lGetMainCategoryRec(mainCatListMap))
		End If
	End If
	' Update Sub Category table
	If dataBaseTables.Get("subCatTable") Is Map Then	' Bit of protection - Check if sub cat available
		Dim subCatList As Map = dataBaseTables.Get("subCatTable")
		' Fix to deal with single and no items - based on https://www.b4x.com/android/forum/threads/xml2map-error-while-parsing-rss.75274/#post-478013'
		If subCatList.Get("clsSubCategoryTableRec") Is List Then ' List of sub category records?
			Dim localSubCatList As List = subCatList.Get("clsSubCategoryTableRec")
			For Each item As Map In localSubCatList
				localRetObject.subCatTable.Add(lGetSubCategoryRec(item))
			Next
		Else if subCatList.Get("clsSubCategoryTableRec") Is Map Then ' Single sub category?
			Dim subCatListMap As Map = subCatList.Get("clsSubCategoryTableRec")
			localRetObject.subCatTable.Add(lGetSubCategoryRec(subCatListMap))
		End If
	End If
	' Update Size Option table
	If dataBaseTables.Get("sizeOptTable") Is Map Then	' Bit of protection - Check if Size Option available
		Dim sizeOptionList As Map = dataBaseTables.Get("sizeOptTable")
		' Fix to deal with single and no items - based on https://www.b4x.com/android/forum/threads/xml2map-error-while-parsing-rss.75274/#post-478013'
		If sizeOptionList.Get("clsSizeOptionTableRec") Is List Then ' List of size option records?
			Dim localSizeOptionList As List = sizeOptionList.Get("clsSizeOptionTableRec")
			For Each item As Map In localSizeOptionList
				localRetObject.sizeOptTable.Add(lGetSizeOptionRec(item))
			Next
		Else if sizeOptionList.Get("clsSubCategoryTableRec") Is Map Then ' Single size option category?
			Dim sizeOptionListMap As Map = sizeOptionList.Get("clsSizeOptionTableRec")
			localRetObject.sizeOptTable.Add(lGetSizeOptionRec(sizeOptionListMap))
		End If
	End If
	' Udpate Size Price table
	If dataBaseTables.Get("sizePriceTable") Is Map Then	' Bit of protection - Check if Size Price available
		Dim sizePriceList As Map = dataBaseTables.Get("sizePriceTable")
		' Fix to deal with single and no items - based on https://www.b4x.com/android/forum/threads/xml2map-error-while-parsing-rss.75274/#post-478013'
		If sizePriceList.Get("clsSizePriceTableRec") Is List Then ' List of size price records?
			Dim localSizePriceList As List = sizePriceList.Get("clsSizePriceTableRec")
			For Each item As Map In localSizePriceList
				localRetObject.sizePriceTable.Add(lGetSizePriceRec(item))
			Next
		Else if sizePriceList.Get("clsSizePriceTableRec") Is Map Then ' Single size price category?
			Dim sizePriceListMap As Map = sizePriceList.Get("clsSizePriceTableRec")
			localRetObject.sizePriceTable.Add(lGetSizePriceRec(sizePriceListMap))
		End If
	End If
	' Udpate Group Category table
	If dataBaseTables.Get("groupCatTable") Is Map Then	' Bit of protection - Check if Group category available
		Dim groupCatList As Map = dataBaseTables.Get("groupCatTable")
		' Fix to deal with single and no items - based on https://www.b4x.com/android/forum/threads/xml2map-error-while-parsing-rss.75274/#post-478013'
		If groupCatList.Get("clsGroupCategoryTableRec") Is List Then ' List of group category records?
			Dim localGroupCatList As List = groupCatList.Get("clsGroupCategoryTableRec")
			For Each item As Map In localGroupCatList
				localRetObject.groupCatTable.Add(lGetGroupCategoryRec(item))
			Next
		Else if groupCatList.Get("clsGroupCategoryTableRec") Is Map Then ' Single group category?
			Dim groupCatListMap As Map = groupCatList.Get("clsGroupCategoryTableRec")
			localRetObject.groupCatTable.Add(lGetGroupCategoryRec(groupCatListMap))
		End If
	End If
	
	' Udpate Goods table
	If dataBaseTables.Get("goodsTable") Is Map Then	' Bit of protection - Check if Goods available
		Dim goodsList As Map = dataBaseTables.Get("goodsTable")
		' Fix to deal with single and no items - based on https://www.b4x.com/android/forum/threads/xml2map-error-while-parsing-rss.75274/#post-478013'
		If goodsList.Get("clsGoodsTableRec") Is List Then ' List of groups category records?
			Dim localGoodsList As List = goodsList.Get("clsGoodsTableRec")
			For Each item As Map In localGoodsList
				localRetObject.goodsTable.Add(lGetGoodsRec(item))
			Next
		Else if goodsList.Get("clsGoodsTableRec") Is Map Then ' Single group category?
			Dim goodsListMap As Map = goodsList.Get("clsGoodsTableRec")
			localRetObject.goodsTable.Add(lGetGoodsRec(goodsListMap))
		End If
	End If
	
	' Update Description table
	If dataBaseTables.Get("descriptionTable")  Is Map Then	' Bit of protection - Check if Descriptions available
		Dim descriptionList As Map = dataBaseTables.Get("descriptionTable")
		' Fix to deal with single and no items - based on https://www.b4x.com/android/forum/threads/xml2map-error-while-parsing-rss.75274/#post-478013'
		If descriptionList.Get("clsDescriptionTableRec") Is List Then ' List description records?
	'		Dim localDescriptionList As List = descriptionList.Get("clsDesciptionTableRec")
			Dim localDescriptionList As List : localDescriptionList.initialize() ' Not sure why we must initialize this List (when ok above and below).
			localDescriptionList = descriptionList.Get("clsDescriptionTableRec")
			For Each item As Map In localDescriptionList
				localRetObject.descriptionTable.Add(lGetDescriptionRec(item))
			Next
		Else if descriptionList.Get("clsDescriptionTableRec") Is Map Then ' Single size price category?
			Dim descriptionListMap As Map = descriptionList.Get("clsDescriptionTableRec")
			localRetObject.descriptionTable.Add(lGetDescriptionRec(descriptionListMap))
		End If
	End If
	
	' Udpate Preparation table
	If dataBaseTables.Get("preparationTable") Is Map Then	' Bit of protection - Check if perparations are available
		Dim preparationList As Map = dataBaseTables.Get("preparationTable")
		' Fix to deal with single and no items - based on https://www.b4x.com/android/forum/threads/xml2map-error-while-parsing-rss.75274/#post-478013'
		If preparationList.Get("clsPreparationTableRec") Is List Then ' List of groups category records?
			Dim localPreparationList As List = preparationList.Get("clsPreparationTableRec")
			For Each item As Map In localPreparationList
				localRetObject.preparationTable.Add(lGetPreparationRec(item))
			Next
		Else if preparationList.Get("clsPreparationTableRec") Is Map Then ' Single group category?
			Dim preparationListMap As Map = preparationList.Get("clsPreparationTableRec")
			localRetObject.preparationTable.Add(lGetPreparationRec(preparationListMap))
		End If
	End If
	
	Return localRetObject
	
End Sub

#End Region

#Region local Subroutines

Private Sub lGetDescriptionRec(descriptionRec As Map) As clsDescriptionTableRec
	Dim tempDescriptionRec As clsDescriptionTableRec : tempDescriptionRec.initialize
	Return tempDescriptionRec.pGetTableRecord(descriptionRec)
End Sub

Private Sub lGetMainCategoryRec(mainCategoryRec As Map) As clsMainCategoryTableRec
	Dim tempMainCategoryRec As clsMainCategoryTableRec: tempMainCategoryRec.Initialize
	Return tempMainCategoryRec.pGetTableRecord(mainCategoryRec)
End Sub

Private Sub lGetPreparationRec(preparationRec As Map) As clsPreparationTableRec
	Dim tempPreparationRec As clsPreparationTableRec: tempPreparationRec.Initialize
	Return tempPreparationRec.pGetTableRecord(preparationRec)
End Sub

Private Sub lGetSubCategoryRec(subCategoryRec As Map) As clsSubCategoryTableRec
	Dim tempSubCategoryRec As clsSubCategoryTableRec: tempSubCategoryRec.Initialize
	Return tempSubCategoryRec.pGetTableRecord(subCategoryRec)
End Sub

Private Sub lGetSizeOptionRec(sizeOptionRec As Map) As clsSizeOptionTableRec
	Dim tempSizeOptionRec As clsSizeOptionTableRec: tempSizeOptionRec.Initialize
	Return tempSizeOptionRec.pGetTableRecord(sizeOptionRec)
End Sub

Private Sub lGetSizePriceRec(sizePriceRec As Map) As clsSizePriceTableRec
	Dim tempSizePriceRec As clsSizePriceTableRec: tempSizePriceRec.Initialize
	Return tempSizePriceRec.pGetTableRecord(sizePriceRec)
End Sub

Private Sub lGetGroupCategoryRec(groupCategoryRec As Map) As clsGroupCategoryTableRec
	Dim tempGroupCategoryRec As clsGroupCategoryTableRec: tempGroupCategoryRec.Initialize
	Return tempGroupCategoryRec.pGetTableRecord(groupCategoryRec)
End Sub

Private Sub lGetGoodsRec(goodsRec As Map) As clsGoodsTableRec
	Dim tempGoodsRec As clsGoodsTableRec: tempGoodsRec.Initialize
	Return tempGoodsRec.pGetTableRecord(goodsRec)
End Sub

#End Region
