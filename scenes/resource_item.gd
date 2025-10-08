extends PanelContainer

# Signal émis quand la valeur change
signal value_changed(old_value: int, new_value: int)

# Références aux noeuds de l'interface
@onready var texture: TextureRect = $HBoxContainer/MarginContainer2/TextureRect
@onready var nom_label: Label = $HBoxContainer/MarginContainer/VBoxContainer/NomLabel
@onready var description_label: Label = $HBoxContainer/MarginContainer/VBoxContainer/DescriptionLabel
@onready var value_label: Label = $HBoxContainer/MarginContainer/VBoxContainer/ControlsContainer/ValueLabel
@onready var minus_button: Button = $HBoxContainer/MarginContainer/VBoxContainer/ControlsContainer/MinusButton
@onready var plus_button: Button = $HBoxContainer/MarginContainer/VBoxContainer/ControlsContainer/PlusButton

# Données de l'item
var current_value: int = 0
var min_value: int = 0
var max_value: int = 20
var step: int = 1  # Incrément par clic

func _ready():
	# Connecte les boutons
	minus_button.pressed.connect(_on_minus_pressed)
	plus_button.pressed.connect(_on_plus_pressed)
	
	update_display()

func setup(data: Dictionary) -> void:
	"""Configure l'item avec les données de l'habitant"""
	# Charge l'icône
	if data.has("icon_path"):
		texture.texture = load(data.get("icon_path"))
	
	# Configure les textes
	nom_label.text = data.get("nom", "")
	description_label.text = data.get("description", "")
	
	# Configure les limites
	min_value = data.get("min_energy", 0)
	max_value = data.get("max_energy", 20)
	
	# Réinitialise la valeur
	current_value = min_value
	
	update_display()

func set_value(new_value: int) -> void:
	"""Définit la valeur sans émettre de signal (pour réinitialisation)"""
	current_value = clamp(new_value, min_value, max_value)
	update_display()

func _on_minus_pressed() -> void:
	"""Diminue la valeur"""
	if current_value > min_value:
		var old_value = current_value
		current_value -= step
		current_value = max(current_value, min_value)
		update_display()
		emit_signal("value_changed", old_value, current_value)

func _on_plus_pressed() -> void:
	"""Augmente la valeur"""
	if current_value < max_value:
		var old_value = current_value
		current_value += step
		current_value = min(current_value, max_value)
		update_display()
		emit_signal("value_changed", old_value, current_value)

func update_display() -> void:
	"""Met à jour l'affichage de la valeur et des boutons"""
	value_label.text = str(current_value) + " 🔥"
	
	# Désactive les boutons si on atteint les limites
	minus_button.disabled = (current_value <= min_value)
	plus_button.disabled = (current_value >= max_value)
	
	# Change la couleur selon le niveau d'énergie
	if current_value >= 15:
		value_label.modulate = Color(0.3, 1, 0.3)  # Vert si beaucoup
	elif current_value >= 10:
		value_label.modulate = Color(1, 1, 0.5)  # Jaune si moyen
	elif current_value > 0:
		value_label.modulate = Color(1, 0.6, 0.3)  # Orange si peu
	else:
		value_label.modulate = Color(1, 0.3, 0.3)  # Rouge si rien
