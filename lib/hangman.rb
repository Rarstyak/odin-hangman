# frozen_string_literal: true

require 'json'
require 'set'

puts 'Executing hangman'

# Runs the game hangman in the cli
class Hangman
  ALPHABET = ('a'..'z').freeze
  WORD_BANK = File.readlines('google-10000-english-no-swears.txt').map(&:chomp).select { |w| w.length.between?(5, 12) }
  GUESSES_TOTAL = 6

  def initialize
    @correct = Set.new
    @incorrect = Set.new

    new_secret_word

    @guesses = 0
    @status = :prog
  end

  def play
    loop do
      clear_screen
      print_header('HANGMAN')
      print_status
      print_word
      print_letters
      puts '1. Save'
      puts '2. Load'
      puts '3. Reset'
      puts '*. Guess'
      puts ''
      p select = gets.to_s[0].downcase
      case select
      when '1' then game_save
      when '2' then game_load
      when '3' then game_reset
      when ALPHABET then guess(select)
      end
    end
  end

  private

  def game_save
    File.write('save.json', JSON.dump({
                                        correct: @correct.to_a,
                                        incorrect: @incorrect.to_a,
                                        secret_word: @secret_word,
                                        guesses: @guesses,
                                        status: @status
                                      }))
  end

  def game_load
    return unless File.exist? 'save.json'

    data = JSON.parse File.read('save.json')
    @correct = data['correct'].to_a.to_set
    @incorrect = data['incorrect'].to_a.to_set
    @secret_word = data['secret_word']
    @guesses = data['guesses']
    @status = data['status'].to_sym
  end

  def game_reset
    @correct.clear
    @incorrect.clear

    new_secret_word

    @guesses = 0
    @status = :prog
  end

  def new_secret_word
    @secret_word = WORD_BANK.sample
  end

  def update_status
    @status = :win  if @secret_word.split('').to_set.subset?(@correct)
    @status = :lose if @guesses == GUESSES_TOTAL
  end

  def guess(char)
    return if @status != :prog || @correct.include?(char) || @incorrect.include?(char)

    if @secret_word.to_s.include?(char)
      @correct.add(char)
    else
      @incorrect.add(char)
      @guesses += 1
    end
    update_status
  end

  def print_header(title)
    puts '=' * (title.length + 6)
    puts "=  #{title}  ="
    puts '=' * (title.length + 6)
    puts ''
  end

  def print_word
    case @status
    when :prog then puts "| Secret    |#{@secret_word.split('').map { |l| @correct.include?(l) ? l : '_' }.join(' ')}|"
    when :win  then puts "| Solved    |#{@secret_word.split('').join(' ')}|"
    when :lose then puts "| Solution  |#{@secret_word.split('').join(' ')}|"
    end
    puts ''
  end

  def print_letters
    puts "| Letters   |#{ALPHABET.to_a.join('|')}|"
    puts "| Correct   |#{ALPHABET.to_a.map { |l| @correct.include?(l) ? l : ' ' }.join('|')}|"
    puts "| Incorrect |#{ALPHABET.to_a.map { |l| @incorrect.include?(l) ? l : ' ' }.join('|')}|"
    puts ''
  end

  def print_status
    case @status
    when :prog then puts "#{GUESSES_TOTAL - @guesses} Limbs Left!"
    when :win  then puts 'Game Won!'
    when :lose then puts 'Game Lost!'
    end
    puts ''
  end

  def clear_screen
    print `clear`
  end
end

Hangman.new.play
