# Losslessly compress PNG figures used in the vignettes.
#
# Rerun after regenerating anything in vignettes/figures/. Run from the
# package root:
#   source("data-raw/compress_vignette_figures.R")
#
# Each PNG is re-encoded at maximum zlib compression with adaptive filtering
# and stripped of metadata. Compression is lossless: a file is only
# overwritten if the decoded pixels are identical to the original AND the new
# file is smaller. Rerunning on already-compressed figures is therefore safe.
#
# (Colour quantization / PNG8 was tried previously and rejected because it
# visibly altered plot colours.)
#
# Requires the magick package (not a package dependency; data-raw/ is
# build-ignored).

if (!requireNamespace("magick", quietly = TRUE)) {
  stop("Install the 'magick' package to run this script.", call. = FALSE)
}

compress_pngs <- function(dir = "vignettes/figures") {
  files <- list.files(dir, pattern = "\\.png$", full.names = TRUE)
  if (length(files) == 0) {
    message("No PNG files found in ", dir)
    return(invisible(NULL))
  }

  res <- lapply(files, function(f) {
    before <- file.size(f)
    tmp <- tempfile(fileext = ".png")
    on.exit(unlink(tmp))

    original <- magick::image_read(f)
    original |>
      magick::image_strip() |>
      magick::image_write(
        tmp,
        format = "png", depth = 8,
        # zlib level 9, adaptive filtering
        compression = "Zip", quality = 95
      )

    after <- file.size(tmp)
    identical_pixels <- identical(
      magick::image_data(original, "rgba"),
      magick::image_data(magick::image_read(tmp), "rgba")
    )
    replaced <- identical_pixels && after < before
    if (replaced && !file.copy(tmp, f, overwrite = TRUE)) {
      stop("Could not overwrite ", f, " (is it open elsewhere?)", call. = FALSE)
    }

    data.frame(
      file = basename(f),
      kb_before = round(before / 1024),
      kb_after = round(if (replaced) after / 1024 else before / 1024),
      replaced = replaced,
      identical_pixels = identical_pixels
    )
  })
  res <- do.call(rbind, res)

  if (any(!res$identical_pixels)) {
    warning(
      "Skipped (re-encode not pixel-identical): ",
      paste(res$file[!res$identical_pixels], collapse = ", "),
      call. = FALSE
    )
  }
  message(sprintf(
    "%d of %d files recompressed; total %d KB -> %d KB",
    sum(res$replaced), nrow(res), sum(res$kb_before), sum(res$kb_after)
  ))
  invisible(res)
}

compress_pngs()
