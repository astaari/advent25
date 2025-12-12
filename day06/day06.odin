package main

import "core:fmt"
import "core:math"
import os "core:os/os2"
import "core:strconv"
import "core:strings"

import "core:testing"
teststr: string : `123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   + 
`

AnswerType :: union {
	int,
	uint,
	u64,
	i64,
}
part_one :: proc(input: string) -> AnswerType {

	answer: u64
	lines, _ := strings.split_lines(input, context.temp_allocator)
	lines = lines[:len(lines) - 1]

	operators: [dynamic]rune
	defer delete(operators)


	opsstr := strings.trim_space(lines[len(lines) - 1])

	for r in opsstr {
		if r != ' ' {
			append_elem(&operators, rune(r))
		}
	}
	cols := len(operators)
	rows := len(lines) - 1

	nums := make([]u64, cols * rows, context.temp_allocator)
	for r in 0 ..< rows {
		parsed := 0
		line := lines[r]
		curr := 0
		for parsed != cols {

			for line[curr] == ' ' {
				curr += 1
			}
			start := curr

			for curr < len(line) && line[curr] != ' ' {
				curr += 1
			}
			idx := r * cols + parsed
			nums[idx], _ = strconv.parse_u64(line[start:curr])

			parsed += 1

		}
	}

	for c in 0 ..< cols {
		value := nums[c]
		for r in 1 ..< rows {

			idx := r * cols + c
			switch operators[c] {
			case '+':
				value += nums[idx]
			case '*':
				value *= nums[idx]
			}

		}
		answer += value
	}


	return answer
}

part_two :: proc(input: string) -> AnswerType {
	answer: u64

	lines, _ := strings.split_lines(input, context.temp_allocator)
	lines = lines[:len(lines) - 1]

	operators: [dynamic]rune
	defer delete(operators)


	opsstr := strings.trim_space(lines[len(lines) - 1])

	for r in opsstr {
		if r != ' ' {
			append_elem(&operators, rune(r))
		}
	}

	//Start at end
	op_idx := len(operators) - 1
	curr := len(lines[0]) - 1
	for curr >= 0 {

		nums: [dynamic]u64
		has_num: bool = false
		//Increment until any row has a number
		for !has_num {

			for r in 0 ..< len(lines) - 1 {
				line := lines[r]
				if curr < 0 {
					break
				}
				if line[curr] != ' ' {
					has_num = true
				}
			}
			if !has_num {
				curr -= 1
			}
		}

		curr_op := operators[op_idx]
		line_val: u64 = 0 if curr_op == '+' else 1
		//Loop, check if any row has a number, create number string, parse, and operate
		for true {

			all_spaces := true

			for r in 0 ..< len(lines) - 1 {
				line := lines[r]
				if curr < 0 {
					break
				}
				if line[curr] != ' ' {
					all_spaces = false
				}
			}
			if all_spaces {
				break
			}
			num_str: string = ""
			for r in 0 ..< len(lines) - 1 {
				line := lines[r]
				if curr < 0 {
					break
				}
				if line[curr] != ' ' {
					num_str = strings.concatenate(
						{num_str[:], string(line[curr:curr + 1])},
						context.temp_allocator,
					)
				}
			}
			curr -= 1

			curr_num, _ := strconv.parse_u64(num_str)
			if curr_op == '*' {
				line_val *= curr_num
			} else if curr_op == '+' {
				line_val += curr_num
			}
		}

		answer += line_val
		op_idx -= 1
	}
	return answer
}

main :: proc() {


	path := "input/day06.txt"

	input_bytes, err := os.read_entire_file_from_path(path, context.allocator)
	defer delete(input_bytes)

	if err != nil {
		fmt.eprintln("Error reading file..")
		os.exit(-1)
	}

	input := string(input_bytes)
	fmt.println("Part one: ", part_one(input))

	fmt.println("Part two: ", part_two(input))

}


@(test)
run_test :: proc(t: ^testing.T) {
	expected_1: AnswerType = u64(4277556)
	expected_2: AnswerType = u64(3263827)

	assert(part_one(teststr) == expected_1)
	assert(part_two(teststr) == expected_2)
}
