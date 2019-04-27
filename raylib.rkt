#lang racket

(require ffi/unsafe
	 (except-in ffi/unsafe/define
		    define-ffi-definer)
	 ffi-definer-convention)


(define-ffi-definer define-raylib
  (ffi-lib "/usr/local/lib/libraylib.so")
  #:make-c-id convention:hyphen->camelcase)


;; raylib basic defines
(define *max-shader-locations* 10)
(define *max-material-maps* 12)

;; c types
(define-cpointer-type _float-ptr)
(define-cpointer-type _short-ptr)
(define-cpointer-type _int-ptr)

(define _camera-mode
  (_enum '(CAMERA_CUSTOM = 0
	   CAMERA_FREE
	   CAMERA_ORBITAL
	   CAMERA_FIRST_PERSON
	   CAMERA_THIRD_PERSON)))

;; structs
(define-cstruct _vector2 ([x _float] [y _float]))
(define-cstruct _vector3 ([x _float] [y _float] [z _float]))
(define-cstruct _vector4
  ([x _float]
   [y _float]
   [z _float]
   [w _float]))

(define-cstruct _color
  ([r _byte]
   [g _byte]
   [b _byte]
   [a _byte]))

(define-cstruct _mesh
  ([vertexCount   _int]
   [triangleCount _int]
   [vertices      _float-ptr]
   [texcoords     _float-ptr]
   [texcoords2    _float-ptr]
   [normals       _float-ptr]
   [tangents      _float-ptr]
   [colors        _string]
   [indices       _short-ptr]
   [baseVertices  _float-ptr]
   [baseNormals   _float-ptr]
   [weightBias    _float-ptr]
   [weightId      _int-ptr]
   [vaoId         _int]
   [vboId         (_array _int 7)]))

(define-cstruct _matrix
  ([m0 _float]  [m1 _float]  [m2 _float]  [m3 _float]  [m4 _float]
   [m5 _float]  [m6 _float]  [m7 _float]  [m8 _float]  [m9 _float]
   [m10 _float] [m11 _float] [m12 _float] [m13 _float] [m14 _float]
   [m15 _float]))

(define-cstruct _shader
  ([id _int]
   [locs (_array _int *max-shader-locations*)]))

(define-cstruct _texture-2d
  ([id _int] [width _int] [height _int] [mipmaps _int] [format _int]))

(define-cstruct _material-map
  ([texture _texture-2d] [color _color] [value _float]))

(define-cstruct _material
  ([shader _shader]
   [maps   (_array _material-map *max-material-maps*)]
   [params _float-ptr]))

(define-cstruct _model
  ([mesh _mesh] [transform _matrix] [material _material]))

(define-cstruct _camera
  ([position _vector3]
   [target   _vector3]
   [up       _vector3]
   [fovy     _float]
   [type     _int]))

(define-cstruct _bounding-box
  ([min _vector3]
   [max _vector3]))


(define-raylib init-window (_fun _int _int _string -> _void))
(define-raylib set-target-fps (_fun _int -> _void)
  #:c-id SetTargetFPS)
(define-raylib window-should-close (_fun -> _bool))
(define-raylib close-window (_fun -> _void))

;; drawing functions

(define-raylib begin-drawing (_fun -> _void))
(define-raylib clear-background (_fun _color -> _void))

;; (define-raylib TextSubtext (_fun _string _int _int -> _string))
(define-raylib draw-text (_fun _string _int _int _int _color -> _void))

(define-raylib end-drawing (_fun -> _void))

;; key functions
(define-raylib is-key-pressed (_fun _int -> _bool))

(define-raylib load-model (_fun _string -> _model))
(define-raylib unload-model (_fun _model -> _void))

(define-raylib load-texture (_fun _string -> _texture-2d))

(define-raylib mesh-bounding-box (_fun _mesh -> _bounding-box))

(define-raylib set-camera-mode (_fun _camera _camera-mode -> _void))

(define-raylib begin-mode-3d (_fun _camera -> _void))
(define-raylib end-mode-3d (_fun -> _void))

(define-raylib draw-model (_fun _model _vector3 _float _color -> _void))
(define-raylib draw-grid (_fun _int _float -> _void))

(define-raylib update-camera (_fun (c : (_ptr io _camera))
				   -> _void
				   -> c))
;;;;;;;;;;;;;;;;;;;;;;;;;;
;; external abstraction ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

(define default-camera (make-camera (make-vector3 30.0 30.0 30.0)
				    (make-vector3  0.0 10.0  0.0)
				    (make-vector3  0.0  1.0  0.0)
    				    45.0
    				    0))


(define (draw state)
  (let* ([d        (hash-ref state 'draw-fn)]
	 [destroy  (hash-ref state 'destroy-fn)]
	 [bg-color (hash-ref state 'background-color)])
    (if (window-should-close)
	(begin (destroy)
	       (close-window))
	(begin  (begin-drawing)
		(clear-background bg-color)
		(d state)
		(end-drawing)
		(draw state)))))


(define (with-window #:init-fn init
		     #:draw-fn d
		     #:height  [height 1366]
		     #:width   [width 768]
		     #:title   [title "raylib"]
		     #:initial-state [state (make-hash)])
  (init-window height width title)
  (hash-set! state 'camera default-camera)
  (hash-set! state 'draw-fn d)
  (init state)
  (set-camera-mode (hash-ref state 'camera) 'CAMERA_CUSTOM)
  (set-target-fps 120)
  (draw state))


(provide (all-defined-out))