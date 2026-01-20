(ns aoc2021.day2
  (:gen-class)
  (:require [aoc2021.common :as common]
            [clojure.string :as str]))


(def split-on-space #(str/split % #" "))

(defn to-instructions [lines]
  "convert a sequence of lines into instructions in the form of ('forward' 2)"
    (->> lines
        (map split-on-space)
        (map (fn [[command amount]]
               (list command (Integer/parseInt amount))))))

(def real-data
  (-> (common/read-lines "resources/day2-input.txt")
      to-instructions))
  
(def test-data
  (-> '("forward 5"
        "down 5"
        "forward 8"
        "up 3"
        "down 8"
        "forward 2")
      to-instructions))

(defn update-position [{depth :depth pos :pos}, [command amount]]
  (cond
    (= command "up") {:depth (max 0 (- depth amount)) :pos pos}
    (= command "down") {:depth (+ depth amount) :pos pos}
    (= command "forward") {:depth depth :pos (+ pos amount)}
    :else (throw (new Exception "invalid command"))))

(defn update-position-with-aim [{depth :depth pos :pos aim :aim}, [command amount]]
  (cond
    (= command "up") {:depth depth :pos pos :aim (- aim amount)}
    (= command "down") {:depth depth  :pos pos :aim (+ aim amount)}
    (= command "forward") {:depth (+ depth (* aim amount)) :pos (+ pos amount) :aim aim}
    :else (throw (new Exception "invalid command"))))

(defn run [update-fn data-set]
  (let [final-pos (reduce update-fn {:depth 0 :pos 0 :aim 0} data-set)]
    (* (:depth final-pos)
       (:pos final-pos))))

(def part1-test (run update-position test-data))
(defn part1 []
  (run update-position real-data))

(def part2-test (run update-position-with-aim test-data))
(defn part2 []
  (run update-position-with-aim real-data))
