extends StaticBody2D

var is_talking: bool = false
var talk_stage: int = 0  # 0 = demande, 1 = a reçu bois, 2+ = dialogues d'état

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# --- DIALOGUES ---
var dialogues := {
	"first": [
		"...",
		"Donne-moi du bois."
	],
	"gave_wood": [
		"Merci."
	],
	"return_wood": [
		"Tiens."
	],
	"state_froid": [
		"J’ai froid..."
	],
	"state_faim": [
		"J’ai faim..."
	],
	"state_both": [
		"J’ai froid et faim..."
	]
}

# --- READY ---
func _ready():
	if Global.sante_pantin <= 0:
		queue_free()
	anim.play("default")

# --- PROCESS ---
func _process(_delta):
	if is_talking and Input.is_action_just_pressed("hit"):
		_start_dialogue()

# --- DÉTECTION ZONE ---
func _on_talk_zone_body_entered(body):
	if body.is_in_group("player"):
		is_talking = true

func _on_talk_zone_body_exited(body):
	if body.is_in_group("player"):
		is_talking = false

# --- DIALOGUE LOGIQUE ---
func _start_dialogue():
	if Global.dialogue:
		return

	var day = Global.current_day

	#  💡 Si le pantin te doit du bois et qu'on est un jour nouveau
	if Global.pantin_owes_wood and Global.pantin_last_talked_day < day:
		for line in dialogues["return_wood"]:
			Textbox.queue_text(line, "pantin")
		Global.wood_stock += 8
		Global.pantin_owes_wood = false
		Global.pantin_last_talked_day = day
		talk_stage = 2  # Repart ensuite sur les dialogues normaux
		return

	# 🪵 1ère fois : il demande du bois
	if talk_stage == 0:
		for line in dialogues["first"]:
			Textbox.queue_text(line, "pantin")
		talk_stage = 1
		Global.pantin_last_talked_day = day
		return

	# 💰 2e fois : il prend 5 bois si possible
	elif talk_stage == 1:
		if Global.wood_stock >= 5:
			Global.wood_stock -= 5
			for line in dialogues["gave_wood"]:
				Textbox.queue_text(line, "pantin")
			Global.pantin_owes_wood = true
			Global.pantin_last_talked_day = day
		else:
			Textbox.queue_text("Tu n’as pas assez de bois...", "pantin")
		talk_stage = 2
		return

	# 🧊 3e fois et après : dialogues selon l’état
	else:
		_show_state_dialogues()
		Global.pantin_last_talked_day = day


# --- ÉTATS FAIM / FROID ---
func _show_state_dialogues():
	var a_froid = Global.etat_pantin[0]
	var a_faim = Global.etat_pantin[1]

	if a_froid and a_faim:
		for line in dialogues["state_both"]:
			Textbox.queue_text(line, "pantin")
	elif a_froid:
		for line in dialogues["state_froid"]:
			Textbox.queue_text(line, "pantin")
	elif a_faim:
		for line in dialogues["state_faim"]:
			Textbox.queue_text(line, "pantin")
	else:
		Textbox.queue_text("Je me sens... en bois.", "pantin")
