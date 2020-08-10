B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=7.3
@EndOfDesignText@
'
' Class to handle SubCategory table record
'
#Region  Documentation
	'
	' Name......: clsSubCategoryTableRec
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

Public Sub pGetTableRecord(subCategoryRec As Map) As clsSubCategoryTableRec
	Dim tempSubCategoryRec As clsSubCategoryTableRec: tempSubCategoryRec.Initialize
	tempSubCategoryRec.key = subCategoryRec.Get("key")
	tempSubCategoryRec.value = subCategoryRec.Get("value")
	Return tempSubCategoryRec
End Sub
#End Region


#Region Local Subroutines

#End Region
