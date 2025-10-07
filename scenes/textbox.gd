extends CanvasLayer

@onready var textbox_container = $TextBoxContainer
@onready var label = $TextBoxContainer/MarginContainer/HBoxContainer/Label
@onready var indicator = $TextBoxContainer/MarginContainer/HBoxContainer/Indicator
@onready var character_sprite = $character  

const CHAR_READ_RATE = 0.05
const MAX_READ_RATE = 5.0

enum State {
	READY,
	READING,
	FINISHED
}

var current_state = State.READY
var tween: Tween
var text_queue = []

func _ready():
	hide_textbox()
	character_sprite.hide()  # ✅ on cache le sprite dès le début

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
					character_sprite.hide()  # ✅ on cache le sprite à la fin du dialogue

func hide_textbox():
	label.text = ""
	textbox_container.hide()
	if indicator:
		indicator.hide()

func show_textbox():
	textbox_container.show()

func queue_text(next_text: String, speaker: String = "nothing"):
	var entry = {
		"text": next_text,
		"speaker": speaker
	}
	text_queue.push_back(entry)

func display_text():
	var entry = text_queue.pop_front()
	var next_text = entry["text"]
	var speaker = entry["speaker"]
	
	label.text = next_text
	label.visible_ratio = 0.0
	show_textbox()
	character_sprite.show() 

	match speaker:
		"good fairy":
			character_sprite.play("good_fairy")
		"marchand":
			character_sprite.play("marchand")
		_:
			character_sprite.play("nothing")

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
			if indicator:
				indicator.hide()
		
		State.READING:
			if indicator:
				indicator.hide()
		
		State.FINISHED:
			if indicator:
				indicator.show()
				indicator.modulate.a = 1.0
				var indicator_tween = create_tween()
				indicator_tween.set_loops()
				indicator_tween.tween_property(indicator, "modulate:a", 0.3, 1.0)
				indicator_tween.tween_property(indicator, "modulate:a", 1.0, 1.0)
				
func start_dialogue():
	Global.dialogue = true
func end_dialogue():
	Global.dialogue = false
