extends Node

var difficulty: String = "Normal" # Easy, Normal, Hard
var bike: String = "Balanced"    # Sprinter, Balanced, Endurance
var track_theme: String = "City"  # City, Countryside, Mountain

func get_player_stats() -> Dictionary:
	match bike:
		"Sprinter":
			return {
				"max_speed": 520.0,
				"acceleration": 1100.0,
				"brake_force": 700.0,
				"jump_force": -520.0,
				"gravity": 1200.0,
				"max_stamina": 90.0,
				"stamina_drain": 30.0,
				"stamina_regen": 12.0,
			}
		"Endurance":
			return {
				"max_speed": 420.0,
				"acceleration": 800.0,
				"brake_force": 700.0,
				"jump_force": -520.0,
				"gravity": 1200.0,
				"max_stamina": 130.0,
				"stamina_drain": 15.0,
				"stamina_regen": 20.0,
			}
		_:
			return {
				"max_speed": 450.0,
				"acceleration": 900.0,
				"brake_force": 700.0,
				"jump_force": -520.0,
				"gravity": 1200.0,
				"max_stamina": 100.0,
				"stamina_drain": 25.0,
				"stamina_regen": 15.0,
			}

func get_ai_stats() -> Dictionary:
	match difficulty:
		"Easy":
			return {
				"target_speed": 340.0,
				"acceleration": 600.0,
				"look_ahead": 90.0,
				"jump_cooldown": 0.40,
				"reaction_time": 0.35,
				"jump_margin": 16.0,
			}
		"Hard":
			return {
				"target_speed": 420.0,
				"acceleration": 800.0,
				"look_ahead": 130.0,
				"jump_cooldown": 0.25,
				"reaction_time": 0.22,
				"jump_margin": 22.0,
			}
		_:
			return {
				"target_speed": 380.0,
				"acceleration": 700.0,
				"look_ahead": 110.0,
				"jump_cooldown": 0.35,
				"reaction_time": 0.28,
				"jump_margin": 20.0,
			}

func get_theme_params() -> Dictionary:
	match track_theme:
		"Countryside":
			return {
				"ground_color": Color(0.36, 0.26, 0.18),
				"obstacle_spacing": Vector2(230.0, 350.0),
				"pickup_spacing": Vector2(280.0, 460.0),
				"target_distance": 3000.0,
			}
		"Mountain":
			return {
				"ground_color": Color(0.30, 0.30, 0.35),
				"obstacle_spacing": Vector2(200.0, 320.0),
				"pickup_spacing": Vector2(320.0, 520.0),
				"target_distance": 3400.0,
			}
		_:
			return {
				"ground_color": Color(0.25, 0.25, 0.28),
				"obstacle_spacing": Vector2(250.0, 370.0),
				"pickup_spacing": Vector2(330.0, 500.0),
				"target_distance": 2600.0,
			}
