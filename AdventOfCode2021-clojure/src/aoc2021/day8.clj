(ns aoc2021.day8
  (:require [clojure.string :as str]
            [clojure.math.combinatorics :as comb]))

(def test-data "be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe\nedbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc\nfgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg\nfbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb\naecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea\nfgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb\ndbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe\nbdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef\negadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb\ngcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce")
(def single-line-data "acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf")

(defn parse-input-line [line]
  (let [[signal output] (str/split line #"\|")
        signal (str/split signal #" ")
        output (str/split output #" ")
        filter-empty (fn [coll] (vec (filter not-empty coll)))]
    [(filter-empty signal) (filter-empty output)]))

(defn is-easy-output? [output]
  (let [c (count output)]
    (cond
      (= c 2) true
      (= c 4) true
      (= c 3) true
      (= c 7) true
      :default false)))

; mapping:
; { 0 -> set(abcd...), 1 -> set(ab), ...}
;
;    0
;  1   2
;    3
;  4   5
;    6
;
(defn ->mapping [ordering]
  (let [digit-to-segments {
                           0 [0,1,2,4,5,6]
                           1 [2,5]
                           2 [0,2,3,4,6]
                           3 [0,2,3,5,6]
                           4 [1,2,3,5]
                           5 [0,1,3,5,6]
                           6 [0,1,3,4,5,6]
                           7 [0,2,5]
                           8 [0,1,2,3,4,5,6]
                           9 [0,1,2,3,5,6]
                           }]
    (into {} (for [x (range 10)]
                  {x (reduce #(conj %1 (nth ordering %2))
                             #{}
                             (digit-to-segments x))}))))

(defn convert-signal->digit [mapping signal]
  (let [s (set signal)]
    (cond
      (= s (mapping 0)) 0
      (= s (mapping 1)) 1
      (= s (mapping 2)) 2
      (= s (mapping 3)) 3
      (= s (mapping 4)) 4
      (= s (mapping 5)) 5
      (= s (mapping 6)) 6
      (= s (mapping 7)) 7
      (= s (mapping 8)) 8
      (= s (mapping 9)) 9
      )))

(defn get-signal->digit [ordering]
  (partial convert-signal->digit (->mapping ordering)))

(defn is-correct-mapping [converter signals]
  (every? true?
          (for [signal signals
                :let [c (count signal)
                      digit (converter signal)]]
            (cond
              (= c 2) (= 1 digit)
              (= c 3) (= 7 digit)
              (= c 4) (= 4 digit)
              (= c 6) (or (= 0 digit) (= 6 digit) (= 9 digit))
              :default true))
          ))

; precompute all converters
(def converters
  (let [wires (vec "abcdefg")
        all-orderings (comb/permutations wires)]
    (map get-signal->digit all-orderings)))

(defn find-valid-converter [signals]
  (first (filter #(is-correct-mapping % signals) converters)))

(defn get-output-from-signals [signals output]
  (let [converter (find-valid-converter signals)]
    (Integer/parseInt (apply str (map converter output)))))

(defn part1 [input]
  (let [lines (str/split-lines input)
        data (map parse-input-line lines)
        all-output (map second data)]
    (->> all-output
         flatten
         (filter is-easy-output?)
         count)))

(defn part2 [input]
  (let [lines (str/split-lines input)
        data (map parse-input-line lines)]
  (as-> data $
        (pmap #(apply get-output-from-signals %) $)
        (reduce + 0 $))))