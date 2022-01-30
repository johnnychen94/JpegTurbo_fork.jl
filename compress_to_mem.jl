using TestImages
using ImageCore
using ImageShow
using JpegTurbo
import JpegTurbo: LibJpeg

function encode_jpeg_to_memory(img, quality=1)
    cinfo = LibJpeg.jpeg_compress_struct()
    jerr = Ref{LibJpeg.jpeg_error_mgr}()
    cinfo.err = LibJpeg.jpeg_std_error(jerr)
    LibJpeg.jpeg_create_compress(cinfo)

    cinfo.image_width = size(img, 2)
    cinfo.image_height = size(img, 1)
    cinfo.input_components = 1
    cinfo.in_color_space = LibJpeg.JCS_GRAYSCALE

    LibJpeg.jpeg_set_defaults(cinfo)
    LibJpeg.jpeg_set_quality(cinfo, quality, true)

    bufsize = Ref{Culong}(0)
    buf_ptr = Ref(Ptr{UInt8}())
    LibJpeg.jpeg_mem_dest(cinfo, buf_ptr, bufsize)
    LibJpeg.jpeg_start_compress(cinfo, true)

    row_stride = size(img, 2)
    row_pointer = Vector{Ptr{UInt8}}(undef, 1)
    while (cinfo.next_scanline < cinfo.image_height)
        row_pointer[1] = pointer(img) + cinfo.next_scanline * row_stride
        LibJpeg.jpeg_write_scanlines(cinfo, row_pointer, 1);
    end

    LibJpeg.jpeg_finish_compress(cinfo)
    LibJpeg.jpeg_destroy_compress(cinfo)
    return unsafe_wrap(Array, buf_ptr.x, bufsize[])
end

img = Gray.(testimage("cameraman"))

write("test.jpg", encode_jpeg_to_memory(img, 100))
