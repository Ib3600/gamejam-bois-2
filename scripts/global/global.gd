extends Node2D


# --- Pnj --- 
var sante_marchand = 100
var sante_good_fairy = 100
var sante_evil_fairy = 100
var sante_pantin = 100

var etat_marchand =[false,false] #case 1 le froid, #case 2 la faim

var etat_good_fairy =[false,false]
var etat_evil_fairy =[false,false]
var etat_pantin =[false,false]

var seuil_fairy = {
	"faim":0,
	"froid":0
}

var current_day:int
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
