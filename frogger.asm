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
	topBarColor: .word 0x000000
	safeZoneColor: .word 0xbca0c8
	waterColor: .word 0xbce6e4
	roadColor: .word 0x989898
	goalColor: .word 0x444444
	takenColor: .word 0xf4f8bb
	frogColor: .word 0x3d9140
	logColor: .word 0xc58811
	carColor: .word 0xae4547
	turColor: .word 0x487053
	truckColor: .word 0xcdcbcb
	omtColor: .word 0xff8a3c
	chosenColor: .word 0x3d9140
	unchosenColor: .word 0xffffff


	frogShapeOri: .word 14720, 14728, 14736, 14980, 14984, 14988, 15236, 15240, 15244, 15488, 15492, 15496, 15500, 15504, 15744, 15760
	frogShape: .word 14720, 14728, 14736, 14980, 14984, 14988, 15236, 15240, 15244, 15488, 15492, 15496, 15500, 15504, 15744, 15760
	logShape: .space 1440
	turShape: .space 624
	carShape: .space 528
	truckShape: .space 816
	flags: .word 0, 0, 0, 0, 0	# NumberOfCollisions, First Goal, Second Goal, Third Goal, Fourth Goal

	One: .word 256, 512, 768, 4, 1028, 8, 1032, 268, 524, 780,
		276, 532, 788, 1044, 280, 540, 796, 1052,
		548, 804, 296, 808, 1064, 556, 1068
	More: .word 256, 512, 768, 1024, 4, 264, 12, 272, 528, 784, 1040,
		536, 792, 284, 1052, 544, 800,
		552, 808, 1064, 300, 560,
		568, 824, 316, 828, 1084, 576, 1088
	Try: .word 0, 4, 260, 516, 772, 1028, 8, 12,
		528, 784, 1040, 276, 536,
		288, 544, 800, 1312, 1316, 296, 552, 808, 1064, 1320
	QM: .word 256, 4, 772, 1284, 264, 520
	Yes: .word 0, 260, 520, 776, 1032, 268, 16,
		532, 788, 280, 792, 1048, 540, 1052,
		292, 548, 1060, 296, 552, 1064, 300, 812, 1068
	N: .word 0, 256, 512, 768, 1024, 4, 264, 524, 16, 272, 528, 784, 1040,
		284, 536, 544, 792, 800, 1052

.text

################## Main Function #############################
	main:
		jal drawBG
		jal drawLives
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

################# Keyboard Pressed ###############
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
		jal drawTopBar
		jal drawLives
		jal shiftFrog
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
		jal drawTopBar
		jal drawSafeZone
		jal drawGoalZone
		jal drawWaterRoad


		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra

################## Draw Top Bar ##############################
	drawTopBar:
		lw $t0, basePoint
		lw $t1, topBarColor
		add $t2, $zero, $zero
		add $t3, $zero, $zero

		addi $t0, $t0, 520
	drawTopBarLoop:
		beq $t2, 60, drawTopBarEnd
		sw $t1, 0($t0)
		sw $t1, 256($t0)
		sw $t1, 512($t0)
		sw $t1, 768($t0)
		sw $t1, 1024($t0)
		addi $t2, $t2, 1
		addi $t0, $t0, 4
		j drawTopBarLoop
	drawTopBarEnd:
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
		addi $t0, $t0, 1800
		lw $t1, safeZoneColor
		add $t2, $zero, $zero

		addi $sp, $sp, -4
		sw $ra, 0($sp)

		jal safeZoneLoop  #Top Safe Zone


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
		addi $t4, $zero, 4

		addi $sp, $sp, -4
		sw $ra, 0($sp)

		jal drawGoalLoop

		lw $ra, 0($sp)
		addi $sp, $sp, 4

		jr $ra

	drawGoalLoop:
		beq $t2, 4, drawGoalEnd

	goalZoneTaken:
		lw $t5, flags($t4)
		addi $t4, $t4, 4
		beq $t5, 1, drawTakenGoal
		j drawSingleGoal

	drawTakenGoal:
		lw $t1, takenColor

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
		lw $t1, goalColor
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

