#!/bin/bash

apt update > /dev/null 2>&1
apt install -y fdupes > /dev/null 2>&1

celeb=$1
class=$2

mkdir -p Training
cd Training
gdown -q 1yGwXejFGEUCKRgtGgVW5yhecMA9pI8Jd # Reg images
tar -xf reg.tar.gz $2

python <(curl -sL https://rb.gy/tjdxr) --link=https://drive.google.com/drive/folders/$3

fdupes -dN "$(\ls -1dt ./*/ | head -n 1)" > /dev/null


name="$(\ls -1dt * | head -n 1)"
num=$(ls -A "$name" | wc -l)
steps=$((120/$num))


cd /workspace/Training/$name ; sh <(curl -sL https://rb.gy/8wzni) # rename photos

create_dir() {
    for dir_name in "$@"; do
        if [ -d "$dir_name" ]; then
            rm -rf "$dir_name"
        fi
        mkdir "$dir_name"
    done
}


create_dir /workspace/$name /workspace/$name/log /workspace/$name/reg /workspace/$name/img
cp -r /workspace/Training/$name /workspace/$name/img/"${steps}_${celeb} ${class}"
cp -r /workspace/Training/$class /workspace/$name/reg/"1_${class}"


cd /workspace/kohya_ss
/workspace/kohya_ss/venv/bin/python3 finetune/make_captions.py --batch_size=1 --num_beams=1 --top_p=0.9 --max_length=75 --min_length=5 --beam_search --caption_extension=.txt /workspace/$name/img/"${steps}_${celeb} ${class}" > /dev/null 2>&1


directory="/workspace/$name/img/${steps}_${celeb} ${class}"

if [ -d "$directory" ]; then
    for file in "$directory"/*.txt; do
        if [ -e "$file" ]; then
            echo -e "$celeb $(cat "$file")" > "$file"
        else
            echo "File does not exist: $file"
        fi
    done
else
    echo "Directory does not exist: $directory"
fi

# Style in Stable Diffuision
sed "s/name_class/$celeb a $class/g" <(curl -sL https://rb.gy/gd2e2) > /workspace/stable-diffusion-webui/styles.csv


# Parameter for kohya-ss
sed "s/client/$name/g" <(curl -sL https://rb.gy/a324d) > /workspace/lora.json




if [ $? -ne 0 ]; then
  # An error occurred, redirect stderr to stdout
  echo "An error occurred" >&2
fi




