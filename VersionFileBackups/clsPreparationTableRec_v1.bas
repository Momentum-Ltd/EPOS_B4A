B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=9.8
@EndOfDesignText@
'
' Class to handle Preparation table record
'
#Region  Documentation
	'
	' Name......: clsPreparationTableRec
	' Release...: 1
	' Date......: 09/02/20
	'
	' History
	' Date......: 09/02/20
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

Public Sub pGetTableRecord(preparationRec As Map) As clsPreparationTableRec
	Dim tempPreparationRec As clsPreparationTableRec: tempPreparationRec.Initialize
	tempPreparationRec.key = preparationRec.Get("key")
	tempPreparationRec.value = preparationRec.Get("value")
	Return tempPreparationRec
End Sub
#End Region


#Region Local Subroutines

#End Region