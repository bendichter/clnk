#!/usr/bin/env node
/**
 * Populate Supabase with mock restaurant and dish data
 * Run with: node scripts/populate-supabase.js
 */

require('dotenv').config();

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://kgfdwcsydjzioqdlovjy.supabase.co';
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_SERVICE_KEY) {
    console.error('Missing SUPABASE_SERVICE_ROLE_KEY in .env');
    process.exit(1);
}

const headers = {
    'apikey': SUPABASE_SERVICE_KEY,
    'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
    'Content-Type': 'application/json',
    'Prefer': 'return=minimal'
};

// Restaurant data from MockData.swift
const restaurants = [
    {
        id: 'aaaa0000-0000-0000-0000-000000000001',
        name: 'Pupatella',
        address: '5104 Wilson Blvd',
        locality: 'Arlington',
        region: 'VA',
        postcode: '22203',
        country: 'US',
        formatted_address: '5104 Wilson Blvd, Arlington, VA 22203',
        latitude: 38.8800,
        longitude: -77.1150,
        cuisine_type: 'Pizza',
        is_user_submitted: false
    },
    {
        id: 'aaaa0000-0000-0000-0000-000000000002',
        name: 'Vermilion',
        address: '1120 King St',
        locality: 'Alexandria',
        region: 'VA',
        postcode: '22314',
        country: 'US',
        formatted_address: '1120 King St, Alexandria, VA 22314',
        latitude: 38.8048,
        longitude: -77.0428,
        cuisine_type: 'American',
        is_user_submitted: false
    },
    {
        id: 'aaaa0000-0000-0000-0000-000000000003',
        name: 'Mai Thai',
        address: '6 King St',
        locality: 'Alexandria',
        region: 'VA',
        postcode: '22314',
        country: 'US',
        formatted_address: '6 King St, Alexandria, VA 22314',
        latitude: 38.8027,
        longitude: -77.0419,
        cuisine_type: 'Thai',
        is_user_submitted: false
    },
    {
        id: 'aaaa0000-0000-0000-0000-000000000004',
        name: 'Pho 75',
        address: '1721 Wilson Blvd',
        locality: 'Arlington',
        region: 'VA',
        postcode: '22209',
        country: 'US',
        formatted_address: '1721 Wilson Blvd, Arlington, VA 22209',
        latitude: 38.8950,
        longitude: -77.0750,
        cuisine_type: 'Vietnamese',
        is_user_submitted: false
    },
    {
        id: 'aaaa0000-0000-0000-0000-000000000005',
        name: 'The Majestic',
        address: '911 King St',
        locality: 'Alexandria',
        region: 'VA',
        postcode: '22314',
        country: 'US',
        formatted_address: '911 King St, Alexandria, VA 22314',
        latitude: 38.8050,
        longitude: -77.0440,
        cuisine_type: 'American',
        is_user_submitted: false
    },
    {
        id: 'aaaa0000-0000-0000-0000-000000000006',
        name: 'Cava Mezze',
        address: '527 King St',
        locality: 'Alexandria',
        region: 'VA',
        postcode: '22314',
        country: 'US',
        formatted_address: '527 King St, Alexandria, VA 22314',
        latitude: 38.8040,
        longitude: -77.0450,
        cuisine_type: 'Greek',
        is_user_submitted: false
    },
    {
        id: 'aaaa0000-0000-0000-0000-000000000007',
        name: 'Sushi Zen',
        address: '2457 18th St NW',
        locality: 'Washington',
        region: 'DC',
        postcode: '20009',
        country: 'US',
        formatted_address: '2457 18th St NW, Washington, DC 20009',
        latitude: 38.9200,
        longitude: -77.0420,
        cuisine_type: 'Sushi',
        is_user_submitted: false
    },
    {
        id: 'aaaa0000-0000-0000-0000-000000000008',
        name: 'Taco Bamba',
        address: '2190 Pimmit Dr',
        locality: 'Falls Church',
        region: 'VA',
        postcode: '22043',
        country: 'US',
        formatted_address: '2190 Pimmit Dr, Falls Church, VA 22043',
        latitude: 38.9020,
        longitude: -77.1890,
        cuisine_type: 'Mexican',
        is_user_submitted: false
    },
    {
        id: 'aaaa0000-0000-0000-0000-000000000009',
        name: 'Founding Farmers',
        address: '1924 Pennsylvania Ave NW',
        locality: 'Washington',
        region: 'DC',
        postcode: '20006',
        country: 'US',
        formatted_address: '1924 Pennsylvania Ave NW, Washington, DC 20006',
        latitude: 38.9002,
        longitude: -77.0421,
        cuisine_type: 'American',
        is_user_submitted: false
    },
    {
        id: 'aaaa0000-0000-0000-0000-000000000010',
        name: 'Joe\'s Seafood',
        address: '750 15th St NW',
        locality: 'Washington',
        region: 'DC',
        postcode: '20005',
        country: 'US',
        formatted_address: '750 15th St NW, Washington, DC 20005',
        latitude: 38.9010,
        longitude: -77.0330,
        cuisine_type: 'Seafood',
        is_user_submitted: false
    },
    {
        id: 'aaaa0000-0000-0000-0000-000000000011',
        name: 'Le Diplomate',
        address: '1601 14th St NW',
        locality: 'Washington',
        region: 'DC',
        postcode: '20009',
        country: 'US',
        formatted_address: '1601 14th St NW, Washington, DC 20009',
        latitude: 38.9120,
        longitude: -77.0320,
        cuisine_type: 'French',
        is_user_submitted: false
    },
    {
        id: 'aaaa0000-0000-0000-0000-000000000012',
        name: 'Rasika',
        address: '633 D St NW',
        locality: 'Washington',
        region: 'DC',
        postcode: '20004',
        country: 'US',
        formatted_address: '633 D St NW, Washington, DC 20004',
        latitude: 38.8952,
        longitude: -77.0220,
        cuisine_type: 'Indian',
        is_user_submitted: false
    },
    {
        id: 'aaaa0000-0000-0000-0000-000000000013',
        name: 'Ben\'s Chili Bowl',
        address: '1213 U St NW',
        locality: 'Washington',
        region: 'DC',
        postcode: '20009',
        country: 'US',
        formatted_address: '1213 U St NW, Washington, DC 20009',
        latitude: 38.9170,
        longitude: -77.0285,
        cuisine_type: 'American',
        is_user_submitted: false
    },
    {
        id: 'bbbb0000-0000-0000-0000-000000000014',
        name: 'Taqueria Habanero',
        address: '3710 14th St NW',
        locality: 'Washington',
        region: 'DC',
        postcode: '20010',
        country: 'US',
        formatted_address: '3710 14th St NW, Washington, DC 20010',
        latitude: 38.9328,
        longitude: -77.0325,
        cuisine_type: 'Mexican',
        is_user_submitted: false
    },
    {
        id: 'cccc0000-0000-0000-0000-000000000015',
        name: 'Sushi Ogawa',
        address: '2100 Connecticut Ave NW',
        locality: 'Washington',
        region: 'DC',
        postcode: '20008',
        country: 'US',
        formatted_address: '2100 Connecticut Ave NW, Washington, DC 20008',
        latitude: 38.9148,
        longitude: -77.0476,
        cuisine_type: 'Sushi',
        is_user_submitted: false
    }
];

