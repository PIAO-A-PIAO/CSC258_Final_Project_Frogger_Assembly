#####################################################################
#
# CSC258H5S Fall 2021 Assembly Final Project
# University of Toronto, St. George
#
# Student: Xuanyi Piao, 1005812818
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4
# - Unit height in pixels: 4
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 3
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Start over after collision with cars
# 2. Exit game after three collisions
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Any additional information that the TA needs to know:
# - The program broke down due to the addition of turtles, so I have to remove some features to make it illustratable.
#
#####################################################################

.data
	basePoint: .word 0x10008000
	frameColor: .word 0xf4f8bb
	safeZoneColor: .word 0xbca0c8
	waterColor: .word 0xbce6e4
	roadColor: .word 0x989898
	goalColor: .word 0x444444
	frogColor: .word 0x266000
	logColor: .word 0xc58811
	carColor: .word 0xae4547
	turColor: .word 0x487053
	truckColor: .word 0xcdcbcb

	emptyLine: .asciiz "\n"

	frogShapeOri: .word 14720, 14728, 14736, 14980, 14984, 14988, 15236, 15240, 15244, 15488, 15492, 15496, 15500, 15504, 15744, 15760
	frogShape: .word 14720, 14728, 14736, 14980, 14984, 14988, 15236, 15240, 15244, 15488, 15492, 15496, 15500, 15504, 15744, 15760
	logShape: .space 1440
	turShape: .space 624
	carShape: .space 616
	truckShape: .space 1020

	add $t7, $zero, $zero

.text

################## Main Function #############################
	main:
		jal drawBG
		jal drawFrog
		jal drawLogs
		jal drawCars
		jal drawTurs
		jal drawTrucks
		j movement
################# Movement ##################
	movement:
		lw $t8, 0xffff0000
 		beq $t8, 1, keyboardPressed	#Check for keyboard Input
		j refresh			#Refresh screen

################# Keyboard Pressed ###############33
	keyboardPressed:
		lw $t1, 0xffff0004
		beq $t1, 0x61, aPressed
 		beq $t1, 0x77, wPressed
 		beq $t1, 0x73, sPressed
 		beq $t1, 0x64, dPressed

 	aPressed:
 		jal left
 		j refresh
 	wPressed:
 		jal up
 		j refresh
 	sPressed:
 		jal down
 		j refresh
 	dPressed:
 		jal right
 		j refresh

################### Refresh ##################
	refresh:
		jal drawFrame

		jal shiftLogs
		jal shiftCars
		jal shiftTurs
		jal shiftTrucks		# Update Positions of Barriers

		jal drawWaterRoad	# Re-draw the Background

		jal paintLogs
		jal paintCars
		jal paintTurs
		jal paintTrucks		# Re-draw the Barriers

		jal drawSafeZone
		jal drawGoalZone	# Re-draw the Safe Zones

		jal frogCollision	# Detect Frog Hitted or Not
		beq $t5, 1, startOver

	refreshFrog:
		jal drawFrog	# Re-draw Frog If Not Hitted

		li $v0, 32
		la $a0, 100
		syscall		# Sleep

		j movement	# Repeat the Procedure
################### Draw Background #####################

	drawBG:
		addi $sp, $sp, -4
		sw $ra, 0($sp)

		jal drawFrame
		jal drawSafeZone
		jal drawGoalZone
		jal drawWaterRoad


		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra

################## Draw Frame #################################

	drawFrame:
		lw $t0, basePoint
		lw $t1, frameColor

		addi $sp, $sp, -4
		sw $ra, 0($sp)

		add $t2, $zero, $zero
		jal frameLeft

		addi $t0, $t0, 15872
		jal frameBottom

		addi $t0, $t0, 16376
		jal frameRight

		addi $t0, $t0, 252
		jal frameTop

		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra

	frameLeft:
		beq $t2, 62, frameEnd
		sw $t1, 0($t0)
		sw $t1, 4($t0)
		addi $t0, $t0, 256
		addi $t2, $t2, 1
		j frameLeft

	frameBottom:
		beq $t2, 62, frameEnd
		sw $t1, 0($t0)
		sw $t1, 256($t0)
		addi $t0, $t0, 4
		addi $t2, $t2, 1
		j frameBottom

	frameRight:
		beq $t2, 62, frameEnd
		sw $t1, 0($t0)
		sw $t1, 4($t0)
		addi $t0, $t0, -256
		addi $t2, $t2, 1
		j frameRight

	frameTop:
		beq $t2, 62, frameEnd
		sw $t1, 0($t0)
		sw $t1, 256($t0)
		addi $t0, $t0, -4
		addi $t2, $t2, 1
		j frameTop

	frameEnd:
		add $t2, $zero, $zero
		lw $t0, basePoint
		jr $ra

