#####################################################################
#
# CSC258H5S Fall 2021 Assembly Final Project
# University of Toronto, St. George
#
# Student:
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
# - Milestone 5
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
######## Easy Features #########
# 1. Display number of lives
# 2. Retry screen after eath
# 3. Dynamic increase in difficulty
# 4. Arcade version
# 5. Different speeds in different rows
# 6. Eight Row of obstacles in total
# 7. Death animation
######## Hard Features ##########
# 1. Second level
# 2. Floating objects sink and reappear
# 3. Extra random hazards
# 4. Powerups to scene
#
# Any additional information that the TA needs to know:
#
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
	stateColor: .word 0xff8a3c
	chosenColor: .word 0x3d9140
	unchosenColor: .word 0xffffff
	webColor: .word 0xe0e0e0
	flyColor: .word 0xffccee
	deathColor: .word 0xffffff


	frogShapeOri: .word 14720, 14728, 14736, 14980, 14984, 14988, 15236, 15240, 15244, 15488, 15492, 15496, 15500, 15504, 15744, 15760
	frogShape: .word 14720, 14728, 14736, 14980, 14984, 14988, 15236, 15240, 15244, 15488, 15492, 15496, 15500, 15504, 15744, 15760
	frogShapeGO: .word 12380, 12388, 12396, 12640, 12644, 12648, 12896, 12900, 12904, 13148,13152, 13156, 13160, 13164, 13404, 13420
	spiderWeb: .word 0, 8, 16, 24, 260, 268, 276, 512, 520, 528, 536, 772, 780, 788, 1024, 1032, 1040, 1048
	logShape: .space 1440
	turShape: .space 624
	carShape: .space 528
	truckShape: .space 816
	flyShape: .word 10792, 11048, 11560, 11816, 11308, 11056, 11312, 11568, 11316, 11572
	death: .word 520, 0, 4, 8, 12, 16, 256, 512, 768, 1024, 1028, 1032, 1036, 1040, 272, 528, 784
	flags: .word 0, 1, 1, 1, 0, 1, 0, 0, 0 #NumberOfCollisions, First Goal, Second Goal, Third Goal, Fourth Goal, GameLevel, Turtle Counter, Fly Appear, Amination

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
	Next: .word 0, 256, 512, 768, 1024, 4, 264, 524, 16, 272, 528, 784, 1040,
		536, 792, 284, 796, 1052, 544, 1056,
		552, 1064, 812, 560, 1072,
		568, 316, 572, 828, 1084, 576, 1088
	Level: .word 0, 256, 512, 768, 1024, 1028, 1032,
		528, 784, 276, 788, 1044, 536, 1048,
		544, 800, 1060, 552, 808,
		560, 816, 308, 820, 1076, 568, 1080,
		64, 320, 576, 832, 1088
	Congrats: .word 256, 512, 768, 4, 1028, 8, 1032, 12, 1036,
		532, 788, 280, 1048, 540, 796,
		292, 548, 804, 1060, 296, 556, 812, 1068,
		308, 564, 820, 1332, 312, 824, 1336, 316, 572, 828, 1084,
		324, 580, 836, 1092, 328, 588,
		340, 852, 1108, 344, 856, 1112, 604, 860, 1116,
		612, 360, 616, 872, 1128, 620, 1132,
		372, 628, 1140, 376, 632, 1144, 380, 892, 1148
	Restart: .word 0, 256, 512, 768, 1024, 4, 516, 8, 520, 776, 268, 524, 1036,
		532, 788, 280, 792, 1048, 540, 1052,
		292, 548, 1060, 296, 552, 1064, 300, 812, 1068,
		564, 312, 568, 824, 1080, 572, 1084
		324, 836, 1092, 328, 840, 1096, 588, 844, 1100,
		340, 596, 852, 1108, 344, 604,
		612, 360, 616, 872, 1128, 620, 1132
	Exit: .word -4, 252, 508, 764, 1020, 0, 256, 512, 768, 1024, 4, 516, 1028, 8, 520, 1032,
		528, 1040, 788, 536, 1048,
		32, 544, 800, 1056,
		552, 300, 556, 812, 1068, 560, 1072
	EM: .word 0, 256, 512, 768, 1280
	QM: .word 256, 4, 772, 1284, 264, 520
	Yes: .word 0, 260, 520, 776, 1032, 268, 16,
		532, 788, 280, 792, 1048, 540, 1052,
		292, 548, 1060, 296, 552, 1064, 300, 812, 1068
	No: .word 0, 256, 512, 768, 1024, 4, 264, 524, 16, 272, 528, 784, 1040,
		284, 536, 544, 792, 800, 1052


