B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=7.3
@EndOfDesignText@
'
' Class to handle description tables
'
#Region  Documentation
	'
	' Name......: clsDescriptionTableRec
	' Release...: 2
	' Date......: 10/02/20
	'
	' History
	' Date......: 23/12/17
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking.
	'
	' Date......: 10/02/20
	' Release...: 2
	' Overview..: Fix: #0074 Changes to support the description table.
	' Amendee...: D Morris
	' Details...: Added: pGetTableRecord().
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
	Public key As Int ' The ID number of the item description.
	Public value As String ' The name of the item.
End Sub

#End Region

#Region Public Subroutines
'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize

End Sub

Public Sub pGetTableRecord(descriptionRec As Map) As clsDescriptionTableRec
	Dim tempDescriptionRec As clsDescriptionTableRec: tempDescriptionRec.Initialize
	tempDescriptionRec.key = descriptionRec.Get("key")
	tempDescriptionRec.value = descriptionRec.Get("value")
	Return tempDescriptionRec
End Sub

#End Region

#Region Local Subroutines

#End Region