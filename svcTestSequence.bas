B4A=true
Group=Services
ModulesStructureVersion=1
Type=Service
Version=8.5
@EndOfDesignText@
'
' Service which handles the Comms Test Sequence operations.
'

#Region  Documentation
	'
	' Name......: svcTestSequence
	' Release...: 3
	' Date......: 26/04/20
	'
	' History
	' Date......: 25/10/18
	' Release...: 1
	' Created by: D Hathway
	' Details...: First release to support version tracking
	'
	' Date......: 07/08/19
	' Release...: 2
	' Overview..: Support for myData.
	' Amendee...: D Morris
	' Details...: Mod: support for myData lSendNextTestCmd().
		'
	' Date......: 26/04/20
	' Release...: 3
	' Overview..: Bugfix: Integer to string conversion if numbers too big.
	' Amendee...: D Morris
	' Details...:  Mod: lSendNextTestCmd().
	'
	' Date......: 
	' Release...: 
	' Overview..:
	' Amendee...: 
	' Details...: 
	'
#End Region

#Region  Service Attributes 
	#StartAtBoot: False
#End Region

#Region  Mandatory Subroutines & Data

Sub Process_Globals
	
	' Local constants
	Private Const SEND_NEXT_CMD_INTERVAL As Int = 1000 ' The interval (in milliseconds) before sending the next command.
	Private Const CMD_RESPONSE_TIMEOUT As Int = 5000 ' The interval (in milliseconds) after which the command is deemed to have failed.
	
	' Public variables	
	Public TestSeqRunning As Boolean ' Whether the test sequence is currently in progress.
	
	' Public types
	Type TestSeqInitialiseArgs(caller As Object, eventName As String, sendInterval As Int)
	
	' Local variables
	Private mPaused As Boolean ' Whether the test sequence is currently paused.
	Private mCommandsSent As Int ' The number of test commands sent to the Server since the start of the current test sequence.
	Private mCommandsSucceeded As Int ' The number of times a response was received from the Server during the current test sequence.
	Private mCommandsFailed As Int ' The number of times the Server failed respond within the timeout during the current test sequence.
	Private mCallerObj As Object ' The object which originally called the test sequence (used for raising the events back to it).
	Private mEventName As String ' The prefix to be used in the title of the callback when raisig events.
	Private mNeedsToStop As Boolean ' Whether the test sequence has been instructed to stop.
	Private tmrSendNextTestCmd As Timer ' The timer used to create an interval between receiving a response and sending the next command.
	Private tmrTestCmdResponseTimeout As Timer ' The timer used as a timeout to determine that a response has failed to be received.
		
End Sub

Sub Service_Create
	tmrSendNextTestCmd.Initialize("tmrSendNextTestCmd", SEND_NEXT_CMD_INTERVAL)
	tmrTestCmdResponseTimeout.Initialize("tmrTestCmdResponseTimeout", CMD_RESPONSE_TIMEOUT)
End Sub

Sub Service_Start (StartingIntent As Intent)
	Service.StopAutomaticForeground ' May be necessary? https://www.b4x.com/android/forum/threads/automatic-foreground-mode.90546/
End Sub

Sub Service_Destroy
	' Currently nothing
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Handles the Tick event of the Send Next Message timer.
Private Sub tmrSendNextTestCmd_Tick
	If tmrSendNextTestCmd.Enabled Then
		tmrSendNextTestCmd.Enabled = False
		lSendNextTestCmd
	End If
End Sub

' Handles the Tick event of the Response Timeout timer.
Private Sub tmrTestCmdResponseTimeout_Tick
	If tmrTestCmdResponseTimeout.Enabled Then
		tmrTestCmdResponseTimeout.Enabled = False
		mCommandsFailed = mCommandsFailed + 1
		lRaiseMsgDoneEvent
		tmrSendNextTestCmd.Enabled = True
	End If
End Sub

#End Region  Event Handlers

#Region  Public Subroutines

' Starts the test sequence. The specified caller will then receive events beginning with the specified event prefix.
Public Sub pStartTestSequence(initArgs As TestSeqInitialiseArgs)
	If initArgs.sendInterval > 0 Then ' Protection - interval must be positive in order to initialise timer
		mCallerObj = initArgs.caller
		mEventName = initArgs.eventName
		tmrSendNextTestCmd.Initialize("tmrSendNextTestCmd", initArgs.sendInterval)
		mCommandsSent = 0
		mCommandsSucceeded = 0
		mCommandsFailed = 0
		TestSeqRunning = True
		mNeedsToStop = False
		mPaused = False
		lSendNextTestCmd
	Else ' Interval is not a positive integer
		ToastMessageShow("Invalid sending interval!", False)
	End If
End Sub

' Invokes the test sequence to end (it will finish after the most recently-sent command receives a response/timeout).
' The values of commands sent, succeeded, and failed won't be retained upon restarting the sequence.
Public Sub pStopTestSequence
	mNeedsToStop = True
	If Not(tmrSendNextTestCmd.Enabled) And Not(tmrTestCmdResponseTimeout.Enabled) Then TestSeqRunning = False
End Sub

' Invokes the test sequence to pause (the next command will not be sent).
' The values of commands sent, succeeded, and failed will be retained.
Public Sub pPauseTestSequence
	mPaused = True
End Sub

' Resumes the test sequence after it was paused.
Public Sub pResumeTestSequence
	mPaused = False
	lSendNextTestCmd
End Sub

' Confirms that the response to the most recent test command was received. The next command will be sent after the interval.
Public Sub pReceivedResponse
	tmrTestCmdResponseTimeout.Enabled = False
	mCommandsSucceeded = mCommandsSucceeded + 1
	lRaiseMsgDoneEvent
	tmrSendNextTestCmd.Enabled = True
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Sends the next test command (so long as the sequence hasn't been paused or stopped).
Private Sub lSendNextTestCmd
	If Not(mNeedsToStop) And Not(mPaused) Then
		mCommandsSent = mCommandsSent + 1
		tmrTestCmdResponseTimeout.Enabled = True
		Dim msg As String = modEposApp.EPOS_ORDERSTATUSLIST & modEposWeb.ConvertToString(Starter.myData.customer.customerId)
		CallSub2(Starter, "pSendMessage", msg )
		lRaiseMsgSentEvent
	Else If mNeedsToStop Then
		TestSeqRunning = False
	End If
End Sub

' Sends the caller a callback event which signifies that a test command has been sent.
Private Sub lRaiseMsgSentEvent
	Dim eventTitle As String = mEventName & "_MsgSent"
	If SubExists(mCallerObj, eventTitle) Then CallSub2(mCallerObj, eventTitle, mCommandsSent)
End Sub

' Sends the caller a callback event which signifies that a test command is complete (either received response or timed out).
Private Sub lRaiseMsgDoneEvent
	Dim eventTitle As String = mEventName & "_MsgDone"
	If SubExists(mCallerObj, eventTitle) Then CallSub3(mCallerObj, eventTitle, mCommandsSucceeded, mCommandsFailed)
End Sub

#End Region  Local Subroutines
