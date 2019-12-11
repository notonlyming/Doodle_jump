extends Node2D

var screen_size
const PLATFORM_GAP = 100
# 平台移动速度
var speed = 300
# 这是一个列表，维护所有平台的目标位置，同时，它也包含对应的平台的引用，
# 因此里面的每个元素还是一个数组，每个数组第一个是引用，第二个是目的地位置
var destinationList = []
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
	# 添加所有平台原始位置到目的地列表，以便日后修改
	destinationList.append([tempPlatform, tempPlatform.position])
	# 注意此处的形参不可传递不可变的值，比如传个index的值是不行的，因为它是会变的，但传进去以后就不变了
	# 传引用是可以的，引用可以不变，但tempPlatform这个引用指向的内容是变的
	tempPlatform.connect("a_platform_touched_by_player", self, "adjustPositonByplatform", [tempPlatform])
	return tempPlatform

func deletPlatform(index):
	destinationList[index][0].queue_free()
	destinationList.remove(index)
	# 此时在最顶部的平台上面再重新生成一个新的平台
	generateNew(destinationList[-1][1].y - PLATFORM_GAP)

func _process(delta):
	var disappearListIndex = []
	# 将所有平台移动到目的地
	for index in range(destinationList.size()):
		var distance = (destinationList[index][0].position - destinationList[index][1]).length()
		if distance < 10:
			break
		var derection = (destinationList[index][1] - destinationList[index][0].position).normalized()
		destinationList[index][0].position += derection * speed * delta
		if destinationList[index][0].position.y > screen_size.y:
			# 删除
			deletPlatform(index)
			break

# 原本platform所在位置要移动到底部，要移动的距离就是底部的减去原本的
# 这个函数会直接给所有平台要去的地方destinationList这个列表赋值
# 移动的事情会交给_process来做
func adjustPositonByplatform(touchedPlatform):
	var touchedPlatformPosition = touchedPlatform.position
	var distance = screen_size.y - PLATFORM_BOTTOM_MARGIN - touchedPlatformPosition.y
	if touchedPlatform.type == "elestic":
		distance = distance * touchedPlatform.elesticK
	elif touchedPlatform.type == "brittle":
		# 这里设置不可见就可以了吧
		touchedPlatform.visible = false
		touchedPlatform.changeCollision("permanentDisable")
	# 根据距离重算所有平台移动的目的地
	# 花费时间太多！！
	for index in range(destinationList.size()):
		destinationList[index][1].y = destinationList[index][0].position.y + distance