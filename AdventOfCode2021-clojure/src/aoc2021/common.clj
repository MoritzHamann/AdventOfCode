(ns aoc2021.common
  (:require [clojure.string :as str]))


(defn read-lines [file-name]
  (str/split-lines (slurp file-name)))

(defn to-int [s]
  (Integer/parseInt s))