// Dish data - sample dishes for each restaurant
const dishes = [
    // Pupatella (aaaa0000-0000-0000-0000-000000000001)
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000001', name: 'Margherita DOC', description: 'San Marzano tomato, fresh mozzarella di bufala, basil, extra virgin olive oil', price: 20.59, category: 'Pizza', dietary_tags: ['vegetarian'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000001', name: 'Diavola', description: 'San Marzano tomato, fior di latte, spicy salame, Calabrian chili oil', price: 21.75, category: 'Pizza', dietary_tags: ['spicy'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000001', name: 'Pepperoni Pizza', description: 'San Marzano tomato, fior di latte, house-cured pepperoni', price: 19.38, category: 'Pizza', dietary_tags: [] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000001', name: 'Prosciutto Arugula', description: 'San Marzano tomato, fior di latte, prosciutto di Parma, arugula, Parmigiano', price: 21.88, category: 'Pizza', dietary_tags: [] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000001', name: 'Burrata Pizza', description: 'San Marzano tomato, fresh burrata, basil, extra virgin olive oil', price: 23.75, category: 'Pizza', dietary_tags: ['vegetarian'] },
    
    // Vermilion (aaaa0000-0000-0000-0000-000000000002)
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000002', name: 'Crispy Brussels Sprouts', description: 'Flash-fried with balsamic glaze and shaved Parmesan', price: 14.00, category: 'Appetizers', dietary_tags: ['vegetarian', 'gluten-free'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000002', name: 'Pan-Seared Scallops', description: 'With cauliflower puree, brown butter, and capers', price: 36.00, category: 'Main Courses', dietary_tags: ['gluten-free'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000002', name: 'Braised Short Rib', description: 'Red wine braised with root vegetables and horseradish cream', price: 38.00, category: 'Main Courses', dietary_tags: ['gluten-free'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000002', name: 'Grilled Salmon', description: 'With lemon herb butter, asparagus, and fingerling potatoes', price: 32.00, category: 'Main Courses', dietary_tags: ['gluten-free'] },
    
    // Mai Thai (aaaa0000-0000-0000-0000-000000000003)
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000003', name: 'Pad Thai', description: 'Rice noodles with shrimp, egg, bean sprouts, peanuts', price: 16.95, category: 'Main Courses', dietary_tags: [] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000003', name: 'Green Curry', description: 'Coconut curry with Thai basil, bamboo, bell peppers', price: 17.95, category: 'Main Courses', dietary_tags: ['spicy', 'gluten-free'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000003', name: 'Tom Yum Soup', description: 'Hot and sour soup with shrimp, mushrooms, lemongrass', price: 8.95, category: 'Soups', dietary_tags: ['spicy', 'gluten-free'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000003', name: 'Mango Sticky Rice', description: 'Sweet sticky rice with fresh mango and coconut cream', price: 9.95, category: 'Desserts', dietary_tags: ['vegetarian', 'vegan', 'gluten-free'] },
    
    // Pho 75 (aaaa0000-0000-0000-0000-000000000004)
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000004', name: 'Pho Tai', description: 'Rice noodle soup with rare beef slices', price: 12.95, category: 'Soups', dietary_tags: ['gluten-free'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000004', name: 'Pho Dac Biet', description: 'House special with rare beef, brisket, tripe, tendon', price: 14.95, category: 'Soups', dietary_tags: ['gluten-free'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000004', name: 'Bun Bo Hue', description: 'Spicy beef noodle soup from Hue', price: 13.95, category: 'Soups', dietary_tags: ['spicy', 'gluten-free'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000004', name: 'Spring Rolls', description: 'Fresh shrimp and pork rolls with peanut sauce', price: 6.95, category: 'Appetizers', dietary_tags: ['gluten-free'] },
    
    // The Majestic (aaaa0000-0000-0000-0000-000000000005)
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000005', name: 'Jumbo Lump Crab Cake', description: 'Maryland-style with remoulade and coleslaw', price: 28.00, category: 'Main Courses', dietary_tags: [] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000005', name: 'Fried Chicken', description: 'Buttermilk brined with honey hot sauce', price: 24.00, category: 'Main Courses', dietary_tags: [] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000005', name: 'Shrimp & Grits', description: 'With andouille sausage and tasso ham gravy', price: 26.00, category: 'Main Courses', dietary_tags: [] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000005', name: 'Deviled Eggs', description: 'With bacon and chives', price: 10.00, category: 'Appetizers', dietary_tags: ['gluten-free'] },
    
    // Cava Mezze (aaaa0000-0000-0000-0000-000000000006)
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000006', name: 'Lamb Chops', description: 'Grilled with tzatziki and Greek salad', price: 34.00, category: 'Main Courses', dietary_tags: ['gluten-free'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000006', name: 'Spanakopita', description: 'Spinach and feta phyllo triangles', price: 12.00, category: 'Appetizers', dietary_tags: ['vegetarian'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000006', name: 'Hummus', description: 'Classic chickpea dip with warm pita', price: 10.00, category: 'Appetizers', dietary_tags: ['vegetarian', 'vegan'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000006', name: 'Grilled Octopus', description: 'With olive oil, lemon, and oregano', price: 18.00, category: 'Appetizers', dietary_tags: ['gluten-free'] },
    
    // Sushi Zen (aaaa0000-0000-0000-0000-000000000007)
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000007', name: 'Dragon Roll', description: 'Shrimp tempura, eel, avocado, eel sauce', price: 18.00, category: 'Sushi & Sashimi', dietary_tags: [] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000007', name: 'Salmon Sashimi', description: 'Fresh Atlantic salmon, 8 pieces', price: 16.00, category: 'Sushi & Sashimi', dietary_tags: ['gluten-free'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000007', name: 'Spicy Tuna Roll', description: 'Fresh tuna with spicy mayo and scallions', price: 14.00, category: 'Sushi & Sashimi', dietary_tags: ['spicy'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000007', name: 'Edamame', description: 'Steamed soybeans with sea salt', price: 6.00, category: 'Appetizers', dietary_tags: ['vegetarian', 'vegan', 'gluten-free'] },
    
    // Taco Bamba (aaaa0000-0000-0000-0000-000000000008)
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000008', name: 'Al Pastor Tacos', description: 'Marinated pork with pineapple, onion, cilantro', price: 4.50, category: 'Tacos & Burritos', dietary_tags: ['gluten-free'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000008', name: 'Carnitas Tacos', description: 'Slow-braised pork with salsa verde', price: 4.50, category: 'Tacos & Burritos', dietary_tags: ['gluten-free'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000008', name: 'Birria Tacos', description: 'Braised beef with consomé for dipping', price: 5.50, category: 'Tacos & Burritos', dietary_tags: ['gluten-free'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000008', name: 'Guacamole', description: 'Fresh made with chips', price: 8.00, category: 'Appetizers', dietary_tags: ['vegetarian', 'vegan', 'gluten-free'] },
    
    // Founding Farmers (aaaa0000-0000-0000-0000-000000000009)
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000009', name: 'Yankee Pot Roast', description: 'Slow-braised beef with root vegetables', price: 28.00, category: 'Main Courses', dietary_tags: ['gluten-free'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000009', name: 'Fried Green Tomatoes', description: 'With pimento cheese and bacon jam', price: 14.00, category: 'Appetizers', dietary_tags: ['vegetarian'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000009', name: 'Cast Iron Chicken', description: 'With mashed potatoes and gravy', price: 24.00, category: 'Main Courses', dietary_tags: [] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000009', name: 'Apple Pie', description: 'Warm with vanilla ice cream', price: 10.00, category: 'Desserts', dietary_tags: ['vegetarian'] },
    
    // Joe's Seafood (aaaa0000-0000-0000-0000-000000000010)
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000010', name: 'Stone Crab Claws', description: 'Chilled with mustard sauce', price: 45.00, category: 'Seafood', dietary_tags: ['gluten-free'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000010', name: 'Lobster Tail', description: 'Butter poached with drawn butter', price: 55.00, category: 'Seafood', dietary_tags: ['gluten-free'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000010', name: 'Oysters on the Half Shell', description: 'East coast selection, half dozen', price: 24.00, category: 'Seafood', dietary_tags: ['gluten-free'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000010', name: 'Key Lime Pie', description: 'House specialty with whipped cream', price: 12.00, category: 'Desserts', dietary_tags: ['vegetarian'] },
    
    // Le Diplomate (aaaa0000-0000-0000-0000-000000000011)
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000011', name: 'Steak Frites', description: 'Hanger steak with herb butter and fries', price: 34.00, category: 'Main Courses', dietary_tags: ['gluten-free'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000011', name: 'French Onion Soup', description: 'Caramelized onions with Gruyère crouton', price: 14.00, category: 'Soups', dietary_tags: ['vegetarian'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000011', name: 'Croque Monsieur', description: 'Ham and Gruyère with béchamel', price: 18.00, category: 'Main Courses', dietary_tags: [] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000011', name: 'Crème Brûlée', description: 'Classic vanilla custard', price: 12.00, category: 'Desserts', dietary_tags: ['vegetarian', 'gluten-free'] },
    
    // Rasika (aaaa0000-0000-0000-0000-000000000012)
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000012', name: 'Palak Chaat', description: 'Crispy spinach with yogurt and tamarind', price: 14.00, category: 'Appetizers', dietary_tags: ['vegetarian', 'gluten-free'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000012', name: 'Lamb Rogan Josh', description: 'Kashmiri braised lamb in aromatic gravy', price: 32.00, category: 'Main Courses', dietary_tags: ['gluten-free'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000012', name: 'Butter Chicken', description: 'Tandoori chicken in tomato cream sauce', price: 28.00, category: 'Main Courses', dietary_tags: ['gluten-free'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000012', name: 'Garlic Naan', description: 'Fresh-baked with garlic and butter', price: 6.00, category: 'Sides', dietary_tags: ['vegetarian'] },
    
    // Ben's Chili Bowl (aaaa0000-0000-0000-0000-000000000013)
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000013', name: 'Half Smoke', description: 'DC\'s signature smoked sausage with chili', price: 8.95, category: 'Main Courses', dietary_tags: [] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000013', name: 'Chili Dog', description: 'All-beef hot dog with Ben\'s famous chili', price: 7.95, category: 'Main Courses', dietary_tags: [] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000013', name: 'Chili Cheese Fries', description: 'Crispy fries with chili and cheese', price: 6.95, category: 'Sides', dietary_tags: ['vegetarian'] },
    { restaurant_id: 'aaaa0000-0000-0000-0000-000000000013', name: 'Veggie Burger', description: 'House-made patty with all the fixings', price: 9.95, category: 'Main Courses', dietary_tags: ['vegetarian'] },
    
    // Taqueria Habanero (bbbb0000-0000-0000-0000-000000000014)
    { restaurant_id: 'bbbb0000-0000-0000-0000-000000000014', name: 'Tacos de Lengua', description: 'Beef tongue with onion and cilantro', price: 4.00, category: 'Tacos & Burritos', dietary_tags: ['gluten-free'] },
    { restaurant_id: 'bbbb0000-0000-0000-0000-000000000014', name: 'Pupusas', description: 'Salvadoran stuffed corn cakes with curtido', price: 3.50, category: 'Appetizers', dietary_tags: ['vegetarian', 'gluten-free'] },
    { restaurant_id: 'bbbb0000-0000-0000-0000-000000000014', name: 'Torta Cubana', description: 'Mexican sandwich with multiple meats', price: 12.00, category: 'Main Courses', dietary_tags: [] },
    { restaurant_id: 'bbbb0000-0000-0000-0000-000000000014', name: 'Horchata', description: 'Traditional rice drink with cinnamon', price: 4.00, category: 'Drinks', dietary_tags: ['vegetarian', 'vegan', 'gluten-free'] },
    
    // Sushi Ogawa (cccc0000-0000-0000-0000-000000000015)
    { restaurant_id: 'cccc0000-0000-0000-0000-000000000015', name: 'Omakase', description: 'Chef\'s choice 12-piece tasting', price: 150.00, category: 'Sushi & Sashimi', dietary_tags: ['gluten-free'] },
    { restaurant_id: 'cccc0000-0000-0000-0000-000000000015', name: 'Otoro', description: 'Fatty tuna belly, 2 pieces', price: 28.00, category: 'Sushi & Sashimi', dietary_tags: ['gluten-free'] },
    { restaurant_id: 'cccc0000-0000-0000-0000-000000000015', name: 'Uni', description: 'Fresh sea urchin from Hokkaido', price: 24.00, category: 'Sushi & Sashimi', dietary_tags: ['gluten-free'] },
    { restaurant_id: 'cccc0000-0000-0000-0000-000000000015', name: 'Miso Soup', description: 'Traditional with tofu and wakame', price: 5.00, category: 'Soups', dietary_tags: ['vegetarian', 'gluten-free'] }
];

async function insertData(table, data) {
    const response = await fetch(`${SUPABASE_URL}/rest/v1/${table}`, {
        method: 'POST',
        headers,
        body: JSON.stringify(data)
    });
    
    if (!response.ok) {
        const error = await response.text();
        throw new Error(`Failed to insert into ${table}: ${response.status} ${error}`);
    }
    return response;
}

async function main() {
    console.log('🍽️  Populating BiteVue Supabase database...\n');
    
    try {
        // Insert restaurants
        console.log(`📍 Inserting ${restaurants.length} restaurants...`);
        await insertData('restaurants', restaurants);
        console.log('✅ Restaurants inserted successfully!\n');
        
        // Insert dishes
        console.log(`🍕 Inserting ${dishes.length} dishes...`);
        await insertData('dishes', dishes);
        console.log('✅ Dishes inserted successfully!\n');
        
        console.log('🎉 Database populated successfully!');
        console.log(`   - ${restaurants.length} restaurants`);
        console.log(`   - ${dishes.length} dishes`);
    } catch (error) {
        console.error('❌ Error:', error.message);
        process.exit(1);
    }
}

main();
