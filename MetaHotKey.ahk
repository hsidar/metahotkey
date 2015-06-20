
;MetaHotKey 1.0 by Marcus Estremera

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#NoEnv  ; Prevents empty variables from being used
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force  ; skip the message box asking if you want to reload script
AutoTrim, On

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Global Variables - Things used in more than one method
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

prefix := "^!"
usedkeys = D
complete =

; Load legend variable below

	FileRead, file, %A_ScriptName%
	stringsplit, legend, file, ‡, %A_Tab%%A_Space%.
	legend=%legend4%
	loop, parse, prefix
		{
		ifequal, A_LoopField, `^
			triggers = %triggers% Ctrl `+
		ifequal, A_LoopField, `+
			triggers = %triggers% Shift `+
		ifequal, A_LoopField, `!
			triggers = %triggers% Alt `+
		ifequal, A_LoopField, `#
			triggers = %triggers% Super/Windows `+
		}
	StringTrimRight, triggers, triggers, 2
	stringreplace, legend, legend, †, %triggers%
	msgbox, 4096, Legend, %legend%
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Pre-made Hotkeys - hard coded keys
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

^!f9::
	exitapp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

^!f11::
	goto, showlegend
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

^!f12::
	goto, editor
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

^!D::
	goto, fixdigits
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Functions/Methods
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

fixdigits:

;takes what is on the clipboard, iterates through and removes anything that is not a digit, send the result to the focus, and copies result to clipboard

output = %clipboard%
	Loop, parse, output
		{
		if A_LoopField is number	
		number .= A_LoopField
		}
	send %number%
clipboard = %number%
number=
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

showlegend:


;Shows a message box with the global legend variable contents

global legend
	msgbox, 4096, Legend, %legend%
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

editor:

;starts up a GUI asking what type of hotkey wants to be made or changed

options := "Create Verbage|Edit Verbage|Edit Hotkey Letter Assignment|Edit Legend|Edit Hotkey Triggers|Delete Hotkey"
	Gui, +AlwaysOnTop
	Gui, Add, text,,  Choose Your Path
	Gui, Add, DropDownList, w200 vchoice gchosen xCenter, %options%
	Gui, Show, w210 h50 Center
	Gui, Add, Button,Default gchosen, Submit
	return
	GuiClose:
	options=
	Gui destroy
exit

chosen:

;Takes selection made above and launches the proper action (GetKeyState below is to prevent arrom keys from making selections above)

	If GetKeyState("Up") OR GetKeyState("Down")
  		Return

	Gui, Submit, nohide
	Gui destroy
options=
	If choice = Open Program
		{
		goto, openprogram
		}
	else If choice = Create Verbage
		{
		goto, createverbage
		}
	else If choice = Create Hotstring
		{
		goto, createhotstring
		}
	else If choice = Edit Hotkey Letter Assignment
		{
		goto, reassign
		}
	else If choice = Edit Hotkey Triggers
		{
		goto, editprefix
		}
	else If choice = Edit Legend
		{
		goto, editdescription
		}
	else If choice = Edit Verbage
		{
		goto, editverbage
		}
	else If choice = Delete Hotkey
		{
		goto, delete
		}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;stub method for future functionality

openprogram:

	msgbox,4096, poop, poop
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;stub method for future functionality

createhotstring:

	msgbox,4096, poop, poop
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

createverbage:

;starts a GUI asking for the verbage the hotkey will output when triggered

	Gui, 2:+AlwaysOnTop
	Gui, 2:Add, text,,Type What You Wanna See
	Gui, 2:Add,Edit,r10 w600 vcustom
	Gui, 2:Add,Button,xs+200 gOK,OK
	Gui, 2:Add,Button,x+10 gCancel,Cancel
	Gui, 2:Show
	Return
	2GuiClose:
	custom=
	Gui, 2:destroy
exit

OK:
	Gui, 2: Submit, nohide
	Gui, 2:destroy

;parse through input from GUI above and escapes out characters that would otherwise cause errors if treated like normal by program

chars = <>:;'"/|\(){}=-+!^&*
	loop, parse, chars
		{
		stringreplace, custom, custom, %A_LoopField%,``%A_LoopField%, ReplaceAll
		}
	stringreplace, custom, custom, `%,```%, ReplaceAll

;check for no input

	IfEqual, custom,
		{
		Msgbox, 4096, Error, That's a whole lotta nuthin'
		Gui, 2:destroy
		Gosub, createverbage
		exit
		}

