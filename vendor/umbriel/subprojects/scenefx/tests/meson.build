color_test = executable(
	'color-test',
	'color.c',
	dependencies: scenefx_deps,
	include_directories: [scenefx_inc, include_directories('..')],
	link_with: lib_scenefx,
)

foreach case_name : [
	'legacy-gamma22-target',
	'srgb-to-gamma22',
	'pq-roundtrip',
	'bt2020-to-srgb',
	'fp16-blending',
	'fp16-blur',
	'fp16-blur-effects',
	'fp16-save-restore',
]
	test(
		'color-' + case_name,
		color_test,
		args: case_name,
	)
endforeach
