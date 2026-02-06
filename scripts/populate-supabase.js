#!/usr/bin/env node
/**
 * Populate Supabase with mock bar and cocktail data
 * Run with: node scripts/populate-supabase.js
 */

require('dotenv').config();

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://rbeuvvttiyxrdsgkrwaa.supabase.co';
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

// Venue (bar) data matching mock_data.sql
const venues = [
    {
        id: '11111111-1111-1111-1111-111111111101',
        name: 'The Velvet Room',
        description: 'Elegant speakeasy with classic cocktails and live jazz',
        address: '123 Main St, Alexandria, VA',
        latitude: 38.8048,
        longitude: -77.0469,
        drink_type: 'Classic',
        price_range: '$$$',
        image_emoji: '🥃',
        header_color: '#8B4513',
        is_featured: true
    },
    {
        id: '11111111-1111-1111-1111-111111111102',
        name: 'Copper & Oak',
        description: 'Whiskey-focused bar with 200+ bottles and craft cocktails',
        address: '456 King St, Alexandria, VA',
        latitude: 38.8051,
        longitude: -77.0428,
        drink_type: 'Whiskey',
        price_range: '$$$$',
        image_emoji: '🥃',
        header_color: '#B87333',
        is_featured: true
    },
    {
        id: '11111111-1111-1111-1111-111111111103',
        name: 'The Gin Garden',
        description: 'Botanical gin bar with garden patio seating',
        address: '789 Duke St, Alexandria, VA',
        latitude: 38.8065,
        longitude: -77.0502,
        drink_type: 'Gin',
        price_range: '$$$',
        image_emoji: '🍸',
        header_color: '#228B22',
        is_featured: false
    },
    {
        id: '11111111-1111-1111-1111-111111111104',
        name: 'Trader Vic\'s Hideaway',
        description: 'Tropical paradise with rum cocktails and Polynesian vibes',
        address: '321 Harbor Dr, Alexandria, VA',
        latitude: 38.7989,
        longitude: -77.0412,
        drink_type: 'Tiki',
        price_range: '$$',
        image_emoji: '🍹',
        header_color: '#035552',
        is_featured: true
    },
    {
        id: '11111111-1111-1111-1111-111111111105',
        name: 'Bamboo Lounge',
        description: 'Retro tiki bar with vintage decor and flaming drinks',
        address: '555 Pacific Ave, Alexandria, VA',
        latitude: 38.8102,
        longitude: -77.0521,
        drink_type: 'Tiki',
        price_range: '$$',
        image_emoji: '🌴',
        header_color: '#FFD700',
        is_featured: false
    },
    {
        id: '11111111-1111-1111-1111-111111111106',
        name: 'Molecule',
        description: 'Molecular mixology and avant-garde cocktails',
        address: '777 Innovation Way, Alexandria, VA',
        latitude: 38.8156,
        longitude: -77.0445,
        drink_type: 'Modern',
        price_range: '$$$$',
        image_emoji: '🧪',
        header_color: '#9400D3',
        is_featured: true
    },
    {
        id: '11111111-1111-1111-1111-111111111107',
        name: 'The Alchemist',
        description: 'Farm-to-glass cocktails with seasonal ingredients',
        address: '888 Garden Ln, Alexandria, VA',
        latitude: 38.8089,
        longitude: -77.0389,
        drink_type: 'Modern',
        price_range: '$$$',
        image_emoji: '⚗️',
        header_color: '#4169E1',
        is_featured: false
    },
    {
        id: '11111111-1111-1111-1111-111111111108',
        name: 'The Rusty Nail',
        description: 'No-frills neighborhood bar with cheap drinks',
        address: '999 Worker St, Alexandria, VA',
        latitude: 38.7945,
        longitude: -77.0567,
        drink_type: 'Classic',
        price_range: '$',
        image_emoji: '🍺',
        header_color: '#CD853F',
        is_featured: false
    },
    {
        id: '11111111-1111-1111-1111-111111111109',
        name: 'Grape & Grain',
        description: 'Wine bar with curated selection and small plates',
        address: '111 Vine St, Alexandria, VA',
        latitude: 38.8112,
        longitude: -77.0401,
        drink_type: 'Wine',
        price_range: '$$$',
        image_emoji: '🍷',
        header_color: '#722F37',
        is_featured: false
    },
    {
        id: '11111111-1111-1111-1111-111111111110',
        name: 'Agave Dreams',
        description: 'Mezcal and tequila specialists with 100+ bottles',
        address: '222 Aztec Ave, Alexandria, VA',
        latitude: 38.8034,
        longitude: -77.0512,
        drink_type: 'Tequila',
        price_range: '$$',
        image_emoji: '🌵',
        header_color: '#DAA520',
        is_featured: true
    }
];

