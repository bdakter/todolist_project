#! /usr/bin/env ruby

require 'bundler/setup'
require 'stamp'
require 'date'

# item class
class Todo
  DONE_MARKER = 'X'
  NOT_DONE_MARKER = ' '

  attr_accessor :title, :description, :done_marker, :due_date

  def initialize(title, description = '')
    @title = title
    @description = description
    @done_marker = NOT_DONE_MARKER
  end

  def done!
    self.done_marker = DONE_MARKER
  end

  def not_done!
    self.done_marker = NOT_DONE_MARKER
  end

  def done?
    done_marker == DONE_MARKER
  end

  def to_s
    result = "[#{done_marker}] #{title}"
    result += due_date.stamp(' (Due: Friday January 6)') if due_date
    result
  end

  def overdue?
    today = Date.today
    !done? && (today <=> due_date).positive?
  end
end

# collection class
class TodoList
  attr_accessor :title

  def initialize(title)
    @title = title
    @todos = []
  end

  def add(todo)
    raise TypeError, 'Can only add Todo objects' unless todo.instance_of? Todo

    todos << todo
    todos
  end

  alias << add

  def size
    todos.size
  end

  def first
    todos.first
  end

  def last
    todos.last
  end

  def to_a
    todos
  end

  def done?
    todos.all?(&:done?)
  end

  def item_at(index)
    todos.fetch index
  end

  def mark_done_at(index)
    todos.fetch(index).done!
  end

  def mark_undone_at(index)
    todos.fetch(index).not_done!
  end

  def done!
    todos.each(&:done!)
  end

  def to_s
    text = "\n------ Today's Todos ------\n"
    text << todos.map(&:to_s).join("\n")
    text
  end

  def shift
    todos.shift
  end

  def pop
    todos.pop
  end

  def remove_at(index)
    todos.delete_at(index)
  end

  def each
    todos.each do |todo|
      yield todo if block_given?
    end

    self
  end

  def select
    temp = TodoList.new(title)

    each do |todo|
      temp.add(todo) if yield todo
    end
    temp
  end

  def find_by_title(str)
    todos.detect do |todo|
      todo.title.downcase == str.downcase
    end
  end

  def all_dones
    select(&:done?)
  end

  def all_not_dones
    select do |todo|
      !todo.done?
    end
  end

  def mark_done(item)
    find_by_title(item).done!
  end

  def mark_all_done
    each(&:done!)
  end

  def mark_all_not_done
    each(&:not_done!)
  end

  def all_with_due_dates
    select(&:due_date)
  end

  def all_overdues
    all_with_due_dates.select(&:overdue?)
  end

  private

  attr_accessor :todos
end

if $PROGRAM_NAME == __FILE__
  todo1 = Todo.new('Buy milk')
  todo2 = Todo.new('Clean room')
  todo3 = Todo.new('Go to gym')

  list = TodoList.new("Today's Todos")
  list.add(todo1)
  list.add(todo2)
  list.add(todo3)

  todo1.due_date = Date.today - 1
  todo3.due_date = Date.today - 1
  puts list.all_overdues
end
