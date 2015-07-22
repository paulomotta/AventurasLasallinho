local bump = require 'bump'
local world = bump.newWorld(64)
local anim8 = require 'anim8'
local actor = require 'actor'
local customLayer = require 'customLayer' 

function inithud()
    heartImage = love.graphics.newImage("HUD/hud_heartFull.png")  
    coinImage = love.graphics.newImage("HUD/hud_coins.png")  
    bibleImage = love.graphics.newImage("spellbook.png")  
    leftButton = {}
    leftButton.imagem = love.graphics.newImage("HUD/leftButton.png")  
    rightButton = {}
    rightButton.imagem = love.graphics.newImage("HUD/rightButton.png")  
    upButton = {}
    upButton.imagem = love.graphics.newImage("HUD/upButton.png")  
end

function initplayer(map)
    lasallinho = actor.new("player",false, "right")
    lasallinho:setImage('LaSallinho490.png', 70, 120, {'1-5',1}, 0.1)

    playerLayer = customLayer.new(map("objects"))
       
    lasallinho:setMapObject(playerLayer:findObject("player"))
    lasallinho:setWorld(world)

    playerLayer:createConvertObjectFunction("player", lasallinho)
end

function initenemies(map)
    enemyLayer = customLayer.new(map("enemies"))

    skulls = enemyLayer:findObjectsByType("skull")

    for index,mapObject in pairs(skulls) do
        local skull1 = actor.new("skull"..index,true, "left",false)
        skull1:setImage('skullidle.png', 64, 64, {'1-16',1}, 0.25)
        skull1:setMapObject(mapObject)
        skull1:setWorld(world)
    end

    grumpys = enemyLayer:findObjectsByType("grumpy")

    for index,mapObject in pairs(grumpys) do
        local grumpy2 = actor.new("grumpy"..index, true, "right", false, false, true)
        grumpy2:setImage('grumpy.png', 64, 64, {'1-8',1}, 0.15)
        grumpy2:setMapObject(mapObject)
        grumpy2:setWorld(world)
    end

    frogs = enemyLayer:findObjectsByType("frog")

    for index,mapObject in pairs(frogs) do
        local frog = actor.new("frog"..index, true, "left")
        frog:setImage('PlayerSprite0_3_2.png', 64, 64, {'1-4',1, 6,1, 2,1}, 0.15)
        frog:setMapObject(mapObject)
        frog:setWorld(world)
    end

    jumpers = enemyLayer:findObjectsByType("jumper")

    for index,mapObject in pairs(jumpers) do
        local jumper = actor.new("jumper"..index, true, "left")
        jumper:setImage('jump.png', 64, 64, {'1-2',1}, 0.25)
        jumper:setMapObject(mapObject)
        jumper:setWorld(world)
    end

    idles = enemyLayer:findObjectsByType("idle")

    for index,mapObject in pairs(idles) do
        local idle = actor.new("idle"..index, true, "left")
        idle:setImage('idle.png', 64, 64, {'1-2',1}, 0.25)
        idle:setMapObject(mapObject)
        idle:setWorld(world)
    end

    abismos = enemyLayer:findObjectsByType("abismo")

    for index,mapObject in pairs(abismos) do
        --new(id, npc, face, collider, collectable, flyer, resetPlayer, stationery)
        local abismo = actor.new("abismo"..index, true, "left", true, false, true, true, true)
        abismo:setImage('stone_transparente.png', 64, 64, {'1-1',1}, 0.25)
        abismo:setMapObject(mapObject)
        abismo:setWorld(world)
    end

    enemyLayer:createConvertObjectFunction()
end

