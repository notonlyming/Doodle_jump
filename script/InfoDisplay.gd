extends Node2D

signal start_game

func GameReady():
	$LabelMessage.visible = true
	$LabelScore.visible = false
	$StartButton.visible = true
	$StartButton/CollisionShape2D.disabled = false
	$LabelMessage.text = "Doodle jump"
	
func GameOver(score):
	$LabelMessage.visible = true
	$LabelScore.visible = false
	$StartButton.visible = true
	$StartButton/CollisionShape2D.disabled = false
	$LabelMessage.text = "Your score:\n%s" %int(score)
	
func GameStarted():
	$LabelMessage.visible = false
	$LabelScore.visible = true
	$StartButton.visible = false
	$StartButton/CollisionShape2D.disabled = true
	$LabelMessage.text = ""

func updateScore(score):
	$LabelScore.text = str(int(score))

func _on_StartButton_pressed():
	emit_signal("start_game")
