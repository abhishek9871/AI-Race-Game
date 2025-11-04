extends CharacterBody2D

# AI bike properties
@export var target_speed := 380.0
@export var acceleration := 700.0
@export var gravity := 1200.0
@export var jump_force := -520.0
@export var look_ahead := 110.0
@export var jump_cooldown := 0.35
@export var reaction_time := 0.28
@export var jump_margin := 20.0

var speed := 0.0
var can_control := false
var _last_jump_time := 0.0
var _obstacles_root: Node2D
var _prev_speed: float = 0.0

func _ready():
	_speed_reset()
	# Find obstacles container created by Game.gd
	if get_parent().has_node("Obstacles"):
		_obstacles_root = get_parent().get_node("Obstacles")

func _physics_process(delta):
	# Ensure obstacle root is resolved even if created after this node's _ready
	if _obstacles_root == null and get_parent() and get_parent().has_node("Obstacles"):
		_obstacles_root = get_parent().get_node("Obstacles")
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if velocity.y > 0:
			velocity.y = 0

	if can_control:
		# Move toward target speed
		speed = move_toward(speed, target_speed, acceleration * delta)
		# Jump decision
		if is_on_floor() and _should_jump():
			_try_jump()
	else:
		# Idle slowdown
		speed = move_toward(speed, 0.0, acceleration * delta)

	velocity.x = speed
	move_and_slide()

	# Safety: if we collided with an obstacle and are on the floor, jump immediately (respect cooldown)
	if can_control and is_on_floor():
		for i in range(get_slide_collision_count()):
			var col := get_slide_collision(i)
			var c := col.get_collider()
			if c and c is Node and c.is_in_group("obstacle"):
				_try_jump()
				break

	_prev_speed = speed

func _should_jump() -> bool:
	if _obstacles_root == null:
		return false
	var closest_dx: float = 99999.0
	for child in _obstacles_root.get_children():
		if child is Node2D:
			var n: Node2D = child
			var dx: float = n.global_position.x - global_position.x
			var dy: float = abs(n.global_position.y - global_position.y)
			if dx > 0.0 and dy < 90.0:
				if dx < closest_dx:
					closest_dx = dx
	if closest_dx == 99999.0:
		return false
	# Dynamic look-ahead based on speed and reaction time
	var dyn_look: float = max(look_ahead, speed * (reaction_time + 0.05))
	# Time-to-obstacle heuristic
	var t_to_obs: float = closest_dx / max(speed, 1.0)
	return (closest_dx <= dyn_look + jump_margin) or (t_to_obs <= reaction_time)

func _try_jump() -> void:
	var now_s: float = Time.get_ticks_msec() / 1000.0
	if (now_s - _last_jump_time) > jump_cooldown:
		velocity.y = jump_force
		_last_jump_time = now_s

func reset(pos: Vector2):
	global_position = pos
	_speed_reset()
	can_control = false

func _speed_reset():
	speed = 0.0
	velocity = Vector2.ZERO
