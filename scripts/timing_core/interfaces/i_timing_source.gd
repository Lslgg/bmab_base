class_name ITimingSource
extends RefCounted

## Abstract interface for timing sources in the rhythm chess system
## Defines the contract for all timing-related components
## Part of the revolutionary delay standardization architecture

## Get the current time with latency compensation applied
func get_compensated_time() -> float:
	push_error("get_compensated_time() must be implemented by subclass")
	return 0.0

## Get the raw system time without compensation
func get_raw_time() -> float:
	push_error("get_raw_time() must be implemented by subclass")
	return 0.0

## Get the current latency compensation value in seconds
func get_latency_compensation() -> float:
	push_error("get_latency_compensation() must be implemented by subclass")
	return 0.0

## Set the latency compensation value
func set_latency_compensation(compensation_seconds: float):
	push_error("set_latency_compensation() must be implemented by subclass")

## Check if the timing source is synchronized and stable
func is_synchronized() -> bool:
	push_error("is_synchronized() must be implemented by subclass")
	return false

## Get timing source accuracy/confidence (0.0 to 1.0)
func get_accuracy() -> float:
	push_error("get_accuracy() must be implemented by subclass")
	return 0.0

## Get the name/type of this timing source
func get_source_name() -> String:
	push_error("get_source_name() must be implemented by subclass")
	return "unknown"

## Initialize the timing source
func initialize() -> bool:
	push_error("initialize() must be implemented by subclass")
	return false

## Cleanup and shutdown the timing source
func shutdown():
	push_error("shutdown() must be implemented by subclass")

## Calibrate the timing source with user input
func calibrate(calibration_data: Dictionary) -> bool:
	push_error("calibrate() must be implemented by subclass")
	return false
