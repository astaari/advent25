package main

import "core:fmt"
import "core:math"
import os "core:os/os2"
import "core:strconv"
import "core:strings"

import "core:testing"
teststr: string : `11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124`

AnswerType :: union {
	int,
	uint,
	u64,
	i64,
}

part_one :: proc(input: string) -> AnswerType {
	answer: u64 = 0

	ranges := strings.split(input, ",")
	defer delete(ranges)

	for r in ranges {
		nums := strings.split(r, "-")
		start, _ := strconv.parse_u64(nums[0])
		end, _ := strconv.parse_u64(nums[1])
		defer delete(nums)

		for i in start ..= end {
			digits := u64(math.floor(math.log10(f64(i)))) + 1
			if digits % 2 == 1 {
				continue
			}
			half_digits_num := u64(math.pow10(f64(digits) / 2))
			half := i % half_digits_num
			if half == 0 {
				continue
			}

			if i / half == half_digits_num + 1 {
				answer += i
			}

		}

	}
	return answer
}

part_two :: proc(input: string) -> AnswerType {

	answer: u64 = 0

	ranges := strings.split(input, ",")
	defer delete(ranges)

	for r in ranges {
		nums := strings.split(r, "-")
		start, _ := strconv.parse_u64(nums[0])
		end, _ := strconv.parse_u64(nums[1])
		defer delete(nums)

		for i in start ..= end {
			digits := u64(math.floor(math.log10(f64(i)))) + 1


			for p: u64 = digits; p > 0; p -= 1 {
				if digits % p == 0 {
					//Based on length of sequence, dividing the number
					//Will equal something like 1010101 (sequence of 2, labeled magic_number)
					//This is to calculate that and compare the 'magic number'
					//Probably a better way to do this -- That's for another day
					repeat_count := digits / p
					base := u64(math.pow10(f64(repeat_count)))
					magic_number := base + 1
					multiplier := base
					for j: i64 = 0; j < i64(p) - 2; j += 1 {
						magic_number *= multiplier
						magic_number += 1
					}

					half := i % base
					if half == 0 {
						continue
					}
					if i / half == magic_number {
						answer += i
						break
					}
				}
			}

		}

	}
	return answer
}

main :: proc() {
	path := "input/day02.txt"

	input_bytes, _ := os.read_entire_file_from_path(path, context.allocator)

	input := string(input_bytes)
	defer delete(input_bytes)
	fmt.println("Part one: ", part_one(input))

	fmt.println("Part two: ", part_two(input))

}


@(test)
run_test :: proc(t: ^testing.T) {
	expected_1: AnswerType = u64(1227775554)
	expected_2: AnswerType = u64(4174379265)

	assert(part_one(teststr) == expected_1)
	assert(part_two(teststr) == expected_2)
}