.text
################## Versions #######################
	versions:

		addi $t0, $zero, 20
		lw $t1, flags($t0)
		beq $t1, 0, main0
		beq $t1, 1, main1
		beq $t1, 2, main1
		beq $t1, 3, main0
		beq $t1, 4, main0
################## Main 1 Function #############################
	main1:
		jal drawBG
		jal drawLives
		jal drawFrog
		jal drawLogs
		jal drawCars
		jal drawTurs
		jal drawTrucks
		jal drawFly

		j movement
################## Main 0 Function ############################
	main0:
		beq $t1, 4, upgrade

		addi $t0, $zero, 20
		lw $t1, flags($t0)

		beq $t1, 2, mode2Lose
		beq $t1, 3, upgradeEnd
	main0Continue:
		addi $t1, $t1, -1
		sw $t1, flags($t0)


	upgradeEnd:
		jal drawLives
		jal frogPointer
		jal drawBG
		jal drawState #One More Try
		jal drawYes
		jal drawNo
		jal drawFrog

		addi $t1, $zero, 20
		j movement

	upgrade:
		addi $t0, $zero, 20
		lw $t1, flags($t0)
		addi $t1, $t1, 2
		sw $t1, flags($t0)
		j upgradeEnd

	mode2Lose:
		lw $t2, flags($zero)
		bne $t2, 3, main0Continue
		add $t1, $zero, $zero
		sw $t1, flags($t0)
		j upgradeEnd
