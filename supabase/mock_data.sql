-- Clnk Mock Data: Bars & Cocktails

-- Insert sample venues (bars)
INSERT INTO venues (id, name, description, address, latitude, longitude, drink_type, price_range, image_emoji, header_color, is_featured) VALUES
-- Classic Cocktail Bars
('11111111-1111-1111-1111-111111111101', 'The Velvet Room', 'Elegant speakeasy with classic cocktails and live jazz', '123 Main St, Alexandria, VA', 38.8048, -77.0469, 'Classic', '$$$', '🥃', '#8B4513', true),
('11111111-1111-1111-1111-111111111102', 'Copper & Oak', 'Whiskey-focused bar with 200+ bottles and craft cocktails', '456 King St, Alexandria, VA', 38.8051, -77.0428, 'Whiskey', '$$$$', '🥃', '#B87333', true),
('11111111-1111-1111-1111-111111111103', 'The Gin Garden', 'Botanical gin bar with garden patio seating', '789 Duke St, Alexandria, VA', 38.8065, -77.0502, 'Gin', '$$$', '🍸', '#228B22', false),

-- Tiki Bars
('11111111-1111-1111-1111-111111111104', 'Trader Vics Hideaway', 'Tropical paradise with rum cocktails and Polynesian vibes', '321 Harbor Dr, Alexandria, VA', 38.7989, -77.0412, 'Tiki', '$$', '🍹', '#FF6B35', true),
('11111111-1111-1111-1111-111111111105', 'Bamboo Lounge', 'Retro tiki bar with vintage decor and flaming drinks', '555 Pacific Ave, Alexandria, VA', 38.8102, -77.0521, 'Tiki', '$$', '🌴', '#FFD700', false),

-- Modern/Craft Bars
('11111111-1111-1111-1111-111111111106', 'Molecule', 'Molecular mixology and avant-garde cocktails', '777 Innovation Way, Alexandria, VA', 38.8156, -77.0445, 'Modern', '$$$$', '🧪', '#9400D3', true),
('11111111-1111-1111-1111-111111111107', 'The Alchemist', 'Farm-to-glass cocktails with seasonal ingredients', '888 Garden Ln, Alexandria, VA', 38.8089, -77.0389, 'Modern', '$$$', '⚗️', '#4169E1', false),

-- Dive/Casual Bars
('11111111-1111-1111-1111-111111111108', 'The Rusty Nail', 'No-frills neighborhood bar with cheap drinks', '999 Worker St, Alexandria, VA', 38.7945, -77.0567, 'Classic', '$', '🍺', '#CD853F', false),

-- Wine Bars
('11111111-1111-1111-1111-111111111109', 'Grape & Grain', 'Wine bar with curated selection and small plates', '111 Vine St, Alexandria, VA', 38.8112, -77.0401, 'Wine', '$$$', '🍷', '#722F37', false),

-- Mezcal/Tequila Bars
('11111111-1111-1111-1111-111111111110', 'Agave Dreams', 'Mezcal and tequila specialists with 100+ bottles', '222 Aztec Ave, Alexandria, VA', 38.8034, -77.0512, 'Tequila', '$$', '🌵', '#DAA520', true);

-- Insert cocktails for each venue

-- The Velvet Room (Classic)
INSERT INTO cocktails (venue_id, name, description, price, category, image_emoji, is_popular) VALUES
('11111111-1111-1111-1111-111111111101', 'Old Fashioned', 'Bourbon, sugar, Angostura bitters, orange peel', 14.00, 'Classic', '🥃', true),
('11111111-1111-1111-1111-111111111101', 'Manhattan', 'Rye whiskey, sweet vermouth, Angostura bitters', 15.00, 'Classic', '🍸', true),
('11111111-1111-1111-1111-111111111101', 'Martini', 'Gin or vodka, dry vermouth, olive or lemon twist', 14.00, 'Classic', '🍸', false),
('11111111-1111-1111-1111-111111111101', 'Negroni', 'Gin, Campari, sweet vermouth', 13.00, 'Classic', '🍹', true),
('11111111-1111-1111-1111-111111111101', 'Sazerac', 'Rye, absinthe, Peychauds bitters, sugar', 16.00, 'Classic', '🥃', false);

