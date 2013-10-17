;;-----------------------------------------------------------------------------
;; gis-asbuilt-batch-convert
;;    by Robert Rockers
;;    2011-07-21 11:07:37  
;;
;;    VERSION: 1.4
;;
;; Batch program to process a group of as-built images and turn them into two-
;;    color alpha masked tiff files suitable for geo-referencing.
;;
;; FUNCTIONS:
;;    *gimp-image-convert-rgb
;;    *gimp-image-convert-grayscale
;;    *gimp-levels
;;    plug-in-colortoalpha
;;    *file-glob
;;-----------------------------------------------------------------------------

(define (script-fu-gis-asbuilt-batch-convert inDirectory inLevelMod)
	; Get our list of tif images files based on the directory they are in.
	(let*
		(
			(filelist (cadr (file-glob (string-append inDirectory "\\*.tif*") 1)))
			; check for alternative file type extension
			(if (null? filelist)
				(filelist (cadr (file-glob (string-append inDirectory "\\*.tiff*") 1))))
		)
		(while (not (null? filelist))
			(let* 
				(
					(filename (car filelist))
					(gimp-message (string-append "processing filename" filename ))	
					(setImage (car (gimp-file-load RUN-NONINTERACTIVE filename filename)))
					(drawable (car (gimp-image-get-active-layer setImage)))
				)
				; DO STUFF HERE
				; convert image to grayscale to limit colors to only black/white
				;   unless the image is already grayscale
				(if(not (gimp-drawable-is-gray drawable))
					(gimp-image-convert-grayscale setImage))
				; adjust our input and output levels to the same selected value, this
				;     forces the entire image to be only black (0,0,0) or white 
				;     (255,255,255)
				(gimp-levels drawable 0 inLevelMod inLevelMod 1.0 0 255)
				
				; convert image into an index color image with only two 
				;    this DRAMATICALLY reduces the overall size. Options are:
				;    0-no dither, 3 b/w color index, and a couple of ignored values
				(gimp-image-convert-indexed setImage 0 3 2 0 1 "")

				; Save file and delete temporary images
				(gimp-file-save RUN-NONINTERACTIVE setImage drawable filename filename)
				(gimp-image-delete setImage)
			)

			(set! filelist (cdr filelist))
		)
	)

	(gimp-message (string-append inDirectory "\n\n COMPLETED SUCCESSFULLY!"))

)

;; Required Gimp Stuff mostly for the menu options.
(script-fu-register
	"script-fu-gis-asbuilt-batch-convert"                        ;Function name
	"GIS AsBuilt Batch Convert"                             ;Menu label
	"Allows you to selected a directory\
	and convert all tif images in that,\
	folder into two color images ready to \
	be geo-reference in ArcGIS."                                 ;Description
	"Robert Rockers"                                             ;Author
	"copyright 2011, Robert Rockers;\
	and Cobb Engineering Company all rights reserved"            ;Copyright notice
	"July 21, 2011"                                              ;Date created
	""                                                           ;image type that the script works on
	; DEAULT INPUT PARAMATERS
	SF-DIRNAME     "Process Directory"  ""      
	SF-ADJUSTMENT  "Set Input Levels" '(128 0 255 1 10 0 0)         ;a slider
)
(script-fu-menu-register "script-fu-gis-asbuilt-batch-convert" "<Image>/Filters/Cobb")
  
