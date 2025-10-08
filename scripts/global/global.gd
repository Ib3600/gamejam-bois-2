extends Node2D

#gestion des arbres : 
var arbres_détruits: Array = []


# --- Pnj --- 
var sante_marchand = 100
var sante_good_fairy = 100
var sante_evil_fairy = 100
var sante_pantin = 100
<<<<<<< HEAD
=======
var etat_marchand = [false, false]  # case 0: le froid, case 1: la faim
var etat_good_fairy = [false, false]
var etat_evil_fairy = [false, false]
var etat_pantin = [false, false]
var seuil_fairy = {
	"faim": 0,
	"froid": 0
}
var current_day: int = 0
>>>>>>> thomas

var pantin_owes_wood: bool = false
var pantin_last_talked_day: int = 0


var axe_collected = false
var etat_marchand =[false,false] #case 1 le froid, #case 2 la faim

var etat_good_fairy =[false,false]
var etat_evil_fairy =[false,false]
var etat_pantin =[false,false]

# --- Seuils individuels de besoins (faim et froid) ---
var besoins_personnages = {
	"good_fairy": {"froid": 6, "faim": 1},   # très sensible au froid, peu de nourriture
	"evil_fairy": {"froid": 7, "faim": 1},   # même chose
	"marchand": {"froid": 4, "faim": 3},     # géant : mange beaucoup, résiste au froid
	"pantin": {"froid": 5, "faim": 2}        # équilibré
}


var current_day:int = 1
# --- Ressources globales ---
var wood_stock: int = 0
var food_stock: int = 0
var dialogue: bool = false

# --- Liens ---
var player: CharacterBody2D = null  # on stockera ici la référence du joueur

# --- Niveaux / progression ---
var kitchen_level: int = 0
<<<<<<< HEAD

# --- Valeurs joueur ---
var player_heat: float = 100.0
var player_hp: int = 120
var niveau_manteau: int = 0
var niveu_hache: int = 0

# --- Chaleur globale ---
var heat_stock: float = 0.0
var money: int = 0
=======

# --- Equipment levels ---
var niveau_moufles: int = 0      # Mittens level
var niveau_manteau: int = 0      # Coat level - Réduit la perte de chaleur
var niveau_bottes: int = 0       # Boots level
var niveau_couverture: int = 0   # Blanket level
var niveau_hache: int = 0        # Axe level - Améliore la récolte de bois
var niveau_cheminee: int = 0     # Chimney level

# --- Valeurs joueur ---
var player_heat: float = 100.0   # Chaleur actuelle
var max_heat: float = 100.0      # Chaleur maximale (peut être améliorée)
var player_hp: int = 120         # Points de vie
var base_hp: int = 120

# --- Player stats (affected by equipment) ---
var heat_resistance: float = 1.0        # Multiplier for heat loss (lower = better)
var wood_chopping_speed: float = 1.0    # Multiplier for wood gathering
var wood_per_chop: int = 1              # Amount of wood per chop
var heat_generation: float = 1.0        # Multiplier for heat generation from fireplace

# --- Chaleur globale ---
var heat_stock: float = 0.0      # Stock de chaleur dans la cheminée
>>>>>>> thomas
var heat_timer: Timer


func _ready():
	player_heat = 100.0
<<<<<<< HEAD
	wood_stock = 10
	food_stock = 0
	money = 0
	heat_stock = 20.0

	# Timer chaleur
=======
	max_heat = 100.0
	wood_stock = 10
	food_stock = 0
	money = 100  # Argent de départ
	heat_stock = 20.0
	current_day = 0
	
	# Initialize equipment levels
	niveau_moufles = 0
	niveau_manteau = 0
	niveau_bottes = 0
	niveau_couverture = 0
	niveau_hache = 0
	niveau_cheminee = 0
	
	# Apply equipment bonuses
	apply_all_equipment_bonuses()
	
	# Timer de chaleur
>>>>>>> thomas
	heat_timer = Timer.new()
	heat_timer.wait_time = 0.1
	heat_timer.one_shot = false
	heat_timer.autostart = true
	add_child(heat_timer)
	heat_timer.timeout.connect(_on_heat_timer_timeout)


func _on_heat_timer_timeout():
	heat_stock = max(heat_stock - 0.1, 0.0)

<<<<<<< HEAD
=======
# --- Equipment upgrade methods ---
func upgrade_moufles():
	niveau_moufles += 1
	apply_all_equipment_bonuses()
	print("Moufles equipped! Heat resistance improved.")

func upgrade_manteau(level: int):
	niveau_manteau = level
	apply_all_equipment_bonuses()
	print("Manteau upgraded to level ", niveau_manteau)

func upgrade_bottes():
	niveau_bottes += 1
	apply_all_equipment_bonuses()
	print("Bottes equipped! Cold resistance improved.")

