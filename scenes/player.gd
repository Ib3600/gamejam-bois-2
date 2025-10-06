extends CharacterBody2D

# --- Variables principales ---
var is_flipped: bool
var is_attacking: bool
var can_attack: bool
var x_sword_offset
var cell


#gestion du shader du froid
@export var cold_overlay: ColorRect
@export var snow_effect:Node2D
@export var cold_animator: AnimationPlayer
var was_cold = false

var is_cold: bool = false
var _last_cold: bool = false
var _cold_tween: Tween


@export var tilemap:TileMapLayer
var wood_scene = preload("res://scenes/wood_item_chimney.tscn")

@onready var swordCollision: CollisionShape2D
@onready var swordArea: Area2D
@export var moveSpeed: int


var near_chimney: bool
@export var fire:Node2D
var fire_position:Vector2
signal attacking

# --- Paramètres pour le bois ---
@export var wood_cooldown := 0.3  # secondes entre deux bois
var last_wood_time := 0.0         # timestamp du dernier bois donné

#gestion des enemies et des dégats : 

@export var knockback_force: float = 400.0
@export var knockback_duration: float = 0.2

var is_knocked_back: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0


# --- Ready ---
func _ready():
	snow_effect.visible = false
	if fire:
		fire_position = fire.global_position
	else:
		push_warning("firePosition not found in tree")
	swordCollision = $swordAttack/Area2D/swordCollision
	swordCollision.disabled = true
	swordArea = $swordAttack/Area2D
	x_sword_offset = swordArea.position.x
	$AnimatedSprite2D.play("idle")
	can_attack = true
	is_flipped = false
	attacking.connect(attack)


# --- Process principal ---
func _process(delta):
	
	if is_knocked_back:
		global_position += knockback_velocity * delta
		knockback_timer -= delta
		if knockback_timer <= 0:
			is_knocked_back = false
	else:
		
		input()
		
	get_cold()
	handle_chimney_interaction()

	# Transition vers froid
	if is_cold and not was_cold:
		print("i am cold")
		cold_animator.play("fade_in")
		snow_effect.visible = true

	# Transition vers chaud
	elif not is_cold and was_cold:
		
		print("i am not cold")
		cold_animator.play("fade_out")
		snow_effect.visible = false

	was_cold = is_cold







# --- Interaction cheminée : maintien pour donner du bois ---
func handle_chimney_interaction():
	if not near_chimney:
		return

	# Si le joueur garde la touche "hit" appuyée
	if Input.is_action_pressed("hit"):
		var now = Time.get_ticks_msec() / 1000.0
		if now - last_wood_time >= wood_cooldown:
			if Global.wood_stock > 0:
				Global.heat_stock +=5
				var wood = wood_scene.instantiate()
				get_parent().add_child(wood)
				wood.z_index = 20
				wood.global_position = global_position
				
				var tween := wood.create_tween()
				tween.tween_property(wood, "global_position", fire_position, 0.7)
				tween.tween_callback(Callable(wood, "queue_free"))
				
				Global.wood_stock -= 1
				last_wood_time = now



# --- Gestion des déplacements et de l’attaque ---
func input():
	if (Input.is_action_just_pressed("hit") or is_attacking) and !near_chimney:
		attack()
	else:
		var direction = Input.get_vector("left", "right", "up", "down")
		velocity = direction.normalized() * moveSpeed

		if direction != Vector2.ZERO:
			$AnimatedSprite2D.play("run")
		else:
			$AnimatedSprite2D.play("idle")

		if direction.x > 0:
			if is_flipped:
				$AnimatedSprite2D.flip_h = false
				is_flipped = false
				swordArea.position = Vector2(x_sword_offset, swordArea.position.y)
		elif direction.x < 0:
			if not is_flipped:
				swordArea.position = Vector2(-x_sword_offset, swordArea.position.y)
				$AnimatedSprite2D.flip_h = true
				is_flipped = true

		move_and_slide()


# --- Attaque ---
func attack():
	$AnimatedSprite2D.play("attack")
	swordCollision.disabled = false
	can_attack = false
	is_attacking = true

	if $swordAttack/attackCooldown.time_left <= 0:
		$swordAttack/attackCooldown.start()


func _on_attack_cooldown_timeout():
	swordCollision.disabled = true
	can_attack = true
	is_attacking = false


# --- Zones (détection cheminée) ---
func _on_area_2d_area_entered(area):
	if area.is_in_group("chimney"):
		near_chimney = true
	if area.is_in_group("damage"):
		apply_knockback(area.global_position)
		print("je prend des dégats")


func _on_area_2d_area_exited(area):
	if area.is_in_group("chimney"):
		near_chimney = false
		
func get_cold():
	cell = tilemap.local_to_map(position)
	var data :TileData = tilemap.get_cell_tile_data(cell)
	if data : 
		is_cold = data.get_custom_data("cold")
		
func apply_knockback(source_position: Vector2):
	# Calcul de la direction du knockback (du coup vers le joueur)
	var direction = (global_position - source_position).normalized()
	knockback_velocity = direction * knockback_force

	is_knocked_back = true
	knockback_timer = knockback_duration


	
