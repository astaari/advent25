package main

import "base:intrinsics"
import "core:fmt"
import os "core:os/os2"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:testing"
teststr: string : `.......S.......
...............
.......^.......
...............
......^.^......
...............
.....^.^.^.....
...............
....^.^...^....
...............
...^.^...^.^...
...............
..^...^.....^..
...............
.^.^.^.^.^...^.
...............
`


// trace_beam :: proc()
//

Pos :: struct {
	line: int,
	pos:  int,
}

//naive search. stack shouldn't get that large...
contains :: proc(p: [dynamic]Pos, val: Pos) -> bool {

	for po in p {

		if po.line == val.line && po.pos == val.pos {
			return true
		}
	}
	return false
}

trace_beam :: proc(i, li: int, lines: []string, visited: ^[dynamic]Pos) -> u64 {
	if li >= len(lines) {
		return 0
	}
	line := lines[li]
	if i < 0 || i >= len(line) {
		return 0
	}
	p: Pos = Pos {
		line = li,
		pos  = i,
	}
	if contains(visited^, p) {

		return 0
	}


	append_elem(visited, p)
	if line[i] == '^' {
		return(
			1 +
			trace_beam(i + 1, li + 1, lines, visited) +
			trace_beam(i - 1, li + 1, lines, visited) \
		)
	}

	return trace_beam(i, li + 1, lines, visited)
}


AnswerType :: union {
	int,
	uint,
	u64,
	i64,
}
part_one :: proc(input: string) -> AnswerType {
	answer: u64


	lines, _ := strings.split_lines(input, context.temp_allocator)


	visited: [dynamic]Pos
	defer delete(visited)

	curr_line := 1
	count: u64 = 0
	for ch, i in lines[0] {
		if ch == 'S' {
			answer = trace_beam(i, 1, lines, &visited)
		}

	}

	return answer
}


// Pretty naive, performance could be improved
part_two :: proc(input: string) -> AnswerType {
	answer: u64


	lines, _ := strings.split_lines(input, context.temp_allocator)


	indices: [dynamic]int
	defer delete(indices)

	counts: []u64 = make([]u64, len(lines[0]), context.temp_allocator)

	curr_line := 1
	count: u64 = 0
	for ch, i in lines[0] {
		if ch == 'S' {


			counts[i] = 1

			for line, li in lines[:] {

				for ch, ci in line {

					if ch == '^' {

						lp := ci - 1
						rp := ci + 1

						counts[lp] += counts[ci]
						counts[rp] += counts[ci]

						counts[ci] = 0

					}
				}

			}

			break
		}

	}

	for c in counts {
		answer += c
	}


	return answer
}

main :: proc() {


	path := "input/day07.txt"

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
	expected_1: AnswerType = u64(21)
	expected_2: AnswerType = u64(40)

	assert(part_one(teststr) == expected_1)
	assert(part_two(teststr) == expected_2)
}
