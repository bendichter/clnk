-- BiteVue Database Schema
-- Run this in Supabase SQL Editor

-- ============================================
-- EXTENSIONS
-- ============================================
create extension if not exists "uuid-ossp";
create extension if not exists "postgis";  -- For geospatial queries

-- ============================================
-- USERS (extends Supabase auth.users)
-- ============================================
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  username text unique,
  full_name text,
  bio text,
  avatar_emoji text default '😊',
  avatar_url text,  -- For custom profile photos
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Enable RLS
alter table public.profiles enable row level security;

-- Policies
create policy "Public profiles are viewable by everyone"
  on public.profiles for select using (true);

create policy "Users can update their own profile"
  on public.profiles for update using (auth.uid() = id);

create policy "Users can insert their own profile"
  on public.profiles for insert with check (auth.uid() = id);

-- ============================================
-- RESTAURANTS
-- ============================================
create table public.restaurants (
  id uuid default uuid_generate_v4() primary key,
  fsq_place_id text unique,  -- Foursquare ID for deduplication
  name text not null,
  address text,
  locality text,  -- City
  region text,    -- State
  postcode text,
  country text default 'US',
  formatted_address text,
  latitude double precision,
  longitude double precision,
  location geography(Point, 4326),  -- PostGIS point for geo queries
  cuisine_type text,  -- Primary cuisine
  categories jsonb,   -- All Foursquare categories
  phone text,
  website text,
  email text,
  hours jsonb,        -- Operating hours
  photo_url text,     -- Primary photo
  is_user_submitted boolean default false,
  submitted_by uuid references public.profiles(id),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Create spatial index for location queries
create index restaurants_location_idx on public.restaurants using gist(location);
create index restaurants_fsq_id_idx on public.restaurants(fsq_place_id);
create index restaurants_cuisine_idx on public.restaurants(cuisine_type);

-- Enable RLS
alter table public.restaurants enable row level security;

-- Policies
create policy "Restaurants are viewable by everyone"
  on public.restaurants for select using (true);

create policy "Authenticated users can add restaurants"
  on public.restaurants for insert with check (auth.role() = 'authenticated');

-- ============================================
-- DISHES
-- ============================================
create table public.dishes (
  id uuid default uuid_generate_v4() primary key,
  restaurant_id uuid references public.restaurants(id) on delete cascade not null,
  name text not null,
  description text,
  price decimal(10,2),
  category text,  -- Appetizer, Entree, Dessert, etc.
  dietary_tags text[],  -- ['vegetarian', 'gluten-free', 'vegan']
  photo_url text,
  submitted_by uuid references public.profiles(id),
  is_verified boolean default false,  -- For restaurant-verified dishes
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  
  -- Aggregated stats (updated via trigger)
  avg_rating decimal(3,2) default 0,
  rating_count integer default 0
);

create index dishes_restaurant_idx on public.dishes(restaurant_id);
create index dishes_category_idx on public.dishes(category);

-- Enable RLS
alter table public.dishes enable row level security;

-- Policies
create policy "Dishes are viewable by everyone"
  on public.dishes for select using (true);

create policy "Authenticated users can add dishes"
  on public.dishes for insert with check (auth.role() = 'authenticated');

-- ============================================
-- RATINGS (Reviews)
-- ============================================
create table public.ratings (
  id uuid default uuid_generate_v4() primary key,
  dish_id uuid references public.dishes(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  rating integer not null check (rating >= 1 and rating <= 5),
  comment text,
  helpful_count integer default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  
  -- One rating per user per dish
  unique(dish_id, user_id)
);

create index ratings_dish_idx on public.ratings(dish_id);
create index ratings_user_idx on public.ratings(user_id);
create index ratings_created_idx on public.ratings(created_at desc);

-- Enable RLS
alter table public.ratings enable row level security;

-- Policies
create policy "Ratings are viewable by everyone"
  on public.ratings for select using (true);

create policy "Authenticated users can create ratings"
  on public.ratings for insert with check (auth.uid() = user_id);

create policy "Users can update their own ratings"
  on public.ratings for update using (auth.uid() = user_id);

create policy "Users can delete their own ratings"
  on public.ratings for delete using (auth.uid() = user_id);

-- ============================================
-- RATING PHOTOS
-- ============================================
create table public.rating_photos (
  id uuid default uuid_generate_v4() primary key,
  rating_id uuid references public.ratings(id) on delete cascade not null,
  photo_url text not null,
  storage_path text,  -- Path in Supabase storage
  created_at timestamptz default now()
);

create index rating_photos_rating_idx on public.rating_photos(rating_id);

-- Enable RLS
alter table public.rating_photos enable row level security;

-- Policies
create policy "Rating photos are viewable by everyone"
  on public.rating_photos for select using (true);

create policy "Users can add photos to their ratings"
  on public.rating_photos for insert 
  with check (
    auth.uid() = (select user_id from public.ratings where id = rating_id)
  );

-- ============================================
-- HELPFUL VOTES
-- ============================================
create table public.helpful_votes (
  id uuid default uuid_generate_v4() primary key,
  rating_id uuid references public.ratings(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamptz default now(),
  
  unique(rating_id, user_id)
);

create index helpful_votes_rating_idx on public.helpful_votes(rating_id);

-- Enable RLS
alter table public.helpful_votes enable row level security;

-- Policies
create policy "Authenticated users can vote"
  on public.helpful_votes for all using (auth.uid() = user_id);

-- ============================================
-- FAVORITES
-- ============================================
create table public.favorites (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  restaurant_id uuid references public.restaurants(id) on delete cascade not null,
  created_at timestamptz default now(),
  
  unique(user_id, restaurant_id)
);

create index favorites_user_idx on public.favorites(user_id);

-- Enable RLS
alter table public.favorites enable row level security;

-- Policies
create policy "Users can manage their own favorites"
  on public.favorites for all using (auth.uid() = user_id);

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Auto-create profile on user signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, avatar_emoji)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    '😊'
  );
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Update dish stats when rating changes
create or replace function public.update_dish_stats()
returns trigger as $$
begin
  if TG_OP = 'DELETE' then
    update public.dishes
    set 
      avg_rating = coalesce((select avg(rating)::decimal(3,2) from public.ratings where dish_id = OLD.dish_id), 0),
      rating_count = (select count(*) from public.ratings where dish_id = OLD.dish_id),
      updated_at = now()
    where id = OLD.dish_id;
    return OLD;
  else
    update public.dishes
    set 
      avg_rating = coalesce((select avg(rating)::decimal(3,2) from public.ratings where dish_id = NEW.dish_id), 0),
      rating_count = (select count(*) from public.ratings where dish_id = NEW.dish_id),
      updated_at = now()
    where id = NEW.dish_id;
    return NEW;
  end if;
end;
$$ language plpgsql security definer;

create trigger on_rating_change
  after insert or update or delete on public.ratings
  for each row execute procedure public.update_dish_stats();

-- Update helpful count when vote changes
create or replace function public.update_helpful_count()
returns trigger as $$
begin
  if TG_OP = 'DELETE' then
    update public.ratings
    set helpful_count = (select count(*) from public.helpful_votes where rating_id = OLD.rating_id)
    where id = OLD.rating_id;
    return OLD;
  else
    update public.ratings
    set helpful_count = (select count(*) from public.helpful_votes where rating_id = NEW.rating_id)
    where id = NEW.rating_id;
    return NEW;
  end if;
end;
$$ language plpgsql security definer;

create trigger on_helpful_vote_change
  after insert or delete on public.helpful_votes
  for each row execute procedure public.update_helpful_count();

-- ============================================
-- USEFUL VIEWS
-- ============================================

-- Top dishes near a location (example function)
create or replace function public.get_top_dishes_near(
  lat double precision,
  lng double precision,
  radius_meters integer default 5000,
  limit_count integer default 20
)
returns table (
  dish_id uuid,
  dish_name text,
  avg_rating decimal,
  rating_count integer,
  restaurant_name text,
  restaurant_id uuid,
  distance_meters double precision
) as $$
begin
  return query
  select 
    d.id as dish_id,
    d.name as dish_name,
    d.avg_rating,
    d.rating_count,
    r.name as restaurant_name,
    r.id as restaurant_id,
    ST_Distance(r.location, ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography) as distance_meters
  from public.dishes d
  join public.restaurants r on d.restaurant_id = r.id
  where 
    d.rating_count > 0
    and ST_DWithin(r.location, ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography, radius_meters)
  order by d.avg_rating desc, d.rating_count desc
  limit limit_count;
end;
$$ language plpgsql;

-- ============================================
-- STORAGE BUCKETS (run separately in Dashboard)
-- ============================================
-- Create these buckets in Supabase Dashboard > Storage:
-- 1. "avatars" - for profile photos (public)
-- 2. "rating-photos" - for dish review photos (public)