-- Copper & Oak (Whiskey)
INSERT INTO cocktails (venue_id, name, description, price, category, image_emoji, is_popular) VALUES
('11111111-1111-1111-1111-111111111102', 'Whiskey Sour', 'Bourbon, lemon juice, simple syrup, egg white', 15.00, 'Whiskey', '🍋', true),
('11111111-1111-1111-1111-111111111102', 'Boulevardier', 'Bourbon, Campari, sweet vermouth', 16.00, 'Whiskey', '🥃', false),
('11111111-1111-1111-1111-111111111102', 'Penicillin', 'Scotch, lemon, honey-ginger, Islay float', 18.00, 'Whiskey', '💊', true),
('11111111-1111-1111-1111-111111111102', 'Paper Plane', 'Bourbon, Aperol, Amaro Nonino, lemon', 17.00, 'Modern', '✈️', true),
('11111111-1111-1111-1111-111111111102', 'Kentucky Mule', 'Bourbon, ginger beer, lime, mint', 14.00, 'Whiskey', '🫏', false);

-- The Gin Garden (Gin)
INSERT INTO cocktails (venue_id, name, description, price, category, image_emoji, is_popular) VALUES
('11111111-1111-1111-1111-111111111103', 'Gin & Tonic', 'Premium gin, Fever-Tree tonic, cucumber', 13.00, 'Classic', '🥒', true),
('11111111-1111-1111-1111-111111111103', 'Bee''s Knees', 'Gin, honey syrup, lemon juice', 14.00, 'Classic', '🐝', true),
('11111111-1111-1111-1111-111111111103', 'Last Word', 'Gin, green Chartreuse, maraschino, lime', 16.00, 'Classic', '💬', false),
('11111111-1111-1111-1111-111111111103', 'Aviation', 'Gin, maraschino, crème de violette, lemon', 15.00, 'Classic', '✈️', false),
('11111111-1111-1111-1111-111111111103', 'Garden Collins', 'Gin, elderflower, cucumber, basil, soda', 14.00, 'Seasonal', '🌿', true);

-- Trader Vics Hideaway (Tiki)
INSERT INTO cocktails (venue_id, name, description, price, category, image_emoji, is_popular) VALUES
('11111111-1111-1111-1111-111111111104', 'Mai Tai', 'Aged rum, lime, orgeat, orange curaçao', 14.00, 'Tiki', '🍹', true),
('11111111-1111-1111-1111-111111111104', 'Zombie', 'Three rums, lime, falernum, absinthe, grenadine', 16.00, 'Tiki', '🧟', true),
('11111111-1111-1111-1111-111111111104', 'Painkiller', 'Rum, pineapple, orange, coconut cream, nutmeg', 13.00, 'Tiki', '💊', true),
('11111111-1111-1111-1111-111111111104', 'Navy Grog', 'Three rums, lime, grapefruit, honey', 15.00, 'Tiki', '⚓', false),
('11111111-1111-1111-1111-111111111104', 'Scorpion Bowl', 'Rum, brandy, orgeat, citrus - serves 2-4', 32.00, 'Tiki', '🦂', true);

-- Bamboo Lounge (Tiki)
INSERT INTO cocktails (venue_id, name, description, price, category, image_emoji, is_popular) VALUES
('11111111-1111-1111-1111-111111111105', 'Jungle Bird', 'Rum, Campari, pineapple, lime, simple', 13.00, 'Tiki', '🦜', true),
('11111111-1111-1111-1111-111111111105', 'Singapore Sling', 'Gin, cherry heering, Bénédictine, citrus', 15.00, 'Tiki', '🌺', false),
('11111111-1111-1111-1111-111111111105', 'Hurricane', 'Light & dark rum, passion fruit, orange, lime', 12.00, 'Tiki', '🌀', true),
('11111111-1111-1111-1111-111111111105', 'Blue Hawaiian', 'Rum, blue curaçao, pineapple, coconut', 13.00, 'Tiki', '🏝️', false);

