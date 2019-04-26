#lang racket

(require ffi/unsafe
	 ffi/unsafe/define)


(define-ffi-definer define-raylib (ffi-lib "/usr/local/lib/libraylib.so"))


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
(define-cstruct _vector2 ([_x _float] [_y _float]))
(define-cstruct _vector3 ([_x _float] [_y _float] [_z _float]))
(define-cstruct _vector4
  ([_x _float]
   [_y _float]
   [_z _float]
   [_w _float]))

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


(define-raylib InitWindow (_fun _int _int _string -> _void))
(define-raylib SetTargetFPS (_fun _int -> _void))
(define-raylib WindowShouldClose (_fun -> _bool))
(define-raylib CloseWindow (_fun -> _void))

;; drawing functions

(define-raylib BeginDrawing (_fun -> _void))
(define-raylib ClearBackground (_fun _color -> _void))

;; (define-raylib TextSubtext (_fun _string _int _int -> _string))
(define-raylib DrawText (_fun _string _int _int _int _color -> _void))

(define-raylib EndDrawing (_fun -> _void))

;; key functions
(define-raylib IsKeyPressed (_fun _int -> _bool))

(define-raylib LoadModel (_fun _string -> _model))
(define-raylib UnloadModel (_fun _model -> _void))

(define-raylib LoadTexture (_fun _string -> _texture-2d))

(define-raylib MeshBoundingBox (_fun _mesh -> _bounding-box))

(define-raylib SetCameraMode (_fun _camera _camera-mode -> _void))

(define-raylib BeginMode3D (_fun _camera -> _void))
(define-raylib EndMode3D (_fun -> _void))
1
(define-raylib DrawModel (_fun _model _vector3 _float _color -> _void))
(define-raylib DrawGrid (_fun _float _float -> _void))

(define-raylib UpdateCamera (_fun (_ptr io _camera) -> _void))
;;;;;;;;;;;;;;;;;
;; Application ;;
;;;;;;;;;;;;;;;;;

(InitWindow 1366 768 "load 3d model")

(define pos (make-vector3 0.0 0.0 0.0))

(define cam (make-camera (make-vector3 30.0 30.0 30.0)
                         (make-vector3  0.0 10.0  0.0)
                         (make-vector3  0.0  1.0  0.0)
    			 45.0
    			 0))

(define m (LoadModel "int.obj")) 

(SetCameraMode cam 'CAMERA_FREE)

(SetTargetFPS 60)

(define (draw)
  (if (WindowShouldClose)
      (begin  (CloseWindow)
	      (UnloadModel m) 
	      (CloseWindow))
      (begin  (UpdateCamera cam)
	      (BeginDrawing)
	      (ClearBackground (make-color 245 245 245 255))
	      (BeginMode3D cam)
	      (DrawModel m pos 1.0 (make-color 0 0 0 255))
	      (DrawGrid 20.0 10.0)
	      (EndMode3D)
	      (EndDrawing)
	      (draw))))

(draw)

;; (define worker (thread (draw 0 "abcdas")))

;; (thread-running? worker)
