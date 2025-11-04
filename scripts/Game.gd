extends Node2D

# References
@onready var player: CharacterBody2D = $PlayerBike
@onready var ui: Control = $UI/HUD
@onready var ai: CharacterBody2D = $AIBike

# Runtime nodes (created on the fly)
var obstacles_root: Node2D
var pickups_root: Node2D
var finish_line: Area2D

# Game state
var distance: float = 0.0
var score: int = 0
var target_distance: float = 1800.0
var game_over: bool = false
var win: bool = false
var race_started: bool = false
var elapsed_time: float = 0.0
var obstacle_spacing: Vector2 = Vector2(260.0, 380.0)
var pickup_spacing: Vector2 = Vector2(340.0, 520.0)
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	_ensure_runtime_roots()
	_reset_game()

func _physics_process(delta):
	if game_over or not race_started:
		return
	elapsed_time += delta
	distance = max(distance, player.global_position.x)
	_check_finish()

func _process(_delta):
	_update_ui()
	if game_over and Input.is_action_just_pressed("ui_accept"):
		_reset_game()
	# ESC to return to menu
	if Input.is_action_just_pressed("ui_cancel") and not game_over:
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _ensure_runtime_roots():
	if not obstacles_root:
		obstacles_root = Node2D.new()
		obstacles_root.name = "Obstacles"
		add_child(obstacles_root)
	if not pickups_root:
		pickups_root = Node2D.new()
		pickups_root.name = "Pickups"
		add_child(pickups_root)

func _reset_game():
	# Clear old nodes
	for c in obstacles_root.get_children():
		c.queue_free()
	for c in pickups_root.get_children():
		c.queue_free()

	# Reset state
	game_over = false
	win = false
	distance = 0.0
	score = 0
	elapsed_time = 0.0
	race_started = false
	# Apply config (bike, difficulty, theme)
	var theme := GameConfig.get_theme_params()
	obstacle_spacing = theme["obstacle_spacing"]
	pickup_spacing = theme["pickup_spacing"]
	target_distance = float(theme["target_distance"])
	var ground_rect := get_node_or_null("Ground/ColorRect") as ColorRect
	if ground_rect:
		ground_rect.color = theme["ground_color"]

	# Ensure ground width covers the whole race
	_resize_ground()

	var pstats := GameConfig.get_player_stats()
	player.max_speed = pstats["max_speed"]
	player.acceleration = pstats["acceleration"]
	player.brake_force = pstats["brake_force"]
	player.jump_force = pstats["jump_force"]
	player.gravity = pstats["gravity"]
	player.max_stamina = pstats["max_stamina"]
	player.stamina_drain = pstats["stamina_drain"]
	player.stamina_regen = pstats["stamina_regen"]

	var astats := GameConfig.get_ai_stats()
	ai.target_speed = astats["target_speed"]
	ai.acceleration = astats["acceleration"]
	ai.look_ahead = astats["look_ahead"]
	ai.jump_cooldown = astats["jump_cooldown"]
	if astats.has("reaction_time"):
		ai.reaction_time = astats["reaction_time"]
	if astats.has("jump_margin"):
		ai.jump_margin = astats["jump_margin"]

	# Reset racers
	player.reset(Vector2(200, 450))
	ai.reset(Vector2(150, 450))
	player.can_control = false
	ai.can_control = false

	# Build a simple level with obstacles and pickups
	_spawn_level()
	_create_finish_line(target_distance)
	_show_message("", true)
	call_deferred("_start_countdown")

func _start_countdown() -> void:
	await _count_step("3")
	await _count_step("2")
	await _count_step("1")
	_show_message("GO!", false)
	await get_tree().create_timer(0.5).timeout
	_show_message("", true)
	player.can_control = true
	ai.can_control = true
	race_started = true

func _count_step(t: String) -> void:
	_show_message(t, false)
	await get_tree().create_timer(0.6).timeout

