B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=7.3
@EndOfDesignText@
'
' Handles Records within the SizePrice table
'
#Region  Documentation
	'
	' Name......: clsSizePriceTableRec
	' Release...: 2
	' Date......: 03/06/18
	'
	' History
	' Date......: 23/12/17
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
	'
	' Date......: 03/06/18
	' Release...: 2
	' Overview..: Bugfix: Now reads in-stock value correctly (before always returned out-of-stock)
	' Amendee...: D Morris
	' Details...: Mod: pGetTableRecord() code corrected.
	'             Mod: Old commented out code removed.
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
	Public key As Int
	Public size As Int
	Public unitPrice As Float
	Public goodsId As Int
	Public inStock As Boolean
	Public lastUpdate As Int	
End Sub
#End Region

#Region Public Subroutines
'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
		
End Sub

Public Sub pGetTableRecord(sizePriceRec As Map) As clsSizePriceTableRec
	Dim tempSizePriceRec As clsSizePriceTableRec: tempSizePriceRec.Initialize

	tempSizePriceRec.key = sizePriceRec.Get("key")
	tempSizePriceRec.size = sizePriceRec.Get("size")
	tempSizePriceRec.unitPrice = sizePriceRec.Get("unitPrice")
	tempSizePriceRec.goodsId = sizePriceRec.Get("goodsId")
	tempSizePriceRec.inStock = modConvert.ConvertStringToBoolean(sizePriceRec.Get("inStock"))
	tempSizePriceRec.lastUpdate = sizePriceRec.Get("lastUpdate")
	Return tempSizePriceRec
End Sub
#End Region


#Region Local Subroutines

#End Region
