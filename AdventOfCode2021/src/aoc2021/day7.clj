(ns aoc2021.day7
  (:require [clojure.string :as str]
            [aoc2021.common :as common]))


(def test-data "16,1,2,0,4,2,7,1,2,14")

(defn parse-input [input]
  (map common/to-int (str/split input #",")))

(defn bounds [positions]
  (list (apply min positions) (apply max positions)))

(defn cost-for-position [positions x current-min]
  (if (nil? current-min)
    (reduce (fn [sum v] (+ sum (Math/abs (- x v)))) 0 positions)
    (reduce (fn [sum v]
              (let [new-sum (+ sum (Math/abs (- x v)))]
                (if (>= new-sum current-min)
                  (reduced nil)
                  new-sum)))
            0 positions)))

(defn linear-cost [x]
  (if (odd? x)
    (int (* (Math/ceil (/ x 2)) x))
    (* (/ x 2) (+ x 1))))

(defn linear-cost-for-position [positions x current-min]
  (if (nil? current-min)
    (reduce (fn [sum v] (+ sum (linear-cost (Math/abs (- x v))))) 0 positions)
    (reduce (fn [sum v]
              (let [new-sum (+ sum (linear-cost (Math/abs (- x v))))]
                (if (>= new-sum current-min)
                  (reduced nil)
                  new-sum)))
            0 positions)))

(defn find-min [data cost-fn exploration-space current-min]
  (if (empty? exploration-space)
    current-min
    (let [pos (first exploration-space)
          remaining-space (rest exploration-space)
          costs (cost-fn data pos (:cost current-min))]
      (if-let [new-min costs]
        (recur data cost-fn remaining-space {:pos pos :cost new-min})
        (recur data cost-fn remaining-space current-min)))))

(defn part1 [input]
  (let [positions (parse-input input)
        [from to] (bounds positions)]
    (find-min positions cost-for-position (range from (inc to)) nil)))

(defn part2 [input]
  (let [positions (parse-input input)
        [from to] (bounds positions)]
    (find-min positions linear-cost-for-position (range from (inc to)) nil)))
