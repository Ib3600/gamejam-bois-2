extends PanelContainer

# --- Variables exportées ---
@export var title: String = "Habitant"  # 🔹 Titre affiché dans la boîte
@export var character_name: String = "nothing"  # 🔹 Nom de l’animation (ex: "good_fairy")

# --- Références ---
@onready var sprite: AnimatedSprite2D = $HBoxContainer/MarginContainer2/character
@onready var nom_label: Label = $HBoxContainer/MarginContainer/VBoxContainer/NomLabel

# --- Contrôles chaleur ---
@onready var heat_label: Label = $HBoxContainer/MarginContainer/VBoxContainer/FoodContainer/HeatLabel
@onready var heat_minus: Button = $HBoxContainer/MarginContainer/VBoxContainer/FoodContainer/HeatMinus
@onready var heat_plus: Button = $HBoxContainer/MarginContainer/VBoxContainer/FoodContainer/HeatPlus

# --- Contrôles nourriture ---
@onready var food_label: Label = $HBoxContainer/MarginContainer/VBoxContainer/HeatContainer/FoodLabel
@onready var food_minus: Button = $HBoxContainer/MarginContainer/VBoxContainer/HeatContainer/FoodMinus
@onready var food_plus: Button = $HBoxContainer/MarginContainer/VBoxContainer/HeatContainer/FoodPlus

# --- Variables de gestion ---
var heat_value: int = 0
var food_value: int = 0
var max_heat: int = 5
var max_food: int = 3
var step: int = 1


# ============================================================
# 🔹 INITIALISATION
# ============================================================

func _ready():
	# Affiche le titre directement depuis l’export
	nom_label.text = title

	# Joue l'animation du personnage si elle existe
	if sprite.sprite_frames.has_animation(character_name):
		sprite.play(character_name)
	else:
		push_warning("Aucune animation trouvée pour '" + character_name + "'")

	# Connexions des boutons
	heat_minus.pressed.connect(_on_heat_minus)
	heat_plus.pressed.connect(_on_heat_plus)
	food_minus.pressed.connect(_on_food_minus)
	food_plus.pressed.connect(_on_food_plus)

	update_display()


# ============================================================
# 🔥 CHALEUR
# ============================================================

func _on_heat_plus():
	if Global.wood_stock > 0 and heat_value < max_heat:
		Global.wood_stock -= step
		heat_value += step
	else:
		print("Pas assez de bois ou maximum atteint.")
	update_display()

func _on_heat_minus():
	if heat_value > 0:
		Global.wood_stock += step
		heat_value -= step
	update_display()


# ============================================================
# 🍖 NOURRITURE
# ============================================================

func _on_food_plus():
	if Global.food_stock > 0 and food_value < max_food:
		Global.food_stock -= step
		food_value += step
	else:
		print("Pas assez de nourriture ou maximum atteint.")
	update_display()

func _on_food_minus():
	if food_value > 0:
		Global.food_stock += step
		food_value -= step
	update_display()


# ============================================================
# 🎨 AFFICHAGE
# ============================================================

func update_display():
	# Texte avec icônes
	heat_label.text = str(heat_value) + " 🔥"
	food_label.text = str(food_value) + " 🍖"

	# Désactivation selon limites ou stock global
	heat_plus.disabled = (Global.wood_stock <= 0 or heat_value >= max_heat)
	heat_minus.disabled = (heat_value <= 0)
	food_plus.disabled = (Global.food_stock <= 0 or food_value >= max_food)
	food_minus.disabled = (food_value <= 0)

	# Couleur selon niveau
	heat_label.modulate = _get_color(heat_value)
	food_label.modulate = _get_color(food_value)


func _get_color(value: int) -> Color:
	if value >= 15:
		return Color(0.3, 1, 0.3)  # Vert
	elif value >= 10:
		return Color(1, 1, 0.5)    # Jaune
	elif value > 0:
		return Color(1, 0.6, 0.3)  # Orange
	else:
		return Color(1, 0.3, 0.3)  # Rouge
