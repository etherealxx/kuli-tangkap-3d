extends AudioStreamPlayer

func _ready():
	get_stream().set_loop(true)

func _on_music_slider_drag_ended(value_changed):
	set_volume_db(%MusicSlider.value - 20)

