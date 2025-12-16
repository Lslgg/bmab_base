## Position: Represents a square on the board
## Supports 9x10 standard Chinese chess board with 3D layer support
class_name Position
extends RefCounted

var x: int  # Column (0-8)
var y: int  # Row (0-9)
var z: int  # Layer (0-2 for 3D)

func _init(p_x: int = 0, p_y: int = 0, p_z: int = 0) -> void:
	x = p_x
	y = p_y
	z = p_z

func _to_string() -> String:
	return "(%d,%d,%d)" % [x, y, z]

func equals(other: Position) -> bool:
	return x == other.x and y == other.y and z == other.z

func hash() -> int:
	return hash(Vector3(x, y, z))

func is_valid() -> bool:
	return x >= 0 and x < 9 and y >= 0 and y < 10 and z >= 0 and z < 3

func duplicate() -> Position:
	return Position.new(x, y, z)
