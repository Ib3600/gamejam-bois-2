extends StaticBody2D

@export var tree_health: int = 3
@export var wood_drop: int = 3

var particle_scene = preload("res://scenes/particles/tree_down.tscn")
var wood_scene = preload("res://scenes/wood_item.tscn")

var is_dying: bool = false  # <-- protection contre exécutions multiples


func _process(delta):
	if tree_health <= 0 and not is_dying:
		is_dying = true  # ✅ empêche de rappeler la destruction
		spawn_particles()
		await spawn_wood(wood_drop)
		queue_free()


func _on_area_2d_area_entered(area):
	if area.is_in_group("sword"):
		tree_health -= 1
		shake_tree()
		print(tree_health)


func spawn_particles():
	var particles = particle_scene.instantiate()
	get_parent().add_child(particles)
	particles.global_position = global_position
	particles.emitting = true


func spawn_wood(wood_drop):
	for i in range(wood_drop):
		var wood = wood_scene.instantiate()
		get_parent().add_child(wood)

		# position aléatoire autour de l’arbre
		var angle = randf_range(0, TAU)
		var radius = randf_range(20, 60)
		var offset = Vector2(cos(angle), sin(angle)) * radius
		wood.global_position = global_position + offset

		await get_tree().create_timer(0.1).timeout


func shake_tree():
	var tween = create_tween()
	var original_pos = position

	tween.tween_property(self, "position", original_pos + Vector2(5, 0), 0.05)
	tween.tween_property(self, "position", original_pos - Vector2(5, 0), 0.05)
	tween.tween_property(self, "position", original_pos, 0.05)
