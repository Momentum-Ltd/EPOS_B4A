B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=7.3
@EndOfDesignText@
'
' Class to handle main category table record
'
#Region  Documentation
	'
	' Name......: clsMainCategoryTableRec
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

public Sub pGetTableRecord(mainCategoryRec As Map) As clsMainCategoryTableRec
	Dim tempMainCategoryRec As clsMainCategoryTableRec: tempMainCategoryRec.Initialize
	tempMainCategoryRec.key = mainCategoryRec.Get("key")
	tempMainCategoryRec.value = mainCategoryRec.Get("value")
	Return tempMainCategoryRec
End Sub
#End Region


#Region Local Subroutines

#End Region