################# Draw Safe Zone ######################

	drawSafeZone:
		lw $t0, basePoint
		addi $t0, $t0, 520
		lw $t1, safeZoneColor
		add $t2, $zero, $zero

		addi $sp, $sp, -4
		sw $ra, 0($sp)

		jal safeZoneLoop

		lw $t0, basePoint
		addi $t0, $t0, 1800
		add $t2, $zero, $zero
		jal safeZoneLoop  #Top safe zone


		lw $t0, basePoint
		addi $t0, $t0, 8200
		add $t2, $zero, $zero
		jal safeZoneLoop  #Middle safe zone

		lw $t0, basePoint
		addi $t0, $t0, 14600
		add $t2, $zero, $zero
		jal safeZoneLoop  #Bottom safe zone

		lw $ra, 0($sp)
		addi $sp, $sp, 4

		jr $ra

	safeZoneLoop:
		beq $t2, 60, safeZoneEnd
		sw $t1, 0($t0)
		sw $t1, 256($t0)
		sw $t1, 512($t0)
		sw $t1, 768($t0)
		sw $t1, 1024($t0)
		addi $t2, $t2, 1
		addi $t0, $t0, 4
		j safeZoneLoop

	safeZoneEnd:
		jr $ra

####################### Draw Goal Zone #######################
	drawGoalZone:
		lw $t0, basePoint
		addi $t0, $t0, 1820
		lw $t1, goalColor
		add $t2, $zero, $zero
		add $t3, $zero, $zero

		addi $sp, $sp, -4
		sw $ra, 0($sp)

		jal drawGoalLoop

		lw $ra, 0($sp)
		addi $sp, $sp, 4

		jr $ra

	drawGoalLoop:
		beq $t2, 4, drawGoalEnd

	drawSingleGoal:
		beq $t3, 5, singleGoalEnd
		sw $t1, 0($t0)
		sw $t1, 256($t0)
		sw $t1, 512($t0)
		sw $t1, 768($t0)
		sw $t1, 1024($t0)
		addi $t3, $t3, 1
		addi $t0, $t0, 4
		j drawSingleGoal

	singleGoalEnd:
		addi $t2, $t2, 1
		add $t3, $zero, $zero
		addi $t0, $t0, 40
		j drawGoalLoop

	drawGoalEnd:
		jr $ra


################# draw Water and Road ####################
	drawWaterRoad:
		lw $t0, basePoint
		addi $t0, $t0, 3080
		lw $t1, waterColor
		add $t2, $zero, $zero
		add $t3, $zero, $zero

		addi $sp, $sp, -4
		sw $ra, 0($sp)

		jal waterRoadLoop  #Draw Water

		lw $t0, basePoint
		addi $t0, $t0, 9480
		lw $t1, roadColor
		add $t2, $zero, $zero
		add $t3, $zero, $zero
		jal waterRoadLoop  #Draw Road

		lw $ra, 0($sp)
		addi $sp, $sp, 4

		jr $ra

	waterRoadLoop:
		beq $t2, 20, waterRoadEnd

	waterRoadRowLoop:
		beq $t3, 60, waterRoadLoopEnd
		sw $t1, 0($t0)
		addi $t3, $t3, 1
		addi $t0, $t0, 4
		j waterRoadRowLoop

	waterRoadLoopEnd:
		addi $t0, $t0, 16
		add $t3, $zero, $zero
		addi $t2, $t2, 1
		j waterRoadLoop


	waterRoadEnd:
		jr $ra

################ Draw Frog ##################
	drawFrog:
		lw $t0, basePoint
		lw $t1, frogColor
		la $t2, frogShape
		add $t3, $zero, $zero

	drawFrogLoop:
		beq $t3, 16, drawFrogEnd
		lw $t4, 0($t2)
		add $t4, $t4, $t0
		sw $t1, 0($t4)
		addi $t3, $t3, 1
		addi $t2, $t2, 4
		j drawFrogLoop

	drawFrogEnd:
		jr $ra