############### Draw Lives ##################
	drawLives:
		lw $t0, basePoint
		lw $t1, frogColor
		addi $t2, $zero, 520
		add $t0, $t0, $t2
		addi $t0, $t0, -14720

		lw $t2, flags($zero)

		addi $t3, $zero, 3
		sub $t2, $t3, $t2
		add $t3, $zero, $zero

		add $t4, $zero, $zero
	drawLivesLoop:
		beq $t3, $t2, drawLiveEnd
	drawSingleLife:
		beq $t4, 64, drawSingleLifeEnd
		lw $t5, frogShapeOri($t4)
		addi $t4, $t4, 4
		add $t5, $t5, $t0
		sw $t1, 0($t5)
		j drawSingleLife

	drawSingleLifeEnd:
		add $t4, $zero, $zero
		addi $t3, $t3, 1
		addi $t0, $t0, 24
		j drawLivesLoop
	drawLiveEnd:
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

		addi $t2, $zero, 15
		addi $t0, $t0, 24
		jal saveLogsRow	 	# Log2 in Line1

		addi $t2, $zero, 15
		addi $t0, $t0, 20
		jal saveLogsRow		# Log3 in Line1

		addi $t2, $zero, 10
		addi $t0, $t0, 16
		jal saveLogsRow		# Log4 in Line 1


		addi $t2, $zero, 15
		addi $t0, $zero, 5900
		jal saveLogsRow		# Log1 in Line2

		addi $t2, $zero, 15
		addi $t0, $t0, 24
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
		addi $t0, $zero, 10760
		add $t1, $zero, $zero
		add $t2, $zero, $zero
		add $t3, $zero, $zero
		add $t4, $zero, $zero

		addi $sp, $sp, -4
		sw $ra, 0($sp)

		jal saveCarsRow 	#First car of line 1

		addi $t0, $t0, 52
		jal saveCarsRow

		addi $t0, $t0, 52
		jal saveCarsRow

		addi $t0, $zero, 13364
		jal saveCarsRow

		addi $t0, $t0, 56
		jal saveCarsRow

		addi $t0, $t0, 56
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
		beq $t2, 6, paintCarsEnd

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

		addi $t0, $zero, 7244
		jal saveTursLoop

		addi $t0, $zero, 7364
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

		addi $t0, $t0, 72
		jal saveTruckTail

		add $t0, $zero, 12088
		jal saveTruckTail

		addi $t0, $t0, 72
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
		beq $t2, 816, paintTrucksEnd
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
		beq $t1, 528, shiftLogsEnd
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
		beq $t1, 816, shiftTrucksEnd
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

################ Frog Collision Options #################
	frogCollision:
		lw $t0, frogShape($zero)
	frogOverStartZone:
		slti $t2, $t0, 14592
		beq $t2, 1, frogBelowSafeZone
		j frogNotHitted
	frogBelowSafeZone:
		sgt, $t2, $t0, 9468
		beq $t2, 1, frogRoadCollision
		j frogOverMidZone
	frogOverMidZone:
		slti $t2, $t0, 8200
		beq $t2, 1, frogBelowGoalZone
		j frogNotHitted
	frogBelowGoalZone:
		sgt, $t2, $t0, 3060
		beq $t2, 1, frogWaterCollision
		j frogGoalCollision

############### Frog Road Collision #################
	frogRoadCollision:
		lw $t0, basePoint
		lw $t1, frogShape($zero)
		lw $t2, roadColor
		add $t3, $zero, $zero
		add $t0, $t0, $t1
	frogRoadCollisionLoop:
		beq $t3, 5, frogNotHitted
		lw $t4, 0($t0)
		bne $t2, $t4, frogHitted
		addi $t3, $t3, 1
		addi $t0, $t0, 4
		j frogRoadCollisionLoop

############### Frog Water Collision #################
	frogWaterCollision:
		lw $t0, basePoint
		addi $t0, $t0, 260
		lw $t1, frogShape($zero)
		lw $t2, waterColor
		add $t0, $t0, $t1
		add $t3, $zero, $zero
		add $t5, $zero, $zero

	frogWaterCollisionLoop:
		beq $t3, 5, countWater
		lw $t4, 0($t0)
		beq $t2, $t4, addWater
		addi $t3, $t3, 1
		addi $t0, $t0, 4
		j frogWaterCollisionLoop

	addWater:
		addi $t5, $t5, 1
		addi $t3, $t3, 1
		addi $t0, $t0, 4
		j frogWaterCollisionLoop

	countWater:
		slti, $t5, $t5, 3
		beq $t5, 1, frogNotHitted
		j frogHitted

############### Frog Goal Zone Collision ###############
	frogGoalCollision:
		lw $t0, basePoint
		lw $t1, frogShape($zero)
		lw $t2, safeZoneColor
		add $t3, $zero, $zero
		add $t0, $t0, $t1
		add $t5, $zero, $zero

	frogGoalCollisionLoop:
		beq $t3, 5, countGoal
		lw $t4, 0($t0)
		beq $t4, $t2, addGoal
		addi $t3, $t3, 1
		addi $t0, $t0, 4
		j frogGoalCollisionLoop
	addGoal:
		addi $t5, $t5, 1
		addi $t3, $t3, 1
		j frogGoalCollisionLoop
	countGoal:
		slti, $t5, $t5, 3
		beq, $t5, 1, frogGoalOccupied
		j frogHitted


