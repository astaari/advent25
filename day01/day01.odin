package day01

import fmt "core:fmt"
import os "core:os/os2"
import "core:strconv"
import "core:strings"

example: string : `L68
L30
R48
L5
R60
L55
L1
L99
R14
L82
R170
L501`

example2: string : `R101
L151
R3
L334
R2
R53
R653
R123
L120`


part_one :: proc() {

	path: string = "input/day01.txt"
	file, _ := os.open(path)

	data, _ := os.read_entire_file(path, context.allocator)
	defer delete(data)
	dstr := string(data)
	zero_count := 0
	pos: i64 = 50
	lines, ok := strings.split(dstr, "\n")
	defer delete(lines)
	for s in lines[:len(lines) - 1] {


		dir := s[0]
		num, _ := strconv.parse_i64_of_base(s[1:], 10)

		if dir == 'L' {
			pos = (pos - num)
		} else {
			pos = (pos + num) % 100
		}
		if pos < 0 {
			pos = (100 + pos) % 100
		}
		if pos == 0 {
			zero_count += 1
		}

	}

	fmt.println("Password: ", zero_count)

}

part_two :: proc() {

	path: string = "input/day01.txt"
	file, _ := os.open(path)

	data, _ := os.read_entire_file(path, context.allocator)
	defer delete(data)
	dstr := string(data)
	zero_count: i64 = 0
	pos: i64 = 50
	lines, ok := strings.split(dstr, "\n")
	defer delete(lines)
	for s in lines[:len(lines) - 1] {

		dir := s[0]
		num, _ := strconv.parse_i64_of_base(s[1:], 10)


		clicks: i64
		x: i64 = num % 100
		if dir == 'L' {
			next: i64 = pos - num
			clicks = num / 100
			if x >= pos && pos != 0 {
				clicks += 1
			}
			pos = (100 - x + pos) % 100
		} else {
			next: i64 = pos + num
			clicks = next / 100
			pos = next % 100
		}
		zero_count += clicks

	}
	fmt.println("Password: ", zero_count)
}

main :: proc() {


	part_one()
	part_two()


}
