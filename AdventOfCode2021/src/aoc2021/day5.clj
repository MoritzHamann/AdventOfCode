(ns aoc2021.day5
  (:require [clojure.test :refer :all]
            [clojure.string :as str]))

(def test-data "0,9 -> 5,9\n8,0 -> 0,8\n9,4 -> 3,4\n2,2 -> 2,1\n7,0 -> 7,4\n6,4 -> 2,0\n0,9 -> 2,9\n3,4 -> 1,4\n0,0 -> 8,8\n5,5 -> 8,2")

(defn get-orientation [line]
  (cond
    (= (:y (:start line))
       (:y (:end line))) :horizontal
    (= (:x (:start line))
       (:x (:end line))) :vertical
    :default :other))

(defn parse-input-line
  "parse lines of input strings into a `line map` of the form
  {:start {:x 1 :y 2} :end {:x 3 :y 4}}"

  [line]
  (let [matches (re-matches #"([0-9]+),([0-9]+) -> ([0-9]+),([0-9]+)" line)]
    (if (nil? matches)
      ; should not happen
      (throw (Exception. "invalid input line"))
      (let [groups (subvec matches 1)
            to-int #(Integer/parseInt %)
            line {:start {:x (to-int (nth groups 0)) :y (to-int (nth groups 1))}
                  :end   {:x (to-int (nth groups 2)) :y (to-int (nth groups 3))}}]

        ; update the line with its orientation (useful for later processing)
        (assoc line :orientation (get-orientation line))))
    ))

(defn parse-lines [input-str-lines]
  (map parse-input-line input-str-lines))

(defn horizontal? [line]
  (= (:orientation line) :horizontal))

(defn vertical? [line]
  (= (:orientation line) :vertical))

(defn bounds [line direction]
  [(direction (:start line)) (direction (:end line))])

(defn inclusive-range [start stop]
  (if (< stop start)
    (range start (dec stop) -1)
    (range start (inc stop))))

(defn horizontal-and-vertical-lines "remove lines which are not vertical or horizontal"
  [lines]
  (filter #(or (horizontal? %)
               (vertical? %))
          lines))

(defn points-on-line [line]
  (let [x-points (apply inclusive-range (bounds line :x))
        y-points (apply inclusive-range (bounds line :y))]

    (if (or (horizontal? line) (vertical? line))
      ; horizontal and vertical lines
      (for [x x-points y y-points] (list x y))
      ; diagonal lines
      (map list x-points y-points))))

(defn mark-line-on-grid [grid line]
  (let [points (points-on-line line)]
    (reduce #(update-in %1 [(first %2) (second %2)] (fnil inc 0)) grid points)))

(defn count-points-in-map [grid f]
  (let [inner-counting-fn (fn [counts key value]
                            (+ counts (count (filter f (vals value)))))]
    (reduce-kv inner-counting-fn 0 grid)))

(defn part1 [input-string]
  (let [input (str/split-lines input-string)
        lines (parse-lines input)
        relevant-lines (horizontal-and-vertical-lines lines)]
    (count-points-in-map (reduce mark-line-on-grid {} relevant-lines)
                         #(>= % 2))
    ))

(defn part2 [input-string]
  (let [input (str/split-lines input-string)
        relevant-lines (parse-lines input)]
    (count-points-in-map (reduce mark-line-on-grid {} relevant-lines)
                         #(>= % 2)
    )))

(deftest day5-test
  (is (= (part1 test-data)
         5))
  (is (= (part2 test-data)
         12))
  )



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; wrong attempt ;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(defn parallel? [l1 l2]
;  (= (:orientation l1) (:orientation l2)))
;
;(defn orthogonal? [l1 l2]
;  (or
;    (and (horizontal? l1) (vertical? l2))
;    (and (horizontal? l2) (vertical? l1))))
;
;(defn on-same-line? [l1 l2]
;  (if (not (parallel? l1 l2))
;    false
;    (if (horizontal? l1)
;      (= (:y (:start l1))
;         (:y (:start l2)))
;      (= (:x (:start l1))
;         (:x (:start l2)))
;      )))
;
;(defn x-bounds [line]
;  [(min (:x (:start line)) (:x (:end line)))
;   (max (:x (:start line)) (:x (:end line)))])
;
;(defn y-bounds [line]
;  [(min (:y (:start line)) (:y (:end line)))
;   (max (:y (:start line)) (:y (:end line)))])
;
;(defn between? [value [lower upper]]
;  (and (<= value upper) (>= value lower)))
;
;(defn overlap [[lower1 upper1] [lower2 upper2]]
;  (cond
;    (<= lower2 lower1) (max 0 (+ 1 (min (- upper1 lower1) (- upper2 lower1))))
;    (> lower2 lower1) (max 0 (+ 1 (min (- upper2 lower2) (- upper1 lower2))))
;    )
;  )
;
;(defn orthogonal-lines-intersect? [l1 l2]
;  (cond
;    ; safety check
;    (not (orthogonal? l1 l2)) false
;    ; if l1 one is not the horizontal one, flip the lines
;    (vertical? l1) (orthogonal-lines-intersect? l2 l1)
;    ; check via bounds check
;    (horizontal? l1)
;      (and
;        (between? (:x (:start l2)) (x-bounds l1))
;        (between? (:y (:start l1)) (y-bounds l2)))
;    ; should normally not be triggered
;    :default (throw (Exception. "invalid lines provided"))))
;
;(defn count-points-on-same-lines [l1 l2]
;  (cond
;    ; safety check
;    (not (on-same-line? l1 l2)) 0
;    ; vertical case
;    (vertical? l1) (overlap (y-bounds l1) (y-bounds l2))
;    ; horizontal case
;    (horizontal? l1) (overlap (x-bounds l1) (x-bounds l2))
;    ; should never be hit
;    :default (throw (Exception. "Invalid lines provided"))
;    ))


;(defn number-of-overlapping-points [l1 l2]
;  (if (parallel? l1 l2)
;    (if (on-same-line? l1 l2)
;      (count-points-on-same-lines l1 l2)
;      0)
;    (if (orthogonal-lines-intersect? l1 l2)
;      1
;      0)))


