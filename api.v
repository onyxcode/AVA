module main

import vweb
import rand
import time
import net.http
import os
import x.json2 as json

struct App {
	vweb.Context
}

fn main() {
	mut port := os.input('What port will you be running the server on?\n> ')
	vweb.run(&App{}, port.int())
}

fn dogapi() ?string {
    resp := http.get_text('https://api.thedogapi.com/v1/images/search')
    raw_resp := json.raw_decode(resp) ?
    dog_json := raw_resp.as_map()

    return dog_json["0"].as_map()["url"].str()
}

fn catapi() ?string {
    resp := http.get_text('https://api.thecatapi.com/v1/images/search')
    raw_resp := json.raw_decode(resp) ?
    dog_json := raw_resp.as_map()

    return dog_json["0"].as_map()["url"].str()
}

pub fn foxapi() ?string {
    resp := http.get_text('https://randomfox.ca/floof/')
    raw_resp := json.raw_decode(resp) ?
    fox_json := raw_resp.as_map()

    return fox_json["image"].str()
}

pub fn bored() ?string {
	ideas := ['Code',
            'Play Minecraft',
            'Watch YouTube',
            'Go live on Twitch',
            'Go outside',
            'Play something new on Itch.io',
            'Play a random game on Game Jolt',
            'Play a Steam game',
            'Check Twitter',
            'Check Discord',
            'Open and contribute to pull requests',
            'Learn a new language',
            'Eat food',
            'Talk to a friend',
            'Play Minecraft',
            'Write a book',
            'Make a scrapbook',
            'Drink water',
            'Check Instagram',
            'Watch a movie',
            'Make a virtual machine',
            'Try a new food']
	return(ideas[rand.intn(ideas.len)])
	
}

pub fn (mut app App) index() vweb.Result {
	app.serve_static("/style.css", "style.css")
	return $vweb.html()
}


//Initial API endpoint
['/api']
pub fn (mut app App) api() vweb.Result {
    return app.json('{\"dog\": \"/api/dog\", \"cat\": \"/api/cat\", \"fox\": \"/api/fox\", \"utc\": \"/api/utc\", \"idea\": \"/api/idea\", \"rng\": \"/api/rng\"}')
}

// Random number generator, up to 9999
['/api/rng']
pub fn (mut app App) random_number() vweb.Result {
	rng := rand.intn(9999)
	return app.json('{"random":$rng}')
}

/// Current UTC time
['/api/utc']
pub fn (mut app App) time_utc() vweb.Result {
	utc := time.utc()
	return app.json('{"time":"$utc"}')
}

['/api/dog']
pub fn (mut app App) dogge() vweb.Result {
    res := dogapi() or {
        return app.json("{ \"error\": \"No dog found\" }")
    }
    return app.json("[{\"url\":\"$res\"}]")
}

['/api/idea']
pub fn (mut app App) idea() vweb.Result {
	id := bored() or {
        return app.json("[{\"error\":\"I can't think of anything, try refreshing.\"}]")
    }
    return app.json("[{\"idea\":\"$id\"}]")
}

['/api/fox']
pub fn (mut app App) fox() vweb.Result {
    id := foxapi() or {
        return app.json("[{\"error\":\"No image found, try again later.\"}]")
    }
    return app.json("[{\"url\":\"$id\"}]")
}

['/api/cat']
pub fn (mut app App) cat() vweb.Result {
    id := catapi() or {
        return app.json("[{\"error\":\"No image found, try again later.\"}]")
    }
    return app.json("[{\"url\":\"$id\"}]")
}