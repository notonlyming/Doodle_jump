extends StaticBody2D

# 弹力系数，玩家将根据该值调整获得的向上初速度
const elesticK = 10
const type = "brittle"
const PLATFORM_WIDTH = 50
# 该信号用于指示平台页面改变自身的位置，使得平台下降到底部
signal a_platform_touched_by_player
# 永久停止碰撞，剂便玩家上升，用于玩家已经触碰到平台的情况
var permanentDisableCollision = false

# 发现玩家碰撞时播放动画
func _on_Area2D_body_entered(body):
	if body.name == "Player":
		$Sprite.play()
		yield(get_tree().create_timer(0.5), "timeout")
		$Sprite.stop()
	if body.name == "Player":
		emit_signal("a_platform_touched_by_player")

func changeCollision(state):
	if !permanentDisableCollision:
		$CollisionShape2D.disabled = (state == "disable" or state == "permanentDisable")
		$Area2D/CollisionShape2D.disabled = $CollisionShape2D.disabled
		if state == "permanentDisable":
			permanentDisableCollision = true