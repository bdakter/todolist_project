#! /usr/bin/env ruby

# Uncomment to see coverage report
# require 'simplecov'
# SimpleCov.start

require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use!
require 'date'

require_relative '../lib/todo_list'

class TodoListTest < MiniTest::Test
  def setup
    @todo1 = Todo.new("Buy milk")
    @todo2 = Todo.new("Clean room")
    @todo3 = Todo.new("Go to gym")
    @todos = [@todo1, @todo2, @todo3]

    @list = TodoList.new("Today's Todos")
    @list.add(@todo1)
    @list.add(@todo2)
    @list.add(@todo3)
  end

  def test_no_due_date
    assert_nil(@todo1.due_date)
  end

  def test_due_date
    due_date = Date.today + 3
    @todo2.due_date = due_date
    assert_equal(due_date, @todo2.due_date)
  end

  def test_to_a
    assert_equal(@todos, @list.to_a)
  end

  def test_size
    assert_equal(3, @list.size)
  end

  def test_first
    assert_equal(@todo1, @list.first)
  end

  def test_last
    assert_equal(@todo3, @list.last)
  end

  def test_shift_returns_first_todo
    assert_equal(@todo1, @list.shift)
  end

  def test_shift_modifies_array
    @list.shift
    assert_equal(2, @list.size)
  end

  def test_pop_returns_last_todo
    last = @list.pop
    assert_equal(@todo3, last)
    assert_equal([@todo1, @todo2], @list.to_a)
  end

  def test_done_question_returns_true_when_all_todos_done
    @list.done!
    assert(@list.done?)
  end

  def test_non_todo_obj_raises_error
    assert_raises(TypeError) { @list.add(1) }
    assert_raises(TypeError) { @list.add('a') }
    assert_raises(TypeError) { @list.add([]) }
  end

  def test_add_method_adds_todo
    @list.add(Todo.new('test'))
    assert_equal(4, @list.size)
  end

  def test_shovel_adds
    @list << Todo.new('test')
    assert_equal(4, @list.size)
  end

  def test_item_at_retrieves_correctly
    assert_equal(@todo1, @list.item_at(0))
    assert_equal(@todo3, @list.item_at(2))
  end

  def test_item_at_raises_index_error
    assert_raises(IndexError) {@list.item_at(100)}
  end

  def test_mark_done_at
    assert_raises(IndexError) {@list.item_at(100)}
    @list.mark_done_at(0)
    assert_equal(true, @todo1.done?)
    assert_equal(false, @todo2.done?)
    assert_equal(false, @todo3.done?)
  end

  def test_mark_undone_at
    assert_raises(IndexError) { @list.mark_undone_at(100) }
    @list.done!
    @list.mark_undone_at(1)
    assert_equal(true, @todo1.done?)
    assert_equal(false, @todo2.done?)
    assert_equal(true, @todo3.done?)
  end

  def test_done_bang_marks_all_done
    @list.done!
    assert(@todo1.done?)
    assert(@todo2.done?)
    assert(@todo3.done?)
    assert(@list.done?)
  end

  def test_remove_at
    assert_nil(@list.remove_at(100))
    assert_equal(@todo2, @list.remove_at(1))
    assert_equal([@todo1, @todo3], @list.to_a)
  end

  def test_to_s_not_done
    output = <<~HEREDOC.chomp

      ------ Today's Todos ------
      [ ] Buy milk
      [ ] Clean room
      [ ] Go to gym
    HEREDOC
    assert_equal(output, @list.to_s)
  end

  def test_to_s_one_done
    output = <<~HEREDOC.chomp

      ------ Today's Todos ------
      [ ] Buy milk
      [X] Clean room
      [ ] Go to gym
    HEREDOC

    @todo2.done!
    assert_equal(output, @list.to_s)
  end

  def test_to_s_all_done
    output = <<~HEREDOC.chomp

      ------ Today's Todos ------
      [X] Buy milk
      [X] Clean room
      [X] Go to gym
    HEREDOC

    @list.done!
    assert_equal(output, @list.to_s)
  end

  def test_to_s_with_due_date
    @todo2.due_date = Date.new(2020, 5, 15)

    output = <<~HEREDOC.chomp

      ------ Today's Todos ------
      [ ] Buy milk
      [ ] Clean room (Due: Friday May 15)
      [ ] Go to gym
    HEREDOC

    assert_equal(output, @list.to_s)
  end

  def test_each_iterates
    results = []
    @list.each { |todo| results << todo }
    assert_equal(results, @list.to_a)
  end

  def test_each_returns_original_obj
    assert_same(@list, @list.each { |todo| nil })
  end

  def test_select
    refute_same(@list, @list.select {|todo| nil })

    result = @list.select { |todo| todo.title == 'Buy milk' }
    assert_equal(@todo1, result.to_a.first)
  end

  def test_find_by_title
    result = @list.find_by_title('Go to gym')
    assert_equal(@todo3, result)
  end

  def test_all_dones
    @todo1.done!
    @todo3.done!
    assert_equal([@todo1, @todo3], @list.all_dones.to_a)
  end

  def test_all_not_dones
    @list.done!
    @todo1.not_done!
    @todo3.not_done!

    assert_equal([@todo1, @todo3], @list.all_not_dones.to_a)
  end

  def test_mark_done
    @list.mark_done('Clean room')
    assert_equal(true, @todo2.done?)
  end

  def test_mark_all_done
    @list.mark_all_done
    assert(@list.done?)
  end

  def test_mark_all_not_done
    @list.mark_all_not_done
    assert_equal([], @list.all_dones.to_a)
  end

  def test_all_overdues
    @todo1.due_date = Date.today - 1
    @todo2.due_date = Date.today + 1
    @todo3.due_date = Date.today - 1

    assert_equal([@todo1, @todo3], @list.all_overdues.to_a)
  end
end
