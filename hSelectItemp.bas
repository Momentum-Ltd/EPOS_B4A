B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
'
' This is a help class for template
'
#Region  Documentation
	'
	' Name......: hXXXXX
	' Release...: -
	' Date......: --/10/19
	'
	' History
	' Date......: --/10/19
	' Release...: 1
	' Created by: D Morris (started 3/8/19)
	' Details...: Based on .
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
	' X-platform related.
	Private xui As XUI			'ignore
	
	' Activity view declarations
	' Private btnXXXX As  B4XView
	
	' Misc objects
	Private progressbox As clsProgressDialog	' Progress box
	
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize (parent As B4XView)
'	parent.LoadLayout("formLayoutFile")
'	InitializeLocals

End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

#End Region  Event Handlers

#Region  Public Subroutines

#End Region  Public Subroutines

#Region  Local Subroutines
' Initialize the locals etc.
private Sub InitializeLocals
	progressbox.Initialize(Me, "progressbox", modEposApp.DFT_PROGRESS_TIMEOUT)
End Sub

' Show the process box
Private Sub ProgressHide
	progressbox.Hide
End Sub

' Hide The process box.
Private Sub ProgressShow(message As String)
	progressbox.Show(message)
End Sub

#End Region  Local Subroutines