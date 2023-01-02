(ns aoc2021.day9
    (:require [clojure.string :as str]
              [aoc2021.common :refer [to-int]]))


(def test-data "2199943210\n3987894921\n9856789892\n8767896789\n9899965678")

(defn parse-input [input]
    (let [lines (str/split-lines input)
          line-parser (fn [line]
                          (as-> line $
                                (str/split $ #"")
                                (map to-int $)
                                (vec $)))]
        (vec (map line-parser lines))))

(defn left-neighbour [[x y]]
    [x (dec y)])
(defn right-neighbour [[x y]]
    [x (inc y)])
(defn up-neighbour [[x y]]
    [(dec x) y])
(defn down-neighbour [[x y]]
    [(inc x) y])

(defn all-neighbours [x y]
    (mapv #(% x y)
          [left-neighbour, right-neighbour, up-neighbour, down-neighbour]))

(defn get-value [grid x y]
    ; using 10 as a default value (to make sure we can ignore the edges)
    (get-in grid [x y] 10))

(defn is-low-point? [grid x y]
    (let [neighbour-coords (all-neighbours x y)
          neighbour-values (map #(apply get-value grid %) neighbour-coords)
          center-value (get-value grid x y)]
        (every? #(> % center-value) neighbour-values)))

(defn is-basin-value? [grid [x y]]
    (< (get-value grid x y) 9))

(defn all-points [grid]
    (for [x (range (count grid))
          y (range (count (first grid)))]
        [x y]))

(defn is-already-explored? [coord & basins]
    (if (some #(contains? % coord) basins)
        true
        false))

(defn explore-basin [grid coord]
    ; TODO: write out a new image for each explored point
    (let [is-valid-exploration-point? (fn [coord basin] (and (not (is-already-explored? coord basin))
                                                             (is-basin-value? grid coord)))]
        (loop [path (list coord)
               basin #{coord}]
            (cond
                ; this is the stop condition, nothing to explore anymore, we backtracked the whole path
                (empty? path) basin

                ; top neighbour part of the basin?
                (is-valid-exploration-point? (up-neighbour (first path)) basin)
                    (recur (conj path (up-neighbour (first path)))
                           (conj basin (up-neighbour (first path))))

                ; right neighbour part of the basin?
                (is-valid-exploration-point? (right-neighbour (first path)) basin)
                    (recur (conj path (right-neighbour (first path)))
                           (conj basin (right-neighbour (first path))))

                ; down neighbour part of the basin?
                (is-valid-exploration-point? (down-neighbour (first path)) basin)
                    (recur (conj path (down-neighbour (first path)))
                           (conj basin (down-neighbour (first path))))

                ; left neighbour part of the basin?
                (is-valid-exploration-point? (left-neighbour (first path)) basin)
                    (recur (conj path (left-neighbour (first path)))
                           (conj basin (left-neighbour (first path))))

                ; if no neighbours can be explored anymore, backtrack to the previous point and
                ; potentially try a different direction
                :default (recur (rest path) basin))
            )))

(defn is-worth-exploring? [grid basins coord]
    (and (is-basin-value? grid coord)
         (not (apply is-already-explored? coord basins))))

(defn part1 [input]
    (let [grid (parse-input input)]
        (->> (for [x (range (count grid))
                   y (range (count (first grid)))]
                 (if (is-low-point? grid x y)
                     (+ 1 (get-value grid x y))
                     0))
             (reduce +))))

(defn part2
    "The basic idea:
    1. iterate over all points in the grid
    2. for each point determine if it already belongs to any existing basin
    3.1 if not, find all points in this basin by exploring neighbouring points recursively (deep first search)
    3.2 all explored points are added to a set of points, which represents the basin
    4. compute the value by multiplying the size for each basin set
    "
    [input]
    (let [grid (parse-input input)
          coordinates (all-points grid)

          ; check for each coordinate if it's worth exploring (not already in basin and not an edge)
          reduce-fn (fn [basins coord] (if (is-worth-exploring? grid basins coord)
                                           (conj basins (explore-basin grid coord))
                                           basins))
          all-basins (reduce reduce-fn [] coordinates)]

        (->> all-basins
             (map count)
             (sort >)
             (take 3)
             (reduce *)
        )))