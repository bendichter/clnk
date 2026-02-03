#!/bin/bash
# Script to download food images from loremflickr

ASSETS_DIR="/Users/bendichter/.openclaw/workspace/BiteVue/BiteVue/Assets.xcassets/DishImages"

download_image() {
    local name=$1
    local search=$2
    local output="${ASSETS_DIR}/${name}.imageset/${name}.jpg"
    
    echo -n "Downloading: $name ... "
    
    curl -L -s "https://loremflickr.com/800/800/${search}" -o "$output"
    
    # Check if it's a valid image
    file_type=$(file -b "$output" 2>/dev/null | head -1)
    if [[ "$file_type" == *"JPEG"* ]] || [[ "$file_type" == *"image"* ]]; then
        echo "✓"
        return 0
    else
        echo "✗ ($file_type)"
        return 1
    fi
}

echo "=== Downloading Italian Dishes ==="
download_image "margherita_pizza" "pizza,margherita"
sleep 0.5
download_image "spaghetti_carbonara" "carbonara,pasta"
sleep 0.5
download_image "osso_buco" "ossobuco,veal"
sleep 0.5
download_image "burrata_caprese" "caprese,mozzarella"
sleep 0.5
download_image "fettuccine_alfredo" "fettuccine,pasta"
sleep 0.5
download_image "chicken_parmigiana" "parmigiana,chicken"
sleep 0.5
download_image "tiramisu" "tiramisu,dessert"
sleep 0.5
download_image "bruschetta" "bruschetta,appetizer"
sleep 0.5
download_image "risotto_funghi" "risotto,mushroom"
sleep 0.5
download_image "cannoli" "cannoli,italian"
sleep 0.5

echo ""
echo "=== Downloading Japanese Dishes ==="
download_image "omakase_sushi" "sushi,omakase"
sleep 0.5
download_image "dragon_roll" "sushi,roll"
sleep 0.5
download_image "tonkotsu_ramen" "ramen,japanese"
sleep 0.5
download_image "wagyu_tataki" "wagyu,beef"
sleep 0.5
download_image "spicy_tuna_roll" "sushi,tuna"
sleep 0.5
download_image "chicken_katsu" "katsu,tonkatsu"
sleep 0.5
download_image "edamame" "edamame,soybeans"
sleep 0.5
download_image "miso_soup" "miso,soup"
sleep 0.5
download_image "salmon_sashimi" "sashimi,salmon"
sleep 0.5
download_image "matcha_ice_cream" "matcha,icecream"
sleep 0.5
download_image "gyoza" "gyoza,dumplings"
sleep 0.5
download_image "unagi_don" "unagi,eel"
sleep 0.5

echo ""
echo "=== Downloading Mexican Dishes ==="
download_image "carne_asada_tacos" "tacos,carneasada"
sleep 0.5
download_image "guacamole" "guacamole,avocado"
sleep 0.5
download_image "burrito" "burrito,mexican"
sleep 0.5
download_image "chicken_enchiladas" "enchiladas,mexican"
sleep 0.5
download_image "queso_fundido" "queso,cheese"
sleep 0.5
download_image "fish_tacos" "fishtacos,baja"
sleep 0.5
download_image "pozole" "pozole,soup"
sleep 0.5
download_image "churros" "churros,dessert"
sleep 0.5
download_image "elote" "elote,corn"
sleep 0.5
download_image "horchata" "horchata,drink"
sleep 0.5

echo ""
echo "=== Downloading Thai Dishes ==="
download_image "pad_thai" "padthai,noodles"
sleep 0.5
download_image "green_curry" "greencurry,thai"
sleep 0.5
download_image "tom_yum_soup" "tomyum,soup"
sleep 0.5
download_image "mango_sticky_rice" "mango,stickyrice"
sleep 0.5
download_image "thai_spring_rolls" "springrolls,thai"
sleep 0.5
download_image "massaman_curry" "massaman,curry"
sleep 0.5
download_image "papaya_salad" "papayasalad,somtam"
sleep 0.5
download_image "basil_chicken" "basil,chicken"
sleep 0.5
download_image "satay_skewers" "satay,skewers"
sleep 0.5
download_image "thai_iced_tea" "thaitea,icedtea"
sleep 0.5

