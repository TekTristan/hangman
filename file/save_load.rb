require 'yaml'

class SaveLoad
  def save_game(hangman_instance)
    game_state = {
      "user_name" => hangman_instance.user_name,
      "guess_count" => hangman_instance.guess_count,
      "word_holder" => hangman_instance.word_holder,
      "wrong_set" => hangman_instance.wrong_set,
      "sample_word" => hangman_instance.sample_word,
      "guess_list" => hangman_instance.guess_list
    }
    Dir.mkdir("saved_games") unless Dir.exist?("saved_games")
  
    file_name = "saved_games/#{hangman_instance.user_name}_hangman.yml"
  
    File.open(file_name, "w") { |file| file.write(game_state.to_yaml) }
  end

  def load_game(file_name)
    file_path = "saved_games/#{file_name}_hangman.yml"
    if File.exist?(file_path)
      game_state = YAML.load_file(file_path)
      return game_state
    else
      puts "No save file found for #{file_name}"
      return nil
    end
  end
end  
  