################# Movement ##################
	movement:
		lw $t8, 0xffff0000
 		beq $t8, 1, keyboardPressed	#Check for keyboard Input
		j refresh		#Refresh screen

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
		addi $t0, $zero, 20
		lw $t1, flags($t0)
		beq $t1, 0, refresh0
		beq $t1, 3, refresh0
		beq $t1, 4, refresh0

	refresh1:
		jal drawFrame

		jal shiftLogs
		jal shiftCars
		jal shiftTurs
		jal shiftTrucks		# Update Positions of Barriers
		jal shiftFly

		jal drawWaterRoad	# Re-draw the Background

		jal paintLogs
		jal paintCars
		jal paintTurs
		jal paintTrucks		# Re-draw the Barriers
		jal drawFly

		jal drawSafeZone
		jal drawGoalZone	# Re-draw the Safe Zones
		jal allGoalsTaken

		jal frogCollision	# Detect Frog Hitted or Not
		jal deathAnim
		beq $t5, 1, startOver

	refreshFrog:
		jal drawTopBar
		jal drawLives
		jal shiftFrog
		jal drawFrog	# Re-draw Frog If Not Hitted

		li $v0, 32
		la $a0, 100
		syscall		# Sleep
 		#addi $t1, $zero, 20
		j movement	# Repeat the Procedure

	refresh0:
 		jal drawWaterRoad
 		jal drawState
 		jal drawYes
 		jal drawNo
 		jal drawFrog

 		li $v0, 32
 		la $a0, 100
 		syscall

 		j movement

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
		addi $t0, $t0, 1816
		lw $t1, goalColor
		add $t2, $zero, $zero
		add $t3, $zero, $zero
		addi $t4, $zero, 4
		lw $t5, goalColor
		add $t6, $zero, $zero

		addi $sp, $sp, -4
		sw $ra, 0($sp)

		jal drawGoalLoop

		lw $ra, 0($sp)
		addi $sp, $sp, 4

		jr $ra

	drawGoalLoop:
		beq $t2, 4, drawWeb

	goalZoneTaken:
		lw $t5, flags($t4)
		addi $t4, $t4, 4
		beq $t5, 1, drawTakenGoal
		j drawSingleGoal

	drawTakenGoal:
		lw $t1, takenColor

	drawSingleGoal:
		beq $t3, 7, singleGoalEnd
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
		addi $t0, $t0, 32
		j drawGoalLoop

	drawGoalEnd:
		jr $ra

	drawWeb:
		addi $t0, $zero, 4
		add $t2, $zero, $zero
	drawWebLoop:
		beq $t0, 20, drawGoalEnd
		lw $t1, flags($t0)
		beq $t1, 0, addCount
	drawWebContinue:
		beq $t2, 2, paintWeb
		addi $t0, $t0, 4
		j drawWebLoop
	addCount:
		addi $t2, $t2, 1
		j drawWebContinue
	paintWeb:
		addi $t4, $zero, 15
		mul $t0, $t0, $t4

		lw $t3, basePoint
		addi $t3, $t3, 1756
		add $t0, $t3, $t0

		add $t3, $zero, $zero
		lw $t1, webColor
	paintWebLoop:
		beq $t3, 72, drawGoalEnd
		lw $t2, spiderWeb($t3)
		add $t2, $t0, $t2
		sw $t1, 0($t2)
		addi $t3, $t3, 4
		j paintWebLoop



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
		add $t2, $zero, $zero
	drawFrogLoop:
		beq $t2, 64, drawFrogEnd
		lw $t3, frogShape($t2)
		add $t3, $t3, $t0
		sw $t1, 0($t3)
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

		addi $t4, $zero, 24
		lw $t4, flags($t4)
		slti $t5, $t4, 14
		slti $t4, $t4, 7

		addi $sp, $sp, -4
		sw $ra, 0($sp)

		jal paintTursLoop1

		lw $ra, 0($sp)
		addi $sp, $sp, 4

		jr $ra

	paintTursLoop1:
		beq $t2, 520, paintTurs1End
		lw $t3, turShape($t2)
		add $t3, $t0, $t3
		sw $t1, 0($t3)
		addi $t2, $t2, 4
		j paintTursLoop1

	paintTurs1End:

		beq $t4, 1, paintTurs4
		beq $t5, 1, paintTurs2
		j paintTurs3

	paintTurs2:
		add $t6, $zero, $zero
		addi $t7, $t2, 36
	paintTursLoop2:
		beq $t6, 2, paintTursEnd
		beq $t2, $t7, paintTurs2End
		lw $t3, turShape($t2)
		add $t3, $t0, $t3
		sw $t1, 0($t3)
		addi $t2, $t2, 4
		j paintTursLoop2
	paintTurs2End:
		addi $t6, $t6, 1
		addi $t2, $t2, 16
		addi $t7, $t2, 36
		j paintTursLoop2

	paintTurs3:
		addi $t2, $t2, 16
		lw $t3, turShape($t2)
		add $t3, $t0, $t3
		sw $t1, 0($t3)

		addi $t2, $t2, 52
		lw $t3, turShape($t2)
		add $t3, $t0, $t3
		sw $t1, 0($t3)
		j paintTursEnd

	paintTurs4:
		beq $t2, 624, paintTursEnd
		lw $t3, turShape($t2)
		add $t3, $t0, $t3
		sw $t1, 0($t3)
		addi $t2, $t2, 4
		j paintTurs4

	paintTursEnd:
		addi $t4, $zero, 24
		lw $t5, flags($t4)
		addi $t5, $t5, 1
		beq $t5, 21, clearCounter
		sw $t5, flags($t4)
		jr $ra
	clearCounter:
		add $t5, $zero, $zero
		sw $t5, flags($t4)
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

		addi $t5, $zero, 20
		lw $t5, flags($t5)

	shiftLogsLoop:
		beq $t1, 1440, shiftLogsEnd
		lw $t0, logShape($t1)

		rem $t3, $t0, $t2

		addi $t4, $zero, 4
	shiftLogsRem:
		beq $t5, 2, shiftLogsMode2

	shiftLogsMode2Continue:
		beq $t3, 244, shiftLogsOver
		add $t0, $t0, $t4
		sw $t0, logShape($t1)

		addi $t1, $t1, 4
		j shiftLogsLoop
	shiftLogsOver:
		addi $t4, $t4, -240
		add $t0, $t0, $t4
		sw $t0, logShape($t1)

		addi $t1, $t1, 4
		j shiftLogsLoop

	shiftLogsEnd:
		jr $ra
	shiftLogsMode2:
		addi $t4, $zero, 8
		beq $t3, 240, shiftLogsOver
		j shiftLogsMode2Continue


