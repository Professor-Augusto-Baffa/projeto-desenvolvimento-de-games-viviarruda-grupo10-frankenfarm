extends Control

func _process(_delta):
	if not Global.playerAlive:
		visible = true


func _on_button_pressed():
	reset()
	get_tree().change_scene_to_file("res://Scenes/World.tscn")

func reset():
	Global.playerAttacking = false 
	Global.nightTime = false
	Global.playerCurrLife = 10
	Global.playerCanPlant = false
	Global.transition = false
	Global.damageGiven = false
	Global.planted = false
	Global.playerAlive = true



