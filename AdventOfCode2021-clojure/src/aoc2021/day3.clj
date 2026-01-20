(ns aoc2021.day3
  (:gen-class)
  (:require [aoc2021.common :as common]))

(defn to-int-sequence [binary-number-str]
  (map #(Integer/parseInt (str %)) binary-number-str))

(def test-data
  (->> ["00100"
        "11110"
       "10110"
       "10111"
       "10101"
       "01111"
       "00111"
       "11100"
       "10000"
       "11001"
        "00010"]
       (map to-int-sequence)))

(def real-data (->> (common/read-lines "resources/day3-input.txt")
                    (map to-int-sequence)))


(defn length-of-binary-numbers [data-set]
  (count (first data-set)))

(defn bit-count-reducer [bit-counts, binary-number]
  (->> binary-number
       (map-indexed
        (fn [idx bit]
          (let [current-count (nth bit-counts idx)]
            (+ current-count bit))))))


(defn count-all-bits [data-set]
  (let [binary-number-size (length-of-binary-numbers data-set),
        initial-counts (repeat binary-number-size 0)]
    (->> (reduce bit-count-reducer initial-counts data-set)
         (map #(/ % (count data-set))))))

(defn to-decimal [binary-number]
  (reduce + (map-indexed (fn [idx bit]
                           (* (Math/pow 2 idx) bit))
                         (reverse binary-number))))

(defn most-common-bit
  ([bit-count]
   (for [idx (range (count bit-count))]
     (most-common-bit idx bit-count)))

  ([idx bit-count]
   (let [bit (nth bit-count idx)]
     (if (>= bit 1/2) 1 0))))

(defn least-common-bit
  ([bit-count]
   (for [idx (range (count bit-count))]
     (least-common-bit idx bit-count)))

  ([idx bit-count]
   (let [bit (nth bit-count idx)]
     (if (< bit 1/2) 1 0))))

(defn gamma-rate [bit-counts]
  (->> bit-counts most-common-bit to-decimal))

(defn epsilon-rate [bit-counts]
  (->> bit-counts least-common-bit to-decimal))

(defn part1 []
  (let [bit-counts (count-all-bits real-data)]
    (* (gamma-rate bit-counts) (epsilon-rate bit-counts))))

(+ 1 4 (+ 2 3))

(defn filter-for-rating [binary-numbers bit-position filter-method]
  (if (= 1 (count binary-numbers))
    (first binary-numbers)
    (let [bit-counts (count-all-bits binary-numbers)
          bit-value (filter-method bit-position bit-counts)
          filtered-numbers (filter #(= bit-value (Integer/parseInt (str (nth % bit-position)))) binary-numbers)]
      (recur filtered-numbers (inc bit-position) filter-method))))

(defn oxygen-rating [binary-numbers]
  (to-decimal (filter-for-rating binary-numbers 0 most-common-bit)))

(defn co2-scrubber-rating [binary-numbers]
  (to-decimal (filter-for-rating binary-numbers 0 least-common-bit)))

(defn part2 []
  (* (co2-scrubber-rating real-data) (oxygen-rating real-data)))
