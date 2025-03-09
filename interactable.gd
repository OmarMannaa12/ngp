class_name Interactable extends Node3D

enum Types {
	DOOR,
	EXIT_DOOR,
	VENDING_MACHINE,
	PAYPHONE
}

var type: Types

var interactable: bool

func _init() -> void:
	interactable = true
