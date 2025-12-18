#!/usr/bin/env bash
set -euo pipefail

# ---------- INPUT ----------
JSON_FILE="$1"
OUTPUT_DIR="downloaded_media"

if [[ ! -f "$JSON_FILE" ]]; then
  echo "JSON file not found: $JSON_FILE"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

# ---------- WORKSPACE ----------
WORK_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

# ---------- PROCESS ----------
jq -c '.["Saved Media"][]' "$JSON_FILE" | while read -r item; do
  media_type=$(jq -r '.["Media Type"]' <<< "$item")
  url=$(jq -r '.["Media Download Url"]' <<< "$item")
  date_utc=$(jq -r '.Date' <<< "$item")
  location=$(jq -r '.Location' <<< "$item")

  lat=$(sed -n 's/.*Latitude, Longitude: \([^,]*\),.*/\1/p' <<< "$location")
  lon=$(sed -n 's/.*Latitude, Longitude: [^,]*, \(.*\)/\1/p' <<< "$location")

  safe_date=$(echo "$date_utc" | tr ' :' '__')
  exif_date=$(echo "$date_utc" | sed 's/-/:/g' | sed 's/ UTC//')

  tmp_media="$WORK_DIR/media"
  curl -L --fail "$url" -o "$tmp_media"

  mime_type=$(file --brief --mime-type "$tmp_media")

  # ---------- IMAGE (JPEG / PNG) ----------
  if [[ "$mime_type" =~ image/ ]]; then
    out="$OUTPUT_DIR/image_${safe_date}.jpg"
    mv "$tmp_media" "$out"

  # ---------- VIDEO ----------
  elif [[ "$mime_type" == "video/mp4" ]]; then
    out="$OUTPUT_DIR/video_${safe_date}.mp4"
    mv "$tmp_media" "$out"
    echo "Saved video: $out"
    continue

  # ---------- ZIP (ONE ZIP = ONE IMAGE) ----------
  elif [[ "$mime_type" == "application/zip" ]]; then
    zip_workspace="$(mktemp -d "$WORK_DIR/zip_XXXX")"
    unzip -qq "$tmp_media" -d "$zip_workspace"

    base_jpg=$(find "$zip_workspace" -type f -iname '*.jpg' | head -n 1)

    if [[ -z "$base_jpg" ]]; then
      echo "ZIP has no JPG base image, skipping"
      rm -rf "$zip_workspace"
      continue
    fi

    out="$OUTPUT_DIR/image_${safe_date}.jpg"
    cp "$base_jpg" "$out"

    overlays=""
    while IFS= read -r png; do
      overlays="$overlays
$png"
    done < <(find "$zip_workspace" -type f -iname '*.png' | sort)

    IFS=$'\n'
    for overlay in $overlays; do
      magick "$out" "$overlay" -compose over -composite "$out"
    done
    unset IFS

    rm -rf "$zip_workspace"

  else
    echo "Unsupported media type: $mime_type"
    continue
  fi

  # ---------- METADATA ----------
  exif_args=(
    -overwrite_original
    -DateTimeOriginal="$exif_date"
    -CreateDate="$exif_date"
    -ModifyDate="$exif_date"
  )

  if [[ "$lat" != "0.0" && "$lon" != "0.0" ]]; then
    lat_ref="N"
    lon_ref="E"
    [[ "$lat" == -* ]] && lat_ref="S"
    [[ "$lon" == -* ]] && lon_ref="W"

    exif_args+=(
      -GPSLatitude="$lat"
      -GPSLongitude="$lon"
      -GPSLatitudeRef="$lat_ref"
      -GPSLongitudeRef="$lon_ref"
    )
  fi

  exiftool "${exif_args[@]}" "$out" >/dev/null

  echo "Saved image: $out"

done

echo "All media processed successfully."