###################### Shift Cars #####################
	shiftCars:
		add $t0, $zero, $zero
		add $t1, $zero, $zero
		addi $t2, $zero, 256

		addi $t5, $zero, 20
		lw $t5, flags($t5)
	shiftCarsLoop:
		beq $t1, 528, shiftCarsEnd
		lw $t0, carShape($t1)

		rem $t3, $t0, $t2
		addi $t4, $zero, -4
	shiftCarsRem:
		beq $t5, 2, shiftCarsMode2

	shiftCarsMode2Continue:
		beq $t3, 8, shiftCarsOver

		add $t0, $t0, $t4
		sw $t0, carShape($t1)

		addi $t1, $t1, 4
		j shiftCarsLoop

	shiftCarsOver:
		addi $t4, $t4, 240
		add $t0, $t0, $t4
		sw $t0, carShape($t1)

		addi $t1, $t1, 4
		j shiftCarsLoop

	shiftCarsEnd:
		jr $ra
	shiftCarsMode2:
		addi $t4, $zero, -8
		beq $t3, 12, shiftCarsOver
		j shiftCarsMode2Continue

################ Shift Turtles ###############
	shiftTurs:
		add $t0, $zero, $zero
		add $t1, $zero, $zero
		addi $t2, $zero, 256

	shiftTursLoop:
		beq $t1, 624, shiftTursEnd
		lw $t0, turShape($t1)

		rem $t3, $t0, $t2

		addi $t4, $zero, -4
	shiftTursRem:
		beq $t3, 8, shiftTursOver

		add $t0, $t0, $t4
		sw $t0, turShape($t1)

		addi $t1, $t1, 4
		j shiftTursLoop

	shiftTursOver:
		addi $t4, $t4, 240
		add $t0, $t0, $t4
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
		addi $t4, $zero, 4
	shiftTrucksRem:
		beq $t3, 244, shiftTrucksOver

		add $t0, $t0, $t4
		sw $t0, truckShape($t1)

		addi $t1, $t1, 4
		j shiftTrucksLoop
	shiftTrucksOver:
		addi $t4, $t4, -240
		add $t0, $t0, $t4
		sw $t0, truckShape($t1)

		addi $t1, $t1, 4
		j shiftTrucksLoop

	shiftTrucksEnd:
		jr $ra

############## Draw Fly ###############
	drawFly:
		addi $t0, $zero, 28
		lw $t0, flags($t0)
		beq $t0, 1, drawFlyEnd

		lw $t0, basePoint
		lw $t1, flyColor
		add $t2, $zero, $zero
	drawFlyLoop:
		beq $t2, 36, drawFlyEnd
		lw $t4, flyShape($t2)
		add $t4, $t4, $t0
		sw $t1, 0($t4)
		addi $t2, $t2, 4
		j drawFlyLoop
	drawFlyEnd:
		jr $ra

