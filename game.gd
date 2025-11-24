extends Control

var initialized = false
var setup = false

var initStarted = false
var setupStarted = false


var db_ref : FirebaseDatabaseReference
var sid
var player
var playerDat
var opp

var ismyturn = false

var hand = []

func _ready():
	Firebase.Auth.login_anonymous()

func buttonAction(idx):
	execAction(str(idx))
	turnsActions.append(str(idx))
######################



func _on_serverid_pressed():
	
	sid = $serverid/LineEdit.text
	db_ref = Firebase.Database.get_database_reference("HCG-servers",{})
	
	db_ref.new_data_update.connect(dataUpdate)
	db_ref.patch_data_update.connect(dataUpdate)
	db_ref.delete_data_update.connect(dataUpdate)

	db_ref.update("",{"iafjswoiafho":randi_range(1,100000)})

func getData(p):
	var odb_ref : FirebaseOnceDatabaseReference = Firebase.Database.get_once_database_reference(p,{})
	odb_ref.once("")
	var data = await odb_ref.once_successful
	return data

func init():
	initStarted = true
	
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
	
	
	db_ref.update("player"+str(player),playerDat)

	$serverid.queue_free()
	initialized = true

func doSetup():

	if !initialized:return
	
	var s = await getData("HCG-servers")
	if !s.has(sid):return

	var data = await getData("HCG-servers/"+sid)

	
	if !data.has("player1") or !data.has("player2"):
		return
	
	if setupStarted:
		return
	
	setupStarted=true

	if player == 1:
		opp = data.player2
	else:
		opp = data.player1
	
	$console/flag.texture = GameData.flags[playerDat.country]
	$oppbar/flag.texture = GameData.flags[opp.country]
	$oppbar/hp.text = str(opp.hp)
	$oppbar/money.text = str(opp.money)

	draw(5)
	setOppHandCount(opp.handCount)
	
	setup = true
	if player == 1:
		turnStart(data)

var cardScene = preload("res://card.tscn")

func draw(count):
	for i in range(count):
		hand.append(playerDat.deck.pop_front())
		var cardi : CardNode = cardScene.instantiate()
		cardi.setCard(hand[-1])
		$console/ScrollContainer/HBoxContainer.add_child(cardi)

var icon = preload("res://assets/icon.svg")
func setOppHandCount(cnt):
	for i in $oppbar/ScrollContainer/HBoxContainer.get_children():
		i.queue_free()
	
	for x in range(cnt):
		var t = TextureRect.new()
		t.texture = icon
		$oppbar/ScrollContainer/HBoxContainer.add_child(t)

func dataUpdate(d):
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
	
	print(sid + str(d))
	var data = await getData("HCG-servers/"+sid)
	print(data)
	
	var wasmyturn = ismyturn
	ismyturn = data.currentTurn == player
	
	if ismyturn and not wasmyturn:
		turnStart(data)

func turnStart(data):
	$endTurn.visible = true
	
	if player==1:
		opp = data.player2
	else:
		opp = data.player1
	
	$oppbar/hp.text = "HP"+str(opp.hp)
	$oppbar/money.text = "$"+str(opp.money)
	
	draw(1)
	setOppHandCount(opp.handCount)
	
	if data.turns[0] != "-1":
		for action in data.turns:
			execAction(action)

var turnsActions = ["-1"]

func _on_end_turn_pressed():
	$endTurn.visible = false
	db_ref.update("",{"turns":turnsActions})
	db_ref.update("player"+str(player),{"handCount":len(hand)})
	db_ref.update("",{"currentTurn":1 if player == 2 else 2})

func execAction(action):
	
	##what the button action
	pass
