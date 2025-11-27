extends Node

var flags = {
	"US":preload("res://assets/usflag.png"),
	"France":preload("res://assets/franceflag.png")
}

var cards = {
	"Musketeer":{
		"hp":1,
		"atk":1,
		"sprite":preload("res://assets/musketeer.jpg"),
		"description":"I must be ready"
	},
	"Croissant":{
		"hp":1,
		"atk":1,
		"sprite":preload("res://assets/croissant.jpg"),
		"description":"oui oui baguette"
	},
	"George Washington":{
		"hp":20,
		"atk":20,
		"sprite":preload("res://assets/georgewashington.jpg"),
		"description":"just call me Mr. President"
	}
}
