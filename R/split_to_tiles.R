#!/usr/bin/Rscript

library(methods)
library(argparser) # requires version 0.4+ due to "nargs = Inf"
library(gdalUtils)
library(raster)

p <- arg_parser("Split a raster into multiple tiles in a grid")

p <- add_argument(p, "INPUT",  help = "
                  Input raster file, e.g. some GeoTIFF.")

p <- add_argument(p, "OUTDIR", help = "
                  Output directory for generating the tiles.")

p <- add_argument(p, "--nrow", short = "-r", help = "
                  How many rows to generate.",
                  default = 3)

p <- add_argument(p, "--ncol", short = "-c", help = "
                  How many columns to generate.",
                  default = 3)

p <- add_argument(p, "--meta", nargs = Inf, default = c(), help = "
                  Additional metadata stored in output tiles. The argument
                  expects multiple entries terminated by '--'.
                  Example: --meta a b c --")

argv <- parse_args(p)

# gdal_translate("data/big/morning_EPSG_31467.tif", "data/tmp.tif",
#                srcwin = c(0,0,1000,1000))

#  argv <- list(INPUT = "data/evening_EPSG_31467.tif",
#               OUTDIR = "data/tiles",
#               nrow = 3, ncol = 3,
#               meta = c("timestamp=2008-09-26 06:30:00"))

# extracting the size of input raster
r <- raster(argv$INPUT)

# creating output directory if does not exist
dir.create(argv$OUTDIR)

# computing the (x,y) split offsets
split_x <- floor(seq(from = 0, to = r@ncols, length.out = argv$ncol + 1))
split_y <- floor(seq.int(from = 0, to = r@nrows, length.out = argv$nrow + 1))

cat(sprintf("Generating %d x %d tiles...\n", argv$ncol, argv$nrow))

for (x in seq_len(length(split_x) - 1)) {
  for (y in seq_len(length(split_y) - 1)) {
    name <- sub("\\.[^.]+$", "", basename(argv$INPUT)) # remove path and extension
    out_fname <- sprintf("%s/%s_tile_%d_%d.tif", argv$OUTDIR, name, x, y)
    cat(out_fname, sep = "\n")
     gdal_translate(argv$INPUT, out_fname,
                    co = c("COMPRESS=DEFLATE",
                           "SPARSE_OK=TRUE",
                           "ZLEVEL=6"),
                    mo = argv$meta,
                    srcwin = c(split_x[x],
                               split_y[y],
                               split_x[x + 1] - split_x[x],
                               split_y[y + 1] - split_y[y]))
  }
}

cat("done\n")