;sanitize input and then pass custom verbage to be assigned to a letter

custom := sanitize(custom)

	assigncustom(custom)	
return

Cancel:
custom=
	Gui, 2:destroy
exit
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

assigncustom(x)

;takes input and creates a variable holding all the script for the new hotkey before appending it to the existing .AHK file

{

;call the assigner method to assign letter and description

	gosub, assigner
	colons := "::"
	header = %complete%

;custom hotkey template, escaping out parentheses so they don't cause any conflicts.

custom =
(

%header%%colons%
poo = 
(
%x%
`)
`sendraw `%poo`%
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;%header%

)
		FileAppend, %custom%, %A_ScriptName%
		msgbox, 4096, Reassign Key, It is done.
		reload
	return
	}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

assigner:

;assigns the letter for the hotkey, checking for illegal strings, and then updates the legend accordingly by calling createdescription

global usedkeys
global complete
global prefix
global legend
stash = %usedkeys%
method = assigner

	InputBox, focus, Custom Hotkey, What letter/number do you want to be assigned to this hot key?
	if ErrorLevel
	exit

	if testcharacter(focus,method)
		{
		StringUpper, focus, focus
		usedkeys = %usedkeys%%focus%
		complete = %prefix%%focus%
		FileRead, file, %A_ScriptName%
		StringReplace, file, file, usedkeys = %stash%,usedkeys = %usedkeys%
		GoSub, createdescription
		}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

createdescription:

	InputBox, description, Custom Hotkey, What is the description of this hotkey?
	if ErrorLevel
	exit
	IfEqual, description,
		{
		Msgbox, 4096, Error, You didn't type anything dum dum.
		Gosub, createdescription
		return
		}
description := sanitize(description)
newlegend =
(
%legend%
%focus% - %description%
)
	StringReplace, file, file, %legend%,%newlegend%
	FileDelete, %A_ScriptName%
	FileAppend, %file%, %A_ScriptName%
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

reassign:

stash = %usedkeys%
global legend

;creates text file for legend to parse through into a variable and then destroy

	fileappend,%legend%,legend.txt
	Loop, Read, legend.txt
		{
		if A_Index > 5
		options = %options%%A_LoopReadLine%|
		}
	filedelete,legend.txt
	Gui, 3:+AlwaysOnTop
	gui, 3:add, text,,Which hotkey do you want to re-assign?
	Gui, 3:Add, DropDownList, w350 vchoice gchoosify xCenter, %options%
	Gui, 3:Show, w350 h50 Center
	Gui, 3:Add, Button,Default gchoosify, Submit
	return
	3GuiClose:
	options=
	Gui, 3:destroy
exit


choosify:

	If GetKeyState("Up") OR GetKeyState("Down")
		Return

	Gui, 3:Submit, nohide
	Gui, 3:destroy
options=
	loop, parse, choice
		ifequal A_Index, 1
		oldie = %A_LoopField%

reassigner:

method = reassigner

	inputbox, newbie, Reassign Hotkey, What letter/number do you want to reassign this hot key to?
	if ErrorLevel
		exit
	if testcharacter(newbie,method)
		{
		StringUpper, newbie, newbie
		StringReplace, change, choice, %oldie%, %newbie%
		StringReplace, usedkeys, usedkeys, %oldie%, %newbie%
		newcommand = %prefix%%newbie%
		oldcommand = %prefix%%oldie%
		FileRead, file, %A_ScriptName%
		StringReplace, file, file, %choice%, %change%
		StringReplace, file, file, usedkeys = %stash%,usedkeys = %usedkeys%
		StringReplace, file, file, %oldcommand%, %newcommand%, ReplaceAll
		FileDelete, %A_ScriptName%
		FileAppend, %file%, %A_ScriptName%
		msgbox, 4096, Reassign Key, It is done.
		reload
		}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

editdescription:

global legend

	fileappend,%legend%,legend.txt
	Loop, Read, legend.txt
		{
		if A_Index > 5
		options = %options%%A_LoopReadLine%|
		}
	filedelete,legend.txt
	Gui, 4:+AlwaysOnTop
	Gui, 4:add, text,,Which description do you want to edit?
	Gui, 4:Add, DropDownList, w350 vchoicy geditify xCenter, %options%
	Gui, 4:Add, Button, Default geditify, Submit
	Gui, 4:Show, w350 h50 Center
	return
	4GuiClose:
	options=
	Gui, 4:destroy
exit


editify:

	If GetKeyState("Up") OR GetKeyState("Down")
		Return

	Gui, 4:Submit, nohide
	Gui, 4:destroy
options=
oldness=
	
	loop, parse, choicy
		{
		ifequal A_Index, 1
			letter = %A_LoopField%
		else
			{
			if (A_Index > 4)
			oldness .= A_LoopField
			}
		}
	Gui, 5:Add, text,,Type What You Wanna See
	Gui, 5:Add,Edit,r1 w600 vcustom, %oldness%
	Gui, 5:Add,Button,xs+200 g5OK,OK
	Gui, 5:Add,Button,x+10 g5Cancel,Cancel
	Gui, 5:Show
	Return
	5GuiClose:
	custom=
	Gui, 5:destroy
exit

5OK:
	Gui, 5: Submit, nohide
	Gui, 5:destroy
	IfEqual, custom,
		{
		Msgbox, 4096, Error, Yo tengo NADA!
		Gosub, editify
		exit
		}

newness = %letter% - %custom%

	FileRead, file, %A_ScriptName%
	StringReplace, file, file, %choicy%,%newness%
	FileDelete, %A_ScriptName%
	FileAppend, %file%, %A_ScriptName%
	msgbox, 4096, Edit Legend, It is done.
	reload
	5Cancel:
	custom=
	Gui, 5:destroy
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

delete:

global legend
options=

	fileappend,%legend%,legend.txt
	Loop, Read, legend.txt
		{
		if A_Index > 6
			options = %options%%A_LoopReadLine%|
		}
	filedelete,legend.txt
	IfEqual, options,
		{
		Msgbox, 4096, Error, Nothing to Delete.
		return
		}
	Gui, 6:+AlwaysOnTop
	Gui, 6:add, text,,Which hotkey do you want to wipe from existence?
	Gui, 6:Add, DropDownList, w350 vchoicen gselectify xCenter, %options%
	Gui, 6:Add, Button, Default gselectify, Submit
	Gui, 6:Show, w350 h50 Center
	return
	6GuiClose:
	options=
	Gui, 6:destroy
exit

selectify:

	If GetKeyState("Up") OR GetKeyState("Down")
		Return

global prefix

	Gui, 6:Submit, nohide
	Gui, 6:destroy
	MsgBox, 4, Last Chance, You are about to delete the crap out of this. You sure?
	IfMsgBox, No
	    Return
	loop, parse, choicen
		{
		ifequal A_Index, 1
		letter = %A_LoopField%
		}

beacon = %prefix%%letter%
updatelegend =
(

%choicen%
)

	FileRead, file, %A_ScriptName%
	Stringreplace, file, file , %beacon%, §, All
	Stringsplit, nugget, file, §

deletion = %beacon%%nugget4%%beacon%

	FileRead, file, %A_ScriptName%
	Stringreplace, file, file , %deletion%,, All
	Stringreplace, file, file , %updatelegend%,, All
	loop, parse, usedkeys
		{
		ifnotequal A_LoopField, %letter%
			newkeys .= A_LoopField
		}
	Stringreplace, file, file , %usedkeys%, %newkeys%
	FileDelete, %A_ScriptName%
	FileAppend, %file%, %A_ScriptName%
	msgbox, 4096, Delete!, Delete!
	reload

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

editverbage:

global legend

	fileappend,%legend%,legend.txt
	Loop, Read, legend.txt
		{
		if A_Index > 6
			options = %options%%A_LoopReadLine%|
		}
	filedelete,legend.txt
	IfEqual, options,
		{
		Msgbox, 4096, Error, Nothing to Edit.
		return
		}
	Gui, 7:+AlwaysOnTop
	Gui, 7:add, text,,Which verbage do you want to edit?
	Gui, 7:Add, DropDownList, w350 vchoicen gselectifate xCenter, %options%
	Gui, 7:Add, Button, Default gselectifate, Submit
	Gui, 7:Show, w350 h50 Center
	return
	7GuiClose:
	options=
	Gui, 7:destroy
	exit

selectifate:

	If GetKeyState("Up") OR GetKeyState("Down")
		Return

colons := "::"
global prefix

	Gui, 7:Submit, nohide
	Gui, 7:destroy
	loop, parse, choicen
		{
		ifequal A_Index, 1
		letter = %A_LoopField%
		}

beacon = %prefix%%letter%

	FileRead, file, %A_ScriptName%
	Stringreplace, file, file , %beacon%, ¶, All
	Stringsplit, nugget, file, ¶

replation=%beacon%%nugget4%%beacon%
kernel = %nugget4%

	fileappend,%kernel%, kernel.txt
	StringTrimLeft,kernel,kernel,14
	StringTrimright,kernel,kernel,59
	filedelete,kernel.txt
	Stringreplace, kernel, kernel,``,,ReplaceAll
	FileRead, file, %A_ScriptName%
	Gui, 8:+AlwaysOnTop
	Gui, 8:Add, text,,Type What You Wanna See
	Gui, 8:Add,Edit,r10 w600 vcustom, %kernel%
	Gui, 8:Add,Button,xs+200 g8OK,OK
	Gui, 8:Add,Button,x+10 g8Cancel,Cancel
	Gui, 8:Show
	Return
	8GuiClose:
	custom=
	Gui, 8:destroy
	exit

8OK:

	Gui, 8: Submit, nohide
	Gui, 8:destroy
	IfEqual, custom,
		{
		Msgbox, 4096, Error, There is nothing there.
		Gosub, createverbage
		exit
		}
update =
(

%beacon%%colons%
poo = 
(
%custom%
`)
`sendraw `%poo`%
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;%beacon%

)

	
	FileRead, file, %A_ScriptName%
	Stringreplace, file, file , %replation%,, All
	FileDelete, %A_ScriptName%
	FileAppend, %file%, %A_ScriptName%
	FileAppend, %update%, %A_ScriptName%
	msgbox, 4096, Edit!, Edit!
	reload

8Cancel:

custom=
	Gui, 8:destroy
exit


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

editprefix:

	Gui, 9:+AlwaysOnTop
	Gui, 9:add, text,,What buttons do you wanna use?
	Gui, 9:Add, Checkbox, vctrl, Control
	Gui, 9:Add, Checkbox, vshift, Shift
	Gui, 9:Add, Checkbox, valt, Alt
	Gui, 9:Add, Checkbox, vsuper, Super/Windows
	Gui, 9:Show, w350 h140 Center
	Gui, 9:Add,Button,xs+200 g9OK,OK
	Gui, 9:Add,Button,x+10 g9Cancel,Cancel
	return
	9GuiClose:
	Gui, 9:destroy
exit

9OK:

	Gui, 9: Submit, nohide
	Gui, 9:destroy
	ifequal, ctrl, 1
		newprefix = %newprefix%`^
	ifequal, shift, 1
		newprefix = %newprefix%`+
	ifequal, alt, 1
		newprefix = %newprefix%`!
	ifequal, super, 1
		newprefix = %newprefix%`#
	ifequal, newprefix,
		{
		msgbox, 4096, Error, That ain't nuthin'
		gosub, editprefix
		return
		}
	FileRead, file, %A_ScriptName%
	Stringreplace, file, file , %prefix%,%newprefix%, All
	FileDelete, %A_ScriptName%
	FileAppend, %file%, %A_ScriptName%
	file=
	msgbox, 4096, Prefixify, That just happened.
	reload

9Cancel:

	Gui, 9:destroy
exit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

testforduplicates(x,y)
{
table = %y%
	Loop, parse, table
		{
		Ifequal A_LoopField, %x%
			return false
		}
	return true
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

testcharacter(x,y)
{
global usedkeys

	if x is not alnum
		{
		MsgBox, 4096, Error, Letters or numbers only please.
		gosub, %y%
		}
	else if (StrLen(x) < 1)
		{
		MsgBox,4096, Error, You gotta give me SOMETHING.
		gosub, %y%
		}
	else if (StrLen(x) > 1)
		{
		MsgBox,4096, Error, Only one character please.
		gosub, %y%
		}
	else if not (testforduplicates(x,usedkeys))
		{
		MsgBox,4096, Error, Already used!!
		gosub, %y%
		}
	else
		{
		return true
		}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sanitize(x)
{
	StringReplace, x, x, ‡, -, ReplaceAll
	return %x%
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Legend
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
‡Press † and the corresponding letter
------------------------------------------------
F12 - Editor
F11 - Legend
F9 - Quit AutoHotKey
D - Remove number formatting from number copied to the clipboard.‡
*/
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;‡


