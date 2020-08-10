B4A=true
Group=Classes
ModulesStructureVersion=1
Type=Class
Version=9.3
@EndOfDesignText@
'
' Class to store device, customer and other information
'  Note: It appears nested maps have problem when trying to convert tham
'         back to the original node element. There this call simply uses
'         a file to store each node.
'
#Region  Documentation
	'
	' Name......: clsMyData
	' Release...: 3
	' Date......: 02/12/19
	'
	' History
	' Date......: 07/08/19
	' Release...: 1
	' Created by: D Morris (started 5/8/19)
	' Details...: First release to support version tracking
		'
	' Date......: 01/12/19
	' Release...: 2
	' Overview..: Load operation improved.
	' Amendee...: D Morris
	' Details...: Mod: Load().
			'
	' Date......: 02/12/19
	' Release...: 3
	' Overview..: Fix in v6 don't appear to work - another attempt
	' Amendee...: D Morris
	' Details...: Mod: Load().
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
	' Constants
	
	' Stored data.
	Public centre As clsCentreInfo				' Customer's centre related information.	
	Public customer As clsCustomerInfo			' Customer information.
End Sub

#End Region  Mandatory Subroutines & Data

#Region  Public Subroutines

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	centre.Initialize
	customer.Initialize
End Sub

' Clears MyData information
Public Sub Clear
	centre.Clear
	customer.Clear
End Sub

' Delete MyData stored information 
'  OK delete non-existant files.
Public Sub Delete
	centre.Delete
	customer.Delete
End Sub

' Loads MyData information from file.
' Returns true if load successful.
Public Sub Load As Boolean
	Dim loadSuccesful As Boolean = True
'	Wait For (centre.Load) complete(loadOk As Boolean)
'	If 	loadOk = False Then
'		loadSuccesful = False
'	End If
'	Wait For (customer.Load) complete(loadOk1 As Boolean)
'	If loadOk1 = False Then
'		loadSuccesful = False
'	End If
	If centre.Load = False Then
		loadSuccesful = False
	End If
	
	If customer.Load = False Then
		loadSuccesful = False
	End If
	Return loadSuccesful
End Sub

' Saves MyData information to file
public Sub Save
	centre.Save
	customer.Save
End Sub
#End Region  Public Subroutines

#Region  Local Subroutines


#End Region  Local Subroutines