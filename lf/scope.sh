#!/bin/bash

# File preview script for lf file manager

set -C -f
IFS="$(printf '%b_' '\n')"; IFS="${IFS%_}"

# Get file path, width, and height for preview
file="$1"
width="${2:-80}" # Default width to 80 columns if not provided
height="${3:-24}" # Default height to 24 lines if not provided
x="$4"
y="$5"

# File extension and MIME type
ext="${file##*.}"
mime=$(file --mime-type "$file" -b)

# Function to display a message if a tool is missing
missing_tool_message() {
    echo "Previewer tool '$1' not found."
    echo "Please install it to enable previews for this file type."
}

# Temporary file for thumbnails
# Ensure TMPDIR is set, fallback to /tmp if not
: "${TMPDIR:=/tmp}"
thumb="${TMPDIR}/scope_thumb_${RANDOM}.jpg"
trap 'rm -f "$thumb"' EXIT # Clean up thumbnail on exit

case "$mime" in
    # Text files (including JSON, JS, Shell scripts)
    text/* | */json | */javascript | */x-shellscript)
        if command -v bat > /dev/null; then
            bat --color=always --style=numbers,grid --line-range=:200 --terminal-width="$width" "$file"
        elif command -v highlight > /dev/null; then
            highlight -O ansi --style=solarized-dark "$file" | head -n 200
        elif command -v pygmentize > /dev/null; then
            pygmentize -g "$file" | head -n 200
        else
            head -n 200 "$file"
        fi
        echo -e "\n\033[1;34mFile:\033[0m $file | \033[1;33mType:\033[0m $mime | \033[1;32mSize:\033[0m $(stat -c %s "$file" 2>/dev/null | numfmt --to=iec 2>/dev/null || stat -f %z "$file" 2>/dev/null)"
        ;;

    # Markdown files - special handling
    text/markdown)
        if command -v bat > /dev/null; then
            bat --color=always --style=numbers,grid --language=markdown --line-range=:200 --terminal-width="$width" "$file"
        elif command -v glow > /dev/null; then
            glow -s dark -w "$width" "$file"
        elif command -v mdcat > /dev/null; then # mdcat might be too slow for previews
            mdcat --columns="$width" "$file" | head -n 200 
        else
            head -n 200 "$file"
        fi
        echo -e "\n\033[1;34mFile:\033[0m $file | \033[1;33mType:\033[0m $mime | \033[1;32mSize:\033[0m $(stat -c %s "$file" 2>/dev/null | numfmt --to=iec 2>/dev/null || stat -f %z "$file" 2>/dev/null)"
        ;;

    # PDF files
    application/pdf)
        if command -v pdftotext > /dev/null; then
            pdftotext -l 10 -nopgbrk -q -W "$((width * 3/4))" -H "$((height * 3/4))" -- "$file" -
        else
            missing_tool_message "pdftotext"
        fi
        echo -e "\n\033[1;34mFile:\033[0m $file | \033[1;33mType:\033[0m $mime | \033[1;32mSize:\033[0m $(stat -c %s "$file" 2>/dev/null | numfmt --to=iec 2>/dev/null || stat -f %z "$file" 2>/dev/null)"
        ;;

    # Image files
    image/*)
        if command -v chafa > /dev/null; then
            chafa -s "${width}x${height}" --animate off "$file"
        elif command -v img2txt > /dev/null; then # from caca-utils
            img2txt -W "$width" -H "$height" "$file"
        elif command -v catimg > /dev/null;
            catimg -w "$((width * 2))" -H "$height" "$file"
        else
            missing_tool_message "chafa, img2txt, or catimg"
            file --brief --dereference "$file"
        fi
        echo -e "\n\033[1;34mFile:\033[0m $file | \033[1;33mType:\033[0m $mime | \033[1;32mSize:\033[0m $(stat -c %s "$file" 2>/dev/null | numfmt --to=iec 2>/dev/null || stat -f %z "$file" 2>/dev/null)"
        ;;

    # Video files - thumbnail preview
    video/*)
        if command -v ffmpegthumbnailer > /dev/null; then
            ffmpegthumbnailer -i "$file" -o "$thumb" -s 0
            if [ -f "$thumb" ]; then
                if command -v chafa > /dev/null; then
                    chafa -s "${width}x${height}" --animate off "$thumb"
                elif command -v img2txt > /dev/null;
                    img2txt -W "$width" -H "$height" "$thumb"
                elif command -v catimg > /dev/null;
                    catimg -w "$((width * 2))" -H "$height" "$thumb"
                else
                    echo "Generated thumbnail, but no image previewer (chafa, img2txt, catimg)."
                fi
            else
                echo "Failed to generate thumbnail for $file."
            fi
        else
            missing_tool_message "ffmpegthumbnailer"
            file --brief --dereference "$file"
        fi
        echo -e "\n\033[1;34mFile:\033[0m $file | \033[1;33mType:\033[0m $mime | \033[1;32mSize:\033[0m $(stat -c %s "$file" 2>/dev/null | numfmt --to=iec 2>/dev/null || stat -f %z "$file" 2>/dev/null)"
        ;;

    # Audio files
    audio/*)
        if command -v mediainfo > /dev/null; then
            mediainfo "$file"
        elif command -v exiftool > /dev/null;
            exiftool "$file"
        else
            missing_tool_message "mediainfo or exiftool"
            file --brief --dereference "$file"
        fi
        echo -e "\n\033[1;34mFile:\033[0m $file | \033[1;33mType:\033[0m $mime | \033[1;32mSize:\033[0m $(stat -c %s "$file" 2>/dev/null | numfmt --to=iec 2>/dev/null || stat -f %z "$file" 2>/dev/null)"
        ;;

    # EPUB files
    application/epub+zip)
        if command -v epubthumbnailer > /dev/null; then
            epubthumbnailer "$file" "$thumb" 
            if [ -f "$thumb" ]; then
                if command -v chafa > /dev/null; then
                    chafa -s "${width}x${height}" --animate off "$thumb"
                elif command -v img2txt > /dev/null;
                    img2txt -W "$width" -H "$height" "$thumb"
                elif command -v catimg > /dev/null;
                    catimg -w "$((width * 2))" -H "$height" "$thumb"
                else
                    echo "Generated EPUB thumbnail, but no image previewer."
                fi
            else
                echo "Failed to generate EPUB thumbnail for $file."
            fi 
        elif command -v pandoc > /dev/null; then
            pandoc -f epub -t plain --standalone "$file" | head -n 200
        else
            missing_tool_message "epubthumbnailer or pandoc"
        fi
        echo -e "\n\033[1;34mFile:\033[0m $file | \033[1;33mType:\033[0m $mime | \033[1;32mSize:\033[0m $(stat -c %s "$file" 2>/dev/null | numfmt --to=iec 2>/dev/null || stat -f %z "$file" 2>/dev/null)"
        ;;

    # Archives
    application/zip | application/x-tar | application/x-rar | application/x-7z-compressed | application/gzip | application/x-bzip2 | application/x-xz)
        if command -v lsar > /dev/null; then
            lsar -l "$file"
        elif command -v bsdtar > /dev/null; then # bsdtar can handle many formats
            bsdtar -tf "$file"
        else # Fallback to individual tools
            case "$ext" in
                zip) unzip -l "$file" ;; 
                tar) tar tf "$file" ;; 
                gz) tar tzf "$file" ;; 
                bz2) tar tjf "$file" ;; 
                xz) tar tJf "$file" ;; # J for xz
                rar) unrar l "$file" ;; 
                7z) 7z l "$file" ;; 
                *) missing_tool_message "lsar or bsdtar (or specific tool for .$ext)";;
            esac
        fi | head -n 200 # Limit output lines for archives
        echo -e "\n\033[1;34mFile:\033[0m $file | \033[1;33mType:\033[0m $mime | \033[1;32mSize:\033[0m $(stat -c %s "$file" 2>/dev/null | numfmt --to=iec 2>/dev/null || stat -f %z "$file" 2>/dev/null)"
        ;;

    # Fallback for any other file type
    *)
        if command -v file > /dev/null; then
            file --brief --dereference "$file"
        else
            echo "File type: $mime (no preview available)"
        fi
        echo -e "\n\033[1;34mFile:\033[0m $file | \033[1;33mType:\033[0m $mime | \033[1;32mSize:\033[0m $(stat -c %s "$file" 2>/dev/null | numfmt --to=iec 2>/dev/null || stat -f %z "$file" 2>/dev/null)"
        ;;
esac

exit 0 