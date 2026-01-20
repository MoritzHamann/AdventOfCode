(ns aoc2021.day4
  (:require [aoc2021.common :as common]
            [clojure.string :as str]
            [clojure.test :refer :all]))

(defn read-numbers [lines]
  "Returns the list of numbers drawn, given the sequence of input lines (as strings)"
  (as-> lines $
      (first $)
      (str/split $ #",")
      (map #(Integer/parseInt %) $)))

(defn parse-board-line [line]
  "Returns the numbers for a single line on the board, parsed as integers in a vector"
  (vec (as-> line $
             (str/split $ #" ")
             (filter #(not (empty? %)) $)
             (map #(Integer/parseInt %) $))))

(defn read-boards
  "Returns the sequence of playing boards, given the sequence of input lines (as strings)"
  [lines]
  (let [board-input (subvec lines 2)
        board-lines (vec (map parse-board-line board-input))]
    ; group by empty vectors
    ; -> filter out empty vectors
    ; -> make sure we have a vector of vectors
    (as-> board-lines $
          (partition-by #(empty? %) $)
          (filter #(not (empty? (first %))) $)
          (map vec $))))

(defn mark-number-on-boards [number, boards]
  (vec (map (fn [board]
              (vec (map (fn [line]
                          (vec (map (fn [n]
                                      (if (= n number) :hit n))
                                    line)))
                        board)))
            boards)))

(defn is-hit? [element]
  (= element :hit))

(defn is-winner? [board]
  "returns true if the board has won, false otherwise"
  (let [horizontal-row (as-> board $
                             (map (fn [row] (every? is-hit? row)) $)
                             (some true? $)
                             (boolean $))

        vertical-row (as-> board $
                           ; pull the columns in separate vectors
                           (apply mapv vector $)
                           (map (fn [row] (every? is-hit? row)) $)
                           (some true? $)
                           (boolean $))]
    (or horizontal-row vertical-row)))

(deftest is-winner-test
  (is (= (is-winner? [[:hit :hit 1]
                      [:hit :hit 3]
                      [1 2 :hit]]) false))
  (is (= (is-winner? [[:hit :hit :hit]
                      [:hit :hit 3]
                      [1 2 :hit]]) true))
  (is (= (is-winner? [[:hit :hit 1]
                      [:hit :hit 3]
                      [:hit 2 :hit]]) true)))

(defn board-score [board last-num]
  (* last-num (apply + (mapcat (fn [row]
                                 (map #(if (is-hit? %) 0 %) row))
                               board))))

(defn print-board [board]
  (map println board))

(defn part1 [input-string]
  (let [lines (str/split-lines input-string)
        numbers (read-numbers lines)
        boards (read-boards lines)]
    (loop [current-boards boards
           remaining-numbers numbers]
      (if (empty? remaining-numbers)
        (str "no winning board determined")
        (let [next-num (first remaining-numbers)
              updated-boards (mark-number-on-boards next-num current-boards)
              winning-board (first (filter is-winner? updated-boards))]
          (if (nil? winning-board)
            (recur updated-boards (rest remaining-numbers))
            (board-score winning-board next-num))
          )))))


(def test-data "7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1\n\n22 13 17 11  0\n 8  2 23  4 24\n21  9 14 16  7\n 6 10  3 18  5\n 1 12 20 15 19\n\n 3 15  0  2 22\n 9 18 13 17  5\n19  8  7 25 23\n20 11 10 24  4\n14 21 16 12  6\n\n14 21 17 24  4\n10 16 15  9 19\n18  8 23 26 20\n22 11 13  6  5\n 2  0 12  3  7")

(deftest part1-test
  (is (= (part1 test-data) 4512)))

(def result-part1 (part1 (slurp "resources/day4-input.txt")))

(defn part2 [input-string]
  (let [lines (str/split-lines input-string)
        numbers (read-numbers lines)
        boards (read-boards lines)]
    (loop [current-boards boards
           remaining-numbers numbers
           winning-board-score nil]
      (if (or (empty? remaining-numbers) (empty? current-boards))
        winning-board-score
        (let [next-num (first remaining-numbers)
              updated-boards (mark-number-on-boards next-num current-boards)
              winning-board (first (filter is-winner? updated-boards))
              filtered-boards (filter #(not (is-winner? %)) updated-boards)]
          (recur
            filtered-boards
            (rest remaining-numbers)
            (if (nil? winning-board) nil (board-score winning-board next-num))))))))

(deftest part2-test
  (is (= (part2 test-data) 1924)))

(def result-part2 (part2 (slurp "resources/day4-input.txt")))
