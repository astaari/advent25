package main

import "core:fmt"
import os "core:os/os2"
import "core:strconv"
import "core:strings"

import "core:testing"
teststr: string : ``

AnswerType :: union {
	int,
	uint,
	u64,
	i64,
}
part_one :: proc(input: string) -> AnswerType {


	return int(0)
}

part_two :: proc(input: string) -> AnswerType {

	return int(0)
}

main :: proc() {

	fmt.println("Template file.\n Use 'odin run day##' to run a specific day.")

	path := "input/day##.txt"

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
	expected_1: AnswerType
	expected_2: AnswerType

	assert(part_one(teststr) == expected_1)
	assert(part_two(teststr) == expected_2)
}