-- Molecule (Modern)
INSERT INTO cocktails (venue_id, name, description, price, category, image_emoji, is_popular) VALUES
('11111111-1111-1111-1111-111111111106', 'Smoke Signal', 'Mezcal, activated charcoal, lime, agave, smoked glass', 22.00, 'Signature', '💨', true),
('11111111-1111-1111-1111-111111111106', 'Lavender Dream', 'Gin, lavender foam, butterfly pea, elderflower', 20.00, 'Signature', '💜', true),
('11111111-1111-1111-1111-111111111106', 'Golden Hour', 'Whiskey, saffron, honey caviar, orange mist', 24.00, 'Signature', '🌅', true),
('11111111-1111-1111-1111-111111111106', 'Forest Floor', 'Vodka, pine, mushroom, truffle oil droplets', 26.00, 'Signature', '🍄', false);

-- The Alchemist (Modern)
INSERT INTO cocktails (venue_id, name, description, price, category, image_emoji, is_popular) VALUES
('11111111-1111-1111-1111-111111111107', 'Farmers Market', 'Seasonal fruit shrub, vodka, herbs from our garden', 16.00, 'Seasonal', '🥕', true),
('11111111-1111-1111-1111-111111111107', 'Midnight Garden', 'Gin, blackberry, rosemary, elderflower', 17.00, 'Signature', '🌙', true),
('11111111-1111-1111-1111-111111111107', 'Autumn Leaves', 'Apple brandy, maple, cinnamon, walnut bitters', 18.00, 'Seasonal', '🍂', false),
('11111111-1111-1111-1111-111111111107', 'Spring Awakening', 'Gin, cucumber, mint, St-Germain, prosecco', 16.00, 'Seasonal', '🌸', true);

-- The Rusty Nail (Dive)
INSERT INTO cocktails (venue_id, name, description, price, category, image_emoji, is_popular) VALUES
('11111111-1111-1111-1111-111111111108', 'Rusty Nail', 'Scotch, Drambuie', 8.00, 'Classic', '🔩', true),
('11111111-1111-1111-1111-111111111108', 'Whiskey Ginger', 'Well whiskey, ginger ale', 6.00, 'Classic', '🥃', true),
('11111111-1111-1111-1111-111111111108', 'Rum & Coke', 'Well rum, Coca-Cola', 6.00, 'Classic', '🥤', false),
('11111111-1111-1111-1111-111111111108', 'PBR & Shot', 'Pabst Blue Ribbon, well whiskey', 7.00, 'Classic', '🍺', true);

-- Grape & Grain (Wine)
INSERT INTO cocktails (venue_id, name, description, price, category, image_emoji, is_popular) VALUES
('11111111-1111-1111-1111-111111111109', 'Aperol Spritz', 'Aperol, prosecco, soda, orange', 12.00, 'Classic', '🍊', true),
('11111111-1111-1111-1111-111111111109', 'Kir Royale', 'Champagne, crème de cassis', 14.00, 'Classic', '🍇', false),
('11111111-1111-1111-1111-111111111109', 'Bellini', 'Prosecco, white peach purée', 13.00, 'Classic', '🍑', true),
('11111111-1111-1111-1111-111111111109', 'Mimosa', 'Champagne, fresh orange juice', 11.00, 'Classic', '🥂', true);

-- Agave Dreams (Tequila/Mezcal)
INSERT INTO cocktails (venue_id, name, description, price, category, image_emoji, is_popular) VALUES
('11111111-1111-1111-1111-111111111110', 'Margarita', 'Blanco tequila, Cointreau, lime, salt rim', 14.00, 'Classic', '🍋', true),
('11111111-1111-1111-1111-111111111110', 'Paloma', 'Tequila, grapefruit soda, lime, salt', 12.00, 'Classic', '🍊', true),
('11111111-1111-1111-1111-111111111110', 'Mezcal Mule', 'Mezcal, ginger beer, lime, cucumber', 14.00, 'Modern', '🫏', false),
('11111111-1111-1111-1111-111111111110', 'Oaxacan Old Fashioned', 'Mezcal, tequila, agave, mole bitters', 16.00, 'Modern', '🌵', true),
('11111111-1111-1111-1111-111111111110', 'Tommy''s Margarita', 'Tequila, lime, agave nectar', 13.00, 'Classic', '🍸', true);
