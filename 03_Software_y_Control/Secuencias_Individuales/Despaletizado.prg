'======================================================================
' DEPALETIZADO — Secuencia independiente
'======================================================================
' Toma una unidad de la charola/pallet y la deja en el punto de entrada
' al proceso, para que Ajuste la reciba después. NO incluye el regreso
' de la pieza al pallet (esa integración se hará más adelante).
'
' Basado en el ejemplo "Pick and Place Pallet to 1" ya usado como
' referencia, adaptado a la convención de botones física del proyecto.
'
' E/S física (IOLabel) ya establecida en el proyecto:
'   Input  StartCycle   Botón de ciclo continuo (NA)
'   Input  UniqB        Botón de ciclo único (NA)
'   Input  StopB        Botón de paro (NA) -> Sw(StopB) = On al presionarlo
'   Output ReadyLed     Indicador de listo
'   Output InCycle      Indicador de ciclo en ejecución
'   Output ErrorLight   Indicador de error/paro
'   Output GripOn       Control de la pinza
'
' Setup antes de ejecutar:
'   1. Ajustar PALLET_ROWS y PALLET_COLS al tamaño real del pallet
'   2. Enseñar el punto de destino: DespaletizadoLugar
'   3. Enseñar las tres esquinas del pallet: pallet1, pallet2, pallet3
'
' Comportamiento de "un ciclo": cada llamado a DePaletizadoCycle toma
' UNA sola unidad (la siguiente posición disponible del pallet) y la
' deja en DespaletizadoLugar — igual que el resto de las funciones de
' la línea, que procesan una pieza por ciclo. Con StartCycle, el robot
' va vaciando el pallet posición por posición sin detenerse.
'
' Pallet agotado: cuando ya se tomaron todas las posiciones, el
' programa enciende ErrorLight y detiene el ciclo. Hace falta recargar
' físicamente el pallet y reiniciar el programa (correr Main de nuevo)
' para reanudar — el índice no se reinicia solo, para evitar que el
' robot intente tomar de una posición que ya se vació.
'======================================================================

#define PALLET_ROWS 3
#define PALLET_COLS 3

Global Boolean gStopRequested
Global Boolean gPalletEmpty
Global Integer gPalletIndex
Global Integer gNumPalletLocs
Global Long gCycleCount

Function Main
	gStopRequested = False
	gPalletEmpty = False
	gPalletIndex = 1
	gCycleCount = 0

	Initialize
	Xqt 2, StopMonitor
	MainLoop
Fend

Function Initialize
	OnErr GoTo eHandler

	Robot 1
	Reset
	Off ErrorLight
	Off InCycle
	Off ReadyLed
	Off GripOn
	Motor On
	Speed 10
	Accel 20, 20
	Power Low
	Arm 0
	Tool 1
	Jump Park

	' Define el pallet a partir de sus tres esquinas enseñadas
	Pallet 1, pallet1, pallet2, pallet3, PALLET_COLS, PALLET_ROWS
	gNumPalletLocs = PALLET_ROWS * PALLET_COLS

	On ReadyLed
	Exit Function

eHandler:
	Print "Error", Err, " en función ", Erf$, ", línea ", Erl, ": ", ErrMsg$(Err)
	Off ReadyLed
	Off InCycle
	On ErrorLight
	Quit All
Fend

Function StopMonitor
	Do
		If Sw(StopB) = On Then
			gStopRequested = True
			Halt 1
			Wait Sw(StopB) = Off
		EndIf
	Loop
Fend

Function MainLoop
	Boolean bContinuous

	OnErr GoTo eHandler
	bContinuous = False

	Do
		If gStopRequested Then
			bContinuous = False
			Off InCycle
			If Not gPalletEmpty Then On ReadyLed
			gStopRequested = False
			Resume 1
		EndIf

		' Si el pallet ya se agotó, no se ejecuta ningún ciclo nuevo
		' hasta que se reinicie el programa tras recargarlo
		If gPalletEmpty Then
			Off ReadyLed
			On ErrorLight
			GoTo SkipCycles
		EndIf

		If Sw(UniqB) = On And Sw(StopB) = Off Then
			Off ReadyLed
			On InCycle
			DePaletizadoCycle
			Off InCycle
			If Not gPalletEmpty Then On ReadyLed
			Wait Sw(UniqB) = Off
		EndIf

		If Sw(StartCycle) = On And Sw(StopB) = Off Then
			bContinuous = True
		EndIf

		If bContinuous And Sw(StopB) = Off And Not gPalletEmpty Then
			Off ReadyLed
			On InCycle
			DePaletizadoCycle
		ElseIf Sw(StopB) = On Then
			bContinuous = False
		EndIf

SkipCycles:
	Loop

eHandler:
	Print "Error", Err, " en función ", Erf$, ", línea ", Erl, ": ", ErrMsg$(Err)
	Off ReadyLed
	Off InCycle
	On ErrorLight
	Quit All
Fend

Function DePaletizadoCycle
	OnErr GoTo eHandler

	If gPalletIndex > gNumPalletLocs Then
		gPalletEmpty = True
		Print "Pallet agotado. Recargar y reiniciar el programa."
		Exit Function
	EndIf

	' 1) Toma la pieza de la siguiente posición disponible del pallet
	Go Pallet(1, gPalletIndex)
	Wait .1
	On GripOn
	Wait .1

	' 2) La deja en el punto de entrada al proceso
	Jump DespaletizadoLugar :Z(0)
	Off GripOn
	Wait .1

	gPalletIndex = gPalletIndex + 1
	gCycleCount = gCycleCount + 1
	Print "Cycle count: ", gCycleCount

	Exit Function

eHandler:
	Print "Error", Err, " en función ", Erf$, ", línea ", Erl, ": ", ErrMsg$(Err)
	Off ReadyLed
	Off InCycle
	On ErrorLight
	Quit All
Fend