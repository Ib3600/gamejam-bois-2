extends Node2D

# --- PNJ --- 
var sante_marchand = 100
var sante_good_fairy = 100
var sante_evil_fairy = 100
var sante_pantin = 100
var etat_marchand = [false, false]  # case 1 le froid, case 2 la faim
var etat_good_fairy = [false, false]
var etat_evil_fairy = [false, false]
var etat_pantin = [false, false]
var seuil_fairy = {
	"faim": 0,
	"froid": 0
}
var current_day: int

# --- Ressources globales ---
var wood_stock: int = 0
var food_stock: int = 0
var money: int = 0
var dialogue: bool = false

# --- Liens ---
var player: CharacterBody2D = null  # Stocke la référence du joueur

# --- Niveaux / progression ---
var kitchen_level: int = 0
var niveau_manteau: int = 0  # Réduit la perte de chaleur
var niveau_hache: int = 0  # Améliore la récolte de bois

# --- Valeurs joueur ---
var player_heat: float = 100.0  # Chaleur actuelle
var max_player_heat: float = 100.0  # Chaleur maximale (peut être améliorée)
var player_hp: int = 120  # Points de vie

# --- Chaleur globale ---
var heat_stock: float = 0.0  # Stock de chaleur dans la cheminée
var heat_efficiency: float = 1.0  # Multiplicateur pour la génération de chaleur
var heat_timer: Timer

func _ready():
	# Initialisation des valeurs de départ
	player_heat = 100.0
	max_player_heat = 100.0
	wood_stock = 10
	food_stock = 0
	money = 100  # Argent de départ (pour tester)
	heat_stock = 20.0
	niveau_manteau = 0
	niveau_hache = 0
	
	# Timer de chaleur
	heat_timer = Timer.new()
	heat_timer.wait_time = 0.1
	heat_timer.one_shot = false
	heat_timer.autostart = true
	add_child(heat_timer)
	heat_timer.timeout.connect(_on_heat_timer_timeout)

func _on_heat_timer_timeout():
	# Diminue le stock de chaleur avec le temps
	heat_stock = max(heat_stock - 0.1, 0.0)

# --- Méthode utilitaire ---
# À appeler depuis le joueur (dans son _ready)
func register_player(p: CharacterBody2D):
	player = p

# --- Système de récompense journalière ---
func calculer_gains_journaliers() -> int:
	"""
	Calcule l'argent gagné à la fin de la journée selon l'état des habitants.
	Retourne le montant total gagné.
	"""
	var gains_total: int = 0
	var bonus_par_habitant: int = 20  # Argent de base par habitant en bonne santé
	var penalite_faim: int = 10  # Perte si l'habitant a faim
	var penalite_froid: int = 10  # Perte si l'habitant a froid
	
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
	
