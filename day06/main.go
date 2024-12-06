package main

import (
	"bufio"
	"fmt"
	"os"
)

const (
	Obstacle = '#'
	Guard    = '^'
	Visited  = 'X'
)

var directions = [][2]int{
	{-1, 0},
	{0, 1},
	{1, 0},
	{0, -1},
}

func main() {
	file, _ := os.Open("./input.txt")
	defer file.Close()

	level := [][]byte{}

	scanner := bufio.NewScanner(file)
	guardPosition := [2]int{0, 0}

	rowIdx := -1
	levelHeight := 0
	levelWidth := 0
	for scanner.Scan() {
		rowIdx++
		line := scanner.Bytes()
		levelWidth = len(line)
		levelRow := []byte{}
		for colIdx, char := range line {
			if char == Guard {
				guardPosition[0] = rowIdx
				guardPosition[1] = colIdx
			}
			levelRow = append(levelRow, char)
		}
		level = append(level, levelRow)

	}
	levelHeight = rowIdx + 1

	curDirectionIdx := 0
	visitedCount := 1
	level[guardPosition[0]][guardPosition[1]] = Visited

	for {
		newPos := getNextPosition(guardPosition, directions[curDirectionIdx])
		if newPos[0] < 0 || newPos[0] >= levelWidth || newPos[1] < 0 || newPos[1] >= levelHeight {
			break
		}

		if level[newPos[0]][newPos[1]] == Obstacle {
			curDirectionIdx = (curDirectionIdx + len(directions) + 1) % len(directions)

			continue
		}

		guardPosition = newPos

		if level[guardPosition[0]][guardPosition[1]] == Visited {
			continue
		}

		level[guardPosition[0]][guardPosition[1]] = Visited
		visitedCount++
	}

	fmt.Println(visitedCount)
}

func getNextPosition(currentPosition [2]int, direction [2]int) [2]int {
	newPosition := currentPosition

	newPosition[0] += direction[0]
	newPosition[1] += direction[1]

	return newPosition
}
