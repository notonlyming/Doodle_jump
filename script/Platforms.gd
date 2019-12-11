extends Node2D

var screen_size
const PLATFORM_GAP = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	screen_size = get_viewport_rect().size
	_generatePlatforms()

func enableCollision():
	var platform_nodes = get_tree().get_nodes_in_group("platforms")
	if platform_nodes.size() > 2:
		for platform in platform_nodes:
			platform.changeCollision("enable")

func disableCollision():
	var platform_nodes = get_tree().get_nodes_in_group("platforms")
	if platform_nodes.size() > 2:
		for platform in platform_nodes:
			platform.changeCollision("disable")

# 该函数随机生成一些platform放在场景上
func _generatePlatforms():
	var Platform_type_list = [
		preload("res://Scene/Platform_normal.tscn"),
		preload("res://Scene/Platform_elestic.tscn")
	]

	# 在y轴上分配
	for y in range(0, screen_size.y, 100):
		# 随机pick一个平台
		var pickPlatformType = Platform_type_list[randi() % Platform_type_list.size()-1]
		var tempPlatform = pickPlatformType.instance()
		# 随机x坐标 从屏幕五分之一处 到 五分之三处
		tempPlatform.position.x = rand_range(screen_size.x/5, screen_size.x/5*4)
		tempPlatform.position.y = y
		add_child(tempPlatform)
		# 添加该页面所有平台到平台组，方便后续改变碰撞属性
		tempPlatform.add_to_group("platforms")