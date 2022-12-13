 # Web Scraper
 
echo "Welcome $(whoami). Please choose an option. The path is $PWD"
d=$(date +%Y-%m-%d)
echo "Date: $d"
echo "Enter one of the following option or press CTRL-D to exit"
echo ""
echo "L - Scrape links from an URL"
echo "I - Download Images from an URL"
echo "E - Enter your own search query"
echo "Q - Quit the program"


echo "Choose an option"
read op
 
function get_base_url() {
    baseURL=`echo $URL | grep -Eo  "[^/]*//[^/]*"`
    # echo $baseURL;
}

function dump_webpage() {
    echo " "
    echo "Searching For URL \"$URL\" : "
    curl -o $preSearchHtml $URL;
    echo "Got Response!!!"
}

function select_img_tags() {
    cat $preSearchHtml | grep "<img.*src=\""  | sed -n 's/.*src="\([^"]*\).*/\1/p' | sort | uniq > $imgsURL;
}

function select_links() {
    cat $preSearchHtml | grep "<a.*href=\""  | sed -n 's/.*href="\([^"]*\).*/\1/p' | sort | uniq > $anchorURL;
    sed 's/ \+/,/g' $anchorURL > $dir/links.csv
}

function downloadImgs() {
    mkdir $dir/imgs;
    count=1;
    maxURL=`wc -l $imgsURL | awk '{ print $1 }'`;
    while read p; do
        if echo "$p" | grep "^/"
        then
            # "relative url"
            img_url=$baseURL$p
            echo img_url | grep -i ".[a-z]*$"
            # echo $img_url
        else
            img_url=$p
            # echo "correct url"
        fi
        
        imgExtension=`echo $img_url | grep -oi "\.[a-z]*$"`

        if [ -z "$imgExtension" ]
        then
            filename=file$count.jpeg
        else
            filename=file$count$imgExtension
        fi
        # echo $img_url
        curl -s $img_url > $dir/imgs/$filename;
        echo "> Downloading $count Image out of $maxURL"
        count=`echo $count + 1 | bc -l`
   	done < $imgsURL
}


if [ "$op" = "L" ] || [ "$op" = "l" ]
then

	echo "Enter the URL";
 	read URL;

 	echo "Enter the dir name";
 	read dir;
 	
 	if [ -d "$dir" ]; then
	    rm -r $dir
	fi
 	
 	mkdir $dir

	preSearchHtml="$dir/PRE_SEARCH_HTML.txt"
	#imgsURL="$dir/IMAGE_URL.txt"
	anchorURL="$dir/ANCHOR_TAGS.txt"

	touch $preSearchHtml
	
	get_base_url;
	dump_webpage;
	select_links;
	
	cat $dir/links.csv
	
	echo "Done"
	
	read -p "Press enter to continue"
	
	clear 
	
	bash main.sh



elif [ "$op" = "I" ] || [ "$op" = "i" ]
then 
	echo "Enter the URL";
 	read URL;

 	echo "Enter the dir name";
 	read dir;
 	
 	if [ -d "$dir" ]; then
	    rm -r $dir
	fi
 	
 	mkdir $dir

	#wget -nd-r -P /$dir -A jpeg,jpg,bmp,gif,png $URL	
	
	wget -nd -H -p -A jpg,jpeg,png,gif -e robots=off $URL
	

	mv $PWD/*.{png,svg,gif,jpg,jpeg} $dir
	
	
	
	ls /$PWD/$dir
	
	echo "Done"
	
	read -p "Press enter to continue"
	
	clear 
	
	bash main.sh
	
	

elif [ "$op" = "e" ] || [ "$op" = "E" ]
then 

	clear

	echo "Enter your query"
	read query
	
	ddgr $query --json | grep "\"url\""|tr -s ' ' |cut -d ' ' -f3|tr -d "\"" > temp
	cat temp
	echo "Visiting results"
	
	#touch $PWD/temp_site
	#touch $PWD/result
	
	input="$PWD/temp"


	
	while IFS= read -r line
	do
	  
	  echo "exploring ----- $line"
	  wget -q $line -O temp_site
	  echo "Extracting -----"
	  grep -hrio "\b[a-z0-9.-]\+@[a-z0-9.-]\+\.[a-z]\{2,4\}\+\b" temp_site >> result
	  echo "done ----"
	  
	done < "$input"
	

		
	
	 
	
	

	
elif [ "$op" = "Q" ] || [ "$op" = "q" ]
then 
	echo "exiting"
	exit 0
	



elif [ "$op" != "I" ] || [ "$op" != "i" ] || [ "$op" != "L" ] || [ "$op" != "l" ] || [ "$op" != "q" ] || [ "$op" != "Q" ]
then 
	echo "Invalid number"
	
	read -p "Press enter to continue"
	
	clear 
	
	bash main.sh
	
	

	
fi


#get_base_url;
#dump_webpage;
#select_img_tags;
#downloadImgs;
