extends StaticBody2D

const type = "dead"
const PLATFORM_WIDTH = 50
var distance = 0

func changeCollision(state):
	$CollisionShape2D.disabled = state == "disable"

func on_Player_touched():
	changeCollision("disable")
	$"../PlayerDeadPlatform".playing = true
	yield(get_tree().create_timer(0.5), "timeout")
	get_node("../..").dead()
