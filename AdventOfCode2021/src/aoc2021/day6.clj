(ns aoc2021.day6
  (:require [aoc2021.common :as common]
            [clojure.string :as str]
            [clojure.test :refer :all]))

(def test-data "3,4,3,1,2")

(defn parse-input-line [line]
  (let [freq (as-> line $
                   (str/split $ #",")
                   (map common/to-int $)
                   (frequencies $))]
    (reduce (fn [v n]
              (conj v (freq n 0)))
            []
            (range 9))))

(defn evolve [state]
  (let [zero-population (first state)
        remaining-population (subvec state 1)]
    (-> remaining-population
        (update 6 (partial + zero-population))
        (conj zero-population))))

(defn run-evolution [state n]
  (if (= 0 n)
    state
    (run-evolution (evolve state) (dec n))))

(defn num-lantern-fish [population]
  (apply + population))

(deftest part1-test
  (let [test-state (parse-input-line test-data)]
    (is (= 26 (-> test-state
                  (run-evolution 18)
                  num-lantern-fish)))
    (is (= 5934 (-> test-state
                    (run-evolution 80)
                    num-lantern-fish)))))

(defn part1 [input]
  (let [initial-state (parse-input-line input)]
    (-> initial-state
        (run-evolution 80)
        num-lantern-fish)))

(defn part2 [input]
  (let [initial-state (parse-input-line input)]
    (-> initial-state
        (run-evolution 256)
        num-lantern-fish)))