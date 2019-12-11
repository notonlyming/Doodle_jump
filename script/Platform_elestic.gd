extends StaticBody2D

# 弹力系数，玩家将根据该值调整获得的向上初速度
const elesticK = 1.2
const type = "elestic"
const PLATFORM_WIDTH = 50

# 发现玩家碰撞时播放动画
func _on_Area2D_body_entered(body):
	if body.name == "Player":
		$Sprite.play()
		yield(get_tree().create_timer(0.5), "timeout")
		$Sprite.playing
		$Sprite.stop()

func changeCollision(state):
	$CollisionShape2D.disabled = (state == "disable")
	$Area2D/CollisionShape2D.disabled = $CollisionShape2D.disabled