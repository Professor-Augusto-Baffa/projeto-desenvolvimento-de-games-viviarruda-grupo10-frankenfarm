extends Node

func _process(_delta):
	if Global.playerAlive:
		if Global.playerAttacking:
			$Swing.play()
		if Global.damageGiven:
			$Hit.play()
			Global.damageGiven = false
		if Global.planted:
			$Plant.play()
			Global.planted = false
	if Global.nightTime:
		if not $Noise.is_playing():
			$Noise.play()
		$Noise.volume_db = (10-Global.playerCurrLife) - 15
		if not Global.playerAlive:
			$Noise.volume_db = 0
	else:
		if $Noise.is_playing():
			$Noise.stop()