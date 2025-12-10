package main

import "core:fmt"
import os "core:os/os2"
import "core:slice"
import "core:sort"
import "core:strconv"
import "core:strings"

import "core:testing"
teststr: string : `3-5
10-14
16-20
12-18

1
5
8
11
17
32
`

AnswerType :: union {
	int,
	uint,
	u64,
	i64,
}

NumRange :: struct {
	low:  u64,
	high: u64,
}


parse_range :: proc(input: string) -> (result: NumRange) {

	nums, _ := strings.split(input, "-", context.temp_allocator)

	result.low, _ = strconv.parse_u64(nums[0])
	result.high, _ = strconv.parse_u64(nums[1])

	return result
}

within_range :: proc(num: AnswerType, range: NumRange) -> bool {
	return num.(u64) >= range.low && num.(u64) <= range.high
}

distance :: proc(range: NumRange) -> AnswerType {
	return range.high - range.low + 1
}

order_by_low :: proc(lhs: NumRange, rhs: NumRange) -> bool {
	return lhs.low < rhs.low
}

part_one :: proc(input: string) -> AnswerType {
	answer: uint

	lines, _ := strings.split_lines(input, context.temp_allocator)
	lines = lines[:len(lines) - 1]
	split := 0
	for strings.compare(lines[split], "") != 0 {
		split += 1
	}


	ranges: []NumRange = make([]NumRange, split, context.temp_allocator)


	for i in 0 ..< split {
		ranges[i] = parse_range(lines[i])
	}

	for l in lines[split:] {
		id, _ := strconv.parse_u64(l)
		for rng in ranges {
			if within_range(id, rng) {
				answer += 1
				break
			}
		}
	}

	return answer
}


part_two :: proc(input: string) -> AnswerType {
	answer: u64

	lines, _ := strings.split_lines(input, context.temp_allocator)
	lines = lines[:len(lines) - 1]
	split := 0
	for strings.compare(lines[split], "") != 0 {
		split += 1
	}


	ranges: []NumRange = make([]NumRange, split, context.temp_allocator)

	all_ranges: [dynamic]NumRange
	defer delete(all_ranges)

	for i in 0 ..< split {
		ranges[i] = parse_range(lines[i])
	}
	//Sort it so it is consistent (lowest low first)
	slice.sort_by(ranges[:], order_by_low)

	for r in ranges {
		if len(all_ranges) == 0 {
			append_elem(&all_ranges, r)
		} else {
			within_any := false
			//Will combine ranges that fall within each other
			for &rng in all_ranges {
				low_in := within_range(r.low, rng)
				high_in := within_range(r.high, rng)

				within_any = low_in || high_in

				if low_in && high_in {
					break
				} else if low_in {
					rng.high = r.high
				} else if high_in {
					rng.low = r.low
				}
				if within_any {
					break
				}
			}

			//unique so add it to the array
			if !within_any {
				append_elem(&all_ranges, r)
			}
		}

	}
	for r in all_ranges {
		answer += distance(r).(u64)
	}
	return answer
}

main :: proc() {


	path := "input/day05.txt"

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
	expected_1: AnswerType = uint(3)
	expected_2: AnswerType = u64(14)

	assert(part_one(teststr) == expected_1)
	assert(part_two(teststr) == expected_2)
}
