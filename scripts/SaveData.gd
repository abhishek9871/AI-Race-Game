extends Node

var data := {
	"best_times": {
		"Easy": 999999.0,
		"Normal": 999999.0,
		"Hard": 999999.0,
	},
	"wins": 0,
	"losses": 0,
	"total_score": 0
}

const SAVE_PATH := "user://save_data.json"

func _ready():
	_load()

func update_result(difficulty: String, elapsed_time: float, win: bool, score: int) -> void:
	if win and elapsed_time < data["best_times"].get(difficulty, 999999.0):
		data["best_times"][difficulty] = elapsed_time
	if win:
		data["wins"] += 1
	else:
		data["losses"] += 1
	data["total_score"] += score
	_save()

func get_best_time(difficulty: String) -> float:
	return data["best_times"].get(difficulty, 999999.0)

func _save() -> void:
	var f = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		f.close()

func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f:
		var text = f.get_as_text()
		f.close()
		var parsed = JSON.parse_string(text)
		if typeof(parsed) == TYPE_DICTIONARY:
			data = parsed