func _spawn_level():
    # Pattern-based generation with simple difficulty ramp
    var x := 420.0
    while x < target_distance - 200.0:
        var progress := clamp(x / target_distance, 0.0, 1.0)
        var choice := rng.randf()
        if choice < 0.35:
            x = _pattern_hurdles(x, 3 + int(progress * 2.0))
        elif choice < 0.65:
            x = _pattern_cluster(x)
        else:
            x = _pattern_stairs(x)

        # Mid/late-race: increase chance of a quick boost zone
        if progress > 0.5 and rng.randf() < 0.25:
            _spawn_boost_zone(x + 40.0, 160.0)

        # Sprinkle stamina/boost pickups between patterns
        if rng.randf() < (0.55 if progress > 0.6 else 0.35):
            _spawn_pickup(Vector2(x + rng.randf_range(60.0, 140.0), 430))

        # Advance by themed spacing with slight tightening later
        var step_min := max(180.0, obstacle_spacing.x - 20.0 * progress)
        var step_max := obstacle_spacing.y
        x += rng.randf_range(step_min, step_max)

    # Extra pickups near the end as a finale
    var px := max(520.0, x - 400.0)
    while px < target_distance - 100.0:
        _spawn_pickup(Vector2(px, 430))
        px += rng.randf_range(140.0, 220.0)

func _resize_ground() -> void:
    var col := get_node_or_null("Ground/CollisionShape2D") as CollisionShape2D
    if col and col.shape and col.shape is RectangleShape2D:
        var width := max(target_distance + 800.0, 4000.0)
        var shape := col.shape as RectangleShape2D
        shape.size = Vector2(width, shape.size.y)
        var rect := get_node_or_null("Ground/ColorRect") as ColorRect
        if rect:
            rect.offset_left = -width * 0.5
            rect.offset_right = width * 0.5

func _pattern_cluster(x_start: float) -> float:
    # 2-3 blocks close together
    var count := 2 + int(rng.randf() < 0.5)
    var x := x_start
    for i in range(count):
        var w := rng.randf_range(40.0, 60.0)
        var h := rng.randf_range(36.0, 56.0)
        _spawn_obstacle(Vector2(x, 480), Vector2(w, h))
        x += rng.randf_range(40.0, 75.0)
    return x

func _pattern_stairs(x_start: float) -> float:
    # Three rising hurdles
    var x := x_start
    var h := 32.0
    for i in range(3):
        _spawn_obstacle(Vector2(x, 480), Vector2(50, h))
        x += rng.randf_range(70.0, 100.0)
        h += rng.randf_range(8.0, 16.0)
    return x

func _pattern_hurdles(x_start: float, n: int) -> float:
    # Sequence of small hurdles
    var x := x_start
    for i in range(n):
        _spawn_obstacle(Vector2(x, 485), Vector2(42, 28))
        x += rng.randf_range(65.0, 95.0)
    return x

func _spawn_boost_zone(x_center: float, width: float) -> void:
    var area := Area2D.new()
    area.global_position = Vector2(x_center, 500)
    var shape := RectangleShape2D.new()
    shape.size = Vector2(width, 20)
    var col := CollisionShape2D.new()
    col.shape = shape
    area.add_child(col)
    area.connect("body_entered", Callable(self, "_on_pickup_body_entered").bind(area))
    area.set_meta("type", "boost_zone")
    var rect := ColorRect.new()
    rect.color = Color(0.2, 0.9, 0.8, 0.6)
    rect.offset_left = -width * 0.5
    rect.offset_right = width * 0.5
    rect.offset_top = -10
    rect.offset_bottom = 10
    area.add_child(rect)
    pickups_root.add_child(area)

func _spawn_obstacle(pos: Vector2, size: Vector2):
	var body := StaticBody2D.new()
	body.global_position = pos
	body.add_to_group("obstacle")
	var shape := RectangleShape2D.new()
	shape.size = size
	var col := CollisionShape2D.new()
	col.shape = shape
	body.add_child(col)
	# Visual
	var rect := ColorRect.new()
	rect.color = Color(0.9, 0.2, 0.2)
	rect.offset_left = -size.x / 2
	rect.offset_right = size.x / 2
	rect.offset_top = -size.y / 2
	rect.offset_bottom = size.y / 2
	body.add_child(rect)
	obstacles_root.add_child(body)

