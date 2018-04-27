basefolder=`pwd`
rm -rf newcon.txt
for name in $(cat input/conferences.txt); do
  x=$(echo $name | cut -d\| -f1)
  url=$(echo $name | cut -d\| -f2)
  # using the etag instead
  md5=$(echo $name | cut -d\| -f3)
  archive="$x-proceedings.tgz"
  datadir="data/$x";
  if test $x = $url; then
      echo "No URL given for $x, skipping for now ..."
      echo "$name" >> newcon.txt
      continue
  fi
  remotemd5=$(curl -I $url | grep ETag | awk '{print $2}')
  if [[ -d $datadir ]] && [[ -e $data/dir/etag ]] && [[ $remotemd5 == $(cat $data/dir/etag) ]]; then
      echo "No change to $x; skipping";
      echo "$name" >> newcon.txt
      continue
  fi
  if [[ -z $remotemd5 ]]; then
      echo "$x not yet uploaded; skipping";
      echo "$name" >> newcon.txt
      continue;
  fi
  # echo $x $url $md5 $archive
  [[ ! -d "data/$x" ]] && mkdir -p data/$x
  cd data/$x
  rm -rf $archive etag
  wget -q -N --no-check-certificate $url -O $archive
  if [[ $? -gt 0 ]]; then
      echo "Couldn't find $x";
      cd $basefolder;
      echo "$name" >> newcon.txt
      continue
  fi
  echo "$remotemd5" > etag
  
  # # if archive already exists, compare MD5 checksum to expected value
  # [[ -f $archive ]] && chk=`md5sum $archive | awk '{ print $1 }'`
  # echo $chk

  # if [[ "$chk" != "$md5" ]]; then
  #   echo "Bad local checksum, deleting local $archive and redownloading from $url"

  #   rm $archive
  #   wget -q -N --no-check-certificate $url -O $archive
  #   if [[ $? -gt 0 ]]; then
  #       echo "Couldn't find $x";
  #       cd $basefolder;
  #       echo "$name" >> newcon.txt
  #       continue
  #   fi
  #   chk=`md5sum $archive | awk '{ print $1 }'`
  #   echo "MD5 checksum: $chk"
  #  fi

  tar -xzf $archive proceedings/order proceedings/final.tgz
  cd proceedings
  tar --exclude '*.pdf' --exclude '*gz' --exclude '*zip' -xzf final.tgz
  rm final.tgz

#  wget -N --no-check-certificate $url -O $archive
#  lastfile=$(ls -r1 *.tgz | tail -n1)
#  tar --exclude '*.pdf' --exclude '*gz' --exclude '*zip' -xzvf $lastfile proceedings/order proceedings/final.tgz 
#  tar --exclude '*.pdf' --exclude '*gz' --exclude '*zip' -xzvf proceedings/final.tgz
  cd $basefolder
  echo "$x|$url|$remotemd5" >> newcon.txt
done
