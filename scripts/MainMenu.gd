extends Control

func _ready():
	# Connect button signals
	$VBoxContainer/StartButton.connect("pressed", Callable(self, "_on_start_pressed"))
	$VBoxContainer/OptionsButton.connect("pressed", Callable(self, "_on_options_pressed"))
	$VBoxContainer/QuitButton.connect("pressed", Callable(self, "_on_quit_pressed"))

func _on_start_pressed():
	# Load the main game scene
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_options_pressed():
	# TODO: Implement options menu
	print("Options menu not yet implemented")

func _on_quit_pressed():
	# Quit the game
	get_tree().quit()