function initstones(map)
    collisionLayer = customLayer.new(map("collision"))

    stones = collisionLayer:findObjectsByType("pedra")
    --print(#stones)

    for index,mapObject in pairs(stones) do
        --print(index,mapObject)
        local stone = actor.new("stone"..index,true, "left", true)
        stone:setImage('stone_transparente.png', 64, 64, {1,1}, 0.9)
        stone:setMapObject(mapObject)
        stone:setWorld(world)
    end

    collisionLayer:createConvertObjectFunction()
end

function initcollectables(map)
    collectablesLayer = customLayer.new(map("collectables"))

    coins = collectablesLayer:findObjectsByType("coin")

    for index,mapObject in pairs(coins) do
        --new(id, npc, face, collider, collectable, flyer, resetPlayer, stationery)
        local coin1 = actor.new("coin"..index,true, "left",false,true)
        coin1:setImage('spin_coin_big_strip6.png', 29, 32, {'1-5',1}, 0.15)
        coin1:setMapObject(mapObject)
        coin1:setWorld(world)
    end

    lifes = collectablesLayer:findObjectsByType("life")

    for index,mapObject in pairs(lifes) do
        --new(id, npc, face, collider, collectable, flyer, resetPlayer, stationery)
        local life1 = actor.new("life"..index,true, "left",false,true)
        life1:setImage('life.png', 32, 32, {'1-2',1}, 0.15)
        life1:setMapObject(mapObject)
        life1:setWorld(world)
    end

    books = collectablesLayer:findObjectsByType("book")

    for index,mapObject in pairs(books) do
        --new(id, npc, face, collider, collectable, flyer, resetPlayer, stationery)
        local book1 = actor.new("book"..index,true, "left",false,true)
        book1:setImage('spellbook_blink.png', 64, 64, {'1-4',1}, 0.15)
        book1:setMapObject(mapObject)
        book1:setWorld(world)
    end

    portas = collectablesLayer:findObjectsByType("porta")

    for index,mapObject in pairs(portas) do
        --new(id, npc, face, collider, collectable, flyer, resetPlayer, stationery)
        local porta = actor.new("porta"..index,true, "left",false,true)
        porta:setImage('stone_transparente.png', 64, 64, {1,1}, 0.15)
        porta:setMapObject(mapObject)
        porta:setWorld(world)
    end

    collectablesLayer:createConvertObjectFunction()
end

function initgame(map)

    font = love.graphics.newFont("font.ttf", 17)
    love.graphics.setFont(font)

    morte = love.audio.newSource("sons/morte.ogg", "static")
    morte:setVolume(0.9) -- 90% of ordinary volume
    
    menusound = love.audio.newSource("sons/menu.mp3", "static")
    menusound:setVolume(0.9) -- 90% of ordinary volume

    hit = love.audio.newSource("sons/hit.mp3", "static")
    hit:setVolume(0.9) -- 90% of ordinary volume

    coletarlife = love.audio.newSource("sons/coletar.ogg", "static")
    coletarlife:setVolume(0.9) -- 90% of ordinary volume
    
    coletarbook = love.audio.newSource("sons/coletarbook.mp3", "static")
    coletarbook:setVolume(0.9) -- 90% of ordinary volume

    coletarmoeda = love.audio.newSource("sons/coletarmoeda.mp3", "static")
    coletarmoeda:setVolume(0.9) -- 90% of ordinary volume

    musica = love.audio.newSource("sons/musica.mp3", "stream")
    musica:setVolume(0.1) -- 90% of ordinary volume

    musica:setLooping(true)                              -- all instances will be looping
    love.audio.play(musica) 

    inithud(map)
    
    initplayer(map)

    initenemies(map)

    initstones(map)

    initcollectables(map)

    endgame = {}
    endgame.x = 300
    endgame.y = 350
    
end

function initstartscreen()
    startbackground = love.graphics.newImage("background800x600.png")

    logo = love.graphics.newImage("logo.png")

    banner = love.graphics.newImage("ls-banner.png")
    
    bannerfinal = love.graphics.newImage("bannerfinal.png")

    cursor = {}
    cursor.imagem = love.graphics.newImage("cursor.png")
    cursor.x = 185
    cursor.y = 350
    cursor.opcao = "play"

    iniciar = {}
    iniciar.x = 300
    iniciar.y = 350
    iniciar.w = 350
    iniciar.h = 50
    iniciar.text = "Iniciar"

    ajuda = {}
    ajuda.x = 300
    ajuda.y = 400
    ajuda.w = 350
    ajuda.h = 50
    ajuda.text = "Ajuda"

    
end

function initgameoverscreen()
    gameoverbackground = love.graphics.newImage("background3-800x600.png")
    gameoverbanner = love.graphics.newImage("gameover.png")

    menu = {}
    menu.x = 250
    menu.y = 250
    menu.w = 350
    menu.h = 50
    menu.text = "q - para sair"

    

    
end

function inithelpscreen()
    help = {}
    help.grumpy = {}
    help.grumpy.imagem = love.graphics.newImage('grumpy.png')
    help.grumpy.grid = anim8.newGrid(64, 64, help.grumpy.imagem:getWidth(), help.grumpy.imagem:getHeight())
    help.grumpy.animation = anim8.newAnimation(help.grumpy.grid(1,1), 0.9)


    help.skull = {}
    help.skull.imagem = love.graphics.newImage('skullidle.png')
    help.skull.grid = anim8.newGrid(64, 64, help.skull.imagem:getWidth(), help.skull.imagem:getHeight())
    help.skull.animation = anim8.newAnimation(help.skull.grid(1,1), 0.9)
    

    help.frog = {}
    help.frog.imagem = love.graphics.newImage('PlayerSprite0_3_2.png')
    help.frog.grid = anim8.newGrid(64, 64, help.frog.imagem:getWidth(), help.frog.imagem:getHeight())
    help.frog.animation = anim8.newAnimation(help.frog.grid(1,1), 0.9)
  
    help.idle = {}
    help.idle.imagem = love.graphics.newImage('idle.png')
    help.idle.grid = anim8.newGrid(64, 64, help.idle.imagem:getWidth(), help.idle.imagem:getHeight())
    help.idle.animation = anim8.newAnimation(help.idle.grid(1,1), 0.9)


    help.coin = {}
    help.coin.imagem = love.graphics.newImage('HUD/hud_coins.png')

    help.life = {}
    help.life.imagem = love.graphics.newImage('HUD/hud_heartFull.png')
    
    help.book = {}
    help.book.imagem = love.graphics.newImage('spellbook.png')
    --help.coin.grid = anim8.newGrid(64, 64, help.coin.imagem:getWidth(), help.coin.imagem:getHeight())
    --help.coin.animation = anim8.newAnimation(help.coin.grid(1,1), 0.9)

    
    
end