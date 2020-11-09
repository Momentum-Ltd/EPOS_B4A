B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=10.2
@EndOfDesignText@
'
' This class is used to store the centre information and image records
'

#Region  Documentation
	'
	' Name......: clsCentreInfoAndImgRec
	' Release...: 1
	' Date......: 08/11/20
	'
	' History
	' Date......: 08/11/20
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
#End Region  Documentation

#Region  Mandatory Subroutines & Data

Sub Class_Globals
	Public centre As clsEposWebCentreLocationRec
	Public imgPanel As Panel	
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	centre.Initialize
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Currently none

#End Region  Local Subroutines
