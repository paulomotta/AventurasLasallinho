local ATL = require("AdvTiledLoader") 
ATL.Loader.path = 'maps/'
local map = ATL.Loader.load("lasallinho_map2.tmx") 

local bump = require 'bump'
require 'initgame'
local world = bump.newWorld(64)
local anim8 = require 'anim8'
local actor = require 'actor'
local customLayer = require 'customLayer'
require 'slam'
--objetos que serao desenhados, mas a classe actor precisa manter a lista de 
--actors existentes para que possa remover dessa lista caso um item seja
--coletado ou um inimigo morto
objectsToDraw = actor.listOfActors

--as pedras podem ser mantidas em uma tabela local porque nao vao ser quebradas
stonesToDraw = actor.listOfColliders

--gameState values: start, play, help, over, credits, win

function love.load()
  
    initgame(map)
    initstartscreen()
    inithelpscreen()
    initgameoverscreen()
  
    love.keyboard.setKeyRepeat( true )

    --posicao original do mapa
    tx = -lasallinho:getMapObject().x + 64
    ty = -767
    gameState = 'start'
    lookDown = 0

    os_string = love.system.getOS( )
    android = false
    if (os_string:find("Android")) then
        android = true
    end

    screenH = love.graphics.getHeight( )
    screenW = love.graphics.getWidth( )
  
    scaleH = screenH / 600
    scaleW = screenW / 800
end

-- Move the camera
function love.update(dt)

    --move a camera e o hud
    offsetx = lasallinho:getMapObject().x - 115
    tx = -lasallinho:getMapObject().x + 115
    
    ty = -lasallinho:getMapObject().y + 400 - lookDown
    offsety = lasallinho:getMapObject().y - 650

    --on screen controls
    

    local x = 10 + offsetx
    leftButton.x = x
    leftButton.y = screenH + offsety + lasallinho:getSprite():getHeight()

    x = x + leftButton.imagem:getWidth() + 100
    rightButton.x = x
    rightButton.y = screenH + offsety + lasallinho:getSprite():getHeight()

    x = x + screenW - 300
    upButton.x = x
    upButton.y = screenH + offsety + lasallinho:getSprite():getHeight()


    if(gameState == 'play') then
        updateGame(dt)
    elseif (gameState == 'start') then
        updateStartScreen(dt)
    elseif (gameState == 'help') then
        updateHelpScreen(dt)
    elseif (gameState == 'over') then
        updateGameOverScreen(dt)
    elseif (gameState == 'win') then
        updateWin(dt)
    end

end

function updateGame(dt)
    for i=1,(actor.actorId-1) do
        if (objectsToDraw[i] ~= nil ) then
            objectsToDraw[i]:update(dt)
        end
    end
    if (lasallinho:getLifes() <=0 ) then
        gameState = "over"
        cursor.x = 185
        cursor.y = 250
        cursor.opcao = "start"
        morte:play()
    end

    if (lasallinho:iswin()) then
        gameState = "win"
    end

    if love.keyboard.isDown("down") then
        lookDown = 200
    end

    if not love.keyboard.isDown("down") then
        lookDown = 0
    end
end

function updateWin(dt)
    if (android) then
        for i = 1, love.touch.getTouchCount() do
            local index, x, y, pressure = love.touch.getTouch(i)
            local cx = x * love.graphics.getWidth() + offsetx
            local cy = y * love.graphics.getHeight() + offsety + 450 
            if (cx > endgame.x and cx < endgame.x + 750 and cy > endgame.y and cy < endgame.y + 350) then
                menusound:play()
                love.event.quit( )
            end
        end
    else
        if love.keyboard.isDown("q") then
            menusound:play()
            love.event.quit( )
        end
    end
end

function updateStartScreen(dt)

    if (android) then
        for i = 1, love.touch.getTouchCount() do
          local index, x, y, pressure = love.touch.getTouch(i)
          local cx = x * love.graphics.getWidth()
          local cy = y * love.graphics.getHeight()

            if (cx > iniciar.x and cx < (iniciar.x + iniciar.w) and cy > iniciar.y and cy < (iniciar.y + iniciar.h)) then
                gameState = "play"
                menusound:play()
            elseif (cx > ajuda.x and cx < (ajuda.x + ajuda.w) and cy > ajuda.y and cy < (ajuda.y + ajuda.h)) then
                gameState = "help"
                menusound:play()
            end
        end
    else

        if love.keyboard.isDown("down") then
            if (cursor.y < ajuda.y ) then
                cursor.y = cursor.y + 50
                cursor.opcao = "help"
                menusound:play()
            end
        end

        if love.keyboard.isDown("up") then
            if (cursor.y > iniciar.y ) then
                cursor.y = cursor.y - 50
                cursor.opcao = "play"
                menusound:play()
            end
        end

        if love.keyboard.isDown(" ") then
            gameState = cursor.opcao
            print("mudando gamestate para "..gameState)
            menusound:play()
        end
    end