// Cocktail data matching mock_data.sql
const cocktails = [
    // The Velvet Room
    { venue_id: '11111111-1111-1111-1111-111111111101', name: 'Old Fashioned', description: 'Bourbon, sugar, Angostura bitters, orange peel', price: 14.00, category: 'Classic', image_emoji: '🥃', is_popular: true },
    { venue_id: '11111111-1111-1111-1111-111111111101', name: 'Manhattan', description: 'Rye whiskey, sweet vermouth, Angostura bitters', price: 15.00, category: 'Classic', image_emoji: '🍸', is_popular: true },
    { venue_id: '11111111-1111-1111-1111-111111111101', name: 'Martini', description: 'Gin or vodka, dry vermouth, olive or lemon twist', price: 14.00, category: 'Classic', image_emoji: '🍸', is_popular: false },
    { venue_id: '11111111-1111-1111-1111-111111111101', name: 'Negroni', description: 'Gin, Campari, sweet vermouth', price: 13.00, category: 'Classic', image_emoji: '🍹', is_popular: true },
    { venue_id: '11111111-1111-1111-1111-111111111101', name: 'Sazerac', description: 'Rye, absinthe, Peychauds bitters, sugar', price: 16.00, category: 'Classic', image_emoji: '🥃', is_popular: false },

    // Copper & Oak
    { venue_id: '11111111-1111-1111-1111-111111111102', name: 'Whiskey Sour', description: 'Bourbon, lemon juice, simple syrup, egg white', price: 15.00, category: 'Whiskey', image_emoji: '🍋', is_popular: true },
    { venue_id: '11111111-1111-1111-1111-111111111102', name: 'Boulevardier', description: 'Bourbon, Campari, sweet vermouth', price: 16.00, category: 'Whiskey', image_emoji: '🥃', is_popular: false },
    { venue_id: '11111111-1111-1111-1111-111111111102', name: 'Penicillin', description: 'Scotch, lemon, honey-ginger, Islay float', price: 18.00, category: 'Whiskey', image_emoji: '💊', is_popular: true },
    { venue_id: '11111111-1111-1111-1111-111111111102', name: 'Paper Plane', description: 'Bourbon, Aperol, Amaro Nonino, lemon', price: 17.00, category: 'Modern', image_emoji: '✈️', is_popular: true },
    { venue_id: '11111111-1111-1111-1111-111111111102', name: 'Kentucky Mule', description: 'Bourbon, ginger beer, lime, mint', price: 14.00, category: 'Whiskey', image_emoji: '🫏', is_popular: false },

    // The Gin Garden
    { venue_id: '11111111-1111-1111-1111-111111111103', name: 'Gin & Tonic', description: 'Premium gin, Fever-Tree tonic, cucumber', price: 13.00, category: 'Classic', image_emoji: '🥒', is_popular: true },
    { venue_id: '11111111-1111-1111-1111-111111111103', name: 'Bee\'s Knees', description: 'Gin, honey syrup, lemon juice', price: 14.00, category: 'Classic', image_emoji: '🐝', is_popular: true },
    { venue_id: '11111111-1111-1111-1111-111111111103', name: 'Last Word', description: 'Gin, green Chartreuse, maraschino, lime', price: 16.00, category: 'Classic', image_emoji: '💬', is_popular: false },
    { venue_id: '11111111-1111-1111-1111-111111111103', name: 'Aviation', description: 'Gin, maraschino, creme de violette, lemon', price: 15.00, category: 'Classic', image_emoji: '✈️', is_popular: false },
    { venue_id: '11111111-1111-1111-1111-111111111103', name: 'Garden Collins', description: 'Gin, elderflower, cucumber, basil, soda', price: 14.00, category: 'Seasonal', image_emoji: '🌿', is_popular: true },

    // Trader Vic's Hideaway
    { venue_id: '11111111-1111-1111-1111-111111111104', name: 'Mai Tai', description: 'Aged rum, lime, orgeat, orange curacao', price: 14.00, category: 'Tiki', image_emoji: '🍹', is_popular: true },
    { venue_id: '11111111-1111-1111-1111-111111111104', name: 'Zombie', description: 'Three rums, lime, falernum, absinthe, grenadine', price: 16.00, category: 'Tiki', image_emoji: '🧟', is_popular: true },
    { venue_id: '11111111-1111-1111-1111-111111111104', name: 'Painkiller', description: 'Rum, pineapple, orange, coconut cream, nutmeg', price: 13.00, category: 'Tiki', image_emoji: '💊', is_popular: true },
    { venue_id: '11111111-1111-1111-1111-111111111104', name: 'Navy Grog', description: 'Three rums, lime, grapefruit, honey', price: 15.00, category: 'Tiki', image_emoji: '⚓', is_popular: false },
    { venue_id: '11111111-1111-1111-1111-111111111104', name: 'Scorpion Bowl', description: 'Rum, brandy, orgeat, citrus - serves 2-4', price: 32.00, category: 'Tiki', image_emoji: '🦂', is_popular: true },

    // Bamboo Lounge
    { venue_id: '11111111-1111-1111-1111-111111111105', name: 'Jungle Bird', description: 'Rum, Campari, pineapple, lime, simple', price: 13.00, category: 'Tiki', image_emoji: '🦜', is_popular: true },
    { venue_id: '11111111-1111-1111-1111-111111111105', name: 'Singapore Sling', description: 'Gin, cherry heering, Benedictine, citrus', price: 15.00, category: 'Tiki', image_emoji: '🌺', is_popular: false },
    { venue_id: '11111111-1111-1111-1111-111111111105', name: 'Hurricane', description: 'Light & dark rum, passion fruit, orange, lime', price: 12.00, category: 'Tiki', image_emoji: '🌀', is_popular: true },
    { venue_id: '11111111-1111-1111-1111-111111111105', name: 'Blue Hawaiian', description: 'Rum, blue curacao, pineapple, coconut', price: 13.00, category: 'Tiki', image_emoji: '🏝️', is_popular: false },

    // Molecule
    { venue_id: '11111111-1111-1111-1111-111111111106', name: 'Smoke Signal', description: 'Mezcal, activated charcoal, lime, agave, smoked glass', price: 22.00, category: 'Signature', image_emoji: '💨', is_popular: true },
    { venue_id: '11111111-1111-1111-1111-111111111106', name: 'Lavender Dream', description: 'Gin, lavender foam, butterfly pea, elderflower', price: 20.00, category: 'Signature', image_emoji: '💜', is_popular: true },
    { venue_id: '11111111-1111-1111-1111-111111111106', name: 'Golden Hour', description: 'Whiskey, saffron, honey caviar, orange mist', price: 24.00, category: 'Signature', image_emoji: '🌅', is_popular: true },
    { venue_id: '11111111-1111-1111-1111-111111111106', name: 'Forest Floor', description: 'Vodka, pine, mushroom, truffle oil droplets', price: 26.00, category: 'Signature', image_emoji: '🍄', is_popular: false },

    // The Alchemist
    { venue_id: '11111111-1111-1111-1111-111111111107', name: 'Farmers Market', description: 'Seasonal fruit shrub, vodka, herbs from our garden', price: 16.00, category: 'Seasonal', image_emoji: '🥕', is_popular: true },
    { venue_id: '11111111-1111-1111-1111-111111111107', name: 'Midnight Garden', description: 'Gin, blackberry, rosemary, elderflower', price: 17.00, category: 'Signature', image_emoji: '🌙', is_popular: true },
    { venue_id: '11111111-1111-1111-1111-111111111107', name: 'Autumn Leaves', description: 'Apple brandy, maple, cinnamon, walnut bitters', price: 18.00, category: 'Seasonal', image_emoji: '🍂', is_popular: false },
    { venue_id: '11111111-1111-1111-1111-111111111107', name: 'Spring Awakening', description: 'Gin, cucumber, mint, St-Germain, prosecco', price: 16.00, category: 'Seasonal', image_emoji: '🌸', is_popular: true },

    // The Rusty Nail
    { venue_id: '11111111-1111-1111-1111-111111111108', name: 'Rusty Nail', description: 'Scotch, Drambuie', price: 8.00, category: 'Classic', image_emoji: '🔩', is_popular: true },
    { venue_id: '11111111-1111-1111-1111-111111111108', name: 'Whiskey Ginger', description: 'Well whiskey, ginger ale', price: 6.00, category: 'Classic', image_emoji: '🥃', is_popular: true },
    { venue_id: '11111111-1111-1111-1111-111111111108', name: 'Rum & Coke', description: 'Well rum, Coca-Cola', price: 6.00, category: 'Classic', image_emoji: '🥤', is_popular: false },
    { venue_id: '11111111-1111-1111-1111-111111111108', name: 'PBR & Shot', description: 'Pabst Blue Ribbon, well whiskey', price: 7.00, category: 'Classic', image_emoji: '🍺', is_popular: true },

    // Grape & Grain
    { venue_id: '11111111-1111-1111-1111-111111111109', name: 'Aperol Spritz', description: 'Aperol, prosecco, soda, orange', price: 12.00, category: 'Classic', image_emoji: '🍊', is_popular: true },
    { venue_id: '11111111-1111-1111-1111-111111111109', name: 'Kir Royale', description: 'Champagne, creme de cassis', price: 14.00, category: 'Classic', image_emoji: '🍇', is_popular: false },
    { venue_id: '11111111-1111-1111-1111-111111111109', name: 'Bellini', description: 'Prosecco, white peach puree', price: 13.00, category: 'Classic', image_emoji: '🍑', is_popular: true },
    { venue_id: '11111111-1111-1111-1111-111111111109', name: 'Mimosa', description: 'Champagne, fresh orange juice', price: 11.00, category: 'Classic', image_emoji: '🥂', is_popular: true },

    // Agave Dreams
    { venue_id: '11111111-1111-1111-1111-111111111110', name: 'Margarita', description: 'Blanco tequila, Cointreau, lime, salt rim', price: 14.00, category: 'Classic', image_emoji: '🍋', is_popular: true },
    { venue_id: '11111111-1111-1111-1111-111111111110', name: 'Paloma', description: 'Tequila, grapefruit soda, lime, salt', price: 12.00, category: 'Classic', image_emoji: '🍊', is_popular: true },
    { venue_id: '11111111-1111-1111-1111-111111111110', name: 'Mezcal Mule', description: 'Mezcal, ginger beer, lime, cucumber', price: 14.00, category: 'Modern', image_emoji: '🫏', is_popular: false },
    { venue_id: '11111111-1111-1111-1111-111111111110', name: 'Oaxacan Old Fashioned', description: 'Mezcal, tequila, agave, mole bitters', price: 16.00, category: 'Modern', image_emoji: '🌵', is_popular: true },
    { venue_id: '11111111-1111-1111-1111-111111111110', name: 'Tommy\'s Margarita', description: 'Tequila, lime, agave nectar', price: 13.00, category: 'Classic', image_emoji: '🍸', is_popular: true }
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
    console.log('🍸 Populating Clnk Supabase database...\n');

    try {
        // Insert venues (bars)
        console.log(`🏠 Inserting ${venues.length} venues...`);
        await insertData('venues', venues);
        console.log('✅ Venues inserted successfully!\n');

        // Insert cocktails
        console.log(`🍹 Inserting ${cocktails.length} cocktails...`);
        await insertData('cocktails', cocktails);
        console.log('✅ Cocktails inserted successfully!\n');

        console.log('🎉 Database populated successfully!');
        console.log(`   - ${venues.length} venues (bars)`);
        console.log(`   - ${cocktails.length} cocktails`);
    } catch (error) {
        console.error('❌ Error:', error.message);
        process.exit(1);
    }
}

main();
