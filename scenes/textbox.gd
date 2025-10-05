extends CanvasLayer

@onready var textbox_container = $TextBoxContainer
@onready var label = $TextBoxContainer/MarginContainer/HBoxContainer/Label
@onready var indicator = $TextBoxContainer/MarginContainer/HBoxContainer/Indicator  # Optional continue indicator

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
	
	# Example usage
	queue_text("First queue")
	queue_text("Second queue")
	queue_text("Third queue")
	queue_text("Fourth queue")
	queue_text("Fifth queue")
	queue_text("Sixth queue")

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

func hide_textbox():
	label.text = ""
	textbox_container.hide()
	if indicator:
		indicator.hide()

func show_textbox():
	textbox_container.show()

func queue_text(next_text: String):
	text_queue.push_back(next_text)

func display_text():
	var next_text = text_queue.pop_front()
	label.text = next_text
	label.visible_ratio = 0.0
	show_textbox()
	
	if indicator:
		indicator.hide()
	
	change_state(State.READING)
	
	if tween:
		if tween.is_valid():
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