end

function updateGameOverScreen(dt)
    if (android) then
        for i = 1, love.touch.getTouchCount() do
          local index, x, y, pressure = love.touch.getTouch(i)
          local cx = x * love.graphics.getWidth()
          local cy = y * love.graphics.getHeight() 
            if (cx > 250 and cx < 750 and cy > 250 and cy < 350) then
                menusound:play()
                love.event.quit( )
            end
        end
    else
        if love.keyboard.isDown("q") then
            menusound:play()
            love.event.quit( )
        end
    end
end

function updateHelpScreen(dt)

    if (android) then
        for i = 1, love.touch.getTouchCount() do
          local index, x, y, pressure = love.touch.getTouch(i)
          local cx = x * love.graphics.getWidth()
          local cy = y * love.graphics.getHeight() 
            if (cx > 50 and cx < 750 and cy > 450 and cy < 550) then
                cursor.opcao = "play"
                gameState = "start"
                menusound:play()
            end
        end
    else
        if love.keyboard.isDown("escape") then

                cursor.opcao = "play"
                gameState = "start"
                menusound:play()

        end
    end

end

-- Draw the map
function love.draw() 

    if(gameState == 'play') then
        drawGame()
    elseif (gameState == 'start') then
        drawStartScreen()
    elseif (gameState == 'help') then
        drawHelpScreen()
    elseif (gameState == 'over') then
        drawGameOverScreen()
     elseif (gameState == 'win') then
        drawGame()
    end
  
 
end

local function drawBox(box, r,g,b)
    love.graphics.setColor(r,g,b,70)
    love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
    love.graphics.setColor(r,g,b)
    love.graphics.rectangle("line", box.x, box.y, box.w, box.h)
    love.graphics.setColor(255,255,255)
    love.graphics.print(box.text, box.x + box.w/4, box.y, 0 ,2 ,2)
end

function drawStartScreen()
    love.graphics.setBackgroundColor( 192, 255, 255 )
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(startbackground, 0, 0, 0, scaleW, scaleH)
    
    love.graphics.draw(logo, screenW/4, 20, 0, scaleW, scaleH)
    love.graphics.draw(banner, screenW/6, (logo:getHeight() * scaleH) + 10, 0, scaleW, scaleH)
    
    iniciar.x = screenW/4
    iniciar.y = (logo:getHeight() * scaleH) + 250
    ajuda.x = iniciar.x
    ajuda.y = iniciar.y + 50

    if (cursor.x == 185) then
        cursor.x = iniciar.x - 150
        cursor.y = iniciar.y
    end

    love.graphics.draw(cursor.imagem, cursor.x,cursor.y, 0, scaleW, scaleH)
    drawBox(iniciar, 0 ,0 ,255)
    drawBox(ajuda, 0 ,0 ,255)
    
    love.graphics.setColor(0,0,0)
 
    local participantesy = 500
    love.graphics.print("Participantes", 150, participantesy, 0, scaleW, scaleH)
    participantesy = participantesy + 20
    love.graphics.print("Programação: Paulo Motta", 150, participantesy, 0, scaleW, scaleH)
    participantesy = participantesy + 20
    love.graphics.print("Ilustração LaSallinho: Ricardo Basílio", 150, participantesy, 0, scaleW, scaleH)
    participantesy = participantesy + 20
    love.graphics.print("Agradecimentos:", 150, participantesy, 0, scaleW, scaleH)
    participantesy = participantesy + 20
    love.graphics.print("    Márcia Sadock, Mario João", 150, participantesy, 0, scaleW, scaleH)
    participantesy = participantesy + 20
    love.graphics.print("    Douglas Nascimento, Felipe Brito", 150, participantesy, 0, scaleW, scaleH)
    participantesy = participantesy + 20
    love.graphics.print("    Vitor Garcia, Francis Kjaer", 150, participantesy, 0, scaleW, scaleH)
    participantesy = participantesy + 20
    love.graphics.print("Arte: OpenGameArt.org", 150, participantesy, 0, scaleW, scaleH)

    --if (android) then
    --    for i = 1, love.touch.getTouchCount() do
    --        local index, x, y, pressure = love.touch.getTouch(i)
    --        local cx = x * love.graphics.getWidth() 
    --        local cy = y * love.graphics.getHeight() 

    --        love.graphics.print("cx="..cx.." cy="..cy, 500, 500)
    --        love.graphics.print("iniciar.x="..iniciar.x, 500, 520)
    --        love.graphics.print("iniciar.w="..iniciar.w, 500, 540)
    --        love.graphics.print("iniciar.y="..iniciar.y, 500, 560)
    --        love.graphics.print("iniciar.h="..iniciar.h, 500, 580)

    --    end
    --end
    
    
