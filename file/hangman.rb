require_relative 'save_load'

class HangMan
  attr_accessor :word_size, :user_guess, :user_guess_size, :guess_count, :word_holder, :wrong_set, :game_over, :guess_list, :file_save, :sample_word, :user_name

  def initialize
    @word_size = 0
    @user_guess = ""
    @user_guess_size = 1
    @guess_count = 10
    @word_holder = {}
    @wrong_set = []
    @game_over = false
    @guess_list = {}
    @sample_word = ''
    @user_name = ''
    @save_load = SaveLoad.new
    read_words_from_file
  end

  def read_words_from_file
    @sample_word = File.readlines("word.txt").sample.strip
    @sample_word.chars.each { |char| @word_holder[char] = false }
  end

  def start_game
    puts "Would you like to: 1) start a new game, 2) load a game"
    choice = gets.chomp
    choice == '1' ? new_game : load_game
  end

  def new_game
    puts "What is your name?"
    @user_name = gets.chomp.downcase
    name_check
    game_loop
  end

  def name_check
    existing_names = []
  
    Dir.glob("saved_games/*.yml").each do |file|
      game_state = YAML.load_file(file)
      existing_names << game_state["user_name"]
    end

    if existing_names.include?(@user_name)
      puts "Name exists. Would you like to 1) Override or 2) Change name?"
      choice = gets.chomp
  
      case choice
      when '1'
        puts "Overriding existing save."
      when '2'
        puts "Please enter a new name:"
        @user_name = gets.chomp.downcase
        name_check 
      else
        puts "Invalid choice."
        name_check 
      end
    end
  end

  def load_game
    list_saved_games
    selected_file = gets.chomp.downcase
    game_state = @save_load.load_game(selected_file)
    
    if game_state
      @user_name = game_state["user_name"]
      @guess_count = game_state["guess_count"]
      @word_holder = game_state["word_holder"]
      @wrong_set = game_state["wrong_set"]
      @sample_word = game_state["sample_word"]
      @guess_list = game_state["guess_list"]
      game_loop
    else
      puts "Failed to load game."
    end
  end

  def game_loop
    until @game_over
      user_guessing
    end
    game_over_message
  end

  def user_guessing
    display_game_state
    puts "Your guess? Or type 'save' to save the game."
    @user_guess = gets.chomp.downcase

    if @user_guess == 'save'
      save_game
    elsif guess_valid
      word_cycle
    else
      puts "Invalid guess. Try again."
      user_guessing
    end
  end

  def guess_valid
    return false if @user_guess.length != @user_guess_size
    return false if @user_guess.match?(/[0-9!@#$%^&*()]/)
    true
  end

  def word_cycle        
    if @sample_word.include?(@user_guess)
      check_letter
      @guess_list[@user_guess] = true
      all_occurrences_found = @sample_word.chars.all? do |char|
        char != @user_guess || @word_holder[char]
      end
  
      if all_occurrences_found
        puts "You've found all occurrences of the letter #{@user_guess}."
      else
        puts "Correct guess! Keep going to find all occurrences."
      end
  
      @word_holder[@user_guess] = true
    else
      check_letter
      puts "No, the letter '#{user_guess}' is not present in the word."
      @guess_count -= 1
      @wrong_set << @user_guess
      @guess_list[@user_guess] = true
    end
    
    user_guessing
  end

  def check_letter
    if @guess_list.key?(@user_guess)
      puts "you already guessed that letter!"
      user_guessing
    end
  end

  def display_game_state
    puts "Guesses remaining: #{@guess_count}"
    puts "Word: #{convert_word}"
    puts "Wrong guesses: #{@wrong_set.join(', ')}"
  end

  def convert_word
    @sample_word.chars.map { |char| @word_holder[char] ? char : '_' }.join(' ')
  end

  def save_game
    @save_load.save_game(self)
    puts "Game saved!"
    exit
  end

  def list_saved_games
    puts "Saved games:"
    Dir.glob("saved_games/*.yml").each do |file|
      game_state = YAML.load_file(file)
      puts game_state["user_name"]
    end
  end

  def game_over_message
    puts "Game Over!"
    puts "The correct word was: #{@sample_word}"
  end
end

hangman_instance = HangMan.new
hangman_instance.start_game
