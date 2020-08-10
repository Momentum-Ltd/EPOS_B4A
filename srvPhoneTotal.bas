B4A=true
Group=Services
ModulesStructureVersion=1
Type=Service
Version=7.8
@EndOfDesignText@
'
' Service module to handle phone totals
'

#Region  Documentation
	'
	' Name......: srvPhoneTotal
	' Release...: 3
	' Date......: 07/08/19
	'
	' History
	' Date......: 31/05/18
	' Release...: 1
	' Created by: D Morris
	' Details...: First release to support version tracking
	'
	' Date......: 24/09/18
	' Release...: 2
	' Overview..: Changes to support separate phone totals for each centre.
	' Amendee...: D Hathway
	' Details...: 
	'		Mod: Large changes to lGetPrevPhoneTotal() and lWritePhoneTotal() to save/load values for separate centres
	'		Mod: Changed lGetPrevPhoneTotal() to public, so that it can be called when the Centre ID number changes
	'		Mod: Tidied up the module by adding method headers, etc.
	'
	' Date......: 07/08/19
	' Release...: 3
	' Overview..: Support for myData.
	' Amendee...: D Morris
	' Details...: Mod: support for myData pGetPrevPhoneTotal() and lWritePhoneTotal().
	'
	' Date......: 
	' Release...: 
	' Overview..:
	' Amendee...: 
	' Details...: 
	'
#End Region  Documentation

#Region  Service Attributes
	#StartAtBoot: False
#End Region  Service Attributes

#Region  Mandatory Subroutines & Data

Sub Process_Globals
	
	' Local constants 
	Private Const PHONETOTALS_FILENAME As String = "PhoneTotals.txt" ' The file used to store phone order totals.
	Private Const CENTRE_VALUE_DIVIDER As Char = "," ' The character used to divide Centre IDs and their values in the saved file.
	
	' Public variables
	Public phoneTotal As Float
	
End Sub

Sub Service_Create
	pGetPrevPhoneTotal
End Sub

Sub Service_Start (StartingIntent As Intent)
	' Currently nothing
End Sub

Sub Service_Destroy
	' Currently nothing
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Event Handlers

' Currently none

#End Region  Event Handlers

#Region  Public Subroutines

Public Sub pAdjustPhoneTotal(changeValue As Float) As Float
	phoneTotal = phoneTotal + changeValue
	lWritePhoneTotal
	Return phoneTotal
End Sub

' Sets this service's .phoneTotalObject to the previously-saved phone total value for the currently-connected centre.
' It will be set to 0 if the save file does not exist or is an old version of the file (without Centre IDs).
Public Sub pGetPrevPhoneTotal
	If File.Exists(File.DirInternal, PHONETOTALS_FILENAME) Then
		Dim savedStr As String = File.ReadString(File.DirInternal, PHONETOTALS_FILENAME)
		If savedStr.Contains(CENTRE_VALUE_DIVIDER) Then ' Protection against the old version of the saved file
			Dim centresAndTotals() As String = Regex.Split(CENTRE_VALUE_DIVIDER, savedStr)
			For centreIdIndex = 0 To (centresAndTotals.Length - 1) Step 2 ' The Centre ID is every other field
				If centresAndTotals(centreIdIndex) = Starter.myData.centre.centreId Then
					phoneTotal = centresAndTotals(centreIdIndex + 1) ' Return the field after the Centre ID
					Exit
				End If
			Next
		Else ' For the old version of the file (no Centre IDs), just overwrite with new zeroed value
			lWritePhoneTotal
		End If
	End If
End Sub

' Sets the phone total to zero (for the currently-connected centre).
Public Sub pZeroPhoneTotal
	phoneTotal = 0
	lWritePhoneTotal
End Sub

#End Region  Public Subroutines

#Region  Local Subroutines

' Saves the current phone total to its file (preserving any other centres' values).
Private Sub lWritePhoneTotal
	' Get current saved values
	Dim valuesToSave As List : valuesToSave.Initialize
	If File.Exists(File.DirInternal, PHONETOTALS_FILENAME) Then
		Dim savedStr As String = File.ReadString(File.DirInternal, PHONETOTALS_FILENAME)
		If savedStr.Contains(CENTRE_VALUE_DIVIDER) Then
			' DH - Can't find a proper "ToList" method so have done it myself:
			Dim valuesArray() As String = Regex.Split(CENTRE_VALUE_DIVIDER, savedStr)
			For Each centreOrValueToLoad As String In valuesArray
				valuesToSave.Add(centreOrValueToLoad)
			Next
		End If
	End If
	
	' Update the value for the current centre
	Dim centreFound As Boolean = False
	For centreIdIndex = 0 To (valuesToSave.Size - 1) Step 2
		Dim gotCentreNumber As Int = valuesToSave.Get(centreIdIndex) ' Must cast it as Int before comparison
		If gotCentreNumber = Starter.myData.centre.centreId Then
			valuesToSave.Set(centreIdIndex + 1, phoneTotal)
			centreFound = True
			Exit
		End If
	Next
	If centreFound = False Then ' Add the centre details if they're not already in the list
		valuesToSave.Add(Starter.myData.centre.centreId)
		valuesToSave.Add(phoneTotal)
	End If
		
	' Save the updated values
	Dim saveStr As String = ""
	' DH - Can't find a proper "Join" method so have done it myself:
	For Each centreOrValueToJoin In valuesToSave 
		If saveStr <> "" Then saveStr = saveStr & CENTRE_VALUE_DIVIDER
		saveStr = saveStr & centreOrValueToJoin
	Next
	File.WriteString(File.DirInternal, PHONETOTALS_FILENAME, saveStr)
End Sub

#End Region  Local Subroutines