echo ""
echo "=== Downloading American Dishes ==="
download_image "classic_cheeseburger" "cheeseburger,burger"
sleep 0.5
download_image "bbq_bacon_burger" "bacon,burger"
sleep 0.5
download_image "loaded_fries" "fries,loaded"
sleep 0.5
download_image "buffalo_wings" "wings,buffalo"
sleep 0.5
download_image "mac_and_cheese" "macaroni,cheese"
sleep 0.5
download_image "philly_cheesesteak" "cheesesteak,sandwich"
sleep 0.5
download_image "caesar_salad" "caesar,salad"
sleep 0.5
download_image "apple_pie" "applepie,dessert"
sleep 0.5
download_image "chocolate_shake" "milkshake,chocolate"
sleep 0.5
download_image "onion_rings" "onionrings,fried"
sleep 0.5

echo ""
echo "=== Downloading Indian Dishes ==="
download_image "butter_chicken" "butterchicken,curry"
sleep 0.5
download_image "lamb_biryani" "biryani,rice"
sleep 0.5
download_image "palak_paneer" "palakpaneer,spinach"
sleep 0.5
download_image "samosas" "samosa,indian"
sleep 0.5
download_image "garlic_naan" "naan,bread"
sleep 0.5
download_image "tikka_masala" "tikkamasala,curry"
sleep 0.5
download_image "mango_lassi" "lassi,mango"
sleep 0.5
download_image "tandoori_chicken" "tandoori,chicken"
sleep 0.5
download_image "dal_makhani" "dal,lentils"
sleep 0.5
download_image "chana_masala" "chana,chickpea"
sleep 0.5

echo ""
echo "=== Downloading French Dishes ==="
download_image "coq_au_vin" "coqauvin,chicken"
sleep 0.5
download_image "beef_bourguignon" "bourguignon,beef"
sleep 0.5
download_image "french_onion_soup" "onionsoup,french"
sleep 0.5
download_image "creme_brulee" "cremebrulee,dessert"
sleep 0.5
download_image "escargot" "escargot,snails"
sleep 0.5
download_image "duck_confit" "duck,confit"
sleep 0.5
download_image "croissants" "croissant,pastry"
sleep 0.5
download_image "salade_nicoise" "nicoise,salad"
sleep 0.5
download_image "chocolate_souffle" "souffle,chocolate"
sleep 0.5
download_image "ratatouille" "ratatouille,vegetables"
sleep 0.5

echo ""
echo "=== Downloading Korean Dishes ==="
download_image "korean_bbq" "koreanbbq,bulgogi"
sleep 0.5
download_image "bibimbap" "bibimbap,korean"
sleep 0.5
download_image "kimchi_jjigae" "kimchi,stew"
sleep 0.5
download_image "korean_fried_chicken" "friedchicken,korean"
sleep 0.5
download_image "japchae" "japchae,noodles"
sleep 0.5
download_image "pajeon" "pajeon,pancake"
sleep 0.5
download_image "tteokbokki" "tteokbokki,ricecake"
sleep 0.5
download_image "samgyeopsal" "samgyeopsal,porkbelly"
sleep 0.5
download_image "mandu" "mandu,dumplings"
sleep 0.5
download_image "bingsu" "bingsu,shaved"
sleep 0.5

echo ""
echo "=== Verification ==="
failed=0
total=0
for dir in "$ASSETS_DIR"/*.imageset; do
    name=$(basename "$dir" .imageset)
    img="$dir/${name}.jpg"
    total=$((total + 1))
    if [[ -f "$img" ]]; then
        ftype=$(file -b "$img" | head -1)
        if [[ "$ftype" != *"JPEG"* ]] && [[ "$ftype" != *"image"* ]]; then
            echo "✗ Invalid: $name"
            failed=$((failed + 1))
        fi
    else
        echo "✗ Missing: $name"
        failed=$((failed + 1))
    fi
done

echo ""
echo "Total: $total, Failed: $failed, Success: $((total - failed))"