############## Shift Fly ################
	shiftFly:
		add $t0, $zero, $zero
		add $t1, $zero, $zero
		addi $t2, $zero, 256

		addi $t5, $zero, 20
		lw $t5, flags($t5)
	shiftFlyLoop:
		beq $t1, 36, shiftFlyEnd
		lw $t0, flyShape($t1)

		rem $t3, $t0, $t2

		addi $t4, $zero, -4
		beq $t5, 2, shiftFlyMode2
	shiftFlyRem:
		beq $t3, 8, shiftFlyOver
		add $t0, $t0, $t4
		sw $t0, flyShape($t1)

		addi $t1, $t1, 4
		j shiftFlyLoop

	shiftFlyOver:
		addi $t4, $t4, 240
		add $t0, $t0, $t4
		sw $t0, flyShape($t1)

		addi $t1, $t1, 4
		j shiftFlyLoop
	shiftFlyEnd:
		jr $ra
	shiftFlyMode2:
		addi $t4, $zero, -8
		beq $t3, 12, shiftFlyOver
		j shiftFlyRem

############## Left ###################
	left:
		lw $t0, frogShape($zero)
		add $t2, $zero, $zero
		addi $t3, $zero, 20
		lw $t3, flags($t3)

		beq $t3, 0, leftEnd
		beq $t3, 4, leftEnd
		beq $t3, 3, leftEnd
	leftLoop:
		beq $t2, 64, leftEnd
		lw $t0, frogShape($t2)
		addi $t0, $t0, -20

		sw $t0, frogShape($t2)
		addi $t2, $t2, 4
		j leftLoop
	leftEnd:
		jr $ra

############## Right ###################
	right:
		lw $t0, frogShape($zero)
		add $t2, $zero, $zero
		addi $t3, $zero, 20
		lw $t3, flags($t3)

		beq $t3, 0, mode0Right
		beq $t3, 3, mode0Right
		beq $t3, 4, mode0Right
	rightLoop:
		beq $t2, 64, rightEnd
		lw $t0, frogShape($t2)

		addi $t0, $t0, 20

		sw $t0, frogShape($t2)
		addi $t2, $t2, 4
		j rightLoop
	rightEnd:
		jr $ra
	mode0Right:
		beq $t0, 10588, updateGame
		beq $t0, 12380, exitGame

################ Up ###################
	up:
		lw $t0, frogShape($zero)
		add $t2, $zero, $zero
		addi $t3, $zero, 20
		lw $t3, flags($t3)
		addi $t4, $zero, -1280

		beq $t3, 0, mode0Up
		beq $t3, 3, mode0Up
		beq $t3, 4, mode0Up
	upLoop:
		beq $t2, 64, upEnd
		lw $t0, frogShape($t2)
		add $t0, $t0, $t4

		sw $t0, frogShape($t2)
		addi $t2, $t2, 4
		j upLoop
	upEnd:
		jr $ra
	mode0Up:
		beq $t0, 10588, upEnd
		addi $t4, $zero, -1792
		j upLoop

############## Down ###################
	down:
		lw $t0, frogShape($zero)
		add $t2, $zero, $zero
		addi $t3, $zero, 20
		lw $t3, flags($t3)
		addi $t4, $zero, 1280

		beq $t3, 0, mode0Down
		beq $t3, 3, mode0Down
		beq $t3, 4, mode0Down
	downLoop:
		beq $t2, 64, downEnd
		lw $t0, frogShape($t2)

	downLoopContinue:
		add $t0, $t0, $t4

		sw $t0, frogShape($t2)
		addi $t2, $t2, 4
		j downLoop
	downEnd:
		jr $ra
	mode0Down:
		beq $t0, 12380, downEnd
		addi $t4, $zero, 1792
		j downLoopContinue

