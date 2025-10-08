extends Node2D

# ============================================================
# 🌲 Gestion du monde
# ============================================================
var arbres_détruits: Array = []

var kitchen_level:int = 1
var axe_collected:bool = false
# ============================================================
# 🧍 PNJ — Santé & États
# ============================================================
var sante_marchand: int = 100
var sante_good_fairy: int = 100
var sante_evil_fairy: int = 100
var sante_pantin: int = 100

# [froid, faim] → true = souffre
var etat_marchand = [false, false]
var etat_good_fairy = [false, false]
var etat_evil_fairy = [false, false]
var etat_pantin = [false, false]

# --- Seuils individuels de besoins ---
var besoins_personnages = {
	"good_fairy": {"froid": 6, "faim": 1},   # très sensible au froid
	"evil_fairy": {"froid": 7, "faim": 1},   # idem
	"marchand": {"froid": 4, "faim": 3},     # géant : mange beaucoup, résiste au froid
	"pantin": {"froid": 5, "faim": 2}        # équilibré
}

# --- État du pantin ---
var pantin_owes_wood: bool = false
var pantin_last_talked_day: int = 0

# ============================================================
# 🕰️ Progression / Temps
# ============================================================
var current_day: int = 1

# ============================================================
# 💰 Ressources globales
# ============================================================
var wood_stock: int = 10
var food_stock: int = 0
var money: int = 100
var dialogue: bool = false

# ============================================================
# 🔥 Chaleur et joueur
# ============================================================
var player: CharacterBody2D = null

var player_heat: float = 100.0
var max_heat: float = 100.0
var player_hp: int = 120
var base_hp: int = 120

var heat_stock: float = 20.0
var heat_timer: Timer

# ============================================================
# 🧤 Équipement et bonus
# ============================================================
var niveau_moufles: int = 0
var niveau_manteau: int = 0
var niveau_bottes: int = 0
var niveau_couverture: int = 0
var niveau_hache: int = 0
var niveau_cheminee: int = 0

# --- Multiplicateurs de gameplay ---
var heat_resistance: float = 1.0        # Réduction de la perte de chaleur
var wood_chopping_speed: float = 1.0    # Vitesse de coupe du bois
var wood_per_chop: int = 1              # Quantité de bois par coup
var heat_generation: float = 1.0        # Efficacité du chauffage


# ============================================================
# 🧭 READY
# ============================================================
func _ready():
	player_heat = 100.0
	max_heat = 100.0
	wood_stock = 5
	food_stock = 2
	money = 3
	heat_stock = 20.0
	current_day = 1

	# Initialisation des niveaux d'équipement
	niveau_moufles = 0
	niveau_manteau = 0
	niveau_bottes = 0
	niveau_couverture = 0
	niveau_hache = 0
	niveau_cheminee = 0

	# Applique les bonus d'équipement
	apply_all_equipment_bonuses()

	# Timer de gestion de la chaleur globale
	heat_timer = Timer.new()
	heat_timer.wait_time = 0.1
	heat_timer.one_shot = false
	heat_timer.autostart = true
	add_child(heat_timer)
	heat_timer.timeout.connect(_on_heat_timer_timeout)


# ============================================================
# 🔥 Gestion de la chaleur
# ============================================================
func _on_heat_timer_timeout():
	heat_stock = max(heat_stock - 0.1, 0.0)


# ============================================================
# 👤 Joueur
# ============================================================
func register_player(p: CharacterBody2D):
	player = p


# ============================================================
# 🧤 Améliorations d’équipement
# ============================================================
func upgrade_moufles():
	niveau_moufles += 1
	apply_all_equipment_bonuses()
	print("🧤 Moufles améliorées — meilleure résistance au froid.")

func upgrade_manteau(level: int):
	niveau_manteau = level
	apply_all_equipment_bonuses()
	print("🧥 Manteau niveau ", niveau_manteau)

func upgrade_bottes():
	niveau_bottes += 1
	apply_all_equipment_bonuses()
	print("🥾 Bottes équipées — résistance au froid améliorée.")

func upgrade_couverture():
	niveau_couverture += 1
	apply_all_equipment_bonuses()
	print("🛏️ Couverture obtenue — chaleur maximale augmentée.")

func upgrade_hache(level: int):
	niveau_hache = level
	apply_all_equipment_bonuses()
	print("🪓 Hache améliorée au niveau ", niveau_hache)

func upgrade_cheminee():
	niveau_cheminee += 1
	apply_all_equipment_bonuses()
	print("🔥 Cheminée améliorée — meilleure génération de chaleur.")


# ============================================================
# ⚙️ Application des bonus d’équipement
# ============================================================
func apply_all_equipment_bonuses():
	# Réinitialise les valeurs de base
	heat_resistance = 1.0
	wood_chopping_speed = 1.0
	wood_per_chop = 1
	heat_generation = 1.0
	max_heat = 100.0

	# --- Bonus cumulés ---
	if niveau_moufles > 0:
		heat_resistance *= pow(0.95, niveau_moufles)

	if niveau_manteau > 0:
		heat_resistance *= (1.0 - (niveau_manteau * 0.10))
		max_heat += niveau_manteau * 10

	if niveau_bottes > 0:
		heat_resistance *= pow(0.92, niveau_bottes)

	if niveau_couverture > 0:
		max_heat += niveau_couverture * 20

	if niveau_hache > 0:
		wood_chopping_speed = 1.0 + (niveau_hache * 0.3)
		wood_per_chop = 1 + niveau_hache

	if niveau_cheminee > 0:
		heat_generation = 1.0 + (niveau_cheminee * 0.5)

	# Cap de réduction max : 70%
	heat_resistance = max(heat_resistance, 0.3)


func get_heat_loss_rate() -> float:
	return 0.1 * heat_resistance


# ============================================================
# 💰 Système de gains journaliers
# ============================================================
func calculer_gains_journaliers() -> int:
	var gains_total: int = 0
	var bonus_par_habitant: int = 1
	var penalite_faim: int = 0
	var penalite_froid: int = 0

	var habitants = [
		{"nom": "Marchand", "etat": etat_marchand, "sante": sante_marchand},
		{"nom": "Bonne Fée", "etat": etat_good_fairy, "sante": sante_good_fairy},
		{"nom": "Mauvaise Fée", "etat": etat_evil_fairy, "sante": sante_evil_fairy},
		{"nom": "Pantin", "etat": etat_pantin, "sante": sante_pantin}
	]

	for habitant in habitants:
		if habitant["sante"] <= 0:
			print(habitant["nom"] + " est mort — aucun gain.")
			continue

		var gain = bonus_par_habitant
		if habitant["etat"][0]: gain -= penalite_froid
		if habitant["etat"][1]: gain -= penalite_faim
		gain = max(gain, 0)
		gains_total += gain

		print(habitant["nom"], "→ Gain:", gain)

	return gains_total


func fin_de_journee():
	current_day += 1
	print("\n--- 🌒 Fin du Jour ", current_day, " ---")
	var gains = calculer_gains_journaliers()
	money += gains
	print("💰 Gains du jour :", gains, "| Total :", money)
	print("-----------------------------\n")
