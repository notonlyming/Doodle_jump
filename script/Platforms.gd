extends Node2D

var screen_size
const PLATFORM_GAP = 100
# 平台移动速度
var speed = 10
# 这是一个列表，第一个是接触到的平台，第二个是应该到达的距离
# 用于_process移动所有平台的参考
var target = [null, null]
# 跳动后平台向下移动目的距离屏幕的边距
const PLATFORM_BOTTOM_MARGIN = 50
var Platform_type_list = [
	preload("res://Scene/Platform_normal.tscn"),
	preload("res://Scene/Platform_elestic.tscn"),
	preload("res://Scene/Platform_brittle.tscn")
]

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	screen_size = get_viewport_rect().size
	_generatePlatforms()

func gameOver():
	queue_free()

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
	# 在y轴上分配，分配顺序从屏幕下到上，因为后面生成的平台在屏幕上方
	# 主义y轴方向朝下
	var yArray = range(PLATFORM_GAP/2, screen_size.y * 2, PLATFORM_GAP)
	yArray.invert()
	for y in yArray:
		var tempPlatform = generateNew(y)


# 给定y值在x方向随机生成一个新随机类型的平台
func generateNew(y):
	# 随机pick一个平台
	var pickPlatformType = Platform_type_list[randi() % Platform_type_list.size()-1]
	var tempPlatform = pickPlatformType.instance()
	# 随机x坐标 从屏幕五分之一处 到 五分之三处
	tempPlatform.position.x = rand_range(screen_size.x/5, screen_size.x/5*4)
	tempPlatform.position.y = y
	
	add_child(tempPlatform)
	tempPlatform.add_to_group("platforms")
	
	# 注意此处的形参不可传递可变的值。
	# 比如传个index的值是不行的。
	# 因为你传进去以后平台数目会变的，但index传进去以后就不变了
	# 传引用是可以的，引用可以不变。
	# tempPlatform这个引用指向的实例的成员变量等等是可以变的
	tempPlatform.connect("a_platform_touched_by_player", self, "adjustPositonByplatform", [tempPlatform])
	return tempPlatform

func deletPlatform(platform, topPlatform):
	platform.queue_free()
	# 此时在最顶部的平台上面再重新生成一个新的平台
	generateNew(topPlatform.position.y - PLATFORM_GAP)

func getTopPlatform():
	var allPlatform = get_tree().get_nodes_in_group("platforms")
	return allPlatform[-1]

func _physics_process(delta):
	var allPlatform = get_tree().get_nodes_in_group("platforms")
	# 将所有平台向下移动，直到下移距离接近0
	var moveLittle = speed
	if target[0] != null and target[1] - target[0].position.y > 0:
		for index in range(allPlatform.size()):
			# 向下落一点点
			allPlatform[index].position.y += moveLittle
			# 根据移动距离加分
			get_node("..").score += moveLittle
			if allPlatform[index].position.y > screen_size.y:
				# 删除
				deletPlatform(allPlatform[index], allPlatform[-1])
				break
	else:
		pass

# 原本platform所在位置要移动到底部，要移动的距离就是底部的减去原本的
# 这个函数会直接把要移动的距离加给一个全局移动距离
# 移动的事情会交给_process来做
func adjustPositonByplatform(touchedPlatform):
	var touchedPlatformPosition = touchedPlatform.position
	var distance = screen_size.y - PLATFORM_BOTTOM_MARGIN - touchedPlatformPosition.y
	# 根据不同平台做出相应响应
	if touchedPlatform.type == "elestic":
		distance = distance * touchedPlatform.elesticK
	elif touchedPlatform.type == "brittle":
		# 这里设置不可见就可以了吧
		touchedPlatform.visible = false
		touchedPlatform.changeCollision("permanentDisable")
	# 重算最顶部位置，以最顶部的平台归位到正确位置为准
	# 这是因为最底部的平台是会被删除的，会出点问题
	var TopPlatform = getTopPlatform()
	target = [TopPlatform, TopPlatform.position.y + distance]