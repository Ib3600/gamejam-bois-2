extends CanvasLayer

@onready var textbox_container = $TextBoxContainer
@onready var label = $TextBoxContainer/MarginContainer/HBoxContainer/Label
@onready var indicator = $TextBoxContainer/MarginContainer/HBoxContainer/Indicator
@onready var character_sprite = $character
@onready var player = $player
@onready var fade_rect: ColorRect = $FadeRect

const CHAR_READ_RATE = 0.05
const MAX_READ_RATE = 5.0

enum State {
	READY,
	READING,
	FINISHED
}

var current_state = State.READY
var tween: Tween
var text_queue: Array = []

signal finished  # Pour await entre dialogues

func _ready():
	hide_textbox()
	character_sprite.hide()
	player.hide()
	fade_rect.color.a = 0.0  # transparent
	Global.dialogue = false  # état initial : pas de dialogue

func _process(_delta):
	match current_state:
		State.READY:
			if !text_queue.is_empty():
				display_text()

		State.READING:
			if Input.is_action_just_pressed("ui_accept"):
				label.visible_ratio = 1.0
				if tween:
					tween.kill()
				change_state(State.FINISHED)

		State.FINISHED:
			if Input.is_action_just_pressed("ui_accept"):
				change_state(State.READY)
				if text_queue.is_empty():
					hide_textbox()
					character_sprite.hide()
					player.hide()
					emit_signal("finished")

# ---------------------------------------------------
# --- Dialogue ---
# ---------------------------------------------------

func hide_textbox():
	label.text = ""
	textbox_container.hide()
	if indicator:
		indicator.hide()
	# Si on ferme la box et qu'il n'y a plus de répliques en file, on sort du mode dialogue
	if text_queue.is_empty():
		Global.dialogue = false

func show_textbox():
	textbox_container.show()
	Global.dialogue = true

func queue_text(next_text: String, speaker: String = "nothing") -> void:
	var entry = {"text": next_text, "speaker": speaker}
	text_queue.push_back(entry)
	# Si on (re)lance une file depuis READY, on bascule en mode dialogue
	if current_state == State.READY:
		Global.dialogue = true

func display_text():
	var entry = text_queue.pop_front()
	var next_text: String = entry["text"]
	var speaker: String = entry["speaker"]

	label.text = next_text
	label.visible_ratio = 0.0
	show_textbox()

	match speaker:
		"good fairy":
			character_sprite.show()
			character_sprite.play("good_fairy")
		"marchand":
			character_sprite.show()
			character_sprite.play("marchand")
		_:
			character_sprite.play("nothing")
		"player":
			player.show()
			player.play("default")

	if indicator:
		indicator.hide()

	change_state(State.READING)

	if tween and tween.is_valid():
		tween.finished.disconnect(_on_tween_finished)
		tween.kill()

	var duration = min(len(next_text) * CHAR_READ_RATE, MAX_READ_RATE)
	tween = create_tween()
	tween.tween_property(label, "visible_ratio", 1.0, duration)
	tween.finished.connect(_on_tween_finished)

func _on_tween_finished():
	change_state(State.FINISHED)

func change_state(next_state: State):
	current_state = next_state

	match current_state:
		State.READY:
			# Entre deux bulles : on reste en mode dialogue s'il reste du texte à afficher
			Global.dialogue = not text_queue.is_empty()
			if indicator:
				indicator.hide()

		State.READING:
			Global.dialogue = true
			if indicator:
				indicator.hide()

		State.FINISHED:
			Global.dialogue = true
			if indicator:
				indicator.show()
				indicator.modulate.a = 1.0
				var indicator_tween = create_tween()
				indicator_tween.set_loops()
				indicator_tween.tween_property(indicator, "modulate:a", 0.3, 1.0)
				indicator_tween.tween_property(indicator, "modulate:a", 1.0, 1.0)

# ---------------------------------------------------
# --- Fondu et changement de scène ---
# ---------------------------------------------------

# 🕶️ Attend que le dialogue soit terminé avant de commencer le fondu
func fade_to_black(duration: float = 1.5) -> void:
	await _wait_for_dialogue_end()
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, duration)
	await tween.finished

#🕹️ Attend aussi la fin du dialogue avant de changer de scène
func change_scene(scene_path: String) -> void:
	await _wait_for_dialogue_end()
	await fade_to_black(1.2)
	get_tree().change_scene_to_file(scene_path)

# --- Fonction utilitaire ---
# Attend que tous les dialogues soient fermés
func _wait_for_dialogue_end() -> void:
	while current_state != State.READY or not text_queue.is_empty():
		await get_tree().process_frame
