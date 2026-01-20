(ns aoc2021.day1
  (:gen-class)
  (:require [clojure.string :refer [split-lines]]))

(def test-data '(
                199 
                200
                208
                210
                200
                207
                240
                269
                260
                263))


(defn windowed
  [size collection]
  (cond
    (empty? collection) '()
    (< (count collection) size) '()
    :else (let [values (take size collection)]
            (cons values (windowed size (rest collection))))))

(defn real-data []
  (map #(Integer/parseInt %)
       (->> (slurp "resources/day1-input.txt")
            split-lines)))

(def test1
  (->> (windowed 2 test-data)
      (map #(apply - %))
      (filter neg?)
      count)) 

(def day1-1
  (->> (windowed 2 (real-data))
            (map #(apply - %))
            (filter neg?)
            count))
(def day1-2
  (->> (windowed 3 (real-data))
       (map #(apply + %))
       (windowed 2)
       (map #(apply - %))
       (filter neg?)
       count))

(defn -main []
  (println day1-1)
  (println day1-2))
