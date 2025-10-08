extends PanelContainer

signal item_buy_pressed(id)


@onready var texture = $HBoxContainer/MarginContainer2/TextureRect
@onready var heading_1 = $HBoxContainer/MarginContainer/VBoxContainer/Heading1
@onready var heading_2 = $HBoxContainer/MarginContainer/VBoxContainer/Heading2
@onready var button = $HBoxContainer/MarginContainer/VBoxContainer/Button


var id : int


func setup(data : Dictionary, p_id: int) -> void:
	texture.texture = load(data.get("icon_path"))
	heading_1.text = data.get("heading_1", "")
	heading_2.text = data.get("heading_2", "")
	id = p_id

	if data.get("custom_button_text"):
		button.text = data.get("custom_button_text")


func _on_button_pressed() -> void:
	emit_signal("item_buy_pressed", id)
