extends RefCounted
class_name AnimationData

var name: String = ""
var index: int = -1

var frame_width: int = 0
var frame_height: int = 0

var durations: Array[int] = []

# Filled later
var offsets: Array[FrameOffset] = []
var frames = []
