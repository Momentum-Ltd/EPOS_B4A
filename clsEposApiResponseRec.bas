B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=10.2
@EndOfDesignText@
'
' Class to provide information about Epos API response. 
'
#Region  Documentation
	'
	' Name......: clsEposApiResponsemRec
	' Release...: 1
	' Date......: 15/12/20
	'
	' History
	' Date......: 15/12/20
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
	Public success As Boolean		' Http job success flag.
	Public statusCode As Int		' Http job status code.
	Public responseStr As String	' Http job response string.
End Sub
#End Region

#Region Public Subroutines
'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize

End Sub
#End Region


#Region Local Subroutines

#End Region
