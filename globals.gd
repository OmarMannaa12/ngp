extends Node

const GAME_SCENE: PackedScene = preload("res://Game/Game.tscn")
const MAIN_SCENE: PackedScene = preload("res://Main/main.tscn")
 
func load_game()-> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(GAME_SCENE)
	
func load_main()-> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(MAIN_SCENE)
