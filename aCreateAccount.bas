B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=9.01
@EndOfDesignText@
'
' Activity to Create a new user account.
'
#Region  Documentation
	' Name......: aCreateAccount
	' Release...: 1
	' Date......: 28/01/21   
	'
	' History
	' Date......: 28/01/21
	' Release...: 1
	' Created by: D Morris
	' Details...: Based on CreateAccount_v7 renamed to aCreateAccount.
	'
	' Date......: 
	' Release...: 
	' Overview..: 
	' Amendee...: 
	' Details...: 
	'
#End Region  Documentation

#Region  Activity Attributes 
	#FullScreen: true
	#IncludeTitle: false
#End Region

#Region  Mandatory Subroutines & Data

Sub Process_Globals

End Sub

Sub Globals
	Private hc As hCreateAccount 		' This activity's helper class.	
End Sub

Private Sub Activity_Create(FirstTime As Boolean)
	hc.Initialize(Activity)
End Sub

' Back button 
Private Sub Activity_Keypress(KeyCode As Int) As Boolean
	Return False ' ensures backbutton works
End Sub

Private Sub Activity_Pause (UserClosed As Boolean)
	hc.OnClose
End Sub

Private Sub Activity_Resume

End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

#End Region  Event Handlers

#Region  Public Subroutines

#End Region  Public Subroutines
' Returns to caller.
public Sub GoBackToCaller
	Activity.Finish
End Sub
#Region  Local Subroutines

#End Region  Local Subroutines


