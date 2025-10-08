extends CharacterBody2D

# --- Variables principales ---
var is_flipped: bool
var is_attacking: bool
var can_attack: bool
var x_sword_offset
var cell
var is_taking_damage: bool = false  
@export var in_scene: bool = true
@export var base_cold_loss: float = 6
@export var invulnerability_time: float = 0.5  # Durée d’invulnérabilité après un coup
var is_invulnerable: bool = false              # Flag pour savoir si le joueur peut reprendre un coup


#gestion de la mort 

var particle_scene = preload("res://scenes/particles/mob_dying.tscn")


var is_dead: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# --- Gestion du froid ---
@export var cold_overlay: ColorRect
@export var snow_effect: Node2D
@export var cold_animator: AnimationPlayer
var was_cold = false
var is_cold: bool = false
var cold_timer := 0.0
var heat_regen_rate := 10  # points par seconde


@export var cold_damage_interval: float = 3.0   # toutes les 3 s à 0 de chaleur
@export var cold_damage_amount: int = 10        # -10 PV par tick
var cold_damage_timer: float = 0.0              # compte à rebours interne
var _was_above_zero_heat: bool = true           # pour détecter le passage à 0


# --- Références scène ---
@export var tilemap: TileMapLayer
var wood_scene = preload("res://scenes/wood_item_chimney.tscn")

@onready var swordCollision: CollisionShape2D
@onready var swordArea: Area2D
@export var moveSpeed: int

var near_chimney: bool
@export var fire: Node2D
var fire_position: Vector2
signal attacking

# --- Paramètres bois ---
@export var wood_cooldown := 0.3
var last_wood_time := 0.0

# --- Dégâts / Knockback ---
@export var knockback_force: float = 400.0
@export var knockback_duration: float = 0.2

var is_knocked_back: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

# --- READY ---
func _ready():
	Global.register_player(self)
	if fire:
		fire_position = fire.global_position
	else:
		push_warning("firePosition not found in tree")
	if snow_effect:
		snow_effect.visible = false
	swordCollision = $swordAttack/Area2D/swordCollision
	swordCollision.disabled = true
	swordArea = $swordAttack/Area2D
	x_sword_offset = swordArea.position.x
	$AnimatedSprite2D.play("idle")
	can_attack = true
	is_flipped = false
	attacking.connect(attack)

# --- PROCESS ---
func _process(delta):

	
	# --- Vérifie la mort ---
	if not is_dead and Global.player_hp <= 20:
		die()
		return  # on quitte tout de suite le process une fois mort

	# Si déjà mort, on ne fait plus rien
	if is_dead:
		return

	
	if Global.player_heat <= 0.0:
		# si on vient juste de tomber à 0, on lance un délai de 3 s avant le 1er tick
		if _was_above_zero_heat:
			cold_damage_timer = cold_damage_interval
			_was_above_zero_heat = false
		else:
			cold_damage_timer -= delta
			if cold_damage_timer <= 0.0:
				Global.player_hp -= cold_damage_amount
				# Optionnel : feedback visuel
				play_damage_animation()
				# relance le prochain tick dans 3 s
				cold_damage_timer = cold_damage_interval
	else:
		# on régénère ou on est au-dessus de 0 → reset du flag et du timer
		_was_above_zero_heat = true
		cold_damage_timer = 0.0
		
		
	if is_knocked_back:
		global_position += knockback_velocity * delta
		knockback_timer -= delta
		if knockback_timer <= 0:
			is_knocked_back = false
	elif not is_taking_damage:
		input()
		
	get_cold()
	handle_chimney_interaction()
	handle_heat(delta)  

	# Animation du froid
	if is_cold and not was_cold:
		cold_animator.play("fade_in")
		snow_effect.visible = true
	elif not is_cold and was_cold:
		cold_animator.play("fade_out")
		snow_effect.visible = false

	was_cold = is_cold

# --- Gestion de la chaleur ---
func handle_heat(delta: float) -> void:
	if not in_scene:
		return

	if is_cold:
		var perte_par_sec: float
		perte_par_sec = max(0.0, base_cold_loss - Global.niveau_manteau)
		Global.player_heat -= perte_par_sec * delta
	else:
		# Regenerate heat, but cap at max_player_heat (which can be upgraded)
		if Global.player_heat < Global.max_player_heat:
			Global.player_heat += heat_regen_rate * delta

	# Clamp to the current maximum
	Global.player_heat = clamp(Global.player_heat, 0.0, Global.max_player_heat)

