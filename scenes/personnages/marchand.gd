extends StaticBody2D

var is_trading: bool
var has_talked_today: bool = false  # pour ne pas répéter le dialogue "première fois"

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var texture_rect: ColorRect = $TextureRect

# --- STRUCTURE DES DIALOGUES ---
var dialogues := {
	1: {
		"first": [
			"Bonjour.",
			"Tu as parlé à mon frère ?",
			"J'espère qu'il va bien.",
			"Bref",
			"De l'argent contre un peu de chaleur ça te dit ?"
		],
		"final": [
			"T'as pas du boulot ??"
		]
	},
	2: {
		"first": [
			"La tempête est plus calme aujourd’hui.",
			"Tu devrais pouvoir t'aventurer un peu plus loin."
		],
		"final": [
			"Je reste ici encore un moment, histoire d’écouler mes stocks.",
			"Et parce que j'ai pas le choix."
		]
	},
	3: {
		"first": [
			"...",
			"On va tous mourir."
		],
		"final": [
			"Je suis assez résistant à la chaleur, mais je mange beaucoup.",
			"Je suis un grand gaillard, que veux-tu.",
			"...",
			"Non, je ne sortirai pas au milieu de cette tempête."
		]
	},
	4: {
		"first": [
			"...",
			"On va tous mourir."
		],
		"final": [
			"..."
		]
	},
	5: {
		"first": [
			"J'aime mon frère.",
			"Mais je le déteste aussi."
		],
		"final": [
			"..."
		]
	},
	"fallback": {
		"first": [
			"Bienvenue étranger, le commerce ne dort jamais."
		],
		"final": [
			"Je me demande combien de temps encore ce blizzard durera..."
		]
	}
}


# --- READY ---
func _ready():
	is_trading = false
	anim.play("default")
	texture_rect.visible = false


# --- PROCESS ---
func _process(_delta):
	texture_rect.visible = is_trading

	if is_trading and Input.is_action_just_pressed("hit"):
		_start_trade_dialogue()


# --- DÉTECTION ZONE ---
func _on_trade_zone_body_entered(body):
	if body.is_in_group("player"):
		is_trading = true


func _on_trade_zone_body_exited(body):
	if body.is_in_group("player"):
		is_trading = false


# --- DIALOGUES ---
func _start_trade_dialogue():
	if Global.dialogue:
		return  # bloque si un dialogue est déjà en cours

	# Récupère le jour courant ou fallback sur 1
	var day = 1
	if "current_day" in Global:
		day = Global.current_day

	var day_dialogues = dialogues.get(day, dialogues["fallback"])

	# --- PREMIÈRE DISCUSSION DU JOUR ---
	if not has_talked_today:
		for line in day_dialogues["first"]:
			Textbox.queue_text(line, "marchand")
		has_talked_today = true
		return  # Pas de final ici

	# --- DISCUSSIONS SUIVANTES ---
	var said_state_dialogue := false


	var a_froid = Global.etat_marchand[0]
	var a_faim = Global.etat_marchand[1]

	if a_froid and a_faim:
		Textbox.queue_text("J’ai froid et faim...", "marchand")
		said_state_dialogue = true
	elif a_froid:
		Textbox.queue_text("J’ai froid... Ce qui ne m’arrive jamais.", "marchand")
		said_state_dialogue = true
	elif a_faim:
		Textbox.queue_text("J’ai faim.", "marchand")
		said_state_dialogue = true
	else:
		Textbox.queue_text("Je vais bien.", "marchand")
		said_state_dialogue = true


	# --- FINAL : seulement si un dialogue d’état a été dit ---
	if said_state_dialogue:
		for line in day_dialogues["final"]:
			Textbox.queue_text(line, "marchand")
