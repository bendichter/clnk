#!/bin/bash
# Script to download food images from Unsplash

ASSETS_DIR="/Users/bendichter/.openclaw/workspace/BiteVue/BiteVue/Assets.xcassets/DishImages"

download_image() {
    local name=$1
    local search=$2
    local output="${ASSETS_DIR}/${name}.imageset/${name}.jpg"
    
    echo "Downloading: $name ($search)"
    
    # Try primary search term
    curl -L -s "https://source.unsplash.com/800x800/?${search}" -o "$output"
    
    # Check if it's a valid image
    file_type=$(file -b "$output" | head -1)
    if [[ "$file_type" == *"JPEG"* ]] || [[ "$file_type" == *"image"* ]]; then
        echo "  ✓ Success: $name"
        return 0
    else
        echo "  ✗ Failed (got $file_type), retrying with fallback..."
        return 1
    fi
}

# Italian dishes
download_image "margherita_pizza" "margherita+pizza+food+italian"
download_image "spaghetti_carbonara" "spaghetti+carbonara+pasta+italian"
download_image "osso_buco" "osso+buco+veal+meat+italian"
download_image "burrata_caprese" "burrata+caprese+tomato+mozzarella"
download_image "fettuccine_alfredo" "fettuccine+alfredo+pasta+creamy"
download_image "chicken_parmigiana" "chicken+parmigiana+italian+food"
download_image "tiramisu" "tiramisu+dessert+italian+coffee"
download_image "bruschetta" "bruschetta+tomato+italian+appetizer"
download_image "risotto_funghi" "risotto+mushroom+italian+rice"
download_image "cannoli" "cannoli+italian+dessert+pastry"

# Japanese dishes
download_image "omakase_sushi" "omakase+sushi+japanese+fish"
download_image "dragon_roll" "dragon+roll+sushi+japanese"
download_image "tonkotsu_ramen" "tonkotsu+ramen+japanese+noodles"
download_image "wagyu_tataki" "wagyu+beef+tataki+japanese"
download_image "spicy_tuna_roll" "spicy+tuna+roll+sushi"
download_image "chicken_katsu" "chicken+katsu+japanese+breaded"
download_image "edamame" "edamame+soybeans+japanese+appetizer"
download_image "miso_soup" "miso+soup+japanese+tofu"
download_image "salmon_sashimi" "salmon+sashimi+japanese+raw+fish"
download_image "matcha_ice_cream" "matcha+ice+cream+green+tea"
download_image "gyoza" "gyoza+dumplings+japanese+pan+fried"
download_image "unagi_don" "unagi+don+eel+rice+japanese"

# Mexican dishes
download_image "carne_asada_tacos" "carne+asada+tacos+mexican+beef"
download_image "guacamole" "guacamole+avocado+chips+mexican"
download_image "burrito" "burrito+mexican+wrapped+tortilla"
download_image "chicken_enchiladas" "chicken+enchiladas+mexican+red+sauce"
download_image "queso_fundido" "queso+fundido+melted+cheese+mexican"
download_image "fish_tacos" "fish+tacos+baja+mexican+seafood"
download_image "pozole" "pozole+mexican+soup+hominy+pork"
download_image "churros" "churros+mexican+dessert+fried+cinnamon"
download_image "elote" "elote+mexican+street+corn+grilled"
download_image "horchata" "horchata+mexican+drink+rice+milk"

# Thai dishes
download_image "pad_thai" "pad+thai+noodles+thai+shrimp"
download_image "green_curry" "green+curry+thai+coconut+spicy"
download_image "tom_yum_soup" "tom+yum+soup+thai+spicy+shrimp"
download_image "mango_sticky_rice" "mango+sticky+rice+thai+dessert"
download_image "thai_spring_rolls" "spring+rolls+thai+crispy+appetizer"
download_image "massaman_curry" "massaman+curry+thai+beef+peanuts"
download_image "papaya_salad" "papaya+salad+thai+som+tam"
download_image "basil_chicken" "thai+basil+chicken+stir+fry"
download_image "satay_skewers" "satay+skewers+chicken+peanut+sauce"
download_image "thai_iced_tea" "thai+iced+tea+orange+creamy"

