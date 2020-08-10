B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=7.3
@EndOfDesignText@
'
' Handles Records within the Group Category table
'
#Region  Documentation
	'
	' Name......: clsGroupCategoryTableRec
	' Release...: 1
	' Date......: 23/12/17
	'
	' History
	' Date......: 23/12/17
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
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
	Public value As String
End Sub
#End Region

#Region Public Subroutines
'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize

End Sub

Public Sub pGetTableRecord(groupCatRec As Map) As clsGroupCategoryTableRec
	Dim tempGroupCatRec As clsGroupCategoryTableRec: tempGroupCatRec.Initialize
	tempGroupCatRec.key = groupCatRec.Get("key")
	tempGroupCatRec.value = groupCatRec.Get("value")
	Return tempGroupCatRec
End Sub
#End Region


#Region Local Subroutines

#End Region
