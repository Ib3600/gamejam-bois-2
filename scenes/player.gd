extends CharacterBody2D

var is_flipped:bool
var is_attacking:bool
var can_attack:bool
@export var moveSpeed:int

signal attacking


func _ready():
	$AnimatedSprite2D.play("idle")
	can_attack = true
	is_flipped = true
	attacking.connect(attack)
	
	pass
	
func _process(delta):
	input()
	
func input():
	if is_attacking : 
		attack()
	else :
		var direction = Input.get_vector("left", "right", "up", "down")
		velocity = direction.normalized() * moveSpeed
		if (direction != Vector2(0,0)):
			$AnimatedSprite2D.play("run")
		else : 
			$AnimatedSprite2D.play("idle")
		
		if (direction.x > 0):
			if is_flipped == true : 
				$AnimatedSprite2D.flip_h = false
				is_flipped = false
		elif (direction.x < 0):
			if is_flipped == false : 
				$AnimatedSprite2D.flip_h = true
				is_flipped = true
		move_and_slide()
	
func attack():
	can_attack = false
	is_attacking = true
	$swordAttack/attackCooldown.start()


func _on_attack_cooldown_timeout():
	can_attack = true
	is_attacking = false
	pass # Replace with function body.
