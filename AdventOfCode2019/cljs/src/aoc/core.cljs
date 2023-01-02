(ns aoc.core
  (:require ["fs" :as fs]
            [clojure.string :as string]))

(defn filename-for-day [& parts]
  (str "src/aoc/" (string/join "_" parts)))

(defn read-input-data-raw [day part]
  (fs/readFileSync (filename-for-day "input" day part) "utf8"))

(defn read-input-data-lines [day part]
  (string/split-lines (read-input-data-raw day part)))

(defn read-test-data-raw [day part]
  (fs/readFileSync (filename-for-day "test" day part)))

(defn read-test-data-lines [day part]
  (string/split-lines (read-test-data-raw day part)))

(defn main [])
