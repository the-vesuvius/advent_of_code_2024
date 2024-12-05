package main

import (
	"bufio"
	"fmt"
	"log"
	"math"
	"os"
	"strconv"
	"strings"
)

func pageOrderingProcessor(txt string) []int {
	parts := strings.Split(txt, "|")
	if len(parts) != 2 {
		log.Panic("wrong number of ordering rules")
	}
	left, _ := strconv.Atoi(parts[0])
	right, _ := strconv.Atoi(parts[1])

	return []int{left, right}
}

func updateProcessor(txt string) []int {
	parts := strings.SplitN(txt, ",", -1)
	nums := make([]int, 0, len(parts))
	for _, part := range parts {
		num, _ := strconv.Atoi(part)
		nums = append(nums, num)
	}
	return nums
}

func main() {
	file, _ := os.Open("./input.txt")
	defer file.Close()

	scanner := bufio.NewScanner(file)

	sum := 0
	pagesMap := make(map[int][]int)
	for scanner.Scan() {
		line := scanner.Text()

		if line == "" {
			break
		}

		pages := pageOrderingProcessor(line)
		if _, ok := pagesMap[pages[1]]; !ok {
			pagesMap[pages[1]] = []int{}
		}
		pagesMap[pages[1]] = append(pagesMap[pages[1]], pages[0])
	}

	for scanner.Scan() {
		line := scanner.Text()

		orderingRow := updateProcessor(line)
		if !isOrderingRowValid(orderingRow, pagesMap) {
			continue
		}

		sum += getMiddle(orderingRow)
	}

	fmt.Println(sum)
}

func isOrderingRowValid(row []int, pagesMap map[int][]int) bool {
	pagesSoFar := make(map[int]struct{})
	for _, page := range row {
		for pageSoFar := range pagesSoFar {
			pg := pagesMap[pageSoFar]
			if sliceContains(pg, page) {
				return false
			}
		}
		pagesSoFar[page] = struct{}{}
	}

	return true
}

func sliceContains(slice []int, num int) bool {
	for _, n := range slice {
		if n == num {
			return true
		}
	}
	return false
}

func getMiddle(slice []int) int {
	return slice[int(math.Ceil(float64(len(slice)/2.0)))]
}
