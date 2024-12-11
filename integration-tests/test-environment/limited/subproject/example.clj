(ns calculator.core)

(defn add [a b]
  (+ a b))

(defn subtract [a b]
  (- a b))

(defn multiply [a b]
  (* a b))

(defn divide [a b]
  (if (zero? b)
    "Cannot divide by zero!"
    (/ a b)))

(defn -main []
  (println "Welcome to the Clojure Calculator!")
  (println "Addition: 10 + 5 =" (add 10 5))
  (println "Subtraction: 10 - 5 =" (subtract 10 5))
  (println "Multiplication: 10 * 5 =" (multiply 10 5))
  (println "Division: 10 / 5 =" (divide 10 5))
  (println "Division: 10 / 0 =" (divide 10 0)))