################ Frog Collision Options #################

	frogCollision:
	frogEatFly:
		add $t1, $zero, $zero
		lw $t0, basePoint
		lw $t5, flyColor
	frogEatFlyLoop:
		beq $t1, 64, frogCollisionContinue
		lw $t2, frogShape($t1)
		add $t2, $t0, $t2
		lw $t2, 0($t2)
		beq $t2, $t5, flyEaten
		addi $t1, $t1, 4
		j frogEatFlyLoop
	flyEaten:
		add $t0, $zero, $zero
		lw $t1, flags($t0)
		addi $t1, $t1, -1
		sw $t1, flags($t0)

		addi $t0, $zero, 28
		lw $t1, flags($t0)
		addi $t1, $t1, 1
		sw $t1, flags($t0)
		j frogNotHitted

	frogCollisionContinue:
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
		bne $t4, $t2, frogHitted
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
		lw $t2, goalColor
		add $t3, $zero, $zero
		add $t0, $t0, $t1
		add $t5, $zero, $zero

	frogGoalCollisionLoop:
		beq $t3, 5, countNotGoal
		lw $t4, 0($t0)
		bne $t4, $t2, addNotGoal
		addi $t3, $t3, 1
		addi $t0, $t0, 4
		j frogGoalCollisionLoop
	addNotGoal:
		addi $t5, $t5, 1
		addi $t3, $t3, 1
		j frogGoalCollisionLoop
	countNotGoal:
		slti, $t5, $t5, 2
		beq, $t5, 1, frogGoalOccupied
		j frogHitted


################# Frog Goal Occupied ##############
	frogGoalOccupied:
		addi $t6, $zero, 1
		lw $t0, frogShape($zero)


	frogFirstGoal:
		slti $t1, $t0, 1856
		beq $t1, 1, frogFirstChange
	frogSecondGoal:
		slti $t1, $t0, 1916
		beq $t1, 1, frogSecondChange
	frogThirdGoal:
		slti $t1, $t0, 1976
		beq $t1, 1, frogThirdChange
	frogFourthGoal:
		slti $t1, $t0, 2036
		beq $t1, 1, frogFourthChange
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

		addi $t1, $zero, 28
		sw $zero, flags($t1)

		j startOver
################ Frog Hitted ###################
	frogHitted:
		addi $t5, $zero, 32
		addi $t7, $zero, 1
		sw $t7, flags($t5)

		addi $t5, $zero, 1
		lw $t7, flags($zero)
		addi $t7, $t7, 1
		sw $t7, flags($zero)


		beq $t7, 3, main0
		jr $ra
	frogNotHitted:
		add $t5, $zero, $zero
		jr $ra

############## Death Animation ###############
	deathAnim:
		lw $t1, deathColor

		addi $t3, $zero, 32
		lw $t3, flags($t3)

		li $v0, 1
		move $a0, $t3
		syscall

		beq $t3, 1, deathAnim1
		beq $t3, 2, deathAnim2
		beq $t3, 3, deathAnim1
	deathAnimEnd:
		jr $ra
	deathAnim1:
		lw $t0, frogShape($zero)
		lw $t2, basePoint
		add $t0, $t0, $t2
		move $s0, $t0

		lw $t4, death($zero)
		add $t4, $t4, $t0
		sw $t1, 0($t4)

		addi $t4, $zero, 2
		addi $t3, $zero, 32
		sw $t4, flags($t3)
		j deathAnimEnd
	deathAnim2:
		add $t5, $zero, $zero
	deathAnim2Loop:
		move $t0, $s0

		beq $t5, 68, deathAnim2End
		lw $t4, death($t5)
		add $t4, $t4, $t0
		sw $t1, 0($t4)
		addi $t5, $t5, 4
		j deathAnim2Loop
	deathAnim2End:
		addi $t4, $zero, 0
		addi $t3, $zero, 32
		sw $t4, flags($t3)
		j deathAnimEnd







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
		addi $t4, $zero, 4

		addi $t5, $zero, 20
		lw $t5, flags($t5)
	moveWithLogLoop:
		beq $t2, 64, shiftFrogEnd
		beq $t5, 2, moveWithLogMode2
	moveWithLogContinue:
		lw $t3, frogShape($t2)
		add $t3, $t3, $t4
		sw $t3, frogShape($t2)
		addi $t2, $t2, 4
		j moveWithLogLoop
	moveWithLogMode2:
		addi $t4, $zero, 8
		j moveWithLogContinue

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


