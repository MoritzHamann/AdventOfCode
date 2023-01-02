(ns aoc.day1
  (:require [aoc.core :refer [read-input-data-lines]]))

(defn required-fuel
  "floor(mass/3)-2"
  [module-mass]
  (- (js/Math.floor (/ module-mass 3)) 2))

(defn required-fuel-including-fuel
  [module-mass]
  (loop [mass module-mass total-mass 0]
    (let [fuel (required-fuel mass)]
        (if (< fuel 0)
            total-mass
            (recur fuel (+ total-mass fuel))))))

(def sum (partial reduce +))

(defn part1 []
  (let [input-data (read-input-data-lines 1 1)
        input-data-int (map js/parseInt input-data)]
    (sum (map required-fuel input-data-int))))

(defn part2 []
  (let [input-data (read-input-data-lines 1 1)
        input-data-int (map js/parseInt input-data)]
    (sum (map required-fuel-including-fuel input-data-int))))
