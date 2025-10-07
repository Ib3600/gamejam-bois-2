extends Area2D

var particle_scene = preload("res://scenes/particles/mob_dying.tscn")
var food_scene = preload("res://scenes/food_item.tscn")

@export var attack_cooldown: float = 3.0
@export var move_speed: float = 120.0
@export var acceleration: float = 4.0
@export var slowdown_distance: float = 60.0
@export var burry_chance: float = 0.5
@export var impact_frame_bite: int = 4
@export var health: int = 3
@export var food_drop: int = 3

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $attackCooldown
@onready var hurtbox_bite: Node = $hurtbox_bite
@onready var hitbox_bite: Node = $hitbox_bite

var target: Node2D = null
var velocity: Vector2 = Vector2.ZERO
var can_attack: bool = true
var has_seen_player: bool = false
var is_attacking: bool = false
var facing_right: bool = true
var is_dead: bool = false


func _ready():
	anim.connect("animation_finished", Callable(self, "_on_animation_finished"))
	anim.connect("frame_changed", Callable(self, "_on_frame_changed"))
	_disable_all_collisions()
	anim.play("default")


func _process(delta):
	if is_dead:
		return

	if health <= 0:
		die()
		return

	if is_attacking or target == null:
		return

	var to_player = target.global_position - global_position
	var distance = to_player.length()

	# --- Gestion du flip ---
	if to_player.x > 0 and not facing_right:
		_flip_direction(true)
	elif to_player.x < 0 and facing_right:
		_flip_direction(false)

	# --- Déplacement ---
	if distance > 40:
		var dir = to_player.normalized()
		var target_speed = move_speed
		if distance < slowdown_distance:
			target_speed *= clamp(distance / slowdown_distance, 0.2, 1.0)
		var current_speed = velocity.length()
		var new_speed = lerp(current_speed, target_speed, delta * acceleration)
		velocity = dir * new_speed
		global_position += velocity * delta

		if has_seen_player and anim.animation != "move":
			anim.play("move")
	else:
		velocity = Vector2.ZERO
		if can_attack:
			perform_attack()


# --- Mort ---
func die():
	if is_dead:
		return
	is_dead = true
	spawn_particles()
	await spawn_food(food_drop)
	queue_free()


# --- Flip direction ---
func _flip_direction(face_right: bool):
	facing_right = face_right
	anim.flip_h = not face_right


# --- Détection du joueur ---
func _on_body_entered(body):
	if body.is_in_group("player"):
		target = body
		if not has_seen_player:
			anim.play("see_player")


func _on_patrol_zone_body_exited(body):
	if body == target:
		target = null
		has_seen_player = false
		is_attacking = false
		anim.play("default")


# --- Attaque ---
func perform_attack():
	is_attacking = true
	can_attack = false

	if randf() < burry_chance:
		anim.play("burry_attack")
	else:
		anim.play("attack")

	attack_timer.start(attack_cooldown)


# --- Frame d’impact ---
func _on_frame_changed():
	if anim.animation == "attack":
		var active = (anim.frame == impact_frame_bite)
		_set_side_collisions("hitbox_bite", active)
		_set_side_collisions("hurtbox_bite", active)
	else:
		_disable_all_collisions()


# --- Gestion des collisions par côté ---
func _set_side_collisions(area_name: String, active: bool):
	var area = get_node(area_name)
	for child in area.get_children():
		if child is CollisionPolygon2D:
			if facing_right and child.name == "right":
				child.disabled = not active
			elif not facing_right and child.name == "left":
				child.disabled = not active
			else:
				child.disabled = true


func _disable_all_collisions():
	for area in [hitbox_bite, hurtbox_bite]:
		for child in area.get_children():
			if child is CollisionPolygon2D:
				child.disabled = true


# --- Fin d’animation ---
func _on_animation_finished():
	match anim.animation:
		"attack", "burry_attack":
			is_attacking = false
			can_attack = true
			_disable_all_collisions()
			if target:
				anim.play("move")
			else:
				anim.play("default")
		"see_player":
			has_seen_player = true


func _on_attack_cooldown_timeout():
	can_attack = true
	is_attacking = false


# --- Dégâts ---
func _on_hitbox_bite_area_entered(area):
	if area.is_in_group("sword"):
		flash_damage()
		health -= 1
		print("🐻 ouch, vie =", health)


func flash_damage():
	for i in range(3):
		anim.modulate = Color(1, 1, 1)
		await get_tree().create_timer(0.08).timeout
		anim.modulate = Color(1, 1, 1, 0.5)
		await get_tree().create_timer(0.08).timeout
	anim.modulate = Color(1, 1, 1, 1)


func spawn_particles():
	var particles = particle_scene.instantiate()
	get_parent().add_child(particles)
	particles.global_position = global_position
	particles.emitting = true


func spawn_food(food_drop):
	for i in range(food_drop):
		var food = food_scene.instantiate()
		get_parent().add_child(food)
		var angle = randf_range(0, TAU)
		var radius = randf_range(20, 60)
		var offset = Vector2(cos(angle), sin(angle)) * radius
		food.global_position = global_position + offset
		await get_tree().create_timer(0.1).timeout
