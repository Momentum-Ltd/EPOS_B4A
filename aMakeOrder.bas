B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=9.5
@EndOfDesignText@
'
' This X-platform activity for Make Order.
'
#Region  Documentation
	'
	' Name......: aMakeOrder
	' Release...: 
	' Date......: 20/10/19
	'
	' History
	' Date......: 20/10/19
	' Release...: -
	' Created by: D Morris
	' Details...: based on ShowOrder_v27.
	'
	' History
	'
	' Date......: 
	' Release...: 
	' Overview..: 
	' Amendee...: 
	' Details...: 
	'
#End Region  Documentation

#Region  Activity Attributes
	#FullScreen: False
	#IncludeTitle: False
#End Region  Activity Attributes

#Region  Mandatory Subroutines & Data

Sub Process_Globals
	' Currently none
End Sub

Sub Globals
	Private hc As hMakeOrder		' This activity's helper class.
End Sub

Sub Activity_Create(FirstTime As Boolean)
	hc.Initialize(Activity)
End Sub

Sub Activity_Resume
	hc.ResumeOp
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	If Starter.DisconnectedCloseActivities Then
		Activity.Finish
	End If
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

#End Region  Event Handlers

#Region  Public Subroutines
' Handles the response from the Server to the Order message.
Public Sub pHandleOrderResponse(orderResponseStr As String)
	hc.pHandleOrderResponse(orderResponseStr)
End Sub
#End Region  Public Subroutines

#Region  Local Subroutines

#End Region  Local Subroutines
