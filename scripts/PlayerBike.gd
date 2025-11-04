extends CharacterBody2D

# Bike properties
@export var max_speed := 450.0
@export var acceleration := 900.0
@export var brake_force := 700.0
@export var jump_force := -520.0
@export var gravity := 1200.0
@export var max_stamina := 100.0
@export var stamina_drain := 25.0
@export var stamina_regen := 15.0

# Current state
var speed := 0.0
var stamina := 100.0
var can_control := true
var boost_multiplier := 1.0
var boost_time_left := 0.0

func _ready():
    stamina = max_stamina
    speed = 0.0

func _physics_process(delta):
    # Apply gravity
    if not is_on_floor():
        velocity.y += gravity * delta
    else:
        if velocity.y > 0:
            velocity.y = 0

    # Handle input only when allowed
    if can_control:
        if Input.is_action_pressed("ui_right") and stamina > 0.0:
            speed = min(speed + acceleration * delta, max_speed)
            stamina = max(stamina - stamina_drain * delta, 0.0)
        elif Input.is_action_pressed("ui_left"):
            speed = max(speed - brake_force * delta, 0.0)
        else:
            # Natural deceleration
            speed = max(speed - 150.0 * delta, 0.0)

        # Jump
        if Input.is_action_just_pressed("ui_accept") and is_on_floor():
            velocity.y = jump_force

    # Apply horizontal movement with optional boost
    if boost_time_left > 0.0:
        boost_time_left -= delta
        if boost_time_left <= 0.0:
            boost_multiplier = 1.0
    velocity.x = speed * boost_multiplier
    move_and_slide()

    # Regenerate stamina when not accelerating
    if not Input.is_action_pressed("ui_right"):
        stamina = min(stamina + stamina_regen * delta, max_stamina)

    # Collision penalty with obstacles
    for i in range(get_slide_collision_count()):
        var col := get_slide_collision(i)
        var collider := col.get_collider()
        if collider and collider is Node and collider.is_in_group("obstacle"):
            speed = max(speed * 0.5, 0.0)

func reset(pos: Vector2):
    global_position = pos
    speed = 0.0
    stamina = max_stamina
    velocity = Vector2.ZERO
    can_control = true
    boost_multiplier = 1.0
    boost_time_left = 0.0

func apply_boost(mult: float=1.5, duration: float=1.5) -> void:
    boost_multiplier = max(boost_multiplier, mult)
    boost_time_left = max(boost_time_left, duration)