func upgrade_couverture():
	niveau_couverture += 1
	apply_all_equipment_bonuses()
	print("Couverture obtained! Max heat increased.")

func upgrade_hache(level: int):
	niveau_hache = level
	apply_all_equipment_bonuses()
	print("Hache upgraded to level ", niveau_hache)

func upgrade_cheminee():
	niveau_cheminee += 1
	apply_all_equipment_bonuses()
	print("Cheminée upgraded! Heat generation improved.")

# Apply equipment bonuses (call this when loading save or starting game)
func apply_all_equipment_bonuses():
	# Reset to base values
	heat_resistance = 1.0
	wood_chopping_speed = 1.0
	wood_per_chop = 1
	heat_generation = 1.0
	max_heat = 100.0
	
	# Reapply all upgrades
	if niveau_moufles > 0:
		heat_resistance *= pow(0.95, niveau_moufles)  # 5% better per level
	
	if niveau_manteau > 0:
		heat_resistance *= (1.0 - (niveau_manteau * 0.10))  # 10% better per level
		max_heat += niveau_manteau * 10  # +10 max heat per level
	
	if niveau_bottes > 0:
		heat_resistance *= pow(0.92, niveau_bottes)  # 8% better per level
	
	if niveau_couverture > 0:
		max_heat += niveau_couverture * 20  # +20 max heat per level
	
	if niveau_hache > 0:
		wood_chopping_speed = 1.0 + (niveau_hache * 0.3)  # 30% faster per level
		wood_per_chop = 1 + niveau_hache  # +1 wood per level
	
	if niveau_cheminee > 0:
		heat_generation = 1.0 + (niveau_cheminee * 0.5)  # 50% more heat per level
	
	# Ensure heat resistance doesn't go below 0.3 (max 70% reduction)
	heat_resistance = max(heat_resistance, 0.3)

# Calculate actual heat loss rate with all modifiers
func get_heat_loss_rate() -> float:
	return 0.1 * heat_resistance
>>>>>>> thomas

# --- Méthode utilitaire ---
# à appeler depuis le joueur (dans son _ready)
func register_player(p: CharacterBody2D):
	player = p
<<<<<<< HEAD
=======

# --- Système de récompense journalière ---
func calculer_gains_journaliers() -> int:
	"""
	Calcule l'argent gagné à la fin de la journée selon l'état des habitants.
	Retourne le montant total gagné.
	"""
	var gains_total: int = 0
	var bonus_par_habitant: int = 2  # Argent de base par habitant en bonne santé
	var penalite_faim: int = 1  # Perte si l'habitant a faim
	var penalite_froid: int = 1  # Perte si l'habitant a froid
	
	# Liste des habitants à vérifier
	var habitants = [
		{"nom": "Marchand", "etat": etat_marchand, "sante": sante_marchand},
		{"nom": "Bonne Fée", "etat": etat_good_fairy, "sante": sante_good_fairy},
		{"nom": "Mauvaise Fée", "etat": etat_evil_fairy, "sante": sante_evil_fairy},
		{"nom": "Pantin", "etat": etat_pantin, "sante": sante_pantin}
	]
	
	# Calcule les gains pour chaque habitant
	for habitant in habitants:
		# Vérifie si l'habitant est encore en vie
		if habitant["sante"] <= 0:
			print(habitant["nom"] + " est mort - pas de gains.")
			continue
		
		var gain_habitant: int = bonus_par_habitant
		
		# Pénalité si l'habitant a froid (case 0)
		if habitant["etat"][0]:  # a froid
			gain_habitant -= penalite_froid
			print(habitant["nom"] + " a froid: -" + str(penalite_froid) + " argent")
		
		# Pénalité si l'habitant a faim (case 1)
		if habitant["etat"][1]:  # a faim
			gain_habitant -= penalite_faim
			print(habitant["nom"] + " a faim: -" + str(penalite_faim) + " argent")
		
		# Assure qu'on ne perd pas d'argent (minimum 0)
		gain_habitant = max(gain_habitant, 0)
		
		gains_total += gain_habitant
		
		# Affiche le détail
		if gain_habitant == bonus_par_habitant:
			print(habitant["nom"] + " est en bonne santé: +" + str(gain_habitant) + " argent")
		else:
			print(habitant["nom"] + " rapporte: +" + str(gain_habitant) + " argent")
	
	return gains_total

func fin_de_journee():
	"""
	Fonction à appeler à la fin de chaque journée.
	Calcule et ajoute les gains journaliers.
	"""
	current_day += 1
	
	print("\n--- Fin du Jour " + str(current_day) + " ---")
	
	# Calcule les gains
	var gains = calculer_gains_journaliers()
	money += gains
	
	print("Gains totaux de la journée: " + str(gains) + " argent")
	print("Argent total: " + str(money) + " argent")
	print("------------------------\n")
>>>>>>> thomas
