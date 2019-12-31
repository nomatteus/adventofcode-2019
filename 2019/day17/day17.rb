require 'pry'
require 'matrix'
require 'set'
require_relative '../day13/intcode_day13'

input = IO.read('input')
program = Intcode::Helpers.parse_program(input)

class ScaffoldGrid
  SCAFFOLD = '#'
  OPEN_SPACE = '.'

  # Find the robot
  ROBOT_CHARS = {
    up: '^',
    left: '<',
    down: 'v',
    right: '>',
    in_space: 'X',
  }

  DIRECTION_VECTORS = {
    north: Vector[0, 1],
    south: Vector[0, -1],
    east: Vector[1, 0],
    west: Vector[-1, 0],
  }

  X = 0
  Y = 1

  def initialize(program:, debug: false)
    @computer = Intcode::Computer.new(program: program, debug: debug)

    @positions = {}
  end

  def read_grid
    # Top left is 0,0
    pos = Vector[0, 0]
    @top_left = pos
    while !@computer.terminated?
      result = @computer.run
      case result&.chr
      when "\n"
        # Move position to next row
        pos = Vector[0, pos[Y] + 1]
      when nil
        # noop
      else
        # current_line << result.chr
        @positions[pos] = result.chr
        pos += Vector[1, 0] # x += 1
      end
    end
    # Find bottom right so we can know grid size
    @bottom_right = @positions.keys.max_by { |pos| pos[X] * 1000 + pos[Y] }
    @minx, @miny = @top_left.to_a
    @maxx, @maxy = @bottom_right.to_a
    @positions
  end

  def find_intersections
    input = read_grid
    @positions
      .select{ |pos| @positions[pos] == SCAFFOLD }
      .select do |pos|
        DIRECTION_VECTORS.values.all? do |dir_vec|
          neighbour_pos = pos + dir_vec
          @positions[neighbour_pos] == SCAFFOLD
        end
      end
  end

  def part1
    intersections = find_intersections
    # Apply formula given by question to calculate the answer
    intersections.keys.map { |pos| pos[X] * pos[Y]  }.sum
  end

  def to_s
    intersections = find_intersections
    @miny.upto(@maxy).map do |y|
      @minx.upto(@maxx).map do |x|
        pos = Vector[x, y]
        char = @positions[pos]
        # Display intersections for debugging...
        intersections.has_key?(pos) ? 'O' : char
      end.join
    end.join("\n")
  end
end


scaffold_grid = ScaffoldGrid.new(program: program)
result = scaffold_grid.part1
puts scaffold_grid
puts "Part 1: #{result}" # 6672
