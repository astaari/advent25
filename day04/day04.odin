package main

import "core:fmt"
import "core:mem"
import os "core:os/os2"
import "core:slice"
import "core:strconv"
import "core:strings"

import "core:testing"
teststr: string : `..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@.
`

AnswerType :: union {
	int,
	uint,
	u64,
	i64,
}

ROLL: u8 : '@'

part_one :: proc(raw_input: []u8) -> AnswerType {
	answer: uint
	cols := 0
	for raw_input[cols] != '\n' {
		cols += 1
	}


	rows := len(raw_input) / cols - 1

	fmt.println("dim: ", rows, cols)
	input: []u8 = make([]u8, rows * cols, context.temp_allocator)
	defer delete(input, context.temp_allocator)
	idx := 0
	for i := 0; i < len(raw_input); i += 1 {
		if raw_input[i] == '\n' {
			continue
		}
		input[idx] = raw_input[i]
		idx += 1
	}

	// cpy := slice.clone(input)
	// defer delete(cpy)
	for r in 0 ..< rows {
		for c in 0 ..< cols {
			curr := r * cols + c
			if input[curr] != ROLL {
				continue
			}
			cp1 := (c + 1) //% cols
			cm1 := (c - 1)
			rp1 := (r + 1) //% rows
			rm1 := (r - 1)
			rrp := rp1 * cols
			rrm := rm1 * cols
			rr := r * cols

			neighbor_count := 0
			tl := ' ' if rm1 < 0 || cm1 < 0 else input[rrm + (cm1)]
			tc := ' ' if rm1 < 0 else input[rrm + (c)]
			tr := ' ' if rm1 < 0 || cp1 >= cols else input[rrm + (cp1)]

			cl := ' ' if cm1 < 0 else input[rr + (cm1)]
			cr := ' ' if cp1 >= cols else input[rr + (cp1)]

			bl := ' ' if rp1 >= rows || cm1 < 0 else input[(rrp) + (cm1)]
			bc := ' ' if rp1 >= rows else input[(rrp) + (c)]
			br := ' ' if rp1 >= rows || cp1 >= rows else input[(rrp) + (cp1)]

			if tl == ROLL {neighbor_count += 1}
			if tc == ROLL {neighbor_count += 1}
			if tr == ROLL {neighbor_count += 1}
			if cl == ROLL {neighbor_count += 1}
			if cr == ROLL {neighbor_count += 1}
			if bl == ROLL {neighbor_count += 1}
			if bc == ROLL {neighbor_count += 1}
			if br == ROLL {neighbor_count += 1}
			if neighbor_count < 4 {
				answer += 1
			}
		}
	}
	// for r := 0; r < rows; r += 1 {
	// 	fmt.println(r, rows)
	// 	fmt.println(string(cpy[r * cols:(r * cols + cols)]))
	// }
	return answer

}

part_two :: proc(raw_input: []u8) -> AnswerType {
	answer: uint

	cols := 0
	for raw_input[cols] != '\n' {
		cols += 1
	}


	rows := len(raw_input) / cols - 1

	fmt.println("dim: ", rows, cols)
	input: []u8 = make([]u8, rows * cols, context.temp_allocator)
	defer delete(input, context.temp_allocator)
	idx := 0
	for i := 0; i < len(raw_input); i += 1 {
		if raw_input[i] == '\n' {
			continue
		}
		input[idx] = raw_input[i]
		idx += 1
	}

	cpy := slice.clone(input)
	defer delete(cpy)
	removed := -1
	for removed != 0 {
		input = cpy
		removed = 0
		for r in 0 ..< rows {
			for c in 0 ..< cols {
				curr := r * cols + c
				if input[curr] != ROLL {
					continue
				}
				cp1 := (c + 1) //% cols
				cm1 := (c - 1)
				rp1 := (r + 1) //% rows
				rm1 := (r - 1)
				rrp := rp1 * cols
				rrm := rm1 * cols
				rr := r * cols

				neighbor_count := 0
				tl := ' ' if rm1 < 0 || cm1 < 0 else input[rrm + (cm1)]
				tc := ' ' if rm1 < 0 else input[rrm + (c)]
				tr := ' ' if rm1 < 0 || cp1 >= cols else input[rrm + (cp1)]

				cl := ' ' if cm1 < 0 else input[rr + (cm1)]
				cr := ' ' if cp1 >= cols else input[rr + (cp1)]

				bl := ' ' if rp1 >= rows || cm1 < 0 else input[(rrp) + (cm1)]
				bc := ' ' if rp1 >= rows else input[(rrp) + (c)]
				br := ' ' if rp1 >= rows || cp1 >= rows else input[(rrp) + (cp1)]

				if tl == ROLL {neighbor_count += 1}
				if tc == ROLL {neighbor_count += 1}
				if tr == ROLL {neighbor_count += 1}
				if cl == ROLL {neighbor_count += 1}
				if cr == ROLL {neighbor_count += 1}
				if bl == ROLL {neighbor_count += 1}
				if bc == ROLL {neighbor_count += 1}
				if br == ROLL {neighbor_count += 1}
				if neighbor_count < 4 {
					cpy[curr] = '.'
					removed += 1
				}
			}
		}
		answer += uint(removed)
	}
	return answer
}

main :: proc() {


	path := "input/day04.txt"

	input_bytes, err := os.read_entire_file_from_path(path, context.allocator)

	if err != nil {

		fmt.eprintln("Error reading file..")
		os.exit(-1)
	}
	defer delete(input_bytes)
	fmt.println("Part one: ", part_one(input_bytes))

	fmt.println("Part two: ", part_two(input_bytes))

}


@(test)
run_test :: proc(t: ^testing.T) {
	expected_1: AnswerType = uint(13)
	expected_2: AnswerType = uint(43)
	tmp := transmute([]u8)teststr

	bytes: []u8 = slice.clone(tmp, context.temp_allocator)
	assert(part_one(bytes) == expected_1)
	assert(part_two(bytes) == expected_2)
}