############### Draw Game Over ##################
	drawGO:
		addi $sp, $sp, -4
		sw $ra, 0($sp)

		jal drawBG
		jal drawOMT #One More Try
		jal drawYes
		jal drawNo
		jal drawFrog


		lw $ra, 0($sp)
		addi $sp, $sp, 4

		jr $ra

############## Draw Statement ####################
	drawState:
		addi $t0, $zero, 20
		lw $t0, flags($t0)

		beq $t0, 0, drawOMT
		beq $t0, 3, drawNL
		beq $t0, 4, drawCong
############### Draw One More Try #################
	drawOMT:
		lw $t0, basePoint
		addi $t0, $t0, 5660
		lw $t1, stateColor
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

################ Draw Next Level ################
	drawNL:
		lw $t0, basePoint
		addi $t0, $t0, 5676
		lw $t1, stateColor
		add $t2, $zero, $zero

	drawNext:
		beq $t2, 128, drawNextEnd
		lw $t3, Next($t2)
		add $t3, $t3, $t0
		addi $t2, $t2, 4
		sw $t1, 0($t3)
		j drawNext
	drawNextEnd:
		add $t2, $zero, $zero
		addi $t0, $t0, 80
	drawLevel:
		beq $t2, 124, drawLevelEnd
		lw $t3, Level($t2)
		add $t3, $t3, $t0
		addi $t2, $t2, 4
		sw $t1, 0($t3)
		j drawLevel
	drawLevelEnd:
		add $t2, $zero, $zero
		addi $t0, $t0, 76
		j drawQM

################# Draw Congrats ##############
	drawCong:
		lw $t0, basePoint
		addi $t0, $t0, 5688
		lw $t1, stateColor
		add $t2, $zero, $zero
	drawCongrats:
		beq $t2, 260, drawCongratsEnd
		lw $t3, Congrats($t2)
		add $t3, $t3, $t0
		addi $t2, $t2, 4
		sw $t1, 0($t3)
		j drawCongrats
	drawCongratsEnd:
		add $t2, $zero, $zero
		addi $t0, $t0, 136
	drawEM:
		beq $t2, 20, drawEMEnd
		lw $t3, EM($t2)
		add $t3, $t3, $t0
		addi $t2, $t2, 4
		sw $t1, 0($t3)
		j drawEM
	drawEMEnd:
		jr $ra

################# Draw Yes ##############
	drawYes:
		addi $t0, $zero, 20
		lw $t0, flags($t0)

		beq $t0, 4, drawRestart

		lw $t0, basePoint
		addi $t0, $t0, 10624
		lw $t1, unchosenColor
		add $t2, $zero, $zero

		lw $t3, frogShape($zero)
		beq $t3, 10588, yesChosen
	drawYesLoop:
		beq $t2, 92, drawYesEnd
		lw $t3, Yes($t2)
		addi $t2, $t2, 4
		add $t3, $t3, $t0
		sw $t1, 0($t3)
		j drawYesLoop
	drawYesEnd:
		jr $ra
	yesChosen:
		lw $t1, chosenColor
		j drawYesLoop

