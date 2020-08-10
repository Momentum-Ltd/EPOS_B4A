B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=7.3
@EndOfDesignText@
'
' Handles Records within the Goods table
'
#Region  Documentation
	'
	' Name......: clsGoodsTableRec
	' Release...: 2
	' Date......: 10/02/20
	'
	' History
	' Date......: 23/12/17
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
	'
	' Date......: 10/02/20
	' Release...: 2
	' Overview..: Fix: #0074 Changes to support the description table.
	' Amendee...: D Morris
	' Details...:   Added: descId.
	'			   Remove: description (replaced by descId).
	'			     Mods: pGetTableRecord().
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
	Public mainCategory As Int
	Public subCategory As Int
	Public groupCategory As Int
'	Public description As String ' try to remove after description fix.
	Public descId As Int
End Sub
#End Region

#Region Public Subroutines
'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize

End Sub


Public Sub pGetTableRecord(goodsRec As Map) As clsGoodsTableRec
	Dim tempGoodsRec As clsGoodsTableRec: tempGoodsRec.Initialize
	
	tempGoodsRec.key = goodsRec.Get("key")
	tempGoodsRec.mainCategory = goodsRec.Get("mainCategory")
	tempGoodsRec.subCategory = goodsRec.Get("subCategory")
	tempGoodsRec.groupCategory = goodsRec.Get("groupCategory")
'	tempGoodsRec.description = goodsRec.Get("description")
	tempGoodsRec.descId = goodsRec.Get("descId")
	Return tempGoodsRec
End Sub
#End Region

#Region Local Subroutines

#End Region
