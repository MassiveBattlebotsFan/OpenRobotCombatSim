extends SpinBox


func _value_changed(new_value):
	if new_value < 0:
		set_value_no_signal(new_value + 360)
