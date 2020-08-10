B4A=true
Group=Activities
ModulesStructureVersion=1
Type=Activity
Version=8.5
@EndOfDesignText@
'
' Activity which is used to send a repeated comms test sequence.
'

#Region  Documentation
	'
	' Name......: TestSequence
	' Release...: 2
	' Date......: 28/01/19   
	'
	' History
	' Date......: 25/10/18
	' Release...: 1
	' Created by: D Hathway
	' Details...: First release to support version tracking
	'
	' Date......: 28/01/19
	' Release...: 2
	' Overview..: Changes to allow the app to determine when it is no longer connected.
	' Amendee...: D Hathway
	' Details...: 
	'		Mod: Change in Activity_Pause() to kill this activity if the phone becomes disconnected from the server
	'
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
#End Region

#Region  Mandatory Subroutines & Data

Sub Process_Globals
	' Currently none
End Sub

Sub Globals
	
	' Local constants
	Private Const BTN_TEXT_STARTED As String = "Stop Comms Test" ' Text of the Start/Stop button when the test sequence is running.
	Private Const BTN_TEXT_STOPPED As String = "Start Comms Test" ' Text of the Start/Stop button when the test sequence isn't running.
	Private Const BTN_TEXT_RESUMED As String = "Pause Test" ' Text of the Pause/Resume button when the test sequence isn't paused.
	Private Const BTN_TEXT_PAUSED As String = "Resume Test" ' Text of the Pause/Resume button when the test sequence is paused.
	
	' View declarations
	Private btnClose As Button ' Button which closes the activity.
	Private btnPauseResume As Button ' Button which either pauses or resumes the test sequence.
	Private btnStartStop As Button ' Button which either starts or stops the test sequence.
	Private lblMessagesSent As Label ' Label which displays how many messages have been sent during the test sequence.
	Private lblMessageSuccessRate As Label ' Label which displays how many messages have succeeded and failed during the test sequence.
	Private txtInterval As EditText ' Textbox which allows the user to customise the interval between sending test messages.
	
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("frmTestSequence")
End Sub

Sub Activity_Resume
	' Currently nothing
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	If UserClosed Then CallSub(svcTestSequence, "pStopTestSequence") ' Make sure to stop the test sequence
	If Starter.DisconnectedCloseActivities Then Activity.Finish
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Handles the Click event of the Close button.
Private Sub btnClose_Click
	CallSub(svcTestSequence, "pStopTestSequence") ' Make sure to stop the test sequence
	Activity.Finish ' Kill this activity, returning the user to whichever activity originally called it
End Sub

' Handles the Click event of the Pause/Resume Test Sequence button.
Private Sub btnPauseResume_Click
	If btnPauseResume.Text = BTN_TEXT_RESUMED Then
		CallSub(svcTestSequence, "pPauseTestSequence")
		btnPauseResume.Text = BTN_TEXT_PAUSED
	Else If btnPauseResume.Text = BTN_TEXT_PAUSED Then
		CallSub(svcTestSequence, "pResumeTestSequence")
		btnPauseResume.Text = BTN_TEXT_RESUMED
	End If
End Sub

' Handles the Click event of the Start/Stop Test Sequence button.
Private Sub btnStartStop_Click
	If btnStartStop.Text = BTN_TEXT_STOPPED Then
		Dim intervalOk As Boolean = False
		If txtInterval.Text <> "" Then
			If IsNumber(txtInterval.Text) Then
				Dim sendingInterval As Int = txtInterval.Text
				If sendingInterval > 0 Then
					intervalOk = True
					lUpdateSentMsgsLabel(0)
					lUpdateMsgSuccessLabel(0,0)
					Dim initArgs As TestSeqInitialiseArgs : initArgs.Initialize
					initArgs.caller = Me
					initArgs.eventName = "TestSeqSvc"
					initArgs.sendInterval = sendingInterval
					CallSub2(svcTestSequence, "pStartTestSequence", initArgs)
					btnStartStop.Text = BTN_TEXT_STARTED
					btnPauseResume.Enabled = True
				End If
			End If
		End If
		
		If Not(intervalOk) Then MsgboxAsync("Invalid sending interval – please try again", "Error")
	Else If btnStartStop.Text = BTN_TEXT_STARTED Then
		CallSub(svcTestSequence, "pStopTestSequence")
		btnStartStop.Text = BTN_TEXT_STOPPED
		btnPauseResume.Enabled = False
	End If
	btnPauseResume.Text = BTN_TEXT_RESUMED
End Sub

' Handles the event raised by the Test Sequence service when a test command has been sent.
Private Sub TestSeqSvc_MsgSent(messagesSent As Int)
	lUpdateSentMsgsLabel(messagesSent)
End Sub

' Handles the event raised by the Test Sequence service when a test command has been completed (either responded to or timed out).
Private Sub TestSeqSvc_MsgDone(succeeded As Int, failed As Int)
	lUpdateMsgSuccessLabel(succeeded, failed)
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' Currently none

#End Region  Public Subroutines

#Region  Local Subroutines

' Updates the label which displays the number of sent messages with the specified value.
Private Sub lUpdateSentMsgsLabel(messagesSent As Int)
	lblMessagesSent.Text = "Sent " & messagesSent & " commands"
End Sub

' Updates the label which displays the number of successful/failed messages with the specified values.
Private Sub lUpdateMsgSuccessLabel(succeeded As Int, failed As Int)
	Dim percentageStr As String = ""
	Dim total As Int = succeeded + failed
	If total > 0 Then percentageStr = " (" & NumberFormat(((succeeded / total) * 100), 1, 2) & "%)"
	lblMessageSuccessRate.Text = succeeded & " succeeded, " & failed & " failed" & percentageStr
End Sub

#End Region  Local Subroutines
