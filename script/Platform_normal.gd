extends StaticBody2D

const type = "normal"
const PLATFORM_WIDTH = 50
# 该信号用于指示平台页面改变自身的位置，使得平台下降到底部
signal a_platform_touched_by_player

func changeCollision(state):
	$CollisionShape2D.disabled = state == "disable"
	$Area2D/CollisionShape2D.disabled = $CollisionShape2D.disabled

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		emit_signal("a_platform_touched_by_player")