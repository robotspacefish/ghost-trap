class GhostTrap
  attr_accessor :grid, :inputs, :state, :outputs, :gtk

  def initialize
    puts "new game"
  end

  def tick
    outputs.sounds << "sounds/Yadu-Rajiv-miniloops-1-22-Adventure-Now-lowered.ogg" if state.tick_count == 1

    defaults
    render
    calc
    process_inputs
  end

  def defaults
    state.player ||= Player.new
    state.disposal ||= Disposal.new
    state.ghosts ||= MAX_GHOSTS.map { Ghost.spawn }
    state.mode ||= :title
    state.timer ||= 20
    state.score ||= 0
    state.countdown ||= 3
  end

  def calc
    calc_play if state.mode == :play
  end

  def freeze?
    state.countdown > 0
  end

  def calc_play
    if state.tick_count % 60 == 0

      play_sound("sounds/alarm.wav") if state.timer == 5

      freeze? ? state.countdown -=1 : state.timer -= 1
    end

    state.mode = :game_over if is_game_over?

    if !freeze?
      state.ghosts << Ghost.spawn if can_spawn_ghost?

      state.disposal.calc(state.tick_count)

      player.calc(outputs, state.tick_count)

      state.ghosts.each do |g|
        if player.is_shooting &&
          g.has_free_will &&
          g.should_be_caught_by_beam?(player.beam) &&
          player.can_fit_all_beam_ghosts_in_pack?

            g.get_caught_in_beam
            player.add_ghost_to_beam(g)

        end

        g.stick_to_beam(player.beam) if !g.has_free_will

        g.calc(state.tick_count)

      end
    end

  end

  def can_spawn_ghost?
    state.tick_count & 60 == 0 && state.ghosts.size < MAX_GHOSTS
  end

  def is_game_over?
    state.timer <= 0
  end

  def add_score(score_to_add)
    state.score += score_to_add
  end

  def remove_ghost(ghost)
    index = state.ghosts.find_index do |gh|
      gh.id == ghost.id
    end

    state.ghosts.slice!(index)
  end

  def player
    state.player
  end

  def process_inputs
    if (state.mode == :title || state.mode == :instructions) && inputs.keyboard.key_down.enter
      inputs.keyboard.clear
      state.mode = :play
    end

    if state.mode == :title && inputs.keyboard.key_down.i
      inputs.keyboard.clear
      state.mode = :instructions
    end

    if state.mode == :play
      player.stop_moving if !inputs.keyboard.d || !inputs.keyboard.right || !inputs.keyboard.a || !inputs.keyboard.left
      player.move_right if inputs.keyboard.d || inputs.keyboard.right
      player.move_left if inputs.keyboard.a || inputs.keyboard.left

      player.is_shooting = true if inputs.keyboard.key_down.space
      player.is_shooting = false if inputs.keyboard.key_up.space

      play_sound("sounds/VOLUME_hit-3.wav") if inputs.keyboard.key_down.space && !player.can_shoot?

      player.dispose_of_ghosts(state.disposal) if inputs.keyboard.key_down.e && player.has_ghosts_in_pack?
    end

    if state.mode == :game_over && inputs.keyboard.key_down.enter
      inputs.keyboard.clear
      gtk.reset
      state.countdown = 4 # extra second so the entire ready, set, etc appears
      state.mode = :play
    end

  end

  def render
    render_title if state.mode == :title
    render_instructions if state.mode == :instructions
    render_play if state.mode == :play
    render_game_over if state.mode == :game_over
  end

  def render_full_screen_sprite(sprite)
    outputs.solids << [0, 0, $WIDTH, $HEIGHT, 0, 0, 0]

    outputs.sprites << [0, 0, $WIDTH, $HEIGHT, sprite]
  end

  def render_instructions
    render_full_screen_sprite("sprites/instructions-no-text.png")

    outputs.labels << center_text("Press [ENTER] to Start Game", -295, 0, 255, 0)

    outputs.labels << center_text("You have 20 seconds to trap as many ghosts as you can.", 330, 255, 255, 0)
    outputs.labels << center_text("Catch multiple ghosts on your beam at a time for a combo.", 300, 255, 255, 0)
    outputs.labels << center_text("Your beam energy depletes over time. Stop shooting to regenerate.", 270, 255, 255, 0)

    instruction("Shoot beam", 364, 553)
    instruction("Move left", 274, 466)
    instruction("Move right", 274, 378)
    instruction("Deposit ghosts in canister", 154, 276)

    instruction("Stand in front of canister and", 154, 160)
    instruction("press E to transfer ghosts", 154, 130)
    instruction("from backpack", 154, 100)

    instruction("Shoot beam at ghosts to catch them.", 844, 563)
    instruction("They are automatically stored in your", 844, 533)
    instruction("pack when you stop shooting", 844, 503)

    instruction("When ghosts are transparent they", 844, 433)
    instruction("cannot be caught", 844, 403)

    instruction("Ghosts are blue when trapped", 844, 333)
    instruction("in your beam", 844, 303)

    instruction("Your pack can hold 10 ghosts.", 754, 203)
    instruction("When the light is red your pack is full.", 754, 173)
    instruction("You can't shoot with a full pack.", 754, 143)
    instruction("Deposit ghosts in canister to fit more", 754, 113)
    instruction("in your pack.", 1024, 83)

  end

  def instruction(text, x, y)
    outputs.labels << [x, y, text, 255, 255, 255]
  end

  def render_title
    render_full_screen_sprite("sprites/title-screen.png")

    outputs.labels << center_text("Press [ENTER] to Start Game", - 240, 0, 255, 0)
    outputs.labels << center_text("Press [I] for Instructions", - 270)
    outputs.labels << center_text("©2020 robotspacefish!", - 330)
  end

  def set_countdown_sprite
    return if !freeze?

    sprite = []
    path = 'sprites/'
    x = grid.w.half
    y = grid.h - 120
    case state.countdown
    when 3
      w = 193
      sprite = [x - w/2, y, w, 67, "#{path}ready.png"]
    when 2
      w = 97
      sprite = [x - w/2, y, w, 57, "#{path}set.png"]
    when 1
      w = 416
      sprite = [x - w/2, y, w, 59, "#{path}catch.png"]
    end

    sprite
  end

  def render_play


    # background
    outputs.sprites << [0, 0, $WIDTH, $HEIGHT, 'sprites/bg.png']


    # ghost disposal
    outputs.sprites << state.disposal.render
    outputs.labels << [600, 311, state.disposal.total_ghosts, 255, 255, 255]

    # ghosts
    outputs.sprites <<  state.ghosts.map { |g| g.render }

    # player
    outputs.sprites << player.render

    # hydrant
    outputs.sprites << [1124, 32, 133, 278, 'sprites/hydrant.png']

    player.render_beam_power(outputs)

    # start countdown timer
    outputs.sprites << set_countdown_sprite if state.countdown > 0

    render_timer if !freeze?

    # display combo, if there is one, & if player can catch ghosts
    if player.space_in_pack?
      total_ghosts_on_beam = player.total_ghosts_on_beam
      combo_sprite = nil

      if total_ghosts_on_beam > 1
        combo_sprite = "sprites/combo/#{total_ghosts_on_beam}x.png"
        outputs.sprites << [1010, 670, 49, 42, combo_sprite]
        outputs.sprites << [1070, 670, 183, 43, "sprites/combo.png"]
      end
    end

    # if pack is full, show 'empty pack!' text
    if !player.space_in_pack?
      outputs.sprites << [980, 660, 270, 51, "sprites/empty-pack.png"]
    end

    # display score
    outputs.sprites << create_sprite_nums(state.score, 10, 680, 's')
  end

  def render_timer
    timer_str = state.timer.to_s
    x = grid.w.half - 60
    y = grid.h - 120

    outputs.sprites << create_sprite_nums(state.timer, x, y)

  end

  def render_game_over
    outputs.solids << [0, 0, $WIDTH, $HEIGHT, 0, 0, 0]
    w = 477
    h = 72
    outputs.sprites << [grid.w.half - w/2, grid.h.half + h, w, h, "sprites/gameover.png"]

    outputs.labels << center_text(
      "You disposed of #{state.disposal.total_ghosts} ghosts", 20
    )

    outputs.labels << center_text("Score:  #{state.score}", -20)

    outputs.labels << center_text("Press [ENTER] to Play Again", - 100)
  end

  def play_sound(sound)
    outputs.sounds << sound
  end

end