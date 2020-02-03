extends Node2D
# 一个用于在结束和开始显示控制按钮和信息的场景

func GameReady():
	$LabelMessage.visible = true
	$LabelScore.visible = false
	$StartButton.visible = true
	$LabelMessage.text = "Doodle jump"
	
func GameOver(score):
	$LabelMessage.visible = true
	$LabelScore.visible = false
	$StartButton.visible = true
	$LabelMessage.text = "Your score:\n%s" %int(score)
	
func GameStarted():
	$LabelMessage.visible = false
	$LabelScore.visible = true
	$StartButton.visible = false
	$LabelMessage.text = ""

func updateScore(score):
	$LabelScore.text = str(int(score))

func _on_StartButton_pressed():
	# 点击开始后调用doodle根下的开始游戏函数
	$"..".start_game()
