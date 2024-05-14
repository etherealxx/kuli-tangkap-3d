extends Control

func _on_retry_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
