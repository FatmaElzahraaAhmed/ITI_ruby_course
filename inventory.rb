
require 'json'

class Inventory
  attr_reader :books

  def initialize(books_file = 'books.txt')
    @books_file = books_file
    @books = load_books
  end

  def load_books
    return [] unless File.exist?(@books_file) && !File.zero?(@books_file)
  
    File.open(@books_file, 'r') do |file|
      return JSON.parse(file.read, symbolize_names: true)
    end
  end
  

  def save_books
    File.open(@books_file, 'w') do |file|
      file.write(JSON.pretty_generate(@books))
    end
  end

  def list_books
    @books.each do |book|
      puts "Title: #{book[:title]}, Author: #{book[:author]}, ISBN: #{book[:isbn]}"
    end
  end

  def add_book(title, author, isbn)
    return puts "Error: Title, author, or ISBN cannot be empty" if [title, author, isbn].any?(&:empty?)

    existing_book = @books.find { |b| b[:isbn] == isbn }
    
    if existing_book
      existing_book[:title] = title
      existing_book[:author] = author
      existing_book[:count] += 1
    else
      @books << { title: title, author: author, isbn: isbn, count: 1 }
    end

    save_books
    puts "Book added successfully!"
  end

  def remove_book(isbn)
    book = @books.find { |b| b[:isbn] == isbn }
    
    if book
      @books.delete(book)
      save_books
      puts "Book removed successfully!"
    else
      puts "Error: No book found with ISBN #{isbn}"
    end
  end

  def sort_books
    @books.sort_by! { |b| b[:isbn] }
    save_books
    puts "Books sorted by ISBN."
  end

  def search_books(query, field)
    return puts "Error: Search query cannot be empty" if query.empty?
    
    found_books = @books.select { |b| b[field.to_sym].downcase.include?(query.downcase) }

    if found_books.any?
      found_books.each do |book|
        puts "Title: #{book[:title]}, Author: #{book[:author]}, ISBN: #{book[:isbn]}"
      end
    else
      puts "No books found for '#{query}' in field '#{field}'"
    end
  end
end

inventory = Inventory.new

loop do
  puts "\n--- Book Inventory Menu ---"
  puts "1. List books"
  puts "2. Add a new book"
  puts "3. Remove a book by ISBN"
  puts "4. Sort books by ISBN"
  puts "5. Search books"
  puts "6. Exit"
  print "Select an option (1-6): "

  choice = gets.chomp

  case choice
  when '1'
    inventory.list_books
  when '2'
    print "Enter book title: "
    title = gets.chomp
    print "Enter book author: "
    author = gets.chomp
    print "Enter book ISBN: "
    isbn = gets.chomp
    inventory.add_book(title, author, isbn)
  when '3'
    print "Enter ISBN of the book to remove: "
    isbn = gets.chomp
    inventory.remove_book(isbn)
  when '4'
    inventory.sort_books
  when '5'
    puts "Search by:"
    puts "1. Title"
    puts "2. Author"
    puts "3. ISBN"
    print "Select search field (1-3): "
    field_choice = gets.chomp

    field = case field_choice
            when '1' then 'title'
            when '2' then 'author'
            when '3' then 'isbn'
            else
              puts "Invalid field choice."
              next
            end
    
    print "Enter search query: "
    query = gets.chomp
    inventory.search_books(query, field)
  when '6'
    break
  else
    puts "Invalid choice. Please try again."
  end
end