####################### Draw Logs ######################
	drawLogs:
		addi $sp, $sp, -4
		sw $ra, 0($sp)

		jal saveLogs	# Save Logs as Points in Array
		jal paintLogs	# Paint Logs Based on Relative Position

		lw $ra, 0($sp)
		addi $sp, $sp, 4

		jr $ra

################ Save Logs ###################
	saveLogs:
		addi $t0, $zero, 3336
		add $t1, $zero, $zero
		addi $t2, $zero, 5
		add $t3, $zero, $zero
		add $t4, $zero, $zero

		addi $sp, $sp, -4
		sw $ra, 0($sp)

		jal saveLogsRow		# Log1 in Line1

		addi $t2, $zero, 20
		addi $t0, $t0, 28
		jal saveLogsRow	 	# Log2 in Line1

		addi $t2, $zero, 10
		addi $t0, $t0, 8
		jal saveLogsRow		# Log3 in Line1

		addi $t2, $zero, 10
		addi $t0, $t0, 24
		jal saveLogsRow		# Log4 in Line 1


		addi $t2, $zero, 15
		addi $t0, $zero, 5900
		jal saveLogsRow		# Log1 in Line2

		addi $t2, $zero, 10
		addi $t0, $t0, 28
		jal saveLogsRow		# Log2 in Line2

		addi $t2, $zero, 20
		addi $t0, $t0, 20
		jal saveLogsRow		# Log3 in Line2

		lw $ra, 0($sp)
		addi $sp, $sp, 4

		jr $ra

	saveLogsRow:
		beq $t1, $t2, saveLogsEnd	# Number of Loops Based on Length of the Log
	saveLogsCol:
		beq $t3, 4, saveLogsColEnd	# The Log Has a Width of 4
		sw $t0, logShape($t4)

		addi $t4, $t4, 4
		addi $t0, $t0, 256
		addi $t3, $t3, 1
		j saveLogsCol

	saveLogsColEnd:
		addi $t0, $t0, -1020		# Re-locate Starting Point after One Column
		add $t3, $zero, $zero
		addi $t1, $t1, 1
		j saveLogsRow

	saveLogsEnd:
		add $t1, $zero, $zero
		jr $ra

############### Paint Logs #################

	paintLogs:
		lw $t0, basePoint
		lw $t1, logColor
		add $t2, $zero, $zero
		add $t3, $zero, $zero

		addi $sp, $sp, -4
		sw $ra, 0($sp)

		jal paintLogsLoop

		lw $ra, 0($sp)
		addi $sp, $sp, 4

		jr $ra

	paintLogsLoop:
		beq $t2, 1440, paintLogsEnd	# Number of Loops Based on Number of Data Points in Array
		lw $t3, logShape($t2)
		add $t3, $t0, $t3
		sw $t1, 0($t3)
		addi $t2, $t2, 4
		j paintLogsLoop
		
	paintLogsEnd:
		jr $ra
	
####################### Draw Cars ######################
	drawCars:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		jal saveCars
		jal paintCars
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra
		
################ Save Cars #####################
	
	saveCars:
		addi $t0, $zero, 10804
		add $t1, $zero, $zero
		add $t2, $zero, $zero
		add $t3, $zero, $zero
		add $t4, $zero, $zero
		
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		jal saveCarsRow 	#First car of line 1
		
		addi $t0, $t0, 24
		jal saveCarsRow
		
		addi $t0, $t0, 44
		jal saveCarsRow
		
		addi $t0, $t0, 32
		jal saveCarsRow
		
		addi $t0, $zero, 13340
		jal saveCarsRow
		
		addi $t0, $t0, 48
		jal saveCarsRow
		
		addi $t0, $t0, 72
		jal saveCarsRow
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra
	
	saveCarsRow:
		beq $t1, 2, saveCarsHeadEnd
	saveCarsHeadColLoop:
		beq $t2, 4, saveCarsHeadColEnd
		sw $t0, carShape($t4)
		
		addi $t4, $t4, 4
		addi $t2, $t2, 1
		addi $t0, $t0, 256
		j saveCarsHeadColLoop
		
	saveCarsHeadColEnd:
		addi $t0, $t0, -1020
		add $t2, $zero, $zero
		addi $t1, $t1, 1
		j saveCarsRow
		
	saveCarsHeadEnd:
		addi $t0, $t0 256
		sw $t0, carShape($t4)
		
		addi $t4, $t4, 4
		
		addi $t0, $t0, 256
		sw $t0, carShape($t4)
		addi $t4, $t4, 4
		
		addi $t0, $t0, -508		

	saveCarsTailLoop:
		beq $t1, 5, saveCarsEnd
	saveCarsTailColLoop:
		beq $t2, 4, saveCarsTailColEnd
		sw $t0, carShape($t4)
		
		
		addi $t4, $t4, 4
		addi $t2, $t2, 1
		addi $t0, $t0, 256
		j saveCarsTailColLoop
		
	saveCarsTailColEnd:
		addi $t0, $t0, -1020
		add $t2, $zero, $zero
		addi $t1, $t1, 1
		j saveCarsTailLoop
	
	saveCarsEnd:
		add $t1, $zero, $zero
		jr $ra
		
		
