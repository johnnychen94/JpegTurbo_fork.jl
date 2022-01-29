using Clang.Generators
using JpegTurbo_jll

cd(@__DIR__)

include_dir = normpath(JpegTurbo_jll.artifact_dir, "include")

options = load_options(joinpath(@__DIR__, "generator.toml"))

args = get_default_args()
push!(args, "-I$include_dir")

# headers = [joinpath(include_dir, header) for header in readdir(include_dir) if endswith(header, ".h")]

jconfig_h = joinpath(JpegTurbo_jll.artifact_dir, "include", "jconfig.h")
jmorecfg_h = joinpath(JpegTurbo_jll.artifact_dir, "include", "jmorecfg.h")
jpeglib_h = joinpath(JpegTurbo_jll.artifact_dir, "include", "jpeglib.h")
headers = [jconfig_h, jmorecfg_h, jpeglib_h]

# headers = detect_headers(include_dir, args)


# create context
ctx = create_context(headers, args, options)

# run generator
build!(ctx)