# American dishes
download_image "classic_cheeseburger" "cheeseburger+american+beef+cheese"
download_image "bbq_bacon_burger" "bbq+bacon+burger+american+gourmet"
download_image "loaded_fries" "loaded+fries+cheese+bacon+american"
download_image "buffalo_wings" "buffalo+wings+chicken+spicy+american"
download_image "mac_and_cheese" "mac+and+cheese+creamy+american"
download_image "philly_cheesesteak" "philly+cheesesteak+sandwich+beef"
download_image "caesar_salad" "caesar+salad+romaine+parmesan"
download_image "apple_pie" "apple+pie+american+dessert+crust"
download_image "chocolate_shake" "chocolate+milkshake+american+dessert"
download_image "onion_rings" "onion+rings+fried+crispy+appetizer"

# Indian dishes
download_image "butter_chicken" "butter+chicken+indian+curry+creamy"
download_image "lamb_biryani" "lamb+biryani+indian+rice+saffron"
download_image "palak_paneer" "palak+paneer+indian+spinach+cheese"
download_image "samosas" "samosas+indian+fried+pastry+appetizer"
download_image "garlic_naan" "garlic+naan+indian+bread+tandoor"
download_image "tikka_masala" "tikka+masala+indian+chicken+curry"
download_image "mango_lassi" "mango+lassi+indian+yogurt+drink"
download_image "tandoori_chicken" "tandoori+chicken+indian+grilled+red"
download_image "dal_makhani" "dal+makhani+indian+lentils+creamy"
download_image "chana_masala" "chana+masala+indian+chickpea+curry"

# French dishes
download_image "coq_au_vin" "coq+au+vin+french+chicken+wine"
download_image "beef_bourguignon" "beef+bourguignon+french+stew+wine"
download_image "french_onion_soup" "french+onion+soup+cheese+bread"
download_image "creme_brulee" "creme+brulee+french+dessert+caramel"
download_image "escargot" "escargot+french+snails+garlic+butter"
download_image "duck_confit" "duck+confit+french+crispy+leg"
download_image "croissants" "croissant+french+pastry+butter+breakfast"
download_image "salade_nicoise" "salade+nicoise+french+tuna+olives"
download_image "chocolate_souffle" "chocolate+souffle+french+dessert+fluffy"
download_image "ratatouille" "ratatouille+french+vegetables+provence"

# Korean dishes
download_image "korean_bbq" "korean+bbq+grilled+meat+bulgogi"
download_image "bibimbap" "bibimbap+korean+rice+bowl+vegetables"
download_image "kimchi_jjigae" "kimchi+jjigae+korean+stew+spicy"
download_image "korean_fried_chicken" "korean+fried+chicken+crispy+spicy"
download_image "japchae" "japchae+korean+noodles+glass+vegetables"
download_image "pajeon" "pajeon+korean+pancake+scallion+crispy"
download_image "tteokbokki" "tteokbokki+korean+rice+cakes+spicy"
download_image "samgyeopsal" "samgyeopsal+korean+pork+belly+grilled"
download_image "mandu" "mandu+korean+dumplings+steamed"
download_image "bingsu" "bingsu+korean+shaved+ice+dessert"

echo ""
echo "Download complete! Verifying all images..."
echo ""

# Verify all images
failed=0
for dir in "$ASSETS_DIR"/*.imageset; do
    name=$(basename "$dir" .imageset)
    img="$dir/${name}.jpg"
    if [[ -f "$img" ]]; then
        ftype=$(file -b "$img" | head -1)
        if [[ "$ftype" != *"JPEG"* ]] && [[ "$ftype" != *"image"* ]]; then
            echo "✗ Invalid: $name ($ftype)"
            failed=$((failed + 1))
        fi
    else
        echo "✗ Missing: $name"
        failed=$((failed + 1))
    fi
done

echo ""
echo "Verification complete. Failed: $failed"
