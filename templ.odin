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
}
part_one :: proc(input: string) -> AnswerType {


	return int(0)
}

part_two :: proc(input: string) -> AnswerType {

	return int(0)
}

main :: proc() {

	fmt.println("Template file.\n Use 'odin run day##' to run a specific day.")
}


@(test)
run_test :: proc(t: ^testing.T) {
	expected_1: AnswerType
	expected_2: AnswerType

	assert(part_one(teststr) == expected_1)
	assert(part_two(teststr) == expected_2)
}
