module challenge::arena;

use challenge::hero::Hero;
use sui::event;

// ========= STRUCTS =========

public struct Arena has key, store {
    id: UID,
    warrior: Hero,
    owner: address,
}

// ========= EVENTS =========

public struct ArenaCreated has copy, drop {
    arena_id: ID,
    timestamp: u64,
}

public struct ArenaCompleted has copy, drop {
    winner_hero_id: ID,
    loser_hero_id: ID,
    timestamp: u64,
}

// ========= PUBLIC FUNCTIONS =========

public fun create_arena(hero: Hero, ctx: &mut TxContext) {
    let timestamp = ctx.epoch_timestamp_ms();
    
    let arena = Arena {
        id: object::new(ctx),
        warrior: hero,
        owner: ctx.sender(),
    };
    
    let arena_id = object::id(&arena);
    
    event::emit(ArenaCreated {
        arena_id,
        timestamp,
    });
    
    transfer::share_object(arena);
}

#[allow(lint(self_transfer))]
public fun battle(hero: Hero, arena: Arena, ctx: &mut TxContext) {
    let Arena { id, warrior, owner } = arena;
    
    let challenger_power = hero.hero_power();
    let warrior_power = warrior.hero_power();
    let timestamp = ctx.epoch_timestamp_ms();
    
    if (challenger_power > warrior_power) {
        let winner_address = ctx.sender();
        
        event::emit(ArenaCompleted {
            winner_hero_id: object::id(&hero),
            loser_hero_id: object::id(&warrior),
            timestamp,
        });
        
        transfer::public_transfer(hero, winner_address);
        transfer::public_transfer(warrior, winner_address);
    } else {
        event::emit(ArenaCompleted {
            winner_hero_id: object::id(&warrior),
            loser_hero_id: object::id(&hero),
            timestamp,
        });
        
        transfer::public_transfer(hero, owner);
        transfer::public_transfer(warrior, owner);
    };
    
    object::delete(id);
}