extends Node2D

var gameState = "ready"
var score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$InfoDisplay.GameReady()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$InfoDisplay.updateScore(score)

func _on_deadLine_body_entered(body):
	if body.name == "Player" and gameState == "starting":
		$InfoDisplay.GameOver(score)
		$Platforms.gameOver()
		gameState = "over"

func _on_InfoDisplay_start_game():
	score = 0
	var platforms = preload("res://Scene/Platforms.tscn").instance()
	add_child(platforms)
	$InfoDisplay.GameStarted()
	gameState = "starting"
