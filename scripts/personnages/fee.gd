extends StaticBody2D

var is_talking: bool = false
var has_talked_today: bool = false
var has_given_today: bool = false  #  ne donne qu’une fois par jour

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# --- STRUCTURE DES DIALOGUES ---
var dialogues := {
	1: {
		"first": [
			"...",
			"T'as parlé à ma soeur ?",
			"Elle vit à côté.",
			"C'est une vraie pute."
		],
		"final": [
			"..."
		]
	},
	2: {
		"first": [
			"Je ne sais pas si je te l'ai dit mais...",
			"Je déteste ma soeur."
		],
		"final": [
			"..."
		]
	},
	3: {
		"first": [
			"Je rêve souvent de l'époque...",
			"Où ma soeur n'existait pas."
		],
		"final": [
			"..."
		]
	},
	4: {
		"first": [
			"Je rêve souvent de l'époque...",
			"Où ma soeur n'existait pas."
		],
		"final": [
			"..."
		]
	},
	5: {
		"first": [
			"Je rêve souvent de l'époque...",
			"Où ma soeur n'existait pas."
		],
		"final": [
			"..."
		]
	},
	"fallback": {
		"first": [
			"Je veille sur toi, petit esprit."
		],
		"final": [
			"..."
		]
	}
}

# --- READY ---
func _ready():
	if Global.sante_good_fairy <= 0:
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

	var day = 1
	if "current_day" in Global:
		day = Global.current_day
	var day_dialogues = dialogues.get(day, dialogues["fallback"])

	# 🌞 Première discussion du jour
	if not has_talked_today:
		for line in day_dialogues["first"]:
			Textbox.queue_text(line, "good_fairy")

		# Donne un objet une seule fois par jour
		if not has_given_today:
			_give_random_reward()
			has_given_today = true

		for line in day_dialogues["final"]:
			Textbox.queue_text(line, "good_fairy")

		has_talked_today = true
		return

	# 🌨 Discussions suivantes (états faim / froid)
	_show_state_dialogues()


# --- FONCTION : Donne une récompense aléatoire ---
func _give_random_reward():
	var reward_type = randi_range(0, 2)
	var sister_alive = Global.sante_evil_fairy > 0

	match reward_type:
		0:
			if sister_alive:
				Global.wood_stock += 1
				Textbox.queue_text("Tiens, j'ai volé ça à ma soeur.", "good_fairy")
			else:
				Global.wood_stock += 2
				Textbox.queue_text("Je t’en donne un peu plus... c’est tout ce qu’il me reste.", "good_fairy")
				Textbox.queue_text("Sans compter les provisions de ma soeur.", "good_fairy")
				Textbox.queue_text("Ils ne lui serviront plus.", "good_fairy")

		1:
			if sister_alive:
				Global.money += 1
				Textbox.queue_text("Tiens, j'ai volé ça à ma soeur.", "good_fairy")
			else:
				Global.money += 2
				Textbox.queue_text("Je t’en donne deux, ma sœur n’en aura plus besoin...", "good_fairy")

		2:
			if sister_alive:
				Global.food_stock += 2
				Textbox.queue_text("Tiens j'ai trouvé ça par terre...", "good_fairy")
				Textbox.queue_text("dans la chambre de ma soeur.", "good_fairy")
			else:
				Global.food_stock += 3
				Textbox.queue_text("Tiens j'ai fouillé dans les provisions de ma soeurs.", "good_fairy")
				Textbox.queue_text("Ils ne lui serviront plus.", "good_fairy")


# --- ÉTATS FAIM / FROID ---
func _show_state_dialogues():
	var a_froid = Global.etat_good_fairy[0]
	var a_faim = Global.etat_good_fairy[1]

	if a_froid and a_faim:
		Textbox.queue_text("J’ai froid et faim...", "good_fairy")
	elif a_froid:
		Textbox.queue_text("J'ai froid...", "good_fairy")
	elif a_faim:
		Textbox.queue_text("J’ai faim...", "good_fairy")
	else:
		Textbox.queue_text("Je vais bien.", "good_fairy")
		Textbox.queue_text("Dans la mesure ou ma soeur est encore vivante." , "good_fairy")
