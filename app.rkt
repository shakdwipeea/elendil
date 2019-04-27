#lang racket

(require "raylib.rkt"
	 threading)

(define origin (make-vector3 0.0 0.0 0.0))

(define black     (make-color   0   0   0 255))
(define ray-white (make-color 245 245 245 255))

(with-window
 #:init-fn (lambda (state)
	     (let ([m (load-model "int.obj")])
	       (~> state
		   (hash-set 'model m)
		   (hash-set 'destroy-fn (lambda () (unload-model m)))
		   (hash-set 'background-color ray-white))))
 #:draw-fn (lambda (state)
	     (let* ([camera (hash-ref state 'camera)]
		    [model (hash-ref state 'model)])
	       (begin-mode-3d camera)
	       (draw-model model origin 1.0 black)
	       (draw-grid 20 10.0)
	       (end-mode-3d)
	       state)))
