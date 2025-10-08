extends Node2D

#gestion des arbres : 
var arbres_détruits: Array = []


# --- Pnj --- 
var sante_marchand = 100
var sante_good_fairy = 100
var sante_evil_fairy = 100
var sante_pantin = 100

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

# --- Valeurs joueur ---
var player_heat: float = 100.0
var player_hp: int = 120
var niveau_manteau: int = 0
var niveu_hache: int = 0

# --- Chaleur globale ---
var heat_stock: float = 0.0
var money: int = 0
var heat_timer: Timer


func _ready():
	player_heat = 100.0
	wood_stock = 10
	food_stock = 0
	money = 0
	heat_stock = 20.0

	# Timer chaleur
	heat_timer = Timer.new()
	heat_timer.wait_time = 0.1
	heat_timer.one_shot = false
	heat_timer.autostart = true
	add_child(heat_timer)
	heat_timer.timeout.connect(_on_heat_timer_timeout)


func _on_heat_timer_timeout():
	heat_stock = max(heat_stock - 0.1, 0.0)


# --- Méthode utilitaire ---
# à appeler depuis le joueur (dans son _ready)
func register_player(p: CharacterBody2D):
	player = p
