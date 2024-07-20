{pkgs}:
pkgs.writeShellScriptBin "extract_if_not_exists" ''
  tar_file=$1
  options=$2
  extracted_dir=$3
  if [ ! -d $extracted_dir ]; then
    echo "Extracting $tar_file to $extracted_dir with options $options"
    tar $options $tar_file
  else
    echo "Directory $extracted_dir already exists, skipping extraction"
  fi
''