################ Draw Restart ###############
	drawRestart:
		lw $t0, basePoint
		addi $t0, $t0, 10624
		lw $t1, unchosenColor
		add $t2, $zero, $zero

		lw $t3, frogShape($zero)
		beq $t3, 10588, restartChosen
	drawRestartLoop:
		beq $t2, 232, drawRestartEnd
		lw $t3, Restart($t2)
		addi $t2, $t2, 4
		add $t3, $t3, $t0
		sw $t1, 0($t3)
		j drawRestartLoop
	drawRestartEnd:
		jr $ra
	restartChosen:
		lw $t1, chosenColor
		j drawRestartLoop

############## Draw No ##################
	drawNo:

		addi $t0, $zero, 20
		lw $t0, flags($t0)

		beq $t0, 4, drawExit

		lw $t0, basePoint
		addi $t0, $t0, 12420
		lw $t1, unchosenColor
		add $t2, $zero, $zero

		lw $t3, frogShape($zero)
		beq $t3, 12380, noChosen
	drawNoLoop:
		beq $t2, 76, drawNoEnd
		lw $t3, No($t2)
		addi $t2, $t2, 4
		add $t3, $t3, $t0
		sw $t1, 0($t3)
		j drawNoLoop
	drawNoEnd:
		jr $ra
	noChosen:
		lw $t1, chosenColor
		j drawNoLoop

############# Draw Exit ################
	drawExit:
		lw $t0, basePoint
		addi $t0, $t0, 12420
		lw $t1, unchosenColor
		add $t2, $zero, $zero

		lw $t3, frogShape($zero)
		beq $t3, 12380, exitChosen
	drawExitLoop:
		beq $t2, 128, drawExitEnd
		lw $t3, Exit($t2)
		addi $t2, $t2, 4
		add $t3, $t3, $t0
		sw $t1, 0($t3)
		j drawExitLoop
	drawExitEnd:
		jr $ra
	exitChosen:
		lw $t1, chosenColor
		j drawExitLoop
############## Update Game #############
	updateGame:
		jal initFlags
		j startOver		#Relocate Frog


############# Frog Pointer #################
	frogPointer:
		add $t0, $zero, $zero
	frogPointerLoop:
		beq $t0, 64, frogPointerEnd
		lw $t1, frogShapeGO($t0)
		sw $t1, frogShape($t0)
		addi $t0, $t0, 4
		j frogPointerLoop
	frogPointerEnd:
		jr $ra

############ Initialize Flags #############
	initFlags:
		add $t0, $zero, $zero
		sw $zero, flags($zero)
		addi $t0, $t0, 4
	initFlagsLoop:
		beq $t0, 20, initFlagsEnd
		sw $zero, flags($t0)
		addi $t0, $t0, 4
		j initFlagsLoop
	initFlagsEnd:
		lw $t2, flags($t0)
		beq $t2, 3, upgradeFlag

		addi $t1, $zero, 1
		sw $t1, flags($t0)
		jr $ra
	upgradeFlag:
		addi $t1, $zero, 2
		sw $t1, flags($t0)
		jr $ra

############ All Goals Taken ###############
	allGoalsTaken:
		add $t0, $zero, 4
		add $t1, $zero, $zero
	allGoalsTakenLoop:
		beq $t0, 20, allGoalsEnd
		lw $t2, flags($t0)
		beq $t2, 1, countGoals
		addi $t0, $t0, 4
		j allGoalsTakenLoop
	countGoals:
		addi $t1, $t1, 1
		addi $t0, $t0, 4
		j allGoalsTakenLoop
	allGoalsEnd:
		beq $t1, 4, main0
		jr $ra

############# Print Flags ##############
	printFlags:
		add $t0, $zero, $zero
	printFlagsLoop:
		beq $t0, 24, exitGame
		li $v0, 1
		lw $a0, flags($t0)
		syscall
		addi $t0, $t0, 4
		j printFlagsLoop


############# Exit Game ################
	exitGame:
		li $v0, 10
		syscall