################ Paint Cars ######################
	
	paintCars:
		lw $t0, basePoint
		lw $t1, carColor
		add $t2, $zero, $zero
		add $t3, $zero, $zero
		add $t4, $zero, $zero
		
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		jal paintCarsLoop	
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra
	
	paintCarsLoop:
		beq $t2, 7, paintCarsEnd
		
	paintSingleCar:
		beq $t3, 88, paintSingleCarEnd
		lw $t5, carShape($t4)
		add $t0, $t0, $t5
		sw $t1, 0($t0)
		lw $t0, basePoint
		addi $t3, $t3, 4
		addi $t4, $t4, 4
		j paintCarsLoop
	
	paintSingleCarEnd:
		
		addi $t2, $t2, 1
		add $t3, $zero, $zero
		j paintCarsLoop
		
	paintCarsEnd:
		jr $ra


		
#################### Draw Turtles ####################
	drawTurs:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		jal saveTurs
		jal paintTurs
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra
		
################### Save Turtles #################		
	saveTurs:
		addi $t0, $zero, 4624
		add $t1, $zero, $zero
		add $t2, $zero, $zero
		add $t3, $zero, $zero
		add $t4, $zero, $zero
		
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		jal saveTursLoop
		
		addi $t0, $zero, 4744
		jal saveTursLoop
		
		addi $t0, $zero, 7224
		jal saveTursLoop
		
		addi $t0, $zero, 7344
		jal saveTursLoop
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra

	
	saveTursLoop:
		beq $t1, 3, saveTursEnd
	saveSingleTur:
		beq $t2, 3, saveSingleTurEnd
	saveSingleTurCol:
		beq $t3, 3, saveSingleTurColEnd
		sw $t0, turShape($t4)
		
		addi $t4, $t4, 4
		addi $t3, $t3, 1
		addi $t0, $t0, 256
		j saveSingleTurCol
		
	saveSingleTurColEnd:
		add $t3, $zero, $zero
		addi $t2, $t2, 1
		addi $t0, $t0, -764
		j saveSingleTur
	
	saveSingleTurEnd:
		add $t2, $zero, $zero
		
		addi $t0, $t0, -256
		sw $t0, turShape($t4)
		addi $t4, $t4, 4
		
		addi $t0, $t0, -16
		sw $t0, turShape($t4)
		addi $t4, $t4, 4
		
		addi $t0, $t0, 1024
		sw $t0, turShape($t4)
		addi $t4, $t4, 4
		
		addi $t0, $t0, 16
		sw $t0, turShape($t4)
		addi $t4, $t4, 4
		
		addi $t0, $t0, -760
		addi $t1, $t1, 1
		j saveTursLoop
	saveTursEnd:
		add $t1, $zero, $zero
		jr $ra

################### Paint Turtles ##################
	paintTurs:
		lw $t0, basePoint
		lw $t1, turColor
		add $t2, $zero, $zero
		add $t3, $zero, $zero
		
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		jal paintTursLoop
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra
		
	paintTursLoop:
		beq $t2, 624, paintLogsEnd
		lw $t3, turShape($t2)
		add $t3, $t0, $t3
		sw $t1, 0($t3)
		addi $t2, $t2, 4
		j paintTursLoop
		
	paintTursEnd:
		jr $ra
		
#################### Draw Trucks ###################### 
	drawTrucks:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		jal saveTrucks
		jal paintTrucks
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra
	
