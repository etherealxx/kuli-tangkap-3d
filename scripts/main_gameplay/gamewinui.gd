extends Control

func _on_replay_pressed():
	get_tree().paused = false
	GlobalVar.restartfromcatching = false
	get_tree().reload_current_scene()
