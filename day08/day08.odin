package main

import "core:fmt"
import "core:log"
import "core:math"
import "core:math/linalg"
import os "core:os/os2"
import "core:slice"
import "core:sort"
import "core:strconv"
import "core:strings"

import "core:testing"
teststr: string : `162,817,812
57,618,57
906,360,560
592,479,940
352,342,300
466,668,158
542,29,236
431,825,988
739,650,466
52,470,668
216,146,977
819,987,18
117,168,530
805,96,715
346,949,466
970,615,88
941,993,340
862,61,35
984,92,344
425,690,689
`

CONNECTIONS_TEST: int : 10
CONNECTIONS: int : 1000


AnswerType :: union {
	int,
	uint,
	u64,
	i64,
}

Vec3 :: distinct ([3]f32)

Circuit :: struct {
	boxes: [dynamic]Box,
}

Box :: struct {
	pos: Vec3,
}

find_box :: proc(c: Circuit, target: Box) -> int {
	for b, i in c.boxes {
		if box_eq(b, target) {
			return i

		}
	}
	return -1
}

find_c :: proc(circuits: [dynamic]^Circuit, target: Box) -> int {
	for c, i in circuits {
		if find_box(c^, target) != -1 {
			return i
		}
	}
	return -1
}

box_eq :: proc(box1, box2: Box) -> bool {
	return box1.pos.xyz == box2.pos.xyz
}

distance :: proc(p1, p2: Vec3) -> f32 {
	return linalg.distance(p1, p2)
}
read_positions :: proc(input: string, allocator := context.allocator) -> []Box {

	lines, _ := strings.split_lines(input)
	defer delete(lines)

	result := make([]Box, len(lines) - 1, allocator)


	for line, i in lines[:len(lines) - 1] {
		coords := strings.split(line, ",", context.temp_allocator)
		x, _ := strconv.parse_f32(coords[0])
		y, _ := strconv.parse_f32(coords[1])
		z, _ := strconv.parse_f32(coords[2])

		result[i] = Box {
			pos = Vec3{x, y, z},
		}
	}


	return result
}


circ_eq :: proc(c1: Circuit, c2: Circuit) -> bool {
	if len(c1.boxes) != len(c2.boxes) {
		return false
	}
	for i in 0 ..< len(c1.boxes) {
		if c1.boxes[i] != c2.boxes[i] {
			return false
		}
	}
	return true
}

remove :: proc(circuits: ^[dynamic]^Circuit, circ: Circuit) -> bool {
	idx: int = -1
	for c, i in circuits {

		if circ_eq(c^, circ) {
			idx = i
			break
		}
	}
	if idx != -1 {
		unordered_remove(circuits, idx)
		return true
	}
	return false
}


BoxDist :: struct {
	distance: f32,
	idx1:     int,
	idx2:     int,
}


less_boxdist :: proc(bd1, bd2: BoxDist) -> bool {
	return bd1.distance < bd2.distance
}


part_one :: proc(input: string, connections: int) -> AnswerType {
	answer: u64
	boxes := read_positions(input, context.temp_allocator)

	length := len(boxes)
	circuits: [dynamic]^Circuit
	defer delete(circuits)

	for b in boxes {
		new_circ := new(Circuit, context.temp_allocator)
		new_circ.boxes = make([dynamic]Box, context.temp_allocator)

		append(&new_circ.boxes, b)
		append(&circuits, new_circ)
	}

	lenfl: f32 = f32(length)
	size: f32 = (lenfl * ((lenfl + 1) / 2)) - lenfl
	distances: []BoxDist = make([]BoxDist, int(size), context.temp_allocator)

	c := 0
	for i in 0 ..< length {
		for j in i + 1 ..< length {
			distances[c] = BoxDist {
				distance = distance(boxes[i].pos, boxes[j].pos),
				idx1     = i,
				idx2     = j,
			}
			c += 1
		}
	}

	c = 0
	slice.sort_by(distances[:], less_boxdist)
	last_dist: f32 = -1
	for c < connections {

		bd: BoxDist = distances[c]
		min_dist: f32 = bd.distance
		idx1: int = bd.idx1
		idx2: int = bd.idx2

		box1: Box = boxes[idx1]
		box2: Box = boxes[idx2]

		ci1 := find_c(circuits, box1)
		ci2 := find_c(circuits, box2)

		if ci1 != ci2 {
			append(&circuits[ci1].boxes, ..circuits[ci2].boxes[:])
			remove(&circuits, circuits[ci2]^)
		}

		c += 1
	}

	circ_less :: proc(o1, o2: ^Circuit) -> bool {
		return len(o1.boxes) > len(o2.boxes)
	}
	slice.sort_by(circuits[:], circ_less)

	answer = 1
	for circ in circuits[0:3] {
		answer *= u64(len(circ.boxes))
	}

	free_all(context.temp_allocator)
	return answer
}

part_two :: proc(input: string, connections: int) -> AnswerType {
	answer: u64
	boxes := read_positions(input, context.temp_allocator)

	length := len(boxes)
	circuits: [dynamic]^Circuit
	defer delete(circuits)

	for b in boxes {
		new_circ := new(Circuit, context.temp_allocator)
		new_circ.boxes = make([dynamic]Box, context.temp_allocator)

		append(&new_circ.boxes, b)
		append(&circuits, new_circ)
	}

	lenfl: f32 = f32(length)
	size: f32 = (lenfl * ((lenfl + 1) / 2)) - lenfl
	distances: []BoxDist = make([]BoxDist, int(size), context.temp_allocator)

	c := 0
	for i in 0 ..< length {
		for j in i + 1 ..< length {
			distances[c] = BoxDist {
				distance = distance(boxes[i].pos, boxes[j].pos),
				idx1     = i,
				idx2     = j,
			}
			c += 1
		}
	}

	c = 0
	slice.sort_by(distances[:], less_boxdist)
	xmul: f32 = 0
	for len(circuits) > 1 {

		bd: BoxDist = distances[c]
		min_dist: f32 = bd.distance
		idx1: int = bd.idx1
		idx2: int = bd.idx2

		box1: Box = boxes[idx1]
		box2: Box = boxes[idx2]

		ci1 := find_c(circuits, box1)
		ci2 := find_c(circuits, box2)

		if ci1 != ci2 {
			append(&circuits[ci1].boxes, ..circuits[ci2].boxes[:])
			remove(&circuits, circuits[ci2]^)
		}

		xmul = boxes[idx1].pos.x * boxes[idx2].pos.x

		c += 1
	}

	answer = u64(xmul)
	return answer
}

main :: proc() {

	path := "input/day08.txt"

	input_bytes, err := os.read_entire_file_from_path(path, context.allocator)
	defer delete(input_bytes)

	if err != nil {
		fmt.eprintln("Error reading file..")
		os.exit(-1)
	}

	input := string(input_bytes)
	fmt.println("Part one: ", part_one(input, CONNECTIONS))

	fmt.println("Part two: ", part_two(input, CONNECTIONS))

}


@(test)
run_test :: proc(t: ^testing.T) {
	expected_1: AnswerType = u64(40)
	expected_2: AnswerType = u64(0)


	assert(part_one(teststr, CONNECTIONS_TEST) == expected_1)

	assert(part_two(teststr, CONNECTIONS_TEST) == expected_2)
}