################### Save Trucks ####################
	saveTrucks:
		addi $t0, $zero, 9480
		add $t1, $zero, $zero
		add $t2, $zero, $zero
		add $t3, $zero, $zero
		add $t4, $zero, $zero
		
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		jal saveTruckTail
		
		addi $t0, $t0, 32
		jal saveTruckTail
		
		addi $t0, $t0, 48
		jal saveTruckTail
		
		add $t0, $zero, 12080
		jal saveTruckTail
		
		addi $t0, $t0, 112
		jal saveTruckTail
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra
		
	saveTruckTail:
		beq $t2, 6, saveTruckTailEnd
	saveTruckTailCol:
		beq $t3, 5, saveTruckTailColEnd
		sw $t0, truckShape($t4)
		addi $t4, $t4, 4
		addi $t0, $t0, 256
		addi $t3, $t3, 1
		j saveTruckTailCol
	
	saveTruckTailColEnd:
		addi $t2, $t2, 1
		add $t3, $zero, $zero
		addi $t0, $t0, -1276
		j saveTruckTail
		
	saveTruckTailEnd:
		addi $t0, $t0, 256
				
	saveTruckLink:
		beq $t3, 3, saveTruckLinkEnd
		sw $t0, truckShape($t4)
		addi $t4, $t4, 4
		addi $t0, $t0, 256
		addi $t3, $t3, 1
		j saveTruckLink
	
	saveTruckLinkEnd:
		add $t3, $zero, $zero
		addi $t0, $t0, -1020
		
	saveTruckHead:
		beq $t2, 9, saveTruckHeadEnd
	saveTruckHeadCol:
		beq $t3, 5, saveTruckHeadColEnd
		sw $t0, truckShape($t4)
		addi $t4, $t4, 4
		addi $t0, $t0, 256
		addi $t3, $t3, 1
		j saveTruckHeadCol
	
	saveTruckHeadColEnd:
		addi $t2, $t2, 1
		add $t3, $zero, $zero
		addi $t0, $t0, -1276
		j saveTruckHead
	
	saveTruckHeadEnd:
		addi $t0, $t0, 256
		add $t3, $zero, $zero
	saveTruckTip:
		beq $t3, 3, saveTruckEnd
		sw $t0, truckShape($t4)
		addi $t4, $t4, 4
		addi $t0, $t0, 256
		addi $t3, $t3, 1
		j saveTruckTip
		
	saveTruckEnd:
		add $t1, $zero, $zero
		add $t2, $zero, $zero
		add $t3, $zero, $zero
		addi $t0, $t0, -1020
		jr $ra
		
#################### Paint Trucks #####################
	paintTrucks:
		lw $t0, basePoint
		lw $t1, truckColor
		add $t2, $zero, $zero
		add $t3, $zero, $zero
		
	paintTrucksLoop:
		beq $t2, 1020, paintTrucksEnd
		lw $t3, truckShape($t2)
		add $t3, $t3, $t0
		sw $t1, 0($t3)
		addi $t2, $t2, 4
		addi $t4, $t4, 4
		j paintTrucksLoop
		
	paintTrucksEnd:
		jr $ra

##################### Shift Logs #######################
	shiftLogs:
		add $t0, $zero, $zero
		add $t1, $zero, $zero
		addi $t2, $zero, 256
		
	shiftLogsLoop:
		beq $t1, 1440, shiftLogsEnd
		lw $t0, logShape($t1)
		
		rem $t3, $t0, $t2
	shiftLogsRem:
		beq $t3, 244, shiftLogsOver
		
		addi $t0, $t0, 4
		sw $t0, logShape($t1)
		
		addi $t1, $t1, 4
		j shiftLogsLoop
	shiftLogsOver:
		addi $t0, $t0, -236
		sw $t0, logShape($t1)
		
		addi $t1, $t1, 4
		j shiftLogsLoop
		
	shiftLogsEnd:
		jr $ra
		
###################### Shift Cars #####################
	shiftCars:
		add $t0, $zero, $zero
		add $t1, $zero, $zero
		addi $t2, $zero, 256
		
	shiftCarsLoop:
		beq $t1, 616, shiftLogsEnd
		lw $t0, carShape($t1)
		
		rem $t3, $t0, $t2
	shiftCarsRem:
		beq $t3, 8, shiftCarsOver
		
		addi $t0, $t0, -4
		sw $t0, carShape($t1)
		
		addi $t1, $t1, 4
		j shiftCarsLoop
		
	shiftCarsOver:
		addi $t0, $t0, 236
		sw $t0, carShape($t1)
		
		addi $t1, $t1, 4	
		j shiftCarsLoop	
	
	shiftCarsEnd:
		jr $ra
		
