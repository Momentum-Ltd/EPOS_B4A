B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
'
' Keyboard Helper class.
'
#Region  Documentation
	'
	' Name......: clsKeyboardHelper
	' Release...: 2
	' Date......: 28/01/21
	'
	' History
	' Date......: 27/01/21
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking.
	'
	' Date......: 28/01/21
	' Release...: 2
	' Overview..: Enhancement to setup operation.
	' Amendee...: D Morris
	' Details...: Added: SetupTextAndKeyboard()
	'
	' Date......: 
	' Release...: 
	' Overview..:
	' Amendee...: 
	' Details...: 
	'
#End Region  Documentation

#Region  Mandatory Subroutines & Data

#event: HideKeyboard

Sub Class_Globals
	
	Private xui As XUI								' Support X platform operation.

#if B4I	
	Private refEnterPanel As Panel					' Local store for the Enter panel reference.  
	Private gWidth As Int							' Saved screen width.
	Private gPnl_Hide As Panel						' Panel added above keyboard the hide keyboard button.
	Private gIm_Hide As ImageView					' Hide keyboard button.
	Private pnlEnterDetailsOrgTop As Int 			' Original top of the Text entry panel (used for moving it above keyboard).
	
	Private mCallBack As Object						'Ignore Storage for callback. 
	Private mObjName As String						' Caller's object name for this class. 
#End If
End Sub

#End Region  Mandatory Subroutines & Data


#Region  Event Handlers

#if B4i
' User clicks on hide keyboard - generates HideKeyboard event.
Sub Im_Hide_Click
	If xui.SubExists(mCallBack, mObjName & "_HideKeyboard", 0) Then
		CallSubDelayed(mCallBack, mObjName & "_HideKeyboard")
	End If
End Sub
#End If

#end Region Event handlers

#Region  Public Subroutines


#If B4I
' Add hide keyboard button to a B4XFloatTextField
Public Sub AddViewToKeyboard( floatTextField As B4XFloatTextField)
	Dim no As NativeObject = floatTextField.textfield
	no.SetField("inputAccessoryView", gPnl_Hide)
End Sub

' Add hide keyboard button to array of B4XFloatTextField.
Public Sub AddViewToKeyboard2( floatTextField() As B4XFloatTextField)
	For Each txtField As B4XFloatTextField In floatTextField
		Dim no As NativeObject = txtField.textfield
		no.SetField("inputAccessoryView", gPnl_Hide)	
	Next
End Sub
#End If

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(callBack As Object, objName As String,  enterPanel As Panel)
#if B4I
	' B4I code for Hide keyboard button.
	mCallBack = callBack
	mObjName = objName
	refEnterPanel = enterPanel
	pnlEnterDetailsOrgTop = refEnterPanel.Top ' Save the original enter panel top postion.

	gIm_Hide.Initialize("Im_Hide")
	gIm_Hide.Bitmap = LoadBitmap(File.DirAssets, "hide_keyboard.png")
	gIm_Hide.Color = xui.Color_Gray
	gIm_Hide.Height = 50
	gIm_Hide.Width = 40
	gWidth = GetPanelWidth
	gPnl_Hide.Initialize ("")
	gPnl_Hide.Color = Colors.Transparent
	gPnl_Hide.AddView ( gIm_Hide, gWidth-55,0,50,40)
	gPnl_Hide.Height = 40
#End If
End Sub

#if B4i
' This method moves a text entry field so it does not get covered by the keyboard.
' B4XFloatTextField is taken from here: https://www.b4x.com/android/forum/threads/b4xfloattextfield-keyboard-hiding-views.118242/#post-740784
Public Sub MoveUpEnterDetailsPanel(height As Float)
	If height = 0 Then ' Keyboard has been hidden
		refEnterPanel.top = pnlEnterDetailsOrgTop
	Else ' Keyboard has been shown
		refEnterPanel.top = pnlEnterDetailsOrgTop
		Sleep(0)
		For Each v As B4XView In refEnterPanel.GetAllViewsRecursive
			If v.Tag Is B4XFloatTextField Then
				Dim f As B4XFloatTextField = v.Tag
				If f.Focused Then
					Dim base As Panel = f.mBase
					Dim d As Double = base.CalcRelativeKeyboardHeight(height)
					If d < base.Height Then
						refEnterPanel.Top = pnlEnterDetailsOrgTop -(base.Height - d)
					End If
				End If
			End If
		Next
	End If
End Sub
#End If

' Removes the default tab operation for an array of B4XFloatTextFields
Public Sub RemovedTabOrder(txtObj() As B4XFloatTextField)
	For Each textField As B4XFloatTextField In txtObj
		textField.NextField = textField
	Next
End Sub

#if B4i
' Handle resize event
Public Sub Resize
	gWidth = GetPanelWidth
	gPnl_Hide.RemoveAllViews
	gPnl_Hide.AddView ( gIm_Hide, gWidth-55,0,50,40)
End Sub
#End If

' Setup a B4XFloatTextField  back colour to white and the border to orange
Public Sub SetupBackcolourAndBorder( txtObj As B4XFloatTextField)
	txtObj.mBase.SetColorAndBorder(xui.Color_White, 3dip, xui.Color_RGB(230, 100, 15), 15dip)
End Sub

' Setup an array of B4XFloatTextField  back colour to white and the border to orange
Public Sub SetupBackcolourAndBorder2(txtObj() As B4XFloatTextField)
	For Each textField As B4XFloatTextField In txtObj
		SetupBackcolourAndBorder(textField)
	Next
End Sub

' Setup bot the text box and keyboard.
Public Sub SetupTextAndKeyboard(txtObj() As B4XFloatTextField)
 #if B4i		
	AddViewToKeyboard2(txtObj)
#End If
	SetupBackcolourAndBorder2(txtObj)
	RemovedTabOrder(txtObj)
End Sub


#End Region  Public Subroutines

#Region  Local Subroutines

#if B4i
' Get the screen width 
Private Sub GetPanelWidth As Int
	Return  refEnterPanel.Width
End Sub
#End If

#End Region  Local Subroutines