# --- Interaction cheminée ---
func handle_chimney_interaction():
	if not near_chimney:
		return

	if Input.is_action_pressed("hit"):
		var now = Time.get_ticks_msec() / 1000.0
		if now - last_wood_time >= wood_cooldown:
			if Global.wood_stock > 0:
				Global.heat_stock += 5
				var wood = wood_scene.instantiate()
				get_parent().add_child(wood)
				wood.z_index = 20
				wood.global_position = global_position
				
				var tween := wood.create_tween()
				tween.tween_property(wood, "global_position", fire_position, 0.7)
				tween.tween_callback(Callable(wood, "queue_free"))
				
				Global.wood_stock -= 1
				last_wood_time = now

# --- Déplacements / Attaque ---
func input():
	# Bloque toute entrée pendant un dialogue
	if Global.dialogue or is_dead:
		velocity = Vector2.ZERO
		if not is_taking_damage:
			$AnimatedSprite2D.play("idle")
		return

	if (Input.is_action_just_pressed("hit") or is_attacking) and not near_chimney:
		attack()
	else:
		var direction = Input.get_vector("left", "right", "up", "down")
		velocity = direction.normalized() * moveSpeed

		if direction != Vector2.ZERO:
			if not is_taking_damage:
				$AnimatedSprite2D.play("run")
		else:
			if not is_taking_damage:
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
	if Global.dialogue or is_dead:
		return
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

# --- Zones ---
func _on_area_2d_area_entered(area):
	if area.is_in_group("chimney"):
		near_chimney = true
	elif area.is_in_group("damage") and not is_invulnerable:
		receive_damage(20, area.global_position)

func _on_area_2d_area_exited(area):
	if area.is_in_group("chimney"):
		near_chimney = false
		
# --- Froid ---
func get_cold():
	if not in_scene or not tilemap:
		return

	cell = tilemap.local_to_map(global_position)
	var data: TileData = tilemap.get_cell_tile_data(cell)

	if data and data.has_custom_data("cold"):
		is_cold = data.get_custom_data("cold")
	else:
		is_cold = false


# --- Knockback ---
func apply_knockback(source_position: Vector2):
	var direction = (global_position - source_position).normalized()
	knockback_velocity = direction * knockback_force
	is_knocked_back = true
	knockback_timer = knockback_duration

# --- Animation de dégâts ---
func play_damage_animation():
	if $AnimatedSprite2D.sprite_frames.has_animation("take_damage"):
		is_taking_damage = true
		$AnimatedSprite2D.play("take_damage")
		await $AnimatedSprite2D.animation_finished
		is_taking_damage = false
	else:
		push_warning("Animation 'take_damage' non trouvée sur AnimatedSprite2D")


func die():
	if is_dead:
		return
	is_dead = true

	# Coupe tout déplacement / attaque
	velocity = Vector2.ZERO
	is_attacking = false
	can_attack = false
	is_taking_damage = false
	is_knocked_back = false
	knockback_velocity = Vector2.ZERO

	# Désactive collisions d’attaque du joueur
	if is_instance_valid(swordCollision):
		swordCollision.disabled = true

	# (Option) désactive la collision du corps pour ne plus gêner la physique
	# set_deferred("collision_layer", 0)
	# set_deferred("collision_mask", 0)

	# Masque le sprite
	if is_instance_valid(anim):
		anim.visible = false

	# Joue les particules de mort (même scène que l’ennemi)
	spawn_death_particles()
	Textbox.fade_to_black(2.5)
	Textbox.queue_text("Vous êtes mort.")
	Textbox.queue_text("Les habitants du chalet vous suivront bientot.")
	Textbox.queue_text("Vous n'avez pas survécu à la tempête.")
	Textbox.change_scene("res://scenes/main_menu.tscn")
	Textbox.fade_from_black(1)
	


func spawn_death_particles():
	var particles = particle_scene.instantiate()
	get_parent().add_child(particles)
	particles.global_position = global_position
	particles.emitting = true

# --- Gestion centralisée des dégâts ---
# --- Gestion centralisée des dégâts ---
func receive_damage(amount: int, source_position: Vector2):
	# Ignore si déjà mort ou invulnérable
	if is_dead or is_invulnerable:
		return

	Global.player_hp -= amount

	is_invulnerable = true
	apply_knockback(source_position)
	play_damage_animation()

	# Effet de clignotement pendant l'invulnérabilité
	await flash_invulnerability(invulnerability_time)

	is_invulnerable = false


# --- Clignotement pendant l'invulnérabilité ---
func flash_invulnerability(duration: float):
	var flash_interval := 0.08
	var elapsed := 0.0

	while elapsed < duration:
		anim.modulate.a = 0.3
		await get_tree().create_timer(flash_interval).timeout
		anim.modulate.a = 1.0
		await get_tree().create_timer(flash_interval).timeout
		elapsed += flash_interval * 2

	anim.modulate.a = 1.0  # Réinitialise à la fin
