class_name CardHandler extends Node

var this : CardNode

func _init(pThis : CardNode):
	this = pThis

func turnStart():
	this.cardData.canAttack = true

func attack(victim : CardNode):
	victim.cardData.hp -= this.cardData.atk
	victim.setHP(victim.cardData.hp)
	victim.handler.onHurt()

func onHurt():
	pass
