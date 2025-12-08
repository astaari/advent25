package main

import "core:fmt"
import os "core:os/os2"
import "core:strconv"
import "core:strings"

import "core:testing"
teststr: string : `987654321111111
811111111111119
234234234234278
818181911112111`

AnswerType :: union {
	int,
	uint,
	u64,
	i64,
}
part_one :: proc(input: string) -> AnswerType {
	answer: uint

	lines, _ := strings.split_lines(input)
	defer delete(lines)


	for line in lines {
		highest: u8 = '0'
		high_idx: uint = 0
		for i := 0; i < len(line); i += 1 {

			if line[i] > highest {
				highest = line[i]
				high_idx = uint(i)
			}
		}

		second: u8 = '0'
		barr: []u8
		if high_idx < len(line) - 1 {

			for i := high_idx + 1; i < len(line); i += 1 {
				//look for next highest
				if line[i] > second {
					second = line[i]
				}
			}
			barr = {highest, second}
		} else {
			//need to look left for highest

			for i := int(high_idx) - 1; i >= 0; i -= 1 {

				if line[i] > second {
					second = line[i]
				}
			}

			barr = {second, highest}

		}

		rstr: string = string(barr)
		num, _ := strconv.parse_uint(rstr)
		answer += num
	}

	return answer
}

part_two :: proc(input: string) -> AnswerType {
	answer := u64(0)

	NUM_LEN :: 12

	lines, _ := strings.split_lines(input)
	defer delete(lines)

	for line in lines {
		if (len(line) == 0) {
			break
		}
		tolerance := len(line) - NUM_LEN
		digits: []u8 = make([]u8, 12)
		defer delete(digits)
		remaining := 12

		line_i := 0
		digits_i := 0
		for digits[11] == 0 {
			dist := 0
			start := line_i
			for i := start; i < (start + tolerance + 1); i += 1 {
				if i >= len(line) {
					break
				}
				if line[i] > digits[digits_i] {
					digits[digits_i] = line[i]
					dist = i - start
					line_i = i

				}
			}
			digits_i += 1
			line_i += 1

			tolerance -= dist
		}

		s := string(digits)
		num, _ := strconv.parse_u64(s)
		answer += num
	}
	return answer
}

main :: proc() {


	path := "input/day03.txt"

	input_bytes, err := os.read_entire_file_from_path(path, context.allocator)

	if err != nil {

		fmt.eprintln("Error reading file..")
		os.exit(-1)
	}
	input := string(input_bytes)
	defer delete(input_bytes)
	fmt.println("Part one: ", part_one(input))

	fmt.println("Part two: ", part_two(input))

}


@(test)
run_test :: proc(t: ^testing.T) {
	expected_1: AnswerType = uint(357)
	expected_2: AnswerType = u64(3121910778619)

	assert(part_one(teststr) == expected_1)
	assert(part_two(teststr) == expected_2)
}
