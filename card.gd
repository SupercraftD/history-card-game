class_name CardNode extends Control

signal mouseEntered
signal mouseExited
signal clicked

var cardName : String

func _on_mouse_entered():
	mouseEntered.emit()


func _on_mouse_exited():
	mouseExited.emit()

func _on_gui_input(event:InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			clicked.emit()

func setCard(card):
	cardName = card
	var d = GameData.cards[card]
	$bg/TextureRect.texture = d.sprite
	setHP(d.hp)
	setATK(d.atk)

func setHP(hp):
	$bg/hp/Label.text = str(hp)

func setATK(atk):
	$bg/atk/Label.text = str(atk)

func popUp():
	$bg.position.y = -100

func popDown():
	$bg.position.y = 0
