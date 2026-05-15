extends Node

var current_class                 : String     = "blank"
var current_lives                 : int        = 3
var current_run_score             : int        = 0
var scion_confidence_at_run_start : float      = 0.0
var going_dark                    : bool       = false

# Run result — written by arena before transitioning to run_end
var run_succeeded      : bool  = false
var waves_cleared      : int   = 0
var final_confidence   : float = 0.0
var unpredictable_bonus: bool  = false

# Roguelike memory — persists across runs
var scion_memory : Dictionary = {}


func add_score(amount: int) -> void:
	current_run_score += amount


func reset_run() -> void:
	current_run_score    = 0
	current_lives        = 3
	waves_cleared        = 0
	run_succeeded        = false
	unpredictable_bonus  = false
	final_confidence     = 0.0
	going_dark           = false
	# scion_memory and current_class intentionally preserved
