(ns aoc.day2
  (:require [aoc.core :refer [read-input-data-raw read-test-data-raw]]
            [clojure.string :as string]))

(defn memory-accessor [data pos]
  (nth data pos))

(defn opcode1 [data pos]
  (let [memory-location-at (partial memory-accessor data)
        operandA           (memory-location-at (+ pos 1))
        operandB           (memory-location-at (+ pos 2))
        A                  (memory-location-at operandA)
        B                  (memory-location-at operandB)
        dest               (memory-location-at (+ pos 3))]
    ;(print "opcode 1:" operandA "-" operandB "-" dest)
    (assoc data dest (+ A B))))

(defn opcode2 [data pos]
  (let [operandA (memory-location-at data (+ pos 1))
        operandB (memory-location-at data (+ pos 2))
        A        (memory-location-at data operandA)
        B        (memory-location-at data operandB)
        dest     (memory-location-at data (+ pos 3))]
    ;(print "opcode 2:" operandA "-" operandB "-" dest)
    (assoc data dest (* A B))))

(defn end-of-program [program pos]
  (or (= pos (- (count program) 1))
      (= 99 (memory-location-at program pos))))

(def opcodes {1 opcode1, 2 opcode2})

(defn execute-program [program pos]
  ;(print "pos:" pos)
  ;(print "program:" program)
  (if (end-of-program program pos)
    (do
      ;(print "end of program")
      program)
    (let [op-code (memory-location-at program pos)
          op      (opcodes op-code)]
      (recur (op program pos) (+ pos 4)))))


(defn modify-program [program value-at-pos1 value-at-pos2]
  (assoc (assoc program 1 value-at-pos1) 2 value-at-pos2))

(defn get-integer-program []
  (vec (map js/parseInt (string/split (read-input-data-raw 2 1) ","))))

(defn part1 []
  (let [integer-program  (get-integer-program)
        modified-program (modify-program integer-program 12 2)]
    (execute-program modified-program 0)
  ))


(defn test1 []
  (let [input-data (read-test-data-raw 2 1)
        integer-program (vec (map js/parseInt (string/split input-data ",")))]
    ;(print "start")
    (execute-program integer-program 0)
    ;(print "end")
    ))

(defn part2 []
  (let [integer-program (get-integer-program)]
    (for [pos1 (range 99)
          pos2 (range 99)]
      (let [program (modify-program integer-program pos1 pos2)
            final-program (execute-program program 0)
            first-pos (nth final-program 0)]
        (when (= first-pos 19690720)
          (print (+ (* 100 pos1) pos2)))))))
  