end

function drawGameOverScreen()
    love.graphics.setBackgroundColor( 192, 255, 255 )
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(gameoverbackground, 0, 0, 0, scaleW, scaleH)
    love.graphics.draw(gameoverbanner, screenW/4, 100, 0 , scaleW, scaleH)
    
    love.graphics.setColor(255,0,0)
    msg = "Aperte 'Q' para sair"
    if (android) then
        msg = "Clique aqui para encerrar"
    end
    love.graphics.print(msg, 250, 250,0, scaleW, scaleH)

    --if (android) then
    --    for i = 1, love.touch.getTouchCount() do
    --        local index, x, y, pressure = love.touch.getTouch(i)
    --        local cx = x * love.graphics.getWidth() 
    --        local cy = y * love.graphics.getHeight() 
    --        
    --        love.graphics.setColor(255,255,255)
    --        love.graphics.print("cx="..cx.." cy="..cy, 500, 500)
    --        love.graphics.print("x=250", 500, 520)
    --        love.graphics.print("w=750", 500, 540)
    --        love.graphics.print("y=250", 500, 560)
    --        love.graphics.print("h=350", 500, 580)
    --
    --    end
    --end
 
end

function drawHelpScreen()
    love.graphics.setBackgroundColor( 192, 255, 255 )
    love.graphics.setColor(255, 255, 255)
    
    help.grumpy.animation:draw(help.grumpy.imagem, 50 , 50)
    help.skull.animation:draw(help.skull.imagem, 120 , 50)
    help.frog.animation:draw(help.frog.imagem, 50 , 110)
    help.idle.animation:draw(help.idle.imagem, 120 , 110)
    
    --help.grumpy.animation:draw(help.grumpy.imagem, 250 , 50)
    love.graphics.draw(help.coin.imagem, 250,50)
    --help.skull.animation:draw(help.skull.imagem, 320 , 50)
    love.graphics.draw(help.life.imagem, 320,50)
    --help.frog.animation:draw(help.frog.imagem, 250 , 110)
    love.graphics.draw(help.book.imagem, 250,110)
    --help.idle.animation:draw(help.idle.imagem, 320 , 110)

    love.graphics.setColor(0, 0, 0)
    love.graphics.print("Inimigos: Pise neles!", 50, 20)
    love.graphics.print("Itens: Colete!", 250, 20)
    love.graphics.print("Use as setas direcionais para controlar o LaSallinho", 50, 340)
    love.graphics.print("Use a barra de espaço para pular", 50, 360)

    msg = "Use ESC para voltar para a tela inicial"
    if (android) then
        msg = "Clique aqui para voltar a tela inicial"
    end
    --love.graphics.print(msg, 250, 250,0, scaleW, scaleH)
    love.graphics.print(msg, 50, 400, 0, scaleW, scaleH)
    
    
end

