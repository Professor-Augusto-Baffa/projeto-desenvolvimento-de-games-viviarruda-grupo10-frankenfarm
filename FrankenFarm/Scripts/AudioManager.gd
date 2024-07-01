extends Node

var playing = false
var canPlay = true
var timerRunning = false

func _process(_delta):
	if Global.transition and not timerRunning:
		playing = false
		Global.transition = false
		$PlayTimer.start()
		canPlay = false
		$Transition.play()
		timerRunning = true
	else:
		if not playing and canPlay:
			if Global.nightTime:
				playing = true
				$Night.play()
				$Day.stop()
			else:
				playing = true
				$Day.play()
				$Night.stop()


func _on_play_timer_timeout():
	canPlay = true
	timerRunning = false
