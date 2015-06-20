

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
;Pre-made Hotkeys - hard coded keys
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; kill app

^!f9::
	exitapp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; show legend message box

^!f11::
	goto, showlegend
	return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; start up editor gui

^!f12::
	goto, editor
	return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

loadLegend:

	;load script into file, split script by special marker into new variable

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
			triggers = %triggers% Win `+
		}

	StringTrimRight, triggers, triggers, 2

	stringreplace, legendplus, legend, †, %triggers%

	; clean up variables

	file=
	legend=
	triggers=

	return %legendplus%