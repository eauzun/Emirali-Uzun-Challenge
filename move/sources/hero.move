module challenge::hero;

use std::string::String;

// ========= STRUCTS =========

public struct Hero has key, store {
    id: UID,
    name: String,
    image_url: String,
    power: u64,
}

public struct HeroMetadata has key, store {
    id: UID,
    timestamp: u64,
}

// ========= PUBLIC FUNCTIONS =========

#[allow(lint(self_transfer))]
public fun create_hero(
    name: String, 
    image_url: String, 
    power: u64, 
    ctx: &mut TxContext
) {
    let sender = ctx.sender();
    let timestamp = ctx.epoch_timestamp_ms();
    
    let hero = Hero {
        id: object::new(ctx),
        name,
        image_url,
        power,
    };
    transfer::public_transfer(hero, sender);
    
    let metadata = HeroMetadata {
        id: object::new(ctx),
        timestamp,
    };
    transfer::freeze_object(metadata);
}

// ========= PUBLIC GETTER FUNCTIONS =========

public fun hero_power(hero: &Hero): u64 {
    hero.power
}

// ========= TEST-ONLY FUNCTIONS =========

#[test_only]
public fun hero_name(hero: &Hero): String {
    hero.name
}

#[test_only]
public fun hero_image_url(hero: &Hero): String {
    hero.image_url
}

#[test_only]
public fun hero_id(hero: &Hero): ID {
    object::id(hero)
}