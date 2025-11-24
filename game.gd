extends Control

var initialized = false
var setup = false

var initStarted = false
var setupStarted = false


var db_ref : FirebaseDatabaseReference

#server id
var sid

#player (1 or 2)
var player

#players datas 
var playerDat
var opp

var ismyturn = false

var hand = []

func _ready():
	Firebase.Auth.login_anonymous()

#ignore!
func buttonAction(idx):
	execAction(str(idx))
	turnsActions.append(str(idx))
######################


#Joins server when submit button pressed
func _on_serverid_pressed():
	
	#gets the server id from the user inputted line edit
	sid = $serverid/LineEdit.text
	
	#reference the database top-level servers directory (probably not scalable)
	db_ref = Firebase.Database.get_database_reference("HCG-servers",{})
	
	db_ref.new_data_update.connect(dataUpdate)
	db_ref.patch_data_update.connect(dataUpdate)
	db_ref.delete_data_update.connect(dataUpdate)

	#send a random update call to trigger a dataUpdate call (probably the worst way to do it)
	db_ref.update("",{"iafjswoiafho":randi_range(1,100000)})

#returns the data stored at a path in relation to the current database reference (always the server directory usually hopefully)
#@param <p>:String, path relative to database reference
func getData(p):
	
	#makes a once call to the database position
	var odb_ref : FirebaseOnceDatabaseReference = Firebase.Database.get_once_database_reference(p,{})
	odb_ref.once("")
	var data = await odb_ref.once_successful
	return data

#initializes the server, handles joining.
func init():
	initStarted = true
	
	#check if the server ID is present in the list: if yes, join that server. If no: create new one
	var dat = await getData("HCG-servers")
	
	var serverList = dat.serverList
	if serverList.has(sid):
		db_ref = Firebase.Database.get_database_reference("HCG-servers/"+sid, {})
		db_ref.update("",{"started":true})
		player = 2
	else:
		serverList[sid]=true
		db_ref.update("serverList", serverList)
		db_ref.update(sid, {"started":false, "turns":["-1"], "currentTurn":1})
		
		player = 1
		db_ref = Firebase.Database.get_database_reference("HCG-servers/"+sid, {})
	#db_ref is now set to server-specific database directory
	
	#TEMP HARDCODED PLAYER DATA
	if player == 1:
		playerDat = {
			"country":"US",
			"deck":[
				"Musketeer",
				"Musketeer",
				"Musketeer",
				"Musketeer",
				"Musketeer",
				"Musketeer",
				"Musketeer",
				"Musketeer",
				"Musketeer",
				"Musketeer",
				"Musketeer",
				"Musketeer",
				"Musketeer",
				"Musketeer",
			],
			"hp":20,
			"money":0,
			"handCount":5
		}
	else:
		playerDat = {
			"country":"France",
			"deck":[
				"Croissant",
				"Croissant",
				"Croissant",
				"Croissant",
				"Croissant",
				"Croissant",
				"Croissant",
				"Croissant",
				"Croissant",
				"Croissant",
				"Croissant",
				"Croissant",
				"Croissant",
				"Croissant",
			],
			"hp":20,
			"money":0,
			"handCount":5
		}
	
	#add player data to database, finish init
	db_ref.update("player"+str(player),playerDat)

	$serverid.queue_free()
	initialized = true

#sets up the game world after server is initalized
func doSetup():

	#verifies all initialization has been complete
	if !initialized:return
	
	var s = await getData("HCG-servers")
	if !s.has(sid):return

	var data = await getData("HCG-servers/"+sid)

	
	if !data.has("player1") or !data.has("player2"):
		return
	
	if setupStarted:
		return
	
	setupStarted=true

	#correctly assign opp and current data and update consoles
	if player == 1:
		opp = data.player2
	else:
		opp = data.player1
	
	$console/flag.texture = GameData.flags[playerDat.country]
	$oppbar/flag.texture = GameData.flags[opp.country]
	$oppbar/hp.text = str(opp.hp)
	$oppbar/money.text = str(opp.money)

	#draw first cards, finish setting up
	draw(5)
	setOppHandCount(opp.handCount)
	
	setup = true
	if player == 1:
		turnStart(data)

#holds a reference to the packed card scene
var cardScene = preload("res://card.tscn")

#draws count amount of cards from player's deck to player's hand (client player only)
#@param <count>:int, number of cards to draw 
func draw(count):
	for i in range(count):
		hand.append(playerDat.deck.pop_front())
		
		#add card object to displayed hand in bottom left
		var cardi : CardNode = cardScene.instantiate()
		cardi.setCard(hand[-1])
		$console/ScrollContainer/HBoxContainer.add_child(cardi)

var icon = preload("res://assets/icon.svg")

#sets the opponent's hand count of face down cards in top left
#@param <cnt>:int, cards to show
func setOppHandCount(cnt):
	for i in $oppbar/ScrollContainer/HBoxContainer.get_children():
		i.queue_free()
	
	for x in range(cnt):
		var t = TextureRect.new()
		t.texture = icon
		$oppbar/ScrollContainer/HBoxContainer.add_child(t)

#called whenever data in the server is updated. NEVER CALLED BY CLIENT
func dataUpdate(d):
	
	#handle init and setup
	if !initStarted:
		init()
		return
	if !initialized:
		return
	
	if !setupStarted:
		doSetup()
		return
	if !setup:
		return
	
	#handle turn switches
	print(sid + str(d))
	var data = await getData("HCG-servers/"+sid)
	print(data)
	
	var wasmyturn = ismyturn
	ismyturn = data.currentTurn == player
	
	#on a new turn, call turnStart (am i overcommenting)
	if ismyturn and not wasmyturn:
		turnStart(data)

#handles the start of a turn. PROBABLY NOT EVER CALLED BY YOU (yes, I mean you)
#@param <data>:Dictionary, all the data of the server at the start of the turn
func turnStart(data):
	
	#do some random start of turn stuff
	$endTurn.visible = true
	
	if player==1:
		opp = data.player2
	else:
		opp = data.player1
	
	$oppbar/hp.text = "HP"+str(opp.hp)
	$oppbar/money.text = "$"+str(opp.money)
	
	draw(1)
	setOppHandCount(opp.handCount)
	
	#run through the opponent's previous turns actions and call execAction on them
	if data.turns[0] != "-1":
		for action in data.turns:
			execAction(action)

#should hold this turns actions
var turnsActions = ["-1"]

#ends a turn. called when end turn button is pressed.
func _on_end_turn_pressed():
	$endTurn.visible = false
	db_ref.update("",{"turns":turnsActions})
	db_ref.update("player"+str(player),{"handCount":len(hand)})
	db_ref.update("",{"currentTurn":1 if player == 2 else 2})

#performs an action based off the data present in the action string.
#both clients will call execAction to handle actions in order to ensure deterministic behavior.
#EXAMPLE: player 1 places a card -> client 1 calls execAction("place card 1")
#         server updates with turn array holding string "place card 1"
#         at the start of opponent's next turn, execAction is called with the same string.
#@param <action>:String, data describing action done. format TBD
func execAction(action):
	
	##what the button action
	pass