function drawGame()

  love.graphics.setBackgroundColor( 192, 255, 255 )
  love.graphics.setColor(255, 255, 255)
  -- Apply the translation
  love.graphics.translate( math.floor(tx), math.floor(ty) )

    -- Set the draw range. Setting this will significantly increase drawing performance.
  map:autoDrawRange( math.floor(tx), math.floor(ty), 1, pad)
  map:draw() 
  
  
  --love.graphics.setBackgroundColor( 222, 222, 222 )
  love.graphics.setColor(255, 255, 255)
  
    --print(#objectsToDraw.." "..actor.actorId)
    for i=1,(actor.actorId-1) do
        if (objectsToDraw[i] ~= nil ) then
            objectsToDraw[i]:draw()
            --print("draw:"..objectsToDraw[i].name)
        end
    end

    for i=1,(actor.colliderId-1) do
        stonesToDraw[i]:draw()
    end

    local x = 10 + offsetx
    love.graphics.draw(logo, x, 300 + offsety)
    
    love.graphics.draw(heartImage, x, 400 + offsety)

    x = x + heartImage:getWidth() + 42
    love.graphics.draw(coinImage, x, 400 + offsety)

    x = x + coinImage:getWidth() + 42
    love.graphics.draw(bibleImage, x, 400 + offsety)

    if (android) then
        --on screen controls
        love.graphics.draw(upButton.imagem, upButton.x, upButton.y)

        love.graphics.draw(leftButton.imagem, leftButton.x, leftButton.y)

        love.graphics.draw(rightButton.imagem, rightButton.x, rightButton.y)
    end

    --[[love.graphics.setColor(0, 0, 0)
    
    love.graphics.line( upButton.x+80, 0, upButton.x+80, 3000 )

    love.graphics.setColor(255, 0, 0)
    love.graphics.line( leftButton.x - 80, 0, leftButton.x - 80, 3000 )
    love.graphics.line( rightButton.x - 50, 0, rightButton.x - 50, 3000 )

    love.graphics.setColor(0, 255, 255)
    love.graphics.line( rightButton.x - 45, 0, rightButton.x - 45, 3000 )
    ]]--

    
    love.graphics.setColor(0, 0, 0)

    x = 10 + offsetx + 32
    love.graphics.print("x"..lasallinho:getLifes(), x, 400 + offsety)
    x = x + heartImage:getWidth() + 42
    love.graphics.print("x"..lasallinho:getCoins(), x, 400 + offsety)
    x = x + coinImage:getWidth() + 42
    love.graphics.print("x"..lasallinho:getBibles(), x, 400 + offsety)

    x = 10 + offsetx
    love.graphics.print("Score:"..lasallinho:getScore(), x, 432 + offsety)

    if (gameState == 'win') then
        -- love.graphics.setColor(0,0,222,70)
        -- love.graphics.rectangle("fill", offsetx+100, offsety+350, 600, 300)
        --love.graphics.setColor(0,0,222)
        --love.graphics.rectangle("line", offsetx+100, offsety+350, 600, 300)
        --love.graphics.setColor(255,255,255)
        --love.graphics.print("Parabéns! Você ajudou o LaSallinho", offsetx+150, offsety+500)
        --love.graphics.print("a levar os livros para a LaSalle", offsetx+150, offsety+520)
        --love.graphics.print("Viva Jesus em nossos corações! Para sempre!", offsetx+150, offsety+550)
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(bannerfinal, offsetx + (screenW/5), offsety+350, 0, scaleW, scaleH)

        love.graphics.setColor(0,0,0)
        msg = "Aperte 'Q' para sair"
        if (android) then
            msg = "Clique aqui para encerrar"
        end
        endgame.x = offsetx + (screenW/4)
        endgame.y = offsety + 450 + (bannerfinal:getHeight() * scaleH)
        love.graphics.print(msg, endgame.x, endgame.y, 0, scaleW, scaleH)

        --love.graphics.rectangle("line", endgame.x ,endgame.y, endgame.x + 750, endgame.y + 350)

        --for i = 1, love.touch.getTouchCount() do
        --    local index, x, y, pressure = love.touch.getTouch(i)
        --    local cx = x * love.graphics.getWidth() + offsetx
        --    local cy = y * love.graphics.getHeight() + offsety
        --    love.graphics.print("cx="..cx.." cy="..cy, endgame.x, endgame.y - 20, 0, scaleW, scaleH)
        --    love.graphics.print("endgame[x,y]="..endgame.x..","..endgame.y, endgame.x, endgame.y - 40, 0, scaleW, scaleH)
        --end
    end
    
    --[[
    if (os_string:find("Android")) then
        for i = 1, love.touch.getTouchCount() do
          local index, x, y, pressure = love.touch.getTouch(i)
           local cx = x * love.graphics.getWidth()
           local cy = y * love.graphics.getHeight()
          love.graphics.print("Touch", cx, cy)
          x = 10 + offsetx + 32
          y = 470 + offsety
          love.graphics.print("Touch "..cx.. " "..cy,x,y)
        end

        x = 10 + offsetx + 32
        y = 450 + offsety
        love.graphics.print("TouchCount="..love.touch.getTouchCount(), x, y)
        
        y = y + 50
        love.graphics.print("upButton.x+80="..upButton.x+80, x, y)
        y = y + 50
        love.graphics.print("leftButton.x - 80="..leftButton.x - 80, x, y)
        y = y + 50
        love.graphics.print("rightButton.x - 50="..rightButton.x - 50, x, y)
        y = y + 50
        love.graphics.print("rightButton.x - 45="..rightButton.x - 45, x, y)

    end
    ]]--
end

