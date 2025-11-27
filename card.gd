class_name CardNode extends Control

signal mouseEntered
signal mouseExited
signal clicked

var cardName : String
var description : String

var handler : CardHandler

var cardData = {
	"hp":-1,
	"atk":-1,
	"canAttack":false
}

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
	cardData.hp = d.hp
	cardData.atk = d.atk
	description = d.description
	
	handler = CardHandler.new(self)

func setHP(hp):
	$bg/hp/Label.text = str(hp)

func setATK(atk):
	$bg/atk/Label.text = str(atk)

func popUp():
	$bg.position.y = -100

func popDown():
	$bg.position.y = 0

func clearFrame():
	$frame.visible = false

func highlight():
	$frame.visible = true
	var b = $frame.get_theme_stylebox("panel").duplicate()
	b.bg_color = Color(1.0, 1.0, 0.0, 1.0)
	$frame.add_theme_stylebox_override("panel",b)

func candidateHighlight():
	$frame.visible = true
	var b = $frame.get_theme_stylebox("panel").duplicate()
	b.bg_color = Color(0.0, 0.931, 1.0, 1.0)
	$frame.add_theme_stylebox_override("panel",b)
