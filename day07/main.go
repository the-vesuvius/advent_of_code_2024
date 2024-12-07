package main

import (
	"bufio"
	"errors"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	file, _ := os.Open("./input.txt")
	defer file.Close()

	scanner := bufio.NewScanner(file)

	table := [][]int{}
	for scanner.Scan() {
		res := []int{}
		row := scanner.Text()
		parts := strings.Split(row, ":")
		num, _ := strconv.Atoi(parts[0])
		res = append(res, num)
		numbers := strings.SplitN(strings.TrimSpace(parts[1]), " ", -1)
		for _, numStr := range numbers {
			numStr = strings.TrimSpace(numStr)
			tmpNum, _ := strconv.Atoi(numStr)
			res = append(res, tmpNum)
		}

		table = append(table, res)
	}

	sum := 0
	for _, row := range table {
		if isValid(row) {
			sum += row[0]
		}
	}

	fmt.Println(sum)
}

func isValid(row []int) bool {
	expectedResult := row[0]
	numbers := row[1:]

	err1 := step(expectedResult, numbers[0], numbers[1:], "+")
	err2 := step(expectedResult, numbers[0], numbers[1:], "*")
	err3 := step(expectedResult, numbers[0], numbers[1:], "||")

	return err1 == nil || err2 == nil || err3 == nil
}

func step(expected int, resultSoFar int, numbers []int, operator string) error {
	if len(numbers) == 0 {
		if expected == resultSoFar {
			return nil
		}
		return errors.New("oh no")
	}
	switch operator {
	case "+":
		resultSoFar = resultSoFar + numbers[0]
	case "*":
		resultSoFar = resultSoFar * numbers[0]
	case "||":
		resultSoFar = concat(resultSoFar, numbers[0])
	}

	err1 := step(expected, resultSoFar, numbers[1:], "+")
	err2 := step(expected, resultSoFar, numbers[1:], "*")
	err3 := step(expected, resultSoFar, numbers[1:], "||")

	if err1 == nil || err2 == nil || err3 == nil {
		return nil
	}

	return errors.New("oh no")
}

func concat(a, b int) int {
	resStr := strconv.Itoa(a) + strconv.Itoa(b)
	res, _ := strconv.Atoi(resStr)
	return res
}