################# Frog Goal Occupied ##############
	frogGoalOccupied:
		addi $t6, $zero, 1
		lw $t1, frogShape($zero)


	frogFirstGoal:
		beq $t1, 1820, frogFirstChange
	frogSecondGoal:
		beq $t1, 1880, frogSecondChange
	frogThirdGoal:
		beq $t1, 1940, frogThirdChange
	frogFourthGoal:
		beq $t1, 2000, frogFourthChange
	frogFirstChange:
		addi $t7, $zero, 4
		j frogGoalTaken
	frogSecondChange:
		addi $t7, $zero, 8
		j frogGoalTaken
	frogThirdChange:
		addi $t7, $zero, 12
		j frogGoalTaken
	frogFourthChange:
		addi $t7, $zero, 16
		j frogGoalTaken
	frogGoalTaken:
		sw $t6, flags($t7)
		j startOver
################ Frog Hitted ###################
	frogHitted:
		addi $t5, $zero, 1
		lw $t7, flags($zero)
		addi $t7, $t7, 1
		sw $t7, flags($zero)

		beq $t7, 3, endOfGame
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

############### Shift Frog ###################
	shiftFrog:
		lw $t0, frogShape($zero)
	frogOverMid:
		slti $t2, $t0, 8200
		beq $t2, 1, frogBelowGoal
		jr $ra
	frogBelowGoal:
		sgt, $t2, $t0, 3060
		beq $t2, 1, logOrTur
		jr $ra

	logOrTur:
		addi $t2, $zero, 256
		div $t0, $t2
		mflo $t3

	log1:
		beq $t3, 12, moveWithLog
	tur1:
		beq $t3, 17, moveWithTur
	log2:
		beq $t3, 22, moveWithLog
	tur2:
		beq $t3, 27, moveWithTur



	moveWithLog:
		add $t2, $zero, $zero
	moveWithLogLoop:
		beq $t2, 64, shiftFrogEnd
		lw $t3, frogShape($t2)
		addi $t3, $t3, 4
		sw $t3, frogShape($t2)
		addi $t2, $t2, 4
		j moveWithLogLoop

	moveWithTur:
		add $t2, $zero, $zero
	moveWithTurLoop:
		beq $t2, 64, shiftFrogEnd
		lw $t3, frogShape($t2)
		addi $t3, $t3, -4
		sw $t3, frogShape($t2)
		addi $t2, $t2, 4

		j moveWithTurLoop
	shiftFrogEnd:
		jr $ra



################ End of Game #################
	endOfGame:
		jal drawLives
		jal drawGO
		li $v0, 10
		syscall

############### Draw Game Over ##################
	drawGO:
		addi $sp, $sp, -4
		sw $ra, 0($sp)

		jal drawBG
		jal drawOMT #One More Try
		jal drawYes
		jal drawNo

		lw $ra, 0($sp)
		addi $sp, $sp, 4

		jr $ra

############### Draw One More Try #################
	drawOMT:
		lw $t0, basePoint
		addi $t0, $t0, 5660
		lw $t1, omtColor
		add $t2, $zero, $zero
	drawOne:
		beq $t2, 100, drawOneEnd
		lw $t3, One($t2)
		add $t3, $t3, $t0
		addi $t2, $t2, 4
		sw $t1, 0($t3)
		j drawOne
	drawOneEnd:
		add $t2, $zero, $zero
		addi $t0, $t0, 60

	drawMore:
		beq $t2, 116, drawMoreEnd
		lw $t3, More($t2)
		add $t3, $t3, $t0
		addi $t2, $t2, 4
		sw $t1, 0($t3)
		j drawMore
	drawMoreEnd:
		add $t2, $zero, $zero
		addi $t0, $t0, 76

	drawTry:
		beq $t2, 92, drawTryEnd
		lw $t3, Try($t2)
		add $t3, $t3, $t0
		addi $t2, $t2, 4
		sw $t1, 0($t3)
		j drawTry
	drawTryEnd:
		add $t2, $zero, $zero
		addi $t0, $t0, 52

	drawQM:
		beq $t2, 24, drawQMEnd
		lw $t3, QM($t2)
		add $t3, $t3, $t0
		addi $t2, $t2, 4
		sw $t1, 0($t3)
		j drawQM
	drawQMEnd:
		jr $ra

################# Draw Yes/No ##############
	drawYes:
		lw $t0, basePoint
		addi $t0, $t0, 10880
		lw $t1, chosenColor
		add $t2, $zero, $zero

	drawYesLoop:
		beq $t2, 92, drawYesEnd
		lw $t3, Yes($t2)
		addi $t2, $t2, 4
		add $t3, $t3, $t0
		sw $t1, 0($t3)
		j drawYesLoop
	drawYesEnd:
		jr $ra

############## Draw No ##################
	drawNo:
		lw $t0, basePoint
		addi $t0, $t0, 13188
		lw $t1, unchosenColor
		add $t2, $zero, $zero
	drawNoLoop:
		beq $t2, 76, drawNoEnd
		lw $t3, N($t2)
		addi $t2, $t2, 4
		add $t3, $t3, $t0
		sw $t1, 0($t3)
		j drawNoLoop
	drawNoEnd:
		jr $ra

