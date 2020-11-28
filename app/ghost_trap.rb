class GhostTrap
  attr_accessor :grid, :inputs, :state, :outputs

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
    state.ghosts ||= 5.map { Ghost.spawn }
    state.mode ||= :title
    state.timer ||= 20
    state.score ||= 0
    state.start_countdown ||= 3
  end

  def calc
    calc_play if state.mode == :play
  end

  def freeze?
    state.start_countdown > 0
  end

  def calc_play
    if state.tick_count % 60 == 0

      play_sound("sounds/alarm.wav") if state.timer == 5

      freeze? ? state.start_countdown -=1 : state.timer -= 1
    end

    state.mode = :game_over if is_game_over?

    if !freeze?
      state.ghosts << Ghost.spawn if can_spawn_ghost?

      # state.disposal.calc(state.player)

      state.player.calc(outputs, state.tick_count)

      state.ghosts.each do |g|
        if state.player.is_shooting &&
          g.has_free_will &&
          g.should_be_caught_by_beam?(state.player.beam) &&
          state.player.can_fit_all_beam_ghosts_in_pack?

            g.get_caught_in_beam
            state.player.add_ghost_to_beam(g)

        end

        g.stick_to_beam(state.player.beam) if !g.has_free_will

        g.calc(state.tick_count)

      end
    end

  end

  def can_spawn_ghost?
    rand >= 0.8 && state.tick_count & 60 == 0 && state.ghosts.size < MAX_GHOSTS
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

  def process_inputs
    if state.mode == :title && inputs.keyboard.key_down.space
      inputs.keyboard.clear
      state.mode = :play
    end


    if state.mode == :play
      state.player.stop_moving if !inputs.keyboard.d || !inputs.keyboard.right || !inputs.keyboard.a || !inputs.keyboard.left
      state.player.move_right if inputs.keyboard.d || inputs.keyboard.right
      state.player.move_left if inputs.keyboard.a || inputs.keyboard.left

      state.player.is_shooting = true if inputs.keyboard.key_down.space
      state.player.is_shooting = false if inputs.keyboard.key_up.space

      state.player.dispose_of_ghosts(state.disposal) if inputs.keyboard.key_down.e && state.player.has_ghosts_in_pack?
    end

  end

  def render
    render_title if state.mode == :title
    render_play if state.mode == :play
    render_game_over if state.mode == :game_over
  end

  def render_title
    outputs.solids << [0, 0, $WIDTH, $HEIGHT, 0, 0, 0]

    outputs.sprites << [0, 0, $WIDTH, $HEIGHT, "sprites/title-screen.png"]

    outputs.labels << [grid.w.half - 120, 100, "Press [SPACEBAR] to Begin", 255, 255, 255]
  end

  def set_countdown_sprite
    return if !freeze?

    sprite = []
    path = 'sprites/'
    x = grid.w.half
    y = grid.h - 120
    case state.start_countdown
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
    outputs.sprites << state.player.render

    # hydrant
    outputs.sprites << [1124, 32, 133, 278, 'sprites/hydrant.png']

    state.player.render_beam_power(outputs)

    # start countdown timer
    outputs.sprites << set_countdown_sprite if state.start_countdown > 0

    render_timer if !freeze?

    # display combo, if there is one, & if player can catch ghosts
    if state.player.space_in_pack?
      total_ghosts_on_beam = state.player.total_ghosts_on_beam
      combo_sprite = nil

      if total_ghosts_on_beam > 1
        combo_sprite = "sprites/combo/#{total_ghosts_on_beam}x.png"
        outputs.sprites << [1010, 670, 49, 42, combo_sprite]
        outputs.sprites << [1070, 670, 183, 43, "sprites/combo.png"]
      end
    end

    # if pack is full, show 'empty pack!' text
    if !state.player.space_in_pack?
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
  end

  def play_sound(sound)
    outputs.sounds << sound
  end

end