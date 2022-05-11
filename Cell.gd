extends TextureButton

signal disable_toggled

export(int) var value = 0 setget set_value
export(Color) var pressed_color
export(Color) var enabled_color
export(Color) var disabled_color

func _ready():
	if get('disabled'):
		$Number.set('custom_colors/font_color', disabled_color)
	$Number.text = str(value)


func _on_Cell_toggled(button_pressed):
	if button_pressed:
		$Number.set('custom_colors/font_color', pressed_color)
	else:
		$Number.set('custom_colors/font_color', enabled_color)
		
func _on_Cell_disable_toggled(button_disabled):
	if button_disabled:
		$Number.set('custom_colors/font_color', disabled_color)
	elif get('pressed'):
		$Number.set('custom_colors/font_color', pressed_color)
	else:
		$Number.set('custom_colors/font_color', enabled_color)

func _set(property, new_value):
	if property == 'disabled':
		emit_signal("disable_toggled", new_value)
	
func set_value(new_value):
	value = new_value
	$Number.text = str(new_value)