func _spawn_pickup(pos: Vector2):
	var area := Area2D.new()
	area.global_position = pos
	var circle := CircleShape2D.new()
	circle.radius = 14.0
	var col := CollisionShape2D.new()
	col.shape = circle
	area.add_child(col)
	area.connect("body_entered", Callable(self, "_on_pickup_body_entered").bind(area))
	# Visual and type
	var rect := ColorRect.new()
	var is_boost := rng.randf() < 0.45
	area.set_meta("type", "boost" if is_boost else "stamina")
	rect.color = Color(0.2, 1.0, 1.0) if is_boost else Color(1.0, 0.85, 0.2)
	rect.offset_left = -14
	rect.offset_right = 14
	rect.offset_top = -14
	rect.offset_bottom = 14
	area.add_child(rect)
	pickups_root.add_child(area)

func _create_finish_line(x: float):
	if finish_line and finish_line.is_inside_tree():
		finish_line.queue_free()
	finish_line = Area2D.new()
	finish_line.global_position = Vector2(x, 450)
	var shape := RectangleShape2D.new()
	shape.size = Vector2(20, 300)
	var col := CollisionShape2D.new()
	col.shape = shape
	finish_line.add_child(col)
	finish_line.connect("body_entered", Callable(self, "_on_finish_body_entered"))
	# Visual post
	var post := ColorRect.new()
	post.color = Color(0.3, 1.0, 0.3)
	post.offset_left = -10
	post.offset_right = 10
	post.offset_top = -150
	post.offset_bottom = 150
	finish_line.add_child(post)
	add_child(finish_line)

func _on_pickup_body_entered(body: Node, area: Area2D):
    if body == player:
        var ptype := String(area.get_meta("type")) if area.has_meta("type") else "stamina"
        if ptype == "boost" or ptype == "boost_zone":
            score += 150
            if player.has_method("apply_boost"):
                player.apply_boost(1.6, 1.2)
        else:
            score += 100
            player.stamina = min(player.stamina + 30.0, player.max_stamina)
        if area and area.is_inside_tree():
            area.queue_free()

func _on_finish_body_entered(body: Node):
	if game_over:
		return
	if body == player:
		win = true
		game_over = true
		race_started = false
		player.can_control = false
		ai.can_control = false
		_show_message("You Win! Press Enter to Restart")
		SaveData.update_result(GameConfig.difficulty, elapsed_time, true, score)
	elif body == ai:
		win = false
		game_over = true
		race_started = false
		player.can_control = false
		ai.can_control = false
		_show_message("AI Wins! Press Enter to Restart")
		SaveData.update_result(GameConfig.difficulty, elapsed_time, false, score)

func _check_finish():
	if player.global_position.y > 700:
		# Fell off screen
		game_over = true
		win = false
		race_started = false
		player.can_control = false
		ai.can_control = false
		_show_message("You Fell! Press Enter to Restart")

func _show_message(text: String, hide: bool=false):
	if not ui:
		return
	var label := ui.get_node_or_null("MessageLabel") as Label
	if label:
		label.text = text
		label.visible = not hide

func _update_ui():
	if not ui:
		return
	var speed_label := ui.get_node_or_null("SpeedLabel") as Label
	if speed_label:
		speed_label.text = "Speed: %s km/h" % int(player.speed)
	var stamina_bar := ui.get_node_or_null("StaminaBar") as ProgressBar
	if stamina_bar:
		stamina_bar.value = player.stamina
	var dist_label := ui.get_node_or_null("DistanceLabel") as Label
	if dist_label:
		dist_label.text = "Distance: %s / %s" % [int(distance), int(target_distance)]
	var score_label := ui.get_node_or_null("ScoreLabel") as Label
	if score_label:
		score_label.text = "Score: %s" % score
	var time_label := ui.get_node_or_null("TimeLabel") as Label
	if time_label:
		time_label.text = "Time: %.1f" % elapsed_time
	var leader_label := ui.get_node_or_null("LeaderLabel") as Label
	if leader_label:
		leader_label.text = "Leader: %s" % ("Player" if player.global_position.x >= ai.global_position.x else "AI")
