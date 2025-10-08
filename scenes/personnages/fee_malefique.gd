extends StaticBody2D

var is_talking: bool
var has_talked_today: bool = false
var has_healed_today: bool = false  # ✅ ne soigne qu’une fois par jour

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


# --- STRUCTURE DES DIALOGUES ---
var dialogues := {
	1: {
		"first": [
			"T'as déjà parlé à ma soeur ?",
			"Elle vit dans la chambre à côté. Elle est trop gentille."
		],
		"final": [
			"Bonne chance et merci pour tout !"
		]
	},
	2: {
		"first": [
			"Il faut voir le bon côté des choses.",
			"Nous sommes tous ensembles !",
			"Même si tu fais tout le boulot..."
		],
		"final": [
			"Nous allons y arriver ! "
		]
	},
	3: {
		"first": [
			"Tu peux donner mon bois à ma soeur.",
			"Je suis sur qu'elle en a plus besoin que moi.",
			"Nous nous aimons beaucoup, tu sais."
		],
		"final": [
			"Le froid, la faim, ta gentillesse... tout cela me nourrit d'une certaine façon."
		]
	},
	4: {
		"first": [
			"Les fées ne mangent pas beaucoup.",
			"Le froid nous est mortel par contre.",
		],
		"final": [
			"Je vais prier pour nous."
		]
	},
	5: {
		"first": [
			"Après cette tempête, j'emmenerai ma soeur au parc des fées",
		],
		"final": [
			"Je vais prier pour nous."
		]
	},
	
	
	"fallback": {
		"first": [
			"Je t’attendais.",
		],
		"final": [
			"Je te surveille, petit être chaud et vivant."
		]
	}
}


# --- READY ---
func _ready():
	if Global.sante_evil_fairy <= 0 :
		queue_free()
	is_talking = false
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
		return  # bloque si un dialogue est déjà en cours

	# 💔 Si la good fairy est morte, tout s’arrête ici
	if Global.sante_good_fairy <= 0:
		Textbox.queue_text("Elle est partie.", "evil_fairy")
		Textbox.queue_text("Ma sœur...", "evil_fairy")
		Textbox.queue_text("Laisse-moi seule.", "evil_fairy")
		return

	# --- Récupère le jour courant ou fallback ---
	var day = 1
	if "current_day" in Global:
		day = Global.current_day
	var day_dialogues = dialogues.get(day, dialogues["fallback"])

	# --- PREMIÈRE DISCUSSION DU JOUR ---
	if not has_talked_today:
		# 💬 D’abord : personnalité / contexte
		for line in day_dialogues["first"]:
			Textbox.queue_text(line, "evil_fairy")

		# 💀 Ensuite : elle évalue l’état du joueur
		if not has_healed_today:
			if Global.player_hp < 120:
				var heal_amount = 80
				Global.player_hp = min(Global.player_hp + heal_amount, 120)
				has_healed_today = true
				Textbox.queue_text("Ton corps tremble... Laisse-moi t'aider.", "evil_fairy")
			else:
				Textbox.queue_text("Tu vas bien. Ca veut dire que je n'ai rien à faire.", "evil_fairy")

		has_talked_today = true
		return  # fin du premier dialogue (pas encore de final ici)

	# --- DISCUSSIONS SUIVANTES ---
	var a_froid = Global.etat_evil_fairy[0]
	var a_faim = Global.etat_evil_fairy[1]
	var said_state_dialogue := false

	if a_froid and a_faim:
		Textbox.queue_text("J’ai froid et faim...", "evil_fairy")
		said_state_dialogue = true
	elif a_froid:
		Textbox.queue_text("J'ai froid....", "evil_fairy")
		said_state_dialogue = true
	elif a_faim:
		Textbox.queue_text("J’ai faim...", "evil_fairy")
		said_state_dialogue = true
	else:
		Textbox.queue_text("Je me sens étrangement paisible aujourd’hui. C'est parce que tu nous aides, petit esprit ?", "evil_fairy")
		said_state_dialogue = true

	# --- FINAL : seulement si un état a été exprimé ---
	if said_state_dialogue:
		for line in day_dialogues["final"]:
			Textbox.queue_text(line, "evil_fairy")