################ Shift Turtles ###############
	shiftTurs:
		add $t0, $zero, $zero
		add $t1, $zero, $zero
		addi $t2, $zero, 256
	
	shiftTursLoop:
		beq $t1, 624, shiftTursEnd
		lw $t0, turShape($t1)
		
		rem $t3, $t0, $t2
	shiftTursRem:
		beq $t3, 8, shiftTursOver
		
		addi $t0, $t0, -4
		sw $t0, turShape($t1)
		
		addi $t1, $t1, 4
		j shiftTursLoop
		
	shiftTursOver:
		addi $t0, $t0, 236
		sw $t0, turShape($t1)
		
		addi $t1, $t1, 4
		j shiftTursLoop
	shiftTursEnd:
		jr $ra

##################### Shift Trucks #######################
	shiftTrucks:
		add $t0, $zero, $zero
		add $t1, $zero, $zero
		addi $t2, $zero, 256
		
	shiftTrucksLoop:
		beq $t1, 1020, shiftTrucksEnd
		lw $t0, truckShape($t1)
		
		rem $t3, $t0, $t2
	shiftTrucksRem:
		beq $t3, 244, shiftTrucksOver
		
		addi $t0, $t0, 4
		sw $t0, truckShape($t1)
		
		addi $t1, $t1, 4
		j shiftTrucksLoop
	shiftTrucksOver:
		addi $t0, $t0, -236
		sw $t0, truckShape($t1)
		
		addi $t1, $t1, 4
		j shiftTrucksLoop
		
	shiftTrucksEnd:
		jr $ra
		
############## Left ###################
	left:
		lw $t0, frogShape($zero)
		add $t2, $zero, $zero
	LeftLoop:
		beq $t2, 64, LeftEnd
		lw $t0, frogShape($t2)
		addi $t0, $t0, -20
		
		sw $t0, frogShape($t2)
		addi $t2, $t2, 4
		j LeftLoop
	LeftEnd:
		jr $ra
		
############## Right ###################
	right:
		lw $t0, frogShape($zero)
		add $t2, $zero, $zero
	rightLoop:
		beq $t2, 64, rightEnd
		lw $t0, frogShape($t2)
		
		addi $t0, $t0, 20
		
		sw $t0, frogShape($t2)
		addi $t2, $t2, 4
		j rightLoop
	rightEnd:
		jr $ra
		
############## Up ###################
	up:
		lw $t0, frogShape($zero)
		add $t2, $zero, $zero
	upLoop:
		beq $t2, 64, upEnd
		lw $t0, frogShape($t2)
		
		addi $t0, $t0, -1280
		
		sw $t0, frogShape($t2)
		addi $t2, $t2, 4
		j upLoop
	upEnd:
		jr $ra

############## Down ###################
	down:
		lw $t0, frogShape($zero)
		add $t2, $zero, $zero
	downLoop:
		beq $t2, 64, downEnd
		lw $t0, frogShape($t2)
		
		addi $t0, $t0, 1280
		
		sw $t0, frogShape($t2)
		addi $t2, $t2, 4
		j downLoop
	downEnd:
		jr $ra

################ Frog hitted #################
	frogCollision:
		lw $t0, frogShape($zero)
	frogOverStartZone:
		slti $t2, $t0, 14592
		beq $t2, 1, frogBelowSafeZone
		j frogNotHitted
	frogBelowSafeZone:
		sgt, $t2, $t0, 9468
		beq $t2, 1, frogRoadCollision
		j frogNotHitted

############### Frog Road Collision #################
	frogRoadCollision:
		lw $t0, basePoint
		lw $t1, frogShape($zero)
		lw $t2, roadColor
		add $t0, $t0, $t1
	frogCollisionLoop:
		beq $t3, 5, frogNotHitted
		lw $t4, 0($t0)
		bne $t2, $t4, frogHitted
		addi $t3, $t3, 1
		addi $t0, $t0, 4
		j frogCollisionLoop

	frogHitted:
		addi $t5, $zero, 1
		addi $7, $7, 1
		beq $7, 3, endOfGame
		jr $ra
	frogNotHitted:
		add $t5, $zero, $zero
		jr $ra
		
############### Start Over ##################
	startOver:
		add $t1, $zero, $zero
	startOverLoop:
		beq $t1, 64, startOverEnd
		lw $t2, frogShapeOri($t1)		
		sw $t2, frogShape($t1)
		addi $t1, $t1, 4
		j startOverLoop
	startOverEnd:
		j refreshFrog
		
################ End of Game #################
	endOfGame:
		li $v0, 10
		syscall
		
		
		
	

		
		
